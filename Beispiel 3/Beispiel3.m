% Code Umgebung vorbereiten
close all;                          % Schließt alle Fenster
clear;                              % Leert Workspace
clc                                 % Leert Command Window

% Einlesen der Daten
load('.\Angabe\Spotpreis.mat');             % Stundenpreise in Cent/kWh für die Jahre 2008-2016 
load('.\Angabe\Load_PVProduction.mat');     % Enthält Last.mat und PV_profil.mat
                                            % Last.mat ist ein Lastprofil
                                            % und PV_Prpfil ein
                                            % Einspeiseprofil
                                            % Jeweils in Stundenwerten
load('.\Angabe\PV_Einspeiseprofil.mat');    % Enthält Leistung_Vec_Temperatur_Temp mit 15min Werte
load('.\Angabe\LeistungHaushalte.mat');     % 15min Werte

% Parameter
% Parameter zur Aufgabe 3.1

Anlagenleistung = 10;               % Anlagenleistung in kWp
Zinssatz = 0.04;                    % Zinssatz: 4%
Systemkosten = 1200;                % Systemkosten in €/kWp
Betriebskosten = 4;                 % Betriebskosten in €/kWp
Lebensdauer = 25;                   % Lebensdauer in Jahren
Einspeisetarif = 0.0824;            % Einspeisetarif in €/kWh (https://www.oem-ag.at/fileadmin/user_upload/Dokumente/gesetze/2015_12_23_OESET-VO_2016.pdf)
Foerderdauer = 13;                  % Förderdauer durch OeMAG in Jahren

% Ergänzungen aus BGBl II Nr. 459/2015, Paragraph 5, Absatz 1
Investitionszuschuss_prozent = 0.4; % Zuschuss in Prozent der Errichtungskosten (maximal allerdings Investitionszuschuss_max)
Investitionszuschuss_max = 375;     % Maximaler Zuschuss in Euro (pro kWp)

% Parameter zur Aufgabe 3.2
Anlagenleistung_5_2 = 5;            % Anlagenleistung in kWp
Anlagenleistung_Max = 20;           % Maximale Anlagenleistung in kWp mit der gerechnet werden soll

% Parameter zur Aufgabe 3.3
Haushaltsstrompreis = 0.15;        % Haushaltsstrompreis in €/kWh
Einspeisetarif_5_3 = 0.05;         % Einspeisetarif in €/kWh

%% Aufgabe 3.1
% 3.1a
NPV = - Systemkosten*Anlagenleistung;    % NPV im Jahr null entspricht den negativen Investitionskosten

figure_1 = figure('Name', 'Aufgabe 3.1 - Verkauf der gesamten Produktion', 'NumberTitle', 'off');
subplot(2,1,1)
hold on
bar(0, NPV);

Investitionszuschuss = min(Systemkosten*Anlagenleistung*Investitionszuschuss_prozent, Investitionszuschuss_max*Anlagenleistung);

for i = 1:25
    if i <= 9
        Preis_i = table2array(Spotpreis(:,i))./100;  % Euro/kWh bis zum Jahr 2016
    else
        Preis_i = table2array(Spotpreis(:,9))./100;  % Euro/kWh ab dem Jahr 2016
    end
    CF = sum(PV_profil.*Anlagenleistung.*Preis_i) + Investitionszuschuss - Betriebskosten*Anlagenleistung;  %Cashflow im Jahr i
    
    NPV = NPV + CF/(1+Zinssatz)^i; % Barwert bis zum Jahr i
    
    bar(i, NPV);
end
hold off

xlabel('Lebensdauer in Jahren');
ylabel('Barwert in Euro');
title('Barwert bei Verkauf am Spotmarkt');

Max_Invest_Gesamtverkauf = NPV + Anlagenleistung*Systemkosten;    % Maximale Investitionskosten für Wirtschaftlichkeit

%3.1b

NPV = - Systemkosten*Anlagenleistung;    % NPV im Jahr null entspricht den negativen Investitionskosten

subplot(2,1,2)
hold on
bar(0, NPV);    % Barchart für Jahr 0 (Also nur Investitionskosten)

for i = 1:25
    if i <= Foerderdauer
        Preis_i = Einspeisetarif;  % Euro/kWh bis zum Förderende
    else
        Preis_i = table2array(Spotpreis(:,9))./100;  % Euro/kWh ab dem Förderende
    end
    CF = sum(PV_profil.*Anlagenleistung.*Preis_i) + Investitionszuschuss - Betriebskosten*Anlagenleistung;  % Cashflow im Jahr i
    
    NPV = NPV + CF/(1+Zinssatz)^i; % Barwert bis zum Jahr i
    
    bar(i, NPV);    % Barchart für Jahr i
end
hold off

xlabel('Lebensdauer in Jahren');
ylabel('Barwert in Euro');
title('Barwert bei Förderung für 13 Jahre');

%% Aufgabe 3.2
% Aufgabe 3.2.a

PV_Einspeiseenergie_a = Leistung_Vec_Temperatur_Temp.*5.*0.25.*1000; % Energie einer 5kWp Anlage in 15min-Intervallen in Wh/4

EigenverbrauchHaushalt_a = zeros(35040, 5);
EigenverbrauchHaushaltGesamt_a = zeros(1,5);
UeberschussHaushalt_a = zeros(1,5);

PV_EinspeiseenergieGesamt_a = sum(PV_Einspeiseenergie_a);   % Jahresgesamteinspeiseenergie

for i=1:5
    for j=1:size(LeistungHaushalte)
        if PV_Einspeiseenergie_a(j) < LeistungHaushalte(j,i)        % Es ist immer das jeweils niedrigere der Eigenverbrauch
            EigenverbrauchHaushalt_a(j,i) = PV_Einspeiseenergie_a(j);
        else
            EigenverbrauchHaushalt_a(j,i) = LeistungHaushalte(j,i);
        end
    end
    EigenverbrauchHaushaltGesamt_a(i) = sum(EigenverbrauchHaushalt_a(:,i)); % Feld mit Jahreseigenverbrauch
    UeberschussHaushalt_a(i) = PV_EinspeiseenergieGesamt_a - EigenverbrauchHaushaltGesamt_a(i); % Feld mit Überschussenergien
end

% Aufgabe 3.2.b

EigenverbrauchHaushalt_b = zeros(1, 35040);
EigenverbrauchHaushaltGesamt_b = zeros(20, 5);
StromverbrauchHaushalt_b = zeros(1, 5);

for i=1:5
    for j=1:Anlagenleistung_Max
        PV_Einspeiseenergie_b = Leistung_Vec_Temperatur_Temp.*j.*0.25.*1000; %Wh
        
        for k=1:size(LeistungHaushalte)
            if PV_Einspeiseenergie_b(k) < LeistungHaushalte(k,i)        % Es ist immer das jeweils niedrigere der Eigenverbrauch
                EigenverbrauchHaushalt_b(k) = PV_Einspeiseenergie_b(k);
            else
                EigenverbrauchHaushalt_b(k) = LeistungHaushalte(k,i);
            end
        end
        
        EigenverbrauchHaushaltGesamt_b(j,i) = sum(EigenverbrauchHaushalt_b); % Matrix mit Gesamteigeverbrauch abhängig von Größe und Haushalt
        Gesamterzeugung_b = sum(PV_Einspeiseenergie_b);
        StromverbrauchHaushalt_b(i) = sum(LeistungHaushalte(:,i));
    end  
end

figure_2 = figure('Name', 'Aufgabe 3.2.b - Eigenverbrauchsanteil und Deckungsgrad', 'NumberTitle', 'off', 'units' , 'normalized', 'outerposition' , [0 0 1 1]);

hold on

for i=1:5
    subplot(2,5,i)
    bar(EigenverbrauchHaushaltGesamt_b(:, i)/Gesamterzeugung_b);
    xlabel('Anlagengröße in kWp');
    ylabel('Eigenverbrauchsanteil');
    title(['Haushalt ',num2str(i)]);
    axis([-inf inf 0 0.2]);
    
    subplot(2,5,i+5)
    bar(EigenverbrauchHaushaltGesamt_b(:, i)/StromverbrauchHaushalt_b(i));
    xlabel('Anlagengröße in kWp');
    ylabel('Deckungsgrad');
    title(['Haushalt ',num2str(i)]);
    axis([-inf inf 0 0.5]);
end

hold off

% Aufgabe 3.2.c

figure_3 = figure('Name', '3.2.c - Erzeugung, Last und Eigenverbrauch');
subplot(1,2,1);
Woche_3(:,1) = EigenverbrauchHaushalt_a(1345:2017, 1);
Woche_3(:,2) = LeistungHaushalte(1345:2017, 1);
Woche_3(:,3) = PV_Einspeiseenergie_a(1345:2017);

area(1345:2017, Woche_3);
legend('Eigenverbrauch', 'Stromverbrauch', 'Einspeiseenergie');
xlabel('Zeit in Viertelstunden');
axis([1345 2017 -inf inf]);
title('Woche 3');

subplot(1,2,2);
Woche_25(:,1) = EigenverbrauchHaushalt_a(16129:16801, 1);
Woche_25(:,2) = LeistungHaushalte(16129:16801, 1);
Woche_25(:,3) = PV_Einspeiseenergie_a(16129:16801);

area(16129:16801, Woche_25);
legend('Eigenverbrauch', 'Stromverbrauch', 'Einspeiseenergie');
xlabel('Zeit in Viertelstunden');
axis([16129 16801 -inf inf]);
title('Woche 25');

%close all

%% Aufgabe 3.3
% Aufgabe 3.3.a

Max_Invest_Vergleich = zeros(1,5);
NPV_mitPV = zeros(1,5);
NPV_ohnePV = zeros(1,5);

Investitionszuschuss = min(Systemkosten*Anlagenleistung*Investitionszuschuss_prozent, Investitionszuschuss_max*Anlagenleistung_5_2);

for i = 1:5
    NPV_mitPV(i) = - Systemkosten*Anlagenleistung_5_2;    % NPV im Jahr null entspricht den negativen Investitionskosten
    NPV_ohnePV(i) = 0;  % Ohne PV keine Investitionskosten
    
    for j = 1:25
        
        CF_mitPV = EigenverbrauchHaushaltGesamt_a(i)*Haushaltsstrompreis/100 + UeberschussHaushalt_a(i)*Einspeisetarif_5_3/100 + Investitionszuschuss - (StromverbrauchHaushalt_b(i) - EigenverbrauchHaushaltGesamt_a(i))*Haushaltsstrompreis/100 - Betriebskosten*Anlagenleistung;  %Cashflow im Jahr i, Mutltiplikation mit Anlagenleistung
        NPV_mitPV(i) = NPV_mitPV(i) + CF_mitPV/(1+Zinssatz)^j; % Barwert bis zum Jahr j
        
        CF_ohnePV = - StromverbrauchHaushalt_b(i)*Haushaltsstrompreis/100;  % Ausgaben haben negatives Vorzeichen
        NPV_ohnePV(i) = NPV_ohnePV(i) + CF_ohnePV/(1+Zinssatz)^j; % Barwert bis zum Jahr j
    end
    
    %Aufgabe 3.3.b
    Max_Invest_Vergleich(i) = ((NPV_mitPV(i) + Systemkosten*Anlagenleistung_5_2) - NPV_ohnePV(i))/Anlagenleistung_5_2;    % Maximale spezifische Investitionskosten für Wirtschaftlichkeit
end

%% Aufgabe 3.4.

% Diese Übung hat ergeben, dass der Barwert einer PV-Anlage im Schnitt nach einer Verwendung von nur fünf Jahren positiv wird.
% Über die gesamte Laufzeit gerechnet ergeben sich durch die Ersparnise bzw. den Verkauf der Überschussleistung beträchtilche Summen.
% Aus rein elektrischer Sicht ist die Verwendung von PV-Anlagen daher als durchaus wirtschaftlich einzustufen.
% 
% Die Förderung von PV-Anlagen ist weiterhin zeitgemäß, weil dadurch auch im privaten Bereich Anreize geschaffen werden.
% Dies ist notwendig um dem stetig wachsenden Stromverbrauch Herr zu werden.





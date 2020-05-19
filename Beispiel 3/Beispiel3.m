% Code Umgebung vorbereiten
close all;                          % Schließt alle Fenster
clear;                              % Leert Workspace
clc                                 % Leert Command Window

% Einlesen der Daten
load('.\Angabe\Spotpreis.mat');
load('.\Angabe\PV_Einspeiseprofil.mat');
load('.\Angabe\Load_PVProduction.mat');
load('.\Angabe\LeistungHaushalte.mat');

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
NPV = - Systemkosten*Anlagenleistung;    %NPV im Jahr null entspricht den negativen Investitionskosten

%figure_1 = figure('Name', '3.1a', 'NumberTitle', 'off');
subplot(2,1,1)
bar(0, NPV);

for i = 1:25
    if i <= 9
        Preis_i = table2array(Spotpreis(:,i))./100;  %Euro/kWh bis zum Jahr 2016
    else
        Preis_i = table2array(Spotpreis(:,9))./100;  %Euro/kWh ab dem Jahr 2016
    end
    PV_Energie = PV_profil.*4;  %Energie in einer Viertelstunge
    CF = sum(PV_Energie.*Spotpreis_i) - Betriebskosten*Anlagenleistung;  %Cashflow im Jahr i
    NPV = NPV + CF/(1+Zinssatz)^i; %Barwert bis zum Jahr i
    
    hold on
    bar(i, NPV);
    hold off
end

xlabel('Lebensdauer in Jahren');
ylabel('Barwert in Euro');
axis([-1 26 -inf inf]);
title('3.1a');

Max_Invest = NPV + Anlagenleistung*Systemkosten;    %Maximale Investitionskosten für Wirtschaftlichkeit

%3.1b

subplot(2,1,2)
NPV = - Systemkosten*Anlagenleistung;    %NPV im Jahr null entspricht den negativen Investitionskosten

%figure_2 = figure('Name', '3.1a', 'NumberTitle', 'off');
bar(0, NPV);

for i = 1:25
    if i <= Foerderdauer
        Preis_i = Einspeisetarif;  %Euro/kWh bis zum Förderende
    else
        Preis_i = table2array(Spotpreis(:,9))./100;  %Euro/kWh ab dem Förderende
    end
    PV_Energie = PV_profil.*4;  %Energie in einer Viertelstunge
    CF = sum(PV_Energie.*Preis_i) - Betriebskosten*Anlagenleistung;  %Cashflow im Jahr i
    NPV = NPV + CF/(1+Zinssatz)^i; %Barwert bis zum Jahr i
    
    hold on
    bar(i, NPV);
    hold off
end

xlabel('Lebensdauer in Jahren');
ylabel('Barwert in Euro');
axis([-1 26 -inf inf]);
title('3.1b');



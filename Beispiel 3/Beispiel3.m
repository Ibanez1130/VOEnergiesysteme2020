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

for i = 1:25
    if i <= 9
        Preis_i = table2array(Spotpreis(:,i))./100;  % Euro/kWh bis zum Jahr 2016
    else
        Preis_i = table2array(Spotpreis(:,9))./100;  % Euro/kWh ab dem Jahr 2016
    end
    CF = sum(PV_profil.*10.*Preis_i) - Betriebskosten*Anlagenleistung;  %Cashflow im Jahr i
                                                                        % Multiplikation
                                                                        % mit
                                                                        % 10kWp
    NPV = NPV + CF/(1+Zinssatz)^i; % Barwert bis zum Jahr i
    
    bar(i, NPV);
end
hold off

xlabel('Lebensdauer in Jahren');
ylabel('Barwert in Euro');
title('Barwert bei Verkauf am Spotmarkt');

Max_Invest = NPV + Anlagenleistung*Systemkosten    % Maximale Investitionskosten für Wirtschaftlichkeit

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
    CF = sum(PV_profil.*10.*Preis_i) - Betriebskosten*Anlagenleistung;  % Cashflow im Jahr i
                                                                        % Multiplikation
                                                                        % mit
                                                                        % 10kWp
    NPV = NPV + CF/(1+Zinssatz)^i; % Barwert bis zum Jahr i
    
    bar(i, NPV);    % Barchart für Jahr i
end
hold off

xlabel('Lebensdauer in Jahren');
ylabel('Barwert in Euro');
title('Barwert bei Förderung für 13 Jahre');

%% Aufgabe 3.2

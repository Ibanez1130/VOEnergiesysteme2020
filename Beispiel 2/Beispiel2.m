% Code Umgebung vorbereiten
close all;                          % Schließt alle Fenster
clear;                              % Leert Workspace
clc                                 % Leert Command Window

% Einlesen der Daten
load ('./Angabe/Strahlung.mat');
load ('./Angabe/time.mat');
load ('./Angabe/Temperatur.mat');
addpath(genpath('Angabe')); % Hinzufügen des Angabe Ordners zum aktuellen Pfad, damit wir die Funktionen darin ausführen können.

% Ausgabe der Tabellen-Header von Strahlung.mat
Strahlung.Properties.VariableNames; % Remove the semicolon to show the table headers.

% Definieren der Eingabeparameter
pvAzimut = 270; % Azimutwinkel der PV-Anlage
pvHoehenwinkel = 20; % Höhenwinkel der PV-Anlage
pvGroesse = 1; % Größe der PV-Anlage (kWp)
sLaengengrad = 16.3; % Längengrad von Wien
sBreitengrad = 48.2; % Breitengrad von Wien
pvWirkungsgrad = 0.17; % Modulwirkungsgrad
pvVerluste = 0.8; % Sonstige Verluste (Reflexion, Temperatur, Wechselrichter, etc.)
albedo = 0.2; % lt. Blabensteiner2011 - bei unbekannter Umgebung
gSTC = 1000; % Strahlung laut Standard Test Condition - in W/m^2
TmodSTC = 25; % Temperaturänderung der PV-Anlage laut Standard Test Conditions.
ct = 0.026; % Beschreibt wie stark die PV-Anlage durch die Strahlung erhitzt wird.

%% Berechnung des Sonnenazimutal- und Höhenwinkels mittels der zur Verfügung gestellten Funktion SonnenstandTST
[sAzimut,sHoehenwinkel] = SonnenstandTST(sLaengengrad,sBreitengrad,time);

%% Berechnung der gesamten Strahlungsenergie auf eine geneigte Fläche (1.1b)
% Moduleinfallswinkel bei einer Südausrichtung von 180°
pvModuleinfallswinkel = acosd(-cosd(sHoehenwinkel).*sind(pvHoehenwinkel).*cosd(sAzimut - pvAzimut - 180)+sind(sHoehenwinkel).*cosd(pvHoehenwinkel));

%% Funktion: Eges = Jahreserzeugung(...) aufrufen. Funktion muss zuvor erstellt werden.
[Eges,EgesT] = Jahreserzeugung(pvHoehenwinkel, pvGroesse, pvWirkungsgrad, pvVerluste, pvModuleinfallswinkel, sHoehenwinkel, Strahlung, gSTC, TmodSTC, ct, Temperatur);
EgesT(isnan(EgesT))=0;

% Plot der Differenz zwischen Eges (ideal) und EgesT (Berücksichtigung der
% Temperatur)
% plot(abs(Eges-EgesT))
% Aufsummieren der jeweiligen Monats-Summen
Emon = zeros(1,12);
EmonT = zeros(1,12);
for monat=1:12
    Emon(monat) = sum(Eges(time.Monat == monat));
    EmonT(monat) = sum(EgesT(time.Monat == monat));
end
figure('Name', 'Monatliche Erträge (2.1.b)', 'NumberTitle', 'Off')
bar(1:12,[Emon;EmonT]);
legend('ideal','temperaturabhängig')
xlabel("Monat")
ylabel("Ertrag in Wh/Monat")

% Berechnen der Stündlichen Werte - Aufsummieren von jeweils 4
% Viertelstundenwerten.
Estunden = sum(reshape(Eges,4,8760));
EstundenT = sum(reshape(EgesT,4,8760));
% Errechnen der Durchschnittswerte pro Stunde, für alle Tage des Jahres
Etagmean = mean(reshape(Estunden,24,365));
EtagmeanT = mean(reshape(EstundenT,24,365));

figure('Name', 'Durchschnittliche stündliche Werte (2.1.b)', 'NumberTitle', 'Off')
bar(1:365,[Etagmean;EtagmeanT]);
legend('ideal','temperaturabhängig')
xlabel("Tag")
ylabel("Ertrag in Wh/Tag")
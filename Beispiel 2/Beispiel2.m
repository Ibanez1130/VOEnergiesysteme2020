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

%% Aufgabe 2.1.b
%{
[Eges,EgesT] = Jahreserzeugung(pvHoehenwinkel, pvGroesse, pvWirkungsgrad, pvVerluste, pvModuleinfallswinkel, sHoehenwinkel, Strahlung, gSTC, TmodSTC, ct, Temperatur);
% Eliminieren aller NaN Werte, die beim Arbeiten mit dem Logarithmus
% entstehen.
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
%}
%% Aufgabe 2.2.a & 2.2.b
pvHoehenwinkelNeu = 0:2.5:90;
pvAzimutNeu = 0:10:360;

combinations = zeros(37);
combinationsJuni = zeros(37);
combinationsDezember = zeros(37);

for h=1:length(pvHoehenwinkelNeu)
    for a=1:length(pvAzimutNeu)
        pvModuleinfallswinkelNeu = acosd(-cosd(sHoehenwinkel).*sind(pvHoehenwinkelNeu(h)).*cosd(sAzimut - pvAzimutNeu(a) - 180)+sind(sHoehenwinkel).*cosd(pvHoehenwinkelNeu(h)));
        [Eges3,Eges3T] = Jahreserzeugung(pvHoehenwinkelNeu(h), pvGroesse, pvWirkungsgrad, pvVerluste, pvModuleinfallswinkelNeu, sHoehenwinkel, Strahlung, gSTC, TmodSTC, ct, Temperatur);
        combinations(h,a) = sum(Eges3)/(pvGroesse.*1000);
        combinationsJuni(h,a) = sum(Eges3(time.Monat == 6))/(pvGroesse.*1000);
        combinationsDezember(h,a) = sum(Eges3(time.Monat == 12))/(pvGroesse.*1000);
    end
end

maxValue = max(combinations(:));
[rowsOfMaxes,colsOfMaxes] = find(combinations == maxValue);

figure('Name', 'Volllast-Stunden abhängig von Azimut- und Neigungswinkel (2.2.b)', 'NumberTitle', 'Off')
meshc(pvAzimutNeu,pvHoehenwinkelNeu,combinations)
hold on
plot3(pvAzimutNeu(colsOfMaxes),pvHoehenwinkelNeu(rowsOfMaxes),maxValue,'r*')
xlabel('PV Azimut [°]')
ylabel('PV Neigungswinkel [°]')
zlabel('Volllast-Stunden [h/a]')

figure('Name', 'Volllast-Stunden abhängig von Azimut- und Neigungswinkel (2.2.b)', 'NumberTitle', 'Off')
contour(pvAzimutNeu,pvHoehenwinkelNeu,combinations)
hold on
plot(pvAzimutNeu(colsOfMaxes),pvHoehenwinkelNeu(rowsOfMaxes),'r*')
xlabel('PV Azimut [°]')
ylabel('PV Neigungswinkel [°]')

%% Aufgabe 2.2.c
% Juni
maxValueJuni = max(combinationsJuni(:));
[rowsOfMaxesJuni,colsOfMaxesJuni] = find(combinationsJuni == maxValueJuni);

figure('Name', 'Volllast-Stunden abhängig von Azimut- und Neigungswinkel Juni (2.2.c)', 'NumberTitle', 'Off')
meshc(pvAzimutNeu,pvHoehenwinkelNeu,combinationsJuni)
hold on
plot3(pvAzimutNeu(colsOfMaxesJuni),pvHoehenwinkelNeu(rowsOfMaxesJuni),maxValueJuni,'r*')
xlabel('PV Azimut [°]')
ylabel('PV Neigungswinkel [°]')
zlabel('Volllast-Stunden [h/a]')

figure('Name', 'Volllast-Stunden abhängig von Azimut- und Neigungswinkel Juni (2.2.c)', 'NumberTitle', 'Off')
contour(pvAzimutNeu,pvHoehenwinkelNeu,combinationsJuni)
hold on
plot(pvAzimutNeu(colsOfMaxesJuni),pvHoehenwinkelNeu(rowsOfMaxesJuni),'r*')
xlabel('PV Azimut [°]')
ylabel('PV Neigungswinkel [°]')

% Dezember
maxValueDezember = max(combinationsDezember(:));
[rowsOfMaxesDezember,colsOfMaxesDezember] = find(combinationsDezember == maxValueDezember);

figure('Name', 'Volllast-Stunden abhängig von Azimut- und Neigungswinkel Dezember (2.2.c)', 'NumberTitle', 'Off')
meshc(pvAzimutNeu,pvHoehenwinkelNeu,combinationsDezember)
hold on
plot3(pvAzimutNeu(colsOfMaxesDezember),pvHoehenwinkelNeu(rowsOfMaxesDezember),maxValueDezember,'r*')
xlabel('PV Azimut [°]')
ylabel('PV Neigungswinkel [°]')
zlabel('Volllast-Stunden [h/a]')

figure('Name', 'Volllast-Stunden abhängig von Azimut- und Neigungswinkel Dezember (2.2.c)', 'NumberTitle', 'Off')
contour(pvAzimutNeu,pvHoehenwinkelNeu,combinationsDezember)
hold on
plot(pvAzimutNeu(colsOfMaxesDezember),pvHoehenwinkelNeu(rowsOfMaxesDezember),'r*')
xlabel('PV Azimut [°]')
ylabel('PV Neigungswinkel [°]')

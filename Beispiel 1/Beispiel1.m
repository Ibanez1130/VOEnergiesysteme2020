% Code Umgebung vorbereiten
close all;                          % Schließt alle Fenster
clear;                              % Leert Workspace
clc                                 % Leert Command Window

% Einlesen der Daten
load ('./Angabe/Strahlung.mat');
load ('./Angabe/time.mat');
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

%% Berechnung des Sonnenazimutal- und Höhenwinkels mittels der zur Verfügung gestellten Funktion SonnenstandTST
[sAzimut,sHoehenwinkel] = SonnenstandTST(sLaengengrad,sBreitengrad,time);

%% Berechnung der gesamten Strahlungsenergie auf eine geneigte Fläche (1.1b)
% Moduleinfallswinkel bei einer Südausrichtung von 180°
pvModuleinfallswinkel = acosd(-cosd(sHoehenwinkel).*sind(pvHoehenwinkel).*cosd(sAzimut - pvAzimut - 180)+sind(sHoehenwinkel).*cosd(pvHoehenwinkel));


%% Funktion: Eges = Jahreserzeugung(...) aufrufen. Funktion muss zuvor erstellt werden.
Eges = Jahreserzeugung(pvHoehenwinkel, pvGroesse, pvWirkungsgrad, pvVerluste, pvModuleinfallswinkel, sHoehenwinkel, Strahlung);

%Berechnung der Vollaststunden
T = sum(Eges)/(pvGroesse.*1000);

%% Darstellung mittels plot(Eges)
figure('Name', 'Gesamtertrag (1.1.b)', 'NumberTitle', 'Off')
plot(Eges)
xlabel("Zeit in Vierteltunden")
ylabel("Gesamtertrag in Wh/15min")
axis([0 35040 0 inf])

%% Aufgabe 1.2.a
figure('Name', 'Leistungsdauerlinie (1.2.a)', 'NumberTitle', 'Off')
Psorted = sort(Eges, 'descend').*15;
plot(Psorted)
xlabel("Zeit in Viertelstunden")
ylabel("Leistung in W")
axis([0 35040 0 inf])

%% Aufgabe 1.2.b und 1.2.c

%Aufgabe 1.2.b
Emon = zeros(1,12);
for monat=1:12
    Emon(monat) = sum(Eges(time.Monat == monat));
end   
figure('Name', 'Monatliche Erträge (1.2.b)', 'NumberTitle', 'Off')
bar(Emon)
xlabel("Monat")
ylabel("Ertrag in Wh/Monat")
close all

% Aufgabe 1.2.c
Etag = zeros(1,365);
for tag=1:365
    Etag(tag) = sum(Eges(time.Tag == tag));
end
% 5 Tage mit der maximalen PV-Erzeugung:
[maxPV,I] = maxk(Etag,5);
maxDates = I+datetime(Strahlung.Year(1),1,0);

% 5 Tage mit der minimalen PV-Erzeugung:
[minPV,J] = mink(Etag,5);
minDates = J+datetime(Strahlung.Year(1),1,0);

%% Diagramm f�r Strahlungsanteile: plotStrahlungsanteile(...)
plotStrahlungsanteile(pvAzimut, pvHoehenwinkel, sLaengengrad, sBreitengrad, Strahlung, time)

%% Aufgabe 1.2.e
% Juni
% Die Daten aus Eges auf den Monat Juni beschränken
Ejuni = Eges(time.Monat == 6);
% Zusammenfassen der Viertelstunden-Werte zu jeweils einem Stundenwert.
% "Jeder Stundenwert besteht aus der Summe von vier Viertelstundenwerten."
EJuniStunden = sum(reshape(Ejuni,4,720));
% Umformen der 1x720 Matrix in eine 24 x 30 Matrix.
EJuniTage = reshape(EJuniStunden,24,30);

boxplot(EJuniTage)
xlabel('Tage (Juni 2005)')
ylabel('Ertrag in Watt')
title('Ertrag pro Stunde - Juni')

% Dezember
% Die Schritte für Dezember sind die selben wie für Juni.
% Ein Unterschied ist, dass Dezember 31 Tage hat und daher die Anzahl der
% Stunden und Tage unterschiedlich sind.
Edezember = Eges(time.Monat == 12);
EDezemberStunden = sum(reshape(Edezember,4,744));
EDezemberTage = reshape(EDezemberStunden,24,31);

boxplot(EJuniTage)
xlabel('Tage (Dezember 2005)')
ylabel('Ertrag in Watt')
title('Ertrag pro Stunde - Dezember')

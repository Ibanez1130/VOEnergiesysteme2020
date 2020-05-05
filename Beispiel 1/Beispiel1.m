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

%% Berechnung des Ertrags einer horizontalen PV-Anlage
gHoriz = Strahlung.DirectHoriz + Strahlung.DiffusHoriz;

eHoriz = gHoriz .* pvGroesse .* pvWirkungsgrad .* pvVerluste

%% Berechnung der gesamten Strahlungsenergie auf eine geneigte Fläche (1.1b)
% Moduleinfallswinkel bei einer Südausrichtung von 180°
pvModuleinfallswinkel = acosd(-cosd(sHoehenwinkel).*sind(pvHoehenwinkel).*cosd(sAzimut - pvAzimut - 180)+sind(sHoehenwinkel).*cosd(pvHoehenwinkel));

gDirekt = Strahlung.DirectHoriz;
gDiffus = Strahlung.DiffusHoriz;

%% Funktion: Eges = Jahreserzeugung(...) aufrufen. Funktion muss zuvor erstellt werden.



%% Darstellung mittels plot(Eges)



%%


%% Aufgabe 1.2.b und 1.2.c



%% Diagramm f�r Strahlungsanteile: plotStrahlungsanteile(...)



%% Aufgabe 1.2.e
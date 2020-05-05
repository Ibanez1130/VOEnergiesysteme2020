% Code Umgebung vorbereiten
close all;                          % Schließt alle Fenster
clear;                              % Leert Workspace
clc                                 % Leert Command Window

% Einlesen der Daten
load ('./Angabe/Strahlung.mat');
load ('./Angabe/time.mat');
addpath(genpath('Angabe'));

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
sAzimut2 = 4;

%% Funktion: Eges = Jahreserzeugung(...) aufrufen. Funktion muss zuvor erstellt werden.



%% Darstellung mittels plot(Eges)



%%

%hallo leute

%% Aufgabe 1.2.b und 1.2.c



%% Diagramm f�r Strahlungsanteile: plotStrahlungsanteile(...)



%% Aufgabe 1.2.e
%% Code Umgebung vorbereiten
close all;                                  % Schließt alle Fenster
clear;                                      % Leert Workspace
clc                                         % Leert Command Window

%% Einlesen der Daten
DatenButendiek = load('./Daten/OffShore_Butendiek.mat');
DatenJuldelund = load('./Daten/OnShore_Juldelund.mat');

DatenHelsinki = load('./Daten/Helsinki.mat');
DatenWien = load('./Daten/Wien.mat');
DatenNeapel = load('./Daten/Neapel.mat');

%% Definition der Variablen
% Definition der Parameter der WKA SWT-3.6-120 in Butendiek
offLatitude = 54.9;         % Längengrad der OffShore WKA
offLongitude = 7.75;        % Breitengrad der OffShore WKA

offHeight = 91;             % above sea level (Meter)
offRotorRadius = 60;        % rotor radius (Meter)
offRotorHubRadius = 1.5;    % Radius der Rotornabe (Meter)
offRatedPower = 3.6;        % (MW)
offCutInWind = 4;           % cut in wind-speed of the turbine (m/s)
offRatedWind = 13.5;        % rated wind-speed of the turbine (m/s)
offCutOutWind = 25;         % cut out wind-speed of the turbine (m/s)
offRotorArea = (offRotorRadius^2 * pi) - (offRotorHubRadius^2 * pi); % Rotorfläche in m^2

% Definition der Parameter der WKA SWT-3.6-120 in Juldelund
onLatitude = 54.9;          % Längengrad der OnShore WKA
onLongitude = 9.1;          % Breitengrad der OnShore WKA

%% Vergleich Offshore/Onshore für den Standort Sylt/Juldelund
% Offshore/Onshore Vergleich - Sylt (Offshore Windpark Butendiek)
% Standorte in Europa - Helsinki, Wien, Neapel
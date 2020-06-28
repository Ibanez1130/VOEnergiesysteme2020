%% Code Umgebung vorbereiten
close all;                                  % Schließt alle Fenster
clear;                                      % Leert Workspace
clc                                         % Leert Command Window

%% Einlesen der Daten
% Alle Winddaten wurden in einer Höhe von 2m gemessen
DatenButendiek = load('./Daten/OffShore_Butendiek.mat');
Butendiek = DatenButendiek.OffShore_Butendiek;
DatenJuldelund = load('./Daten/OnShore_Joldelund.mat');
Joldelund = DatenJuldelund.OnShore_Joldelund;

DatenHelsinki = load('./Daten/Helsinki.mat');
Helsinki = DatenHelsinki.Helsinki;
DatenWien = load('./Daten/Wien.mat');
Wien = DatenWien.Wien;
DatenNeapel = load('./Daten/Neapel.mat');
Neapel = DatenNeapel.Neapel;

%% Definition der Variablen
% Allgemeine Konstanten
spezGaskonst = 287.058;     % spezifische Gaskonstante der Luft

% Definition der Parameter der WKA SWT-3.6-120 in Butendiek
offLatitude = 54.9;         % Längengrad der OffShore WKA
offLongitude = 7.75;        % Breitengrad der OffShore WKA

offHeight = 91;             % above sea level (Meter)
offRotorRadius = 60;        % rotor radius (Meter)
offRotorHubRadius = 1.5;    % Radius der Rotornabe (Meter)
offRatedPower = 3.6;    	% (MW)
offCutInWind = 3;           % cut in wind-speed of the turbine (m/s)
offRatedWind = 12.5;        % rated wind-speed of the turbine (m/s)
offCutOutWind = 25;         % cut out wind-speed of the turbine (m/s)
offRotorArea = (offRotorRadius^2 * pi) - (offRotorHubRadius^2 * pi); % Rotorfläche in m^2
offZ = 0.0001;              % Rauhigkeit für Wasserflächen lt. Tabelle 2-1 im Skript
% Definition der Parameter der WKA SWT-3.6-120 in Juldelund
onLatitude = 54.9;          % Längengrad der OnShore WKA

onLongitude = 9.1;          % Breitengrad der OnShore WKA
onZ = 0.05;                 % Rauhigkeit für landwirtschaftl. Gelände mit offenem Erscheindungsbild lt. Tabelle 2-1 im Skript

%% Vergleich Offshore/Onshore für den Standort Sylt/Juldelund
% Offshore/Onshore Vergleich - Sylt (Offshore Windpark Butendiek)

% Berechnen der Offshore Leistung
% Mangels Messdaten zu der expliziten Anlage, errechnen wir das Produkt aus
% Leistungsbeiwert und Effizienz aus den Nenndaten der WKA.
offEffFactor = offRatedPower / (0.5 * mean(calculateAirDensity(Butendiek.Pressure,Butendiek.Temperature,spezGaskonst)) * offRotorArea * offRatedWind ^ 3);
offWindSpeed = sort(convertWindspeedToHeight(Butendiek.WindSpeed,2,offHeight,offZ), 'descend');
offPWind = 0.5 .* calculateAirDensity(Butendiek.Pressure,Butendiek.Temperature,spezGaskonst) .* offRotorArea .* offWindSpeed .^ 3;
offP = offPWind .* offEffFactor;
offP(offWindSpeed < 3) = 0;
offP(offWindSpeed > 12.5) = offRatedPower;
offP(offWindSpeed > 25) = 0;

% Plot der Leistungsdauerlinie
figure('Name','Dauerlinie der Offshore Windkraftanlage (Butendiek)','NumberTitle','off');
plot(sort(offWindSpeed, 'descend'));
ylabel('Windgeschwindigkeit in m/s');
hold on
yyaxis right
ylabel('Leistung in MW')
plot(offP);
xlim([0 35040]);
xlabel('Zeit in Viertelstunden');

% Berechnen der Onshore Leistung
% Mangels Messdaten zu der expliziten Anlage, errechnen wir das Produkt aus
% Leistungsbeiwert und Effizienz aus den Nenndaten der WKA.
onEffFactor = offRatedPower / (0.5 * mean(calculateAirDensity(Joldelund.Pressure,Joldelund.Temperature,spezGaskonst)) * offRotorArea * offRatedWind ^ 3);
onWindSpeed = sort(convertWindspeedToHeight(Joldelund.WindSpeed,2,offHeight,onZ), 'descend');
onPWind = 0.5 .* calculateAirDensity(Joldelund.Pressure,Joldelund.Temperature,spezGaskonst) .* offRotorArea .* onWindSpeed .^ 3;
onP = onPWind .* onEffFactor;
onP(onWindSpeed < 3) = 0;
onP(onWindSpeed > 12.5) = offRatedPower;
onP(onWindSpeed > 25) = 0;

% Plot der Leistungsdauerlinie
figure('Name','Dauerlinie der Onshore Windkraftanlage (Joldelund)','NumberTitle','off');
plot(sort(onWindSpeed, 'descend'));
ylabel('Windgeschwindigkeit in m/s');
hold on
yyaxis right
ylabel('Leistung in MW')
plot(onP);
xlim([0 35040]);
xlabel('Zeit in Viertelstunden');

%% Vergleich unterschiedlicher Standorte in Europa
% Standorte in Europa - Helsinki, Wien, Neapel

function speed = convertWindspeedToHeight(data,refHeight,height,z)
    speed = data.*(log(height/z)/log(refHeight/z));
end

function airDensity = calculateAirDensity(pressure,temperature,rs)
    airDensity = pressure.*100./(rs.*temperature); % mal 100, da der Druck in hPa vorliegt
end

%% Notizen
% Luftdruck und Temperature sind beide auf Boden-Niveau. Sind also ungenau.
% Aufgrund mangelnder Messdaten wird in allen Fällen von einem
% Leistungsbeiwert von 0.45 ausgegangen (Beispiel 5-1 vergleichbar)
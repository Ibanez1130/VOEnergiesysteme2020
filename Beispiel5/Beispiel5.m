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

%% Definition der Variablen für den Offshore/Onshore Vergleich
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

%% Definition der Variablen für den Europa Vergleich
% Anhand der Senvion 3.4M122 NES
eurHeight = 85:5:140;       % above sea level (Meter)
eurRotorRadius = 61;        % rotor radius (Meter)
eurRotorHubRadius = 1.2;    % Radius der Rotornabe (Meter)
eurRatedPower = 3.4;    	% (MW)
eurCutInWind = 3;           % cut in wind-speed of the turbine (m/s)
eurRatedWind = 12.5;        % rated wind-speed of the turbine (m/s)
eurCutOutWind = 22;         % cut out wind-speed of the turbine (m/s)
eurRotorArea = (eurRotorRadius^2 * pi) - (eurRotorHubRadius^2 * pi);
eurZ = onZ;

%% Vergleich Offshore/Onshore für den Standort Butendiek/Joldelund

% Berechnen der Offshore Leistung
% Mangels Messdaten zu der expliziten Anlage, errechnen wir das Produkt aus
% Leistungsbeiwert und Effizienz aus den Nenndaten der WKA.
offEffFactor = offRatedPower / (0.5 * mean(calculateAirDensity(Butendiek.Pressure,Butendiek.Temperature,spezGaskonst)) * offRotorArea * offRatedWind ^ 3);
offWindSpeed = sort(convertWindspeedToHeight(Butendiek.WindSpeed,2,offHeight,offZ), 'descend');
offPWind = 0.5 .* calculateAirDensity(Butendiek.Pressure,Butendiek.Temperature,spezGaskonst) .* offRotorArea .* offWindSpeed .^ 3;
offP = offPWind .* offEffFactor;
offP(offWindSpeed < offCutInWind) = 0;
offP(offWindSpeed > offRatedWind) = offRatedPower;
offP(offWindSpeed > offCutOutWind) = 0;

% Plot der Leistungsdauerlinie
figure('Name','Dauerlinie der Offshore Windkraftanlage (Butendiek, SWT-3.6-120)','NumberTitle','off');
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
onP(onWindSpeed < offCutInWind) = 0;
onP(onWindSpeed > offRatedWind) = offRatedPower;
onP(onWindSpeed > offCutOutWind) = 0;

% Plot der Leistungsdauerlinie
figure('Name','Dauerlinie der Onshore Windkraftanlage (Joldelund, SWT-3.6-120)','NumberTitle','off');
plot(sort(onWindSpeed, 'descend'));
ylabel('Windgeschwindigkeit in m/s');
hold on
yyaxis right
ylabel('Leistung in MW')
plot(onP);
xlim([0 35040]);
xlabel('Zeit in Viertelstunden');

%% Vergleich Offshore/Onshore für höhere und niedrigere Anlagen
comparisonHeight = 70:5:140;
offVolllaststunden = zeros(length(comparisonHeight), 1);

for h=1:length(comparisonHeight)
    effFactor = offRatedPower / (0.5 * mean(calculateAirDensity(Butendiek.Pressure,Butendiek.Temperature,spezGaskonst)) * offRotorArea * offRatedWind ^ 3);
    windSpeed = sort(convertWindspeedToHeight(Butendiek.WindSpeed,2,comparisonHeight(h),offZ), 'descend');
    PWind = 0.5 .* calculateAirDensity(Butendiek.Pressure,Butendiek.Temperature,spezGaskonst) .* offRotorArea .* windSpeed .^ 3;
    P = PWind .* effFactor;
    P(windSpeed < offCutInWind) = 0;
    P(windSpeed > offRatedWind) = offRatedPower;
    P(windSpeed > offCutOutWind) = 0;
    offVolllaststunden(h) = sum(P)/(4 * offRatedPower);
end

onVolllaststunden = zeros(length(comparisonHeight), 1);

for h=1:length(comparisonHeight)
    effFactor = offRatedPower / (0.5 * mean(calculateAirDensity(Joldelund.Pressure,Joldelund.Temperature,spezGaskonst)) * offRotorArea * offRatedWind ^ 3);
    windSpeed = sort(convertWindspeedToHeight(Joldelund.WindSpeed,2,comparisonHeight(h),onZ), 'descend');
    PWind = 0.5 .* calculateAirDensity(Joldelund.Pressure,Joldelund.Temperature,spezGaskonst) .* offRotorArea .* windSpeed .^ 3;
    P = PWind .* effFactor;
    P(windSpeed < offCutInWind) = 0;
    P(windSpeed > offRatedWind) = offRatedPower;
    P(windSpeed > offCutOutWind) = 0;
    onVolllaststunden(h) = sum(P)/(4 * offRatedPower);
end

figure('Name','Vergleich unterschiedlicher Höhen für Offshore und Onshore Anlagen','NumberTitle','off');
plot(comparisonHeight, [offVolllaststunden, onVolllaststunden]);
xlabel('Höhe der Rotornabe in m');
ylabel('Volllaststunden in h');
legend('Offshore (Butendiek)','Onshore (Joldelund)');

%% Vergleich unterschiedlicher Standorte in Europa, bei unterschiedlichen Höhen
% Standorte in Europa - Helsinki, Wien, Neapel
[ertragHelsinki,volllaststundenHelsinki] = calculateIncomeEurope(' Helsinki',Helsinki.WindSpeed,eurHeight,eurRatedPower,eurRatedWind,eurCutInWind,eurCutOutWind,Helsinki.Pressure,Helsinki.Temperature,eurRotorArea,eurZ,spezGaskonst);
[ertragWien,volllaststundenWien] = calculateIncomeEurope(' Wien',Wien.WindSpeed,eurHeight,eurRatedPower,eurRatedWind,eurCutInWind,eurCutOutWind,Wien.Pressure,Wien.Temperature,eurRotorArea,eurZ,spezGaskonst);
[ertragNeapel,volllaststundenNeapel] = calculateIncomeEurope(' Neapel',Neapel.WindSpeed,eurHeight,eurRatedPower,eurRatedWind,eurCutInWind,eurCutOutWind,Neapel.Pressure,Neapel.Temperature,eurRotorArea,eurZ,spezGaskonst);

figure('Name','Der Ertrag unterschiedlicher Standorte in Europa, mit unterschiedlichen Höhen','NumberTitle','off');
bar(eurHeight, [ertragHelsinki, ertragWien, ertragNeapel]);
xlabel('Höhe der Rotornabe in m');
ylabel('Ertrag in MWh');
legend('Helsinki','Wien','Neapel');

figure('Name','Die Volllaststunden unterschiedlicher Standorte in Europa, mit unterschiedlichen Höhen','NumberTitle','off');
bar(eurHeight, [volllaststundenHelsinki, volllaststundenWien, volllaststundenNeapel]);
xlabel('Höhe der Rotornabe in m');
ylabel('Volllaststunden in h');
legend('Helsinki','Wien','Neapel');

%% Funktionen

% Funktion zum Umrechnen der Windgeschwindigkeiten von einer Referenzhöhe
% auf eine andere.
function speed = convertWindspeedToHeight(data,refHeight,height,z)
    speed = data.*(log(height/z)/log(refHeight/z));
end

% Funktion zum Berechnen der Luftdichte
function airDensity = calculateAirDensity(pressure,temperature,rs)
    airDensity = pressure.*100./(rs.*temperature); % mal 100, da der Druck in hPa vorliegt
end

% Funktion zum Berechnen des Ertrags und der Volllaststunden
function [income,hours] = calculateIncomeEurope(location,speed,height,ratedPower,ratedWind,cutin,cutout,pressure,temperature,area,z,spezGaskonst)
    volllaststunden = zeros(length(height), 1);
    ertrag = zeros(length(height), 1);

    figure('Name',strcat('Leistungsdauerlinien, für unterschiedliche Höhen, für den Standort',location),'NumberTitle','off');
    for h=1:length(height)
        effFactor = ratedPower / (0.5 * mean(calculateAirDensity(pressure,temperature,spezGaskonst)) * area * ratedWind ^ 3);
        windSpeed = sort(convertWindspeedToHeight(speed,2,height(h),z), 'descend');
        PWind = 0.5 .* calculateAirDensity(pressure,temperature,spezGaskonst) .* area .* windSpeed .^ 3;
        P = PWind .* effFactor;
        P(windSpeed < cutin) = 0;
        P(windSpeed > ratedWind) = ratedPower;
        P(windSpeed > cutout) = 0;
        plot(1:35040, P);
        hold on
        ertrag(h) = sum(P);
        volllaststunden(h) = sum(P)/ratedPower;
    end
    xlabel('Zeit in Viertelstunden');
    ylabel('Leistung in MW');
    xlim([0,35040]);
    legend(string(height));
    income = ertrag ./ 4;
    hours = volllaststunden ./ 4;
end

%% Notizen
% Luftdruck und Temperature sind beide auf Boden-Niveau. Sind also ungenau.
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

load('./Daten/Spotpreis');

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

%% Definition der Daten für die Barwertanalyse

lifespan = 25;                                      % Lebensdauer (a)
interestRate = 4;                                   % Zinssatz (%)
feedInTariff_OEMAG = 0.082;                         % Einspeisetarif in €/kWh lt. OEMAG
fundingPeriod = 13;                                 % Förderdauer 13a
spotprice = table2array(Spotpreis(:,9))./10./100;   % Einspeisetarif in €/kWh im Jahr 2016 (Annahme: Spotpreis jedes Jahr gleich)

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

%% Barwert der Einnahmen zum Zeitpunkt der Erbauung
% Aus Mangel an weiteren Daten wird der österreichische Spotmarktpreis vom Jahr 2016
% für alle begutachteten WKAs hergezogen.
% Für einen korrekten Vergleich, bei dem länderspezifische Investitionskosten bzw
% Betriebskosten miteinberechnet werden, müsste auch länderspezifisch der Spotmarktpreis 
% verwendet werden.

% UNSORTIERTE LEISTUNG
but = calculatePowerUnsorted(Butendiek.WindSpeed,comparisonHeight,offRatedPower,offRatedWind,offCutInWind,offCutOutWind,Butendiek.Pressure,Butendiek.Temperature,offRotorArea,offZ,spezGaskonst);
jol = calculatePowerUnsorted(Joldelund.WindSpeed,comparisonHeight,offRatedPower,offRatedWind,offCutInWind,offCutOutWind,Joldelund.Pressure,Joldelund.Temperature,offRotorArea,onZ,spezGaskonst);
hel = calculatePowerUnsorted(Helsinki.WindSpeed,eurHeight,eurRatedPower,eurRatedWind,eurCutInWind,eurCutOutWind,Helsinki.Pressure,Helsinki.Temperature,eurRotorArea,eurZ,spezGaskonst);
wie = calculatePowerUnsorted(Wien.WindSpeed,eurHeight,eurRatedPower,eurRatedWind,eurCutInWind,eurCutOutWind,Wien.Pressure,Wien.Temperature,eurRotorArea,eurZ,spezGaskonst);
nea = calculatePowerUnsorted(Neapel.WindSpeed,eurHeight,eurRatedPower,eurRatedWind,eurCutInWind,eurCutOutWind,Neapel.Pressure,Neapel.Temperature,eurRotorArea,eurZ,spezGaskonst);


% Jährlicher Ertrag Förderdauer
CF_But_OEMAG = sum(but)./4.*1000.*feedInTariff_OEMAG;
CF_Jol_OEMAG = sum(jol)./4.*1000.*feedInTariff_OEMAG;
CF_Hel_OEMAG = sum(hel)./4.*1000.*feedInTariff_OEMAG;
CF_Wie_OEMAG = sum(wie)./4.*1000.*feedInTariff_OEMAG;
CF_Nea_OEMAG = sum(nea)./4.*1000.*feedInTariff_OEMAG;

% Jährlicher Ertrag Spotmarkt
CF_But_Spotprice = 0;
CF_Jol_Spotprice = 0;
CF_Hel_Spotprice = 0;
CF_Wie_Spotprice = 0;
CF_Nea_Spotprice = 0;

for i=1:8760
    run =4*i;
    CF_But_Spotprice = CF_But_Spotprice + sum(but(run-3:run))./4.*1000.*spotprice(i);
    CF_Jol_Spotprice = CF_Jol_Spotprice + sum(jol(run-3:run))./4.*1000.*spotprice(i);
    CF_Hel_Spotprice = CF_Hel_Spotprice + sum(hel(run-3:run))./4.*1000.*spotprice(i);
    CF_Wie_Spotprice = CF_Wie_Spotprice + sum(wie(run-3:run))./4.*1000.*spotprice(i);
    CF_Nea_Spotprice = CF_Nea_Spotprice + sum(nea(run-3:run))./4.*1000.*spotprice(i);
end

%Barwert
NPV_But = zeros(25,1);
NPV_Jol = zeros(25,1);
NPV_Hel = zeros(25,1);
NPV_Wie = zeros(25,1);
NPV_Nea = zeros(25,1);

for i = 1:25
    if i==1
        NPV_But(1) = CF_But_OEMAG/(1+interestRate./100);
        NPV_Jol(1) = CF_Jol_OEMAG/(1+interestRate./100);
        NPV_Hel(1) = CF_Hel_OEMAG/(1+interestRate./100);
        NPV_Wie(1) = CF_Wie_OEMAG/(1+interestRate./100);
        NPV_Nea(1) = CF_Nea_OEMAG/(1+interestRate./100);
    elseif i<=13
        NPV_But(i) = NPV_But(i-1) + CF_But_OEMAG./((1+interestRate./100)^i);
        NPV_Jol(i) = NPV_Jol(i-1) + CF_Jol_OEMAG./((1+interestRate./100)^i);
        NPV_Hel(i) = NPV_Hel(i-1) + CF_Hel_OEMAG./((1+interestRate./100)^i);
        NPV_Wie(i) = NPV_Wie(i-1) + CF_Wie_OEMAG./((1+interestRate./100)^i);
        NPV_Nea(i) = NPV_Nea(i-1) + CF_Nea_OEMAG./((1+interestRate./100)^i);
    else
        NPV_But(i) = NPV_But(i-1) + CF_But_Spotprice./((1+interestRate./100)^i);
        NPV_Jol(i) = NPV_Jol(i-1) + CF_Jol_Spotprice./((1+interestRate./100)^i);
        NPV_Hel(i) = NPV_Hel(i-1) + CF_Hel_Spotprice./((1+interestRate./100)^i);
        NPV_Wie(i) = NPV_Wie(i-1) + CF_Wie_Spotprice./((1+interestRate./100)^i);
        NPV_Nea(i) = NPV_Nea(i-1) + CF_Nea_Spotprice./((1+interestRate./100)^i);
    end
end

figure('Name', 'Barwert der Einnahmen', 'NumberTitle', 'Off');
xlabel('Barwert der Einnahmen');
ylabel('Betriebsjahre');
bar([NPV_But, NPV_Jol, NPV_Hel, NPV_Wie, NPV_Nea]);
legend('Butendiek', 'Joldelund', 'Helsinki', 'Wien', 'Neapel', 'Location', 'northwest');

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
    leistung = zeros(length(height), 35040);

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
        leistung(h,:) = P;
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

function power = calculatePowerUnsorted(speed,height,ratedPower,ratedWind,cutin,cutout,pressure,temperature,area,z,spezGaskonst)
    for h=1:length(height)
        effFactor = ratedPower / (0.5 * mean(calculateAirDensity(pressure,temperature,spezGaskonst)) * area * ratedWind ^ 3);
        windSpeed = convertWindspeedToHeight(speed,2,height(h),z);
        PWind = 0.5 .* calculateAirDensity(pressure,temperature,spezGaskonst) .* area .* windSpeed .^ 3;
        P = PWind .* effFactor;
        P(windSpeed < cutin) = 0;
        P(windSpeed > ratedWind) = ratedPower;
        P(windSpeed > cutout) = 0;
        power = P;
    end
end

%% Notizen
% Luftdruck und Temperature sind beide auf Boden-Niveau. Sind also ungenau.
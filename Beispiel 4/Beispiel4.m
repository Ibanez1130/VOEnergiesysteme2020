%% Code Umgebung vorbereiten
close all;                                  % Schließt alle Fenster
clear;                                      % Leert Workspace
clc                                         % Leert Command Window

%% Einlesen der Daten
load('.\Angabe\Spotpreis.mat');             % Stundenpreise in Cent/kWh für die Jahre 2008-2016 
load('.\Angabe\Load_PVProduction.mat');     % Enthält Last.mat und PV_profil.mat. Last.mat ist ein Lastprofil und PV_Profil ein Einspeiseprofil. Jeweils in Stundenwerten
ExcelFile = readtable('.\Angabe\Daten_Preise_Last_2012.xlsx');
Netzlast2012 = ExcelFile.Netzlast;
PV2012 = ExcelFile.PV;
Wind2012 = ExcelFile.Wind;
Spotpreis2012 = ExcelFile.Spotpreis;

%% Aufgabe 4.1
% Aufgabe 4.1.a
iLeistung = 0:50:200; % Die installierte Leistung von PV-Anlagen.

% Lastdauerlinie
figure('Name', 'Lastdauerlinie (4.1.a)', 'NumberTitle', 'Off')
plot(sort(Last, 'descend'))
xlabel('Zeit in Stunden')
ylabel('Last in MW')
title('Lastdauerlinie')
axis([0 8760 0 10*10^4])

% Residuallast Dauerlinie
figure('Name', 'Dauerlinie der Residuallast (4.1.a)', 'NumberTitle', 'Off')
for l=1:length(iLeistung)
    Residuallast = Last - (PV_profil .* (iLeistung(l) * 1000));
    plot(sort(Residuallast, 'descend'))
    hold on
end
xlabel('Zeit in Stunden')
ylabel('Residuallast in MW')
title('Dauerlinie der Residuallast')
legend({'Installierte Leistung: 0 GW', 'Installierte Leistung: 50 GW', 'Installierte Leistung: 100 GW', 'Installierte Leistung: 150 GW', 'Installierte Leistung: 200 GW'})
axis([0 8760 -10^5 10^5])
%{
% Aufgabe 4.1.b
figure('Name', 'Lastdauerlinie 2012 (4.1.b)', 'NumberTitle', 'Off')
plot(sort(Netzlast2012, 'descend'))
xlabel('Zeit in Stunden')
ylabel('Last in MW')
title('Lastdauerlinie 2012')

figure('Name', 'Dauerlinie der Residuallast 2012 (4.1.b)', 'NumberTitle', 'Off')
Residuallast2012 = Netzlast2012 - PV2012 - Wind2012;
plot(sort(Residuallast2012, 'descend'))
xlabel('Zeit in Stunden')
ylabel('Residuallast in MW')
title('Dauerlinie der Residuallast 2012')

% Aufgabe 4.1.c
figure('Name', 'Spotpreis 2012 in Abhängigkeit der Netzlast (4.1.c)', 'NumberTitle', 'Off')
scatter(Netzlast2012, Spotpreis2012)
xlabel('Netzlast in MW')
ylabel('Spotpreis in Euro')
title('Spotpreis 2012 in Abhängigkeit der Netzlast')

figure('Name', 'Spotpreis 2012 in Abhängigkeit der Residuallast (4.1.c)', 'NumberTitle', 'Off')
scatter(Residuallast2012, Spotpreis2012)
xlabel('Residuallast in MW')
ylabel('Spotpreis in Euro')
title('Spotpreis 2012 in Abhängigkeit der Residuallast')

figure('Name', 'Spotpreis 2012 in Abhängigkeit der Einspeisung erneuerbarer Energie (4.1.c)', 'NumberTitle', 'Off')
EinspeisungErneuerbareEnergie2012 = PV2012 + Wind2012;
scatter(EinspeisungErneuerbareEnergie2012, Spotpreis2012)
xlabel('Einspeisung erneuerbarer Energie in MW')
ylabel('Spotpreis in Euro')
title('Spotpreis 2012 in Abhängigkeit der Einspeisung erneuerbarer Energie')

% Aufgabe 4.1.d
% Besonders im Scatterplot des Spotpreises in Abhängigkeit von der
% Residuallast ist schön zu erkennen, dass der Spotpreis mit der Nachfrage
% (der Residuallast) steigt. Ein ähnliches Verhalten, jedoch nicht ganz so
% eindeutig, kann in der Darstellung der Spotpreise in Abhängigkeit der
% Netzlast gesehen werden.
% Die Spotpreise in Abhängigkeit der Einspeisung erneuerbarer Energie ist
% genau gegenteilig aufgebaut - Umso mehr Energie eingespeist wird, umso
% geringer ist der Spotpreis. Wenn wenig erneuerbare Energien eingespeist
% werden, steigt der Spotpreis (siehe die linke Seite des Diagramms).

%% Aufgabe 4.2
% Aufgabe 4.2.a
SpotpreisDaten = ["Spotpreis2008","Spotpreis2009","Spotpreis2010","Spotpreis2011","Spotpreis2012","Spotpreis2013","Spotpreis2014","Spotpreis2015","Spotpreis2016"];

figure('Name', 'Dauerlinie der Spotpreise von 2008 bis 2016 (4.2.a)', 'NumberTitle', 'Off')
for i=1:length(SpotpreisDaten)
    plot(sort(Spotpreis.(SpotpreisDaten(i)), 'descend'))
    hold on
end
xlabel('Zeit in Stunden')
ylabel('Preis in Euro')
legend(SpotpreisDaten)
title('Dauerlinie der Spotpreise von 2008 bis 2016')
axis([0 8760 -70 260])

% Aufgabe 4.2.b
SpotpreiseStd2008 = reshape(Spotpreis.Spotpreis2008,365,24);
SpotpreiseStd2016 = reshape(Spotpreis.Spotpreis2016,365,24);

figure('Name', 'Boxplot der mittleren stündlichen Großhandelsstrompreise 2008 und 2016 (4.2.b)', 'NumberTitle', 'Off')
subplot(2,1,1)
boxplot(SpotpreiseStd2008)
xlabel('Zeit in Stunden')
ylabel('Preis in Euro')
title('Boxplot der mittleren stündlichen Großhandelsstrompreise 2008')

subplot(2,1,2)
boxplot(SpotpreiseStd2016)
xlabel('Zeit in Stunden')
ylabel('Preis in Euro')
title('Boxplot der mittleren stündlichen Großhandelsstrompreise 2016')

%% Aufgabe 4.3
% Aufgabe 4.3.a
Skalierungsfaktor = 0.001; % Da der Ertrag in MW/MWp angegeben ist, müssen wir auf die 1kWp Anlage skalieren.
MonetaererEtrag = zeros(9,1);

for i=1:length(SpotpreisDaten)
    MonetaererEtrag(i) = sum(Skalierungsfaktor.*PV_profil.*Spotpreis.(SpotpreisDaten(i)));
end

MonetaererEtragGesamt = sum(MonetaererEtrag);

figure('Name', 'Die monetären Erträge einer 1kWp Anlage von 2008 bis 2016 (4.3.c)', 'NumberTitle', 'Off')
bar(2008:2016,MonetaererEtrag)
xlabel('Jahr')
ylabel('Ertrag in Euro')
title('Die monetären Erträge einer 1kWp Anlage von 2008 bis 2016')

% Aufgabe 4.3.b
MonetaererEtrag2008_1 = 0;
MonetaererEtrag2016_1 = 0;
MonetaererEtrag2008_2 = 0;
MonetaererEtrag2016_2 = 0;

Ertrag2008 = Skalierungsfaktor.*PV_profil.*Spotpreis.Spotpreis2008;
Ertrag2016 = Skalierungsfaktor.*PV_profil.*Spotpreis.Spotpreis2016;

for j=4:34
    MonetaererEtrag2008_1 = MonetaererEtrag2008_1 + sum(Skalierungsfaktor*PV_profil(j)*Spotpreis.Spotpreis2008(j));
    MonetaererEtrag2016_1 = MonetaererEtrag2016_1 + sum(Skalierungsfaktor*PV_profil(j)*Spotpreis.Spotpreis2016(j));
end

for k=180:220
    MonetaererEtrag2008_2 = MonetaererEtrag2008_2 + sum(Skalierungsfaktor*PV_profil(k)*Spotpreis.Spotpreis2008(k));
    MonetaererEtrag2016_2 = MonetaererEtrag2016_2 + sum(Skalierungsfaktor*PV_profil(k)*Spotpreis.Spotpreis2016(k));
end

figure('Name', 'Die monetären Erträge der Tag 4 bis 34 und 180 bis 220 in den Jahren 2008 bis 2016 (4.3.c)', 'NumberTitle', 'Off')
bar([MonetaererEtrag2008_1,MonetaererEtrag2016_1,MonetaererEtrag2008_2,MonetaererEtrag2016_2])
xlabel('Zeitbereich')
ylabel('Ertrag in Euro')
set(gca, 'XTickLabel',{'Tage 4-34 (2008)' 'Tage 4-34 (2016)' 'Tage 180-220 (2008)' 'Tage 180-220 (2016)'})
title('Die monetären Erträge der Tag 4 bis 34 und 180 bis 220 in den Jahren 2008 bis 2016')
%}
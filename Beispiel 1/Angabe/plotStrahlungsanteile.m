function plotStrahlungsanteile(pv_azimut, pv_hoehenwinkel, laengengrad, breitengrad, Strahlung, time)

%% Energieerzeugung

%% Funktion SonnenstandTST aufrufen und azimut und hoehenwinkel fuer beliebigen Standort bekommen.

[azimut,hoehenwinkel] = SonnenstandTST(laengengrad, breitengrad, time);

%% Strahlungsenergie einlesen

Gdirekt = Strahlung.DirectHoriz;
Gdiffus = Strahlung.DiffusHoriz;
Gglobal = Strahlung.GlobalHoriz;

%% Einstrahlungswinkel berechnen

% Berechnung des Einstrahlungswinkels: Das ist jener Winkel zwischen dem
% Normalvektor der Anlage und dem Sonnenstandsvektor.
Theta = acosd( -cosd(hoehenwinkel).*sind(pv_hoehenwinkel).*cosd(azimut - pv_azimut - 180) + sind(hoehenwinkel)*cosd(pv_hoehenwinkel));

%% Strahlungsenergie berechnen 

% Berechnung der direkten Sonneneinstrahlung
GpvDirekt = Gdirekt.*(cosd(Theta)./sind(hoehenwinkel));
GpvDirekt(GpvDirekt<0) = 0;
% Direkte Einstrahlung bei Einstrahlungswinkel groesser 90 Grad werden
% vernachlaessigt, weil keine Einstrahlung auf die PV-Anlage erfolgt.
GpvDirekt(Theta>90)=0;

% Berechnung der diffusen Strahlung
GpvdiffusH = Gdiffus.*((1+cosd(pv_hoehenwinkel))/2); 

% Berechnung der reflektierten Strahlung mit Albedo = 0.2 wegen unbekannter
% Umgebung
GpvdiffusB = Gglobal.*((1-cosd(pv_hoehenwinkel))/2).*(0.2);

% Gesammte Einstrahlung auf die PV_Anlage
GpvGes = GpvDirekt + GpvdiffusH + GpvdiffusB;

% Einstrahlung fuer Hoehenwinkel kleiner 5 Grad werden laut Angabe
% vernachlaessigt
GpvGes(hoehenwinkel<5)=0;

GpvDirektDay= sum(reshape(GpvDirekt,96,365))';
GpvdiffusHDay= sum(reshape(GpvdiffusH,96,365))';
GpvdiffusBDay= sum(reshape(GpvdiffusB,96,365))';

GpvGesAnteilig = [GpvDirektDay, GpvdiffusHDay, GpvdiffusBDay];
% GpvGes = [GpvDirekt./GpvGes; GpvdiffusH./GpvGes; GpvdiffusB./GpvGes]

%% plotten
% Grafische Ausgabe der Monatsertraege als Balkendiagramm
figure('Name','Strahlungsanteile');
area(GpvGesAnteilig,'LineStyle','none');
title('Ertraege');
xlabel('Tage');
ylabel('Erzeugung in Wh');
legend('direkte Einstrahlung','diffuse Einstrahlung','reflektierte Einstrahlung')

end



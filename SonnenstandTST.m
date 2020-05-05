function [azimut,hoehenwinkel] = SonnenstandTST (laengengrad,breitengrad,time)
%% Berechnung Sonnenstand
%Diese Funktion erstellt einen Vektor f�r den Sonnenstand in 15 min
%Aufl�sung �ber ein Jahr

%die Variable "azimut" ergibt einen Vektor des azimuts �ber ein Jahr
%der azimut ergibt nur f�r positive Hoehenwinkel verl�ssliche Werte, da
%die atan-Funktion nur Abweichungen bis zu 90� liefert. In weiteren 
%Berechnungen sollten also nur jene Werte mit positiven Hoehenwinkeln 
%(nach Sonnenaufgang) verwendet werden. F�r die Berechnung von PV-Ertr�gen
%reicht dies vollkommen aus. 
%die Variable "hoehenwinkel" ergibt einen Vektor aller hoehenwinkel �ber 
%ein Jahr
%f�r Schaltjahre muss die Berechnung dementsprechend angepasst werden. Dies
%Anpassung muss im Rahmen dieser LV allerdings nicht ber�cksichtigt werden.

%Quellen zur Berechnung des Sonnenstands: Ursula Eicker(2012), 
%Jakob Anger(2012), Rainer Blabensteiner(2011)

%% Zeitgleichung zur Berechnung der wahren Ortszeit

%Zeitgleichung - ergibt die 
%Abweichung der Sonnenuhr von der mittlerer Ortszeit(MOZ)

hw1=360/365.*time.Tag; %Hilfswinkel 1

z=0.008*cosd(hw1)-0.122*sind(hw1)-0.052*cosd(2*hw1)-0.157*sind(2*hw1)...
    -0.001*cosd(3*hw1)-0.005*sind(3*hw1); %Zeitgleichung

% Zeitgleichungplot(time.Tag,z); %Plot
WOZ=time.Stunden+z+1/15*laengengrad-floor(1/15*laengengrad); %Wahre Ortszeit(WOZ), der Vektor 
%time.Stunden entspricht der mittleren Ortszeit(MOZ) in Stunden

%% Stundenwinkel bei Berechnung �ber True Solar Time
% time.Stunden entspricht hier der Sonnenzeit und nicht der Ortszeit
% Stw=15*time.Stunden; %Stundenwinkel 
Stw=15*WOZ; %Stundenwinkel

%% Berechnung der Deklination

Ew=0.98630*(time.Tag-2.8749)+1.9137*sind(0.98630*(time.Tag-2.8749))+102.06; 
% Ekliptikale L�nge in Grad
% Winkel zwischen Verbindungslinie Sonne-Erde und der Verbindungsline
% Sonne-Fr�hlingspunkt. Wird als Ekliptikale L�nge bezeichnet

Dw=asind(-0.3979.*sind(Ew)); %Winkel zwischen �quatorebene und Verbindungs-
% linie Sonne-Erde. Dieser Winkel wird als Sonnendeklination bezeichnet
% und schwankt �ber das Jahr zwischen 23�26,5' und -23�26,5'


% Sonnendeklination(time.Tag,Dw); %Plot

%% Berechnung des H�henwinkels

hoehenwinkel=asind(sind(Dw).*sind(breitengrad)-cosd(Dw).*cosd(breitengrad).*cosd(Stw));

%% Berechnung des Azimuts
% Winkel nach Sonnenuntergang werden hier nicht vollst�ndig abgebildet

azimutfull=180+atand(-cosd(Dw).*sind(Stw)./(-cosd(Dw).*sind(breitengrad).*cosd(Stw)-sind(Dw).*cosd(breitengrad)));
azimutfull(hoehenwinkel<-20)=0; %Eliminiert alle Winkel bei Hoehenwinkel
% unter -20�
azimutaufteilung=reshape(azimutfull,length(time.Stunden)/365,365); % teilt
% Vektor auf Tage auf
az1=azimutaufteilung(1:(length(time.Stunden)/365)/2,:); % ergibt Werte
% f�r die erste Tagesh�lfte
az1(az1>220)=az1(az1>220)-180; % Korrektur der Winkel f�r Abweichungen von
% �ber 90� aus S�drichtung
az11=az1(1:(length(time.Stunden)/365)*0.25,:);
az11(az11>=180)=az11(az11>=180)-180;
az1(1:length(az11(:,1)),:)=az11;

az2=azimutaufteilung((length(time.Stunden)/365)/2+1:end,:); % ergibt Werte
% f�r die zweite Tagesh�lfte
az2(az2<150&az2>0)=az2(az2<150&az2>0)+180; % Korrektur der Winkel f�r 
% Abweichungen von �ber 90� aus S�drichtung
az22=az2(length(az2(:,1))*0.5:end,:);
az22(az22<=180&az22>0)=az22(az22<=180&az22>0)+180;
az2(length(az2(:,1))-length(az22(:,1))+1:end,:)=az22;

azimutaufteilung=[az1;az2]; %Zusammenfassung der ersten und zweiten 
% Tagesh�lfte
azimut=reshape(azimutaufteilung,35040,1); % reshape der Tage in einen 
% Vektor aller Winkel �ber den Jahresverlauf in 15min Intervallen


end


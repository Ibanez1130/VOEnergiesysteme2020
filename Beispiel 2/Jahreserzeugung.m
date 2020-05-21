%Berechnet die viertelstündlichen Erträge der Anlage
function [Eges,EgesT] = Jahreserzeugung (pvHoehenwinkel, pvGroesse, pvWirkungsgrad, pvVerluste, pvModuleinfallswinkel, sHoehenwinkel, Strahlung, gSTC, TmodSTC, ct, Temperatur)

k1 = -0.017162;
k2 = -0.040289;
k3 = -0.004681;
k4 = 0.000148;
k5 = 0.000169;
k6 = 0.000005;

%Flaeche des PV-Moduls
pvFlaeche = pvGroesse./pvWirkungsgrad;

%Direkte Strahlung auf geneigter Fläche (Blabensteiner (3.21))
DirectGen = Strahlung.DirectHoriz.*max(0, (cosd(pvModuleinfallswinkel)./sind(sHoehenwinkel)));

%Reflektierte Strahlung auf geneigte Fläche (Blabensteiner (3.22))
ReflectedGen = Strahlung.Reflected.*0.2.*(1-cosd(pvHoehenwinkel))./2;

%Diffuse Strahlung auf geneigter Fläche (Blabensteiner (3.23))
DiffusGen = Strahlung.DiffusHoriz.*(1+cosd(pvHoehenwinkel))./2;

%Gesamtstrahlung
GesGen = DirectGen + ReflectedGen + DiffusGen;
GesGen(sHoehenwinkel < 5) = 0;  % Strahlung bei Hoehenwinkel unter 5° wird nicht berücksichtigt

Tmod = repelem(Temperatur,4) + ct.*GesGen;
T = Tmod - TmodSTC;
G = GesGen./gSTC;
G(G<0.00000000000000000000000001)=0.0000001; % Notwendig um unendliche Werte im Wirkungsgrad zu vermeiden.
TWirkungsgrad=1+k1.*log(G)+k2.*pow2(log(G))+T.*(k3+k4.*log(G)+k5.*pow2(log(G)))+k6.*pow2(T);

%Ertrag in 15min Intervallen
Eges = GesGen.*pvFlaeche.*pvWirkungsgrad.*pvVerluste;
% Ertrag mit Einfluss der Temperatur
EgesT = GesGen.*pvFlaeche.*pvWirkungsgrad.*pvVerluste.*TWirkungsgrad;

end

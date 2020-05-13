%Berechnet die viertelstündlichen Erträge der Anlage
function [Eges,EgesT] = Jahreserzeugung (pvHoehenwinkel, pvGroesse, pvWirkungsgrad, pvVerluste, pvModuleinfallswinkel, sHoehenwinkel, Strahlung, gSTC, TmodSTC, ct, Temperatur)

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
GesGen(sHoehenwinkel < 5) = 0;  %Strahlung bei Hoehenwinkel unter 5° wird nicht berücksichtigt

Tmod = repelem(Temperatur,4) + ct.*GesGen;
T = Tmod - TmodSTC;
TWirkungsgrad=1-0.017162*log(GesGen./gSTC)-0.040289*log(GesGen./gSTC).^2-0.004681.*log(GesGen./gSTC).^3+0.000148.*log(GesGen./gSTC).^4+0.000169.*log(GesGen./gSTC).^5+0.000005.*T.^2;

%Ertrag in 15min Intervallen
Eges = GesGen.*0.25.*pvFlaeche.*pvWirkungsgrad.*pvVerluste;
% Ertrag mit Einfluss der Temperatur
EgesT = GesGen.*0.25.*pvFlaeche.*pvWirkungsgrad.*pvVerluste.*TWirkungsgrad;

end

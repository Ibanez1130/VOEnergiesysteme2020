%Berechnet die viertelstündlichen Erträge der Anlage
function Eges = Jahreserzeugung (pvHoehenwinkel, pvGroesse, pvWirkungsgrad, pvVerluste, pvModuleinfallswinkel, sHoehenwinkel, Strahlung)

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

%Ertrag in 15min Intervallen
Eges = GesGen.*0.25.*pvFlaeche.*pvWirkungsgrad.*pvVerluste;

end


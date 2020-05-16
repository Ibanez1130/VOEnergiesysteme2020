%% Laden von Strahlungsdaten aus .xls File
% Die "SODA" Daten müssen zuerst in einem .xls File gespeichert werden.
% Dabei stehen in der ersten Zeile die Beschriftungen [Direct Inclined, ...,
% Global Horiz,....]. Danach folgen die Daten.
% Der Befehl Dataset erzeugt eine Struktur mit dem Namen "Strahlung". 
% (siehe Matlab-Hilfe zu "struct") Den Vektor der Globalstrahlung auf eine
% horizontale Fläche erhalten sie z.B. über Strahlung.GlobalHoriz

Strahlung=dataset('XLSFile','Strahlung_Neapel.xlsx');

%% Korrektur fehlender Werte - Vorsicht!!! lange Rechenzeit!
% alle Datensätze von "SODA" aus dem Jahr 2005 enthalten einen Fehler. Über
% mehrere Tage wurden keine Daten gemessen. Diese werden nach dem Download 
% mit dem Wert -999 belegt. Die folgende Schleife ersetzt diese Werte mit
% den Werten aus der Vorwoche. Dies kann je nach Rechenleistung einige Zeit
% in Anspruch nehmen!!

fn=fieldnames(Strahlung);

for i=1:1:(length(fn)-1)
    
    Strahlung.(fn{i})(strcmp(Strahlung.(fn{i}),-999))=Strahlung.(fn{i})(find(strcmp(Strahlung.(fn{i}),-999))-672);
   
end

save Strahlung 
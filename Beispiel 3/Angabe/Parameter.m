%% Parameter zur Aufgabe 3.1

Anlagenleistung = 10;               % Anlagenleistung in kWp
Zinssatz = 0.04;                    % Zinssatz: 4%
Systemkosten = 1200;                % Systemkosten in €/kWp
Betriebskosten = 4;                 % Betriebskosten in €/kWp
Lebensdauer = 25;                   % Lebensdauer in Jahren
Einspeisetarif = 0.0824;            % Einspeisetarif in €/kWh (https://www.oem-ag.at/fileadmin/user_upload/Dokumente/gesetze/2015_12_23_OESET-VO_2016.pdf)
Foerderdauer = 13;                  % Förderdauer durch OeMAG in Jahren

% Ergänzungen aus BGBl II Nr. 459/2015, Paragraph 5, Absatz 1
Investitionszuschuss_prozent = 0.4; % Zuschuss in Prozent der Errichtungskosten (maximal allerdings Investitionszuschuss_max)
Investitionszuschuss_max = 375;     % Maximaler Zuschuss in Euro (pro kWp)

%% Parameter zur Aufgabe 3.2
Anlagenleistung_5_2 = 5;            % Anlagenleistung in kWp
Anlagenleistung_Max = 20;           % Maximale Anlagenleistung in kWp mit der gerechnet werden soll

%% Parameter zur Aufgabe 3.3
Haushaltsstrompreis = 0.15;        % Haushaltsstrompreis in €/kWh
Einspeisetarif_5_3 = 0.05;         % Einspeisetarif in €/kWh
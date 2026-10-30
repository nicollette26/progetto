function [esito, anomaliaPerc, dettagli] = diagnostica_emocromo(sesso, hgb, wbc, plt, mcv, mch, mchc)
    sesso = upper(string(sesso));

    if ~(sesso == "M" || sesso == "F")
        error('Sesso non valido: usare M o F');
    end

    esito = "Valori nella Norma";
    anomaliaPerc = 0;
    dettagli = struct('tipoAnemia', 'Nessuna', 'anomalie', {});

    anomalie = {};

    % 1) Anemia
    if (sesso == "F" && hgb < 12) || (sesso == "M" && hgb < 13.5)
        if mcv < 80
            tipo = "Anemia Microcitica";
        elseif mcv > 100
            tipo = "Anemia Macrocitica";
        else
            tipo = "Anemia Normocitica";
        end

        if mch < 27 || mchc < 32
            tipo = strcat(tipo, " / Ipocromica");
        end

        esito = tipo;
        anomaliaPerc = max(anomaliaPerc, 25);
        dettagli.tipoAnemia = tipo;
        anomalie{end+1} = 'Anemia';
    end

    % 2) WBC
    if wbc > 11000 || wbc < 4000
        if strcmp(esito, "Valori nella Norma")
            esito = "Anomalia Globuli Bianchi";
        else
            esito = sprintf('%s + Anomalia Globuli Bianchi', esito);
        end
        anomaliaPerc = max(anomaliaPerc, 30);
        anomalie{end+1} = 'WBC';
    end

    % 3) PLT
    if plt < 150000
        if strcmp(esito, "Valori nella Norma")
            esito = "Piastrinopenia";
        else
            esito = sprintf('%s + Piastrinopenia', esito);
        end
        anomaliaPerc = max(anomaliaPerc, 20);
        anomalie{end+1} = 'PLT';
    end

    dettagli.anomalie = anomalie;

    % In caso di nessuna anomalia
    if isempty(anomalie)
        esito = "Valori nella Norma";
        anomaliaPerc = 0;
        dettagli.tipoAnemia = 'Nessuna';
    end
end

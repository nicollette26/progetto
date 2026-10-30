function [esito, anomaliaPerc, dettagli] = diagnostica_emocromo(sesso, hgb, wbc, plt, mcv, mch, mchc)
    sesso = upper(string(sesso));
    if ~(sesso == "M" || sesso == "F")
        error('Sesso non valido: usare M o F');
    end

    esito = "Valori nella Norma";
    anomaliaPerc = 0;
    
    if (sesso == "F" && hgb < 12) || (sesso == "M" && hgb < 13.5)
        if mcv < 80
            esito = "Anemia Microcitica";
        elseif mcv > 100
            esito = "Anemia Macrocitica";
        else
            esito = "Anemia Normocitica";
        end

        if mch < 27 || mchc < 32
            esito = strcat(esito, " / Ipocromica");
        end
        anomaliaPerc = 25;
        dettagli = struct('tipoAnemia', esito);
        return
    end

    if wbc > 11000 || wbc < 4000
        esito = "Anomalia Globuli Bianchi";
        anomaliaPerc = 30;
        dettagli = struct('tipoAnemia', 'WBC');
        return
    end

    if plt < 150000
        esito = "Piastrinopenia";
        anomaliaPerc = 20;
        dettagli = struct('tipoAnemia', 'PLT');
        return
    end

    dettagli = struct('tipoAnemia', 'Nessuna');

end

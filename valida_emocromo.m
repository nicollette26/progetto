function [ok, messaggio] = valida_emocromo(sesso, hgb, rbc, wbc, plt, mcv, mch, mchc)
    ok = true;
    messaggio = '';

    if nargin ~= 8
        ok = false;
        messaggio = 'Numero di parametri non valido.';
        return;
    end

    if isempty(sesso)
        ok = false;
        messaggio = 'Inserire il sesso.';
        return;
    end

    sesso = upper(string(sesso));
    if ~(sesso == "M" || sesso == "F")
        ok = false;
        messaggio = 'Sesso non valido. Usare M o F.';
        return;
    end

    vals = [hgb, rbc, wbc, plt, mcv, mch, mchc];
    if any(~isfinite(vals)) || any(vals <= 0)
        ok = false;
        messaggio = 'Tutti i valori devono essere numerici, finiti e maggiori di zero.';
        return;
    end

    % Limiti clinici di base
    if hgb < 4 || hgb > 25
        ok = false;
        messaggio = 'HGB fuori range ragionevole (4-25 g/dL).';
        return;
    end

    if rbc < 2 || rbc > 8
        ok = false;
        messaggio = 'RBC fuori range ragionevole (2-8 10^6/µL).';
        return;
    end

    if wbc < 2000 || wbc > 30000
        ok = false;
        messaggio = 'WBC fuori range ragionevole (2000-30000/µL).';
        return;
    end

    if plt < 50000 || plt > 700000
        ok = false;
        messaggio = 'PLT fuori range ragionevole (50000-700000/µL).';
        return;
    end

    if mcv < 50 || mcv > 150
        ok = false;
        messaggio = 'MCV fuori range ragionevole (50-150 fL).';
        return;
    end

    if mch < 15 || mch > 40
        ok = false;
        messaggio = 'MCH fuori range ragionevole (15-40 pg).';
        return;
    end

    if mchc < 20 || mchc > 45
        ok = false;
        messaggio = 'MCHC fuori range ragionevole (20-45 g/dL).';
        return;
    end
end

%[appendix]{"version":"1.0"}
%---

% Script per popolare il Database emocromo.db dal file CSV
nomeFile = 'blood_count_dataset_clean.csv';

if ~exist(nomeFile, 'file')
    if exist('blood_count_dataset.csv', 'file')
        nomeFile = 'blood_count_dataset.csv';
    else
        error('File %s non trovato! Controlla di averlo messo nella cartella progetto.', nomeFile);
    end
end

if exist('prepara_dataset.m', 'file')
    dataset = prepara_dataset(nomeFile);
else
    dataset = readtable(nomeFile);
    dataset = unique(dataset, 'rows');
end

if strcmp(nomeFile, 'blood_count_dataset.csv')
    dataset = unique(dataset, 'rows');
end

conn = sqlite('emocromo.db');

exec(conn, 'DELETE FROM REFERTO_ANALISI;');
exec(conn, 'DELETE FROM ESAME_EMOCROMO;');
exec(conn, 'DELETE FROM PAZIENTE;');

exec(conn, 'DELETE FROM sqlite_sequence WHERE name="PAZIENTE";');
exec(conn, 'DELETE FROM sqlite_sequence WHERE name="ESAME_EMOCROMO";');
exec(conn, 'DELETE FROM sqlite_sequence WHERE name="REFERTO_ANALISI";');

disp('Database pulito. Inizio inserimento dei dati...');

for i = 1:height(dataset)
    eta = dataset{i, 'Age'};
    if isempty(eta) || isnan(eta)
        continue;
    end

    annoCorrente = year(datetime('now'));
    annoNascita = annoCorrente - eta;
    dataNascita = sprintf('%d-01-01', annoNascita);

    sessoRaw = lower(string(dataset{i, 'Gender'}));
    if sessoRaw == "male"
        sesso = 'M';
    elseif sessoRaw == "female"
        sesso = 'F';
    else
        sesso = 'F'; 
    end

    hgb = dataset{i, 'Hemoglobin'};
    rbc = dataset{i, 'Red_Blood_Cells'};
    wbc = dataset{i, 'White_Blood_Cells'};
    plt = dataset{i, 'Platelet_Count'};
    mcv = dataset{i, 'MCV'};
    mch = dataset{i, 'MCH'};
    mchc = dataset{i, 'MCHC'};

    [ok, msg] = valida_emocromo(sesso, hgb, rbc, wbc, plt, mcv, mch, mchc);
    if ~ok
        warning('Riga %d scartata: %s', i, msg);
        continue;
    end

    hct = rbc * mcv / 10;

    [esito, anomaliaPerc, dettagli] = diagnostica_emocromo(sesso, hgb, wbc, plt, mcv, mch, mchc);

    codicePaziente = sprintf('PAZ_%03d', i);
    sqlPaz = sprintf("INSERT INTO PAZIENTE (Codice, Data_Nascita, Sesso) VALUES ('%s', '%s', '%s');", ...
        codicePaziente, dataNascita, sesso);
    exec(conn, sqlPaz);

    resultPaziente = fetch(conn, "SELECT last_insert_rowid();");
    idPaziente = resultPaziente{1, 1};

    sqlEsame = sprintf("INSERT INTO ESAME_EMOCROMO (ID_Paziente, RBC, HGB, HCT, WBC, PLT, MCV, MCH, MCHC) VALUES (%d, %.2f, %.2f, %.2f, %.0f, %.0f, %.2f, %.2f, %.2f);", ...
        idPaziente, rbc, hgb, hct, wbc, plt, mcv, mch, mchc);
    exec(conn, sqlEsame);

    resultEsame = fetch(conn, "SELECT last_insert_rowid();");
    idEsame = resultEsame{1, 1};

    sqlRef = sprintf("INSERT INTO REFERTO_ANALISI (ID_Esame, Esito_Diagnostico, Indice_Anomalia_Perc) VALUES (%d, '%s', %.1f);", ...
        idEsame, esito, anomaliaPerc);
    exec(conn, sqlRef);
end

close(conn);

disp('----------------------------------------------------');
disp(' Database popolato correttamente! ');
disp('----------------------------------------------------');

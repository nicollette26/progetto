% Script per popolare il Database emocromo.db dal file CSV
nomeFile = 'blood_count_dataset.csv';
if ~exist(nomeFile, 'file')
    error('File %s non trovato! Controlla di averlo messo nella cartella progetto.', nomeFile);
end

dataset = readtable(nomeFile);
dataset = unique(dataset, 'rows');

conn = sqlite('emocromo.db');

exec(conn, 'DELETE FROM REFERTO_ANALISI;');
exec(conn, 'DELETE FROM ESAME_EMOCROMO;');
exec(conn, 'DELETE FROM PAZIENTE;');

exec(conn, 'DELETE FROM sqlite_sequence WHERE name="PAZIENTE";');
exec(conn, 'DELETE FROM sqlite_sequence WHERE name="ESAME_EMOCROMO";');
exec(conn, 'DELETE FROM sqlite_sequence WHERE name="REFERTO_ANALISI";');

disp('Database pulito. Inizio inserimento dei dati...');

for i = 1:height(dataset)

    % Eta
    eta = dataset{i, 'Age'};

    % Data di nascita approssimativa dall'eta
    annoCorrente = year(datetime('now'));
    annoNascita = annoCorrente - eta;
    dataNascita = sprintf('%d-01-01', annoNascita);

    % Sesso
    sessoRaw = lower(string(dataset{i, 'Gender'}));
    if sessoRaw == "male"
        sesso = 'M';
    elseif sessoRaw == "female"
        sesso = 'F';
    else
        sesso = 'F'; % default prudente
    end

    % Valori dell'emocromo
    hgb = dataset{i, 'Hemoglobin'};
    rbc = dataset{i, 'Red_Blood_Cells'};
    wbc = dataset{i, 'White_Blood_Cells'};
    plt = dataset{i, 'Platelet_Count'};
    mcv = dataset{i, 'MCV'};
    mch = dataset{i, 'MCH'};
    mchc = dataset{i, 'MCHC'};
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

% Script per popolare il Database emocromo.db dal file CSV

% 1. Verifica esistenza del file CSV
nomeFile = 'blood_count_dataset.csv';
if ~exist(nomeFile, 'file')
    error('File %s non trovato! Controlla di averlo messo nella cartella progetto.', nomeFile);
end

dataset = readtable(nomeFile);

% 2. Connessione al database SQLite
conn = sqlite('emocromo.db');

% 3. Pulizia tabelle esistenti
exec(conn, 'DELETE FROM REFERTO_ANALISI;');
exec(conn, 'DELETE FROM ESAME_EMOCROMO;');
exec(conn, 'DELETE FROM PAZIENTE;');

% Reset dei contatori autoincrement
exec(conn, 'DELETE FROM sqlite_sequence WHERE name="PAZIENTE";');
exec(conn, 'DELETE FROM sqlite_sequence WHERE name="ESAME_EMOCROMO";');
exec(conn, 'DELETE FROM sqlite_sequence WHERE name="REFERTO_ANALISI";');

disp('Database pulito. Inizio inserimento dei dati...'); %[output:3a693eda]

% 4. Ciclaggio su ogni riga del dataset
for i = 1:height(dataset)
    % CORREZIONE: Accedi correttamente ai dati con (i, 'NomeColonna')
    eta = dataset{i, 'Age'};
    
    % Calcolo data di nascita approssimativa dall'età per evitare valori NULL
    % CORREZIONE: Usa l'anno corrente invece di 2026
    annoCorrente = year(datetime('now'));
    annoNascita = annoCorrente - eta;
    dataNascita = sprintf('%d-01-01', annoNascita);
    
    % Gestione genere ('Male'/'Female' convertiti in 'M'/'F')
    sessoRaw = lower(string(dataset{i, 'Gender'}));
    if sessoRaw == "male"
        sesso = 'M';
    elseif sessoRaw == "female"
        sesso = 'F';
    else
        sesso = 'F'; % default
    end
    
    % Valori dell'emocromo - CORREZIONE: Usa accesso sicuro
    hgb = dataset{i, 'Hemoglobin'};
    rbc = dataset{i, 'Red_Blood_Cells'};
    wbc = dataset{i, 'White_Blood_Cells'};
    plt = dataset{i, 'Platelet_Count'};
    mcv = dataset{i, 'MCV'};
    mch = dataset{i, 'MCH'};
    mchc = dataset{i, 'MCHC'};
    
    % Calcolo HCT approssimato
    hct = rbc * 3.1;
    
    % Logica diagnostica
    esito = "Valori nella Norma";
    anomaliaPerc = 0.0;
    
    if (sesso == 'F' && hgb < 12.0) || (sesso == 'M' && hgb < 13.5)
        if mcv < 80
            esito = "Anemia Microcitica";
        else
            esito = "Anemia Normocitica";
        end
        anomaliaPerc = 25.0;
    elseif wbc > 11000 || wbc < 4000
        esito = "Anomalia Globuli Bianchi";
        anomaliaPerc = 30.0;
    elseif plt < 150000
        esito = "Piastrinopenia";
        anomaliaPerc = 20.0;
    end
    
    % Inserimento Paziente (inclusa la Data_Nascita)
    codicePaziente = sprintf('PAZ_%03d', i);
    sqlPaz = sprintf("INSERT INTO PAZIENTE (Codice, Data_Nascita, Sesso) VALUES ('%s', '%s', '%s');", ...
        codicePaziente, dataNascita, sesso);
    exec(conn, sqlPaz);
    
    % CORREZIONE: Recupera l'ID reale del paziente appena inserito
    resultPaziente = fetch(conn, "SELECT last_insert_rowid();");
    idPaziente = resultPaziente{1, 1}; % Estrai il valore dalla cell
    
    % Inserimento Esame - CORREZIONE: Usa idPaziente, non i
    sqlEsame = sprintf("INSERT INTO ESAME_EMOCROMO (ID_Paziente, RBC, HGB, HCT, WBC, PLT, MCV, MCH, MCHC) VALUES (%d, %.2f, %.2f, %.2f, %.0f, %.0f, %.2f, %.2f, %.2f);", ...
        idPaziente, rbc, hgb, hct, wbc, plt, mcv, mch, mchc);
    exec(conn, sqlEsame);
    
    % CORREZIONE: Recupera l'ID reale dell'esame appena inserito
    resultEsame = fetch(conn, "SELECT last_insert_rowid();");
    idEsame = resultEsame{1, 1}; % Estrai il valore dalla cell
    
    % Inserimento Referto - CORREZIONE: Usa idEsame, non i
    sqlRef = sprintf("INSERT INTO REFERTO_ANALISI (ID_Esame, Esito_Diagnostico, Indice_Anomalia_Perc) VALUES (%d, '%s', %.1f);", ...
        idEsame, esito, anomaliaPerc);
    exec(conn, sqlRef);
end

close(conn);

disp('----------------------------------------------------'); 
disp(' Database popolato correttamente senza valori NULL! '); 
disp('----------------------------------------------------');




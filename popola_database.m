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
    eta = dataset.Age(i);
    
    % Calcolo data di nascita approssimativa dall'età per evitare valori NULL
    annoNascita = 2026 - eta;
    dataNascita = sprintf('%d-01-01', annoNascita);
    
    % Gestione genere ('Male'/'Female' convertiti in 'M'/'F')
    sessoRaw = string(dataset.Gender{i});
    if sessoRaw == "Male"
        sesso = 'M';
    else
        sesso = 'F';
    end
    
    % Valori dell'emocromo
    hgb = dataset.Hemoglobin(i);
    rbc = dataset.Red_Blood_Cells(i);
    wbc = dataset.White_Blood_Cells(i);
    plt = dataset.Platelet_Count(i);
    mcv = dataset.MCV(i);
    mch = dataset.MCH(i);
    mchc = dataset.MCHC(i);
    
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
    
    % Inserimento Esame
    sqlEsame = sprintf("INSERT INTO ESAME_EMOCROMO (ID_Paziente, RBC, HGB, HCT, WBC, PLT, MCV, MCH, MCHC) VALUES (%d, %.2f, %.2f, %.2f, %.0f, %.0f, %.2f, %.2f, %.2f);", ...
        i, rbc, hgb, hct, wbc, plt, mcv, mch, mchc);
    exec(conn, sqlEsame);
    
    % Inserimento Referto
    sqlRef = sprintf("INSERT INTO REFERTO_ANALISI (ID_Esame, Esito_Diagnostico, Indice_Anomalia_Perc) VALUES (%d, '%s', %.1f);", ...
        i, esito, anomaliaPerc);
    exec(conn, sqlRef);
end

close(conn);

disp('----------------------------------------------------'); %[output:4268f338]
disp(' Database popolato correttamente senza valori NULL! '); %[output:9241fbdf]
disp('----------------------------------------------------'); %[output:0f636ce8]

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright"}
%---
%[output:3a693eda]
%   data: {"dataType":"text","outputData":{"text":"Database pulito. Inizio inserimento dei dati...\n","truncated":false}}
%---
%[output:4268f338]
%   data: {"dataType":"text","outputData":{"text":"----------------------------------------------------\n","truncated":false}}
%---
%[output:9241fbdf]
%   data: {"dataType":"text","outputData":{"text":" Database popolato correttamente senza valori NULL! \n","truncated":false}}
%---
%[output:0f636ce8]
%   data: {"dataType":"text","outputData":{"text":"----------------------------------------------------\n","truncated":false}}
%---

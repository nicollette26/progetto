% Script per la creazione del Database SQLite 'emocromo.db'
function crea_database(dbPath)

    if nargin < 1 || isempty(dbPath)
        dbPath = fullfile(prefdir, 'emocromo.db');
    end

    [dbFolder, ~, ~] = fileparts(dbPath);
    if ~isempty(dbFolder) && ~isfolder(dbFolder)
        mkdir(dbFolder);
    end

    conn = [];

try
    if isfile(dbPath)
        conn = sqlite(dbPath);
    else
        conn = sqlite(dbPath, "create");
    end

    exec(conn, 'PRAGMA foreign_keys = ON;');

    sqlPaziente = ['CREATE TABLE IF NOT EXISTS PAZIENTE (' ...
        'ID_Paziente INTEGER PRIMARY KEY AUTOINCREMENT, ' ...
        'Codice VARCHAR(20) NOT NULL UNIQUE, ' ...
        'Data_Nascita DATE, ' ...
        'Sesso CHAR(1) CHECK (Sesso IN (''M'', ''F''))' ...
        ');'];
    exec(conn, sqlPaziente);

    exec(conn, 'CREATE INDEX IF NOT EXISTS idx_paziente_codice ON PAZIENTE(Codice);');

    sqlEsame = ['CREATE TABLE IF NOT EXISTS ESAME_EMOCROMO (' ...
        'ID_Esame INTEGER PRIMARY KEY AUTOINCREMENT, ' ...
        'ID_Paziente INTEGER NOT NULL, ' ...
        'Data_Esame DATE DEFAULT CURRENT_DATE, ' ...
        'RBC REAL CHECK (RBC > 0 AND RBC < 10), ' ...
        'HGB REAL CHECK (HGB > 0 AND HGB < 25), ' ...
        'HCT REAL CHECK (HCT > 0 AND HCT < 70), ' ...
        'WBC REAL CHECK (WBC > 0 AND WBC < 50000), ' ...
        'PLT REAL CHECK (PLT > 0 AND PLT < 1000000), ' ...
        'MCV REAL CHECK (MCV > 0 AND MCV < 200), ' ...
        'MCH REAL CHECK (MCH > 0 AND MCH < 60), ' ...
        'MCHC REAL CHECK (MCHC > 0 AND MCHC < 60), ' ...
        'FOREIGN KEY (ID_Paziente) REFERENCES PAZIENTE(ID_Paziente) ON DELETE CASCADE' ...
        ');'];
    exec(conn, sqlEsame);

    exec(conn, 'CREATE INDEX IF NOT EXISTS idx_esame_paziente ON ESAME_EMOCROMO(ID_Paziente);');

    sqlReferto = ['CREATE TABLE IF NOT EXISTS REFERTO_ANALISI (' ...
        'ID_Referto INTEGER PRIMARY KEY AUTOINCREMENT, ' ...
        'ID_Esame INTEGER UNIQUE NOT NULL, ' ...
        'Esito_Diagnostico TEXT NOT NULL, ' ...
        'Indice_Anomalia_Perc REAL, ' ...
        'Data_Referto DATE DEFAULT CURRENT_DATE, ' ...
        'FOREIGN KEY (ID_Esame) REFERENCES ESAME_EMOCROMO(ID_Esame) ON DELETE CASCADE' ...
        ');'];
    exec(conn, sqlReferto);

    exec(conn, 'CREATE INDEX IF NOT EXISTS idx_referto_esame ON REFERTO_ANALISI(ID_Esame);');

    close(conn);

    disp('----------------------------------------------------');
    disp(' Database "emocromo.db" creato con successo! ');
    disp('----------------------------------------------------');

catch ME
    if ~isempty(conn)
            try
                close(conn);
            catch
                % La connessione potrebbe non essere stata aperta
            end
    end
    disp('----------------------------------------------------');
    disp('ERRORE nella creazione del database:');
    disp(ME.message);
    disp('----------------------------------------------------');

    rethrow(ME);
end
end

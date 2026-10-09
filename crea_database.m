% Script per la creazione del Database SQLite 'emocromo.db'

try
    % 1. Connessione / Creazione del file di database
    conn = sqlite('emocromo.db','connect');
    
    % 2. Abilita i vincoli sulle chiavi esterne (Foreign Keys)
    exec(conn, 'PRAGMA foreign_keys = ON;');
    
    % 3. Creazione Tabella PAZIENTE
    sqlPaziente = ['CREATE TABLE IF NOT EXISTS PAZIENTE (' ...
        'ID_Paziente INTEGER PRIMARY KEY AUTOINCREMENT, ' ...
        'Codice VARCHAR(20) NOT NULL UNIQUE, ' ...
        'Data_Nascita DATE, ' ...
        'Sesso CHAR(1) CHECK (Sesso IN (''M'', ''F''))' ...
        ');'];
    exec(conn, sqlPaziente);
    
    % Crea indice su Codice per ricerche più veloci
    exec(conn, 'CREATE INDEX IF NOT EXISTS idx_paziente_codice ON PAZIENTE(Codice);');
    
    % 4. Creazione Tabella ESAME_EMOCROMO
    sqlEsame = ['CREATE TABLE IF NOT EXISTS ESAME_EMOCROMO (' ...
        'ID_Esame INTEGER PRIMARY KEY AUTOINCREMENT, ' ...
        'ID_Paziente INTEGER NOT NULL, ' ...
        'Data_Esame DATE DEFAULT CURRENT_DATE, ' ...
        'RBC REAL, HGB REAL, HCT REAL, WBC REAL, ' ...
        'PLT REAL, MCV REAL, MCH REAL, MCHC REAL, ' ...
        'FOREIGN KEY (ID_Paziente) REFERENCES PAZIENTE(ID_Paziente) ON DELETE CASCADE' ...
        ');'];
    exec(conn, sqlEsame);
    
    % Crea indice su ID_Paziente per join più veloci
    exec(conn, 'CREATE INDEX IF NOT EXISTS idx_esame_paziente ON ESAME_EMOCROMO(ID_Paziente);');
    
    % 5. Creazione Tabella REFERTO_ANALISI
    sqlReferto = ['CREATE TABLE IF NOT EXISTS REFERTO_ANALISI (' ...
        'ID_Referto INTEGER PRIMARY KEY AUTOINCREMENT, ' ...
        'ID_Esame INTEGER UNIQUE NOT NULL, ' ...
        'Esito_Diagnostico TEXT NOT NULL, ' ...
        'Indice_Anomalia_Perc REAL, ' ...
        'Data_Referto DATE DEFAULT CURRENT_DATE, ' ...
        'FOREIGN KEY (ID_Esame) REFERENCES ESAME_EMOCROMO(ID_Esame) ON DELETE CASCADE' ...
        ');'];
    exec(conn, sqlReferto);
    
    % Crea indice su ID_Esame per join più veloci
    exec(conn, 'CREATE INDEX IF NOT EXISTS idx_referto_esame ON REFERTO_ANALISI(ID_Esame);');
    
    % 6. Chiusura della connessione
    close(conn);
    
    disp('----------------------------------------------------');
    disp(' Database "emocromo.db" creato con successo! ');
    disp('----------------------------------------------------');
    
catch ME
    % Gestione degli errori
    disp('----------------------------------------------------');
    disp('ERRORE nella creazione del database:');
    disp(ME.message);
    disp('----------------------------------------------------');
    if ~isempty(conn) && isa(conn, 'sqlite')
        close(conn);
    end
end

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright","rightPanelPercent":45.5}
%---

# Progetto Elaborato Biomedico
# EmocromoAnalyzer - Gestione & Analisi Emocromo

**EmocromoAnalyzer** è un'applicazione desktop sviluppata in MATLAB App Designer integrata con un database relazionale **SQLite**. L'obiettivo del progetto è automatizzare l'analisi dei parametri dell'esame emocromocitometrico, calcolare una diagnosi clinica preliminare e gestire lo storico dei pazienti. La logica dell'algoritmo si basa sul fatto che l'emocromo è un primo indicatore chiave riconosciuto dalla letteratura scientifica anche per valutare la gravità di patologie sistemiche e virali.

---

## Funzionalità Principali

* **Input : Dati Paziente & Esame:** Inserimento parametri clinici (Sesso, HGB, RBC, WBC, PLT, MCV).
  - HGB (Emoglobina): È la proteina contenuta nei globuli rossi che trasporta l'ossigeno dai polmoni a tutti i tessuti del corpo.
  - RBC (Globuli Rossi / Eritrociti): Indica il numero totale di globuli rossi presenti nel sangue. Sono le cellule responsabili del trasporto di ossigeno ed          anidride carbonica.
  - WBC (Globuli Bianchi / Leucociti): Rappresenta il numero totale di cellule del sistema immunitario nel sangue. Difendono l'organismo da infezioni (batteriche,     virali, ecc.), infiammazioni e altre reazioni immunitarie.
  - PLT (Piastrine / Trombociti): Indica il numero di piastrine, cellule fondamentali per la coagulazione del sangue e la riparazione dei vasi sanguigni in caso       di ferite o emorragie.
  - MCV (Volume Corpuscolare Medio): Misura la dimensione media dei singoli globuli rossi. È un parametro utile per distinguere i vari tipi di anemia (esempio: un     MCV basso indica globuli rossi piccoli, tipici della carenza di ferro, mentre un MCV alto indica globuli rossi grandi, tipici della carenza di vitamina B12 o      acido folico).
* **Diagnosi Automatica:** Algoritmo integrato per il rilevamento di anomalie (Anemia, Piastrinopenia, Anomalia Leucocitaria).
  - L'anemia: la quantità di emoglobina (HGB) o il numero di globuli rossi (RBC) è inferiore ai valori di norma
  - La piastrinopenia: il numero di piastrine (PLT) scende sotto i livelli normali
  - Anomalia Leucocitaria (WBC): un'alterazione sia quantitativa (troppi o troppo pochi) che qualitativa (cellule di forma o funzionamento anomalo) dei globuli        bianchi (WBC) o di una delle sue sottocategorie (neutrofili, linfociti, monociti, eosinofili, basofili).
* **Visualizzazione Grafica Avanzata:** Grafico a barre interattivo su `UIAxes` con normalizzazione percentuale dei parametri e linea guida di riferimento al 100%.
* **Integrazione SQLite:** Salvataggio coordinato su 3 tabelle relazionali (`PAZIENTE`, `ESAME_EMOCROMO`, `REFERTO_ANALISI`).
* **Storico Dinamico:** Visualizzazione immediata nella `UITable` degli ultimi pazienti inseriti tramite query `LEFT JOIN` e gestione dei valori nulli (`COALESCE`).

---

## Architettura del Database SQLite (`emocromo.db`)

Il database relazionale è composto da tre tabelle collegate tramite chiavi esterne (`FOREIGN KEY`):

1. **`PAZIENTE`**: Contiene l'anagrafica (`ID_Paziente`, `Codice`, `Data_Nascita`, `Sesso`).
2. **`ESAME_EMOCROMO`**: Registra i valori di laboratorio (`ID_Esame`, `ID_Paziente`, `RBC`, `HGB`, `HCT`, `WBC`, `PLT`, `MCV`, `MCH`, `MCHC`).
3. **`REFERTO_ANALISI`**: Memorizza l'esito diagnostico (`ID_Referto`, `ID_Esame`, `Esito_Diagnostico`, `Indice_Anomalia_Perc`).

* ## 🗄️ Schema del Database (Diagramma ER)

```mermaid
erDiagram
    PAZIENTE ||--o{ ESAME_EMOCROMO : "effettua"
    ESAME_EMOCROMO ||--|| REFERTO_ANALISI : "genera"

    PAZIENTE {
        INTEGER ID_Paziente PK
        TEXT Codice
        TEXT Data_Nascita
        TEXT Sesso
    }

    ESAME_EMOCROMO {
        INTEGER ID_Esame PK
        INTEGER ID_Paziente FK
        TEXT Data_Esame
        REAL RBC
        REAL HGB
        REAL HCT
        REAL WBC
        REAL PLT
        REAL MCV
        REAL MCH
        REAL MCHC
    }

    REFERTO_ANALISI {
        INTEGER ID_Referto PK
        INTEGER ID_Esame FK
        TEXT Esito_Diagnostico
        REAL Indice_Anomalia_Perc
        TEXT Data_Referto
    }
---

## Come eseguire il Progetto

### Requisiti Software
* **MATLAB** (versione R2020b o successiva)
* **MATLAB Database Toolbox** (supporto nativo `sqlite`)
* **VS Code** (opzionale, consigliato con estensione `vscode-sqlite` per la gestione del repository)

### Istruzioni per l'Avvio


### Background Scientifico e Riferimenti
Tramite i link forniti mi sono documentata sull'alterazione dei parametri dell'emocromo in relazione alla rilevanza delle infezioni virali, ritrovando un articolo sullo studio e l'analisi dell'emocromo completo durante l'infezione da Covid-19 in cui i pazienti venivano classificati in lievi, moderati, gravi e diversi parametri ematologici sono stati descritti come associati all'infezione da Covid-19 e alla sua gravità.

> "Reconstitution of lymphocytes may be an important factor for recovery (33). Low lymphocyte count might be used by clinicians in risk stratification to             predict severe and fatal COVID-19 in hospitalized patient"
* **Sito consultato PubMed**: "Complete blood count alterations in COVID-19 patients" -> https://pmc.ncbi.nlm.nih.gov/articles/PMC8495616/


Inoltre l'algoritmo di diagnosi dell'emocromo si inserisce nel contesto della ricerca ematologica moderna, dove lo studio dell'invecchiamento del midollo osseo e della senescenza cellulare spiega l'insorgenza di patologie come l'anemia e le alterazioni emopoietiche. 
Sempre tramite un altro link fornito, ho approfondito un bioprogetto riguardante l'eliminazione farmacologica delle cellule senescenti che attenua l'invecchiamento del midollo osseo. Lo studio evidenzia come la compromissione delle cellule staminali ematopoietiche (HSC) e del microambiente midollare aumenti la predisposizione ad anemia e infezioni, i cui parametri chiave (HGB, RBC, WBC) vengono analizzati e monitorati dal software 'EmocromoAnalyzer'.
* **Sito consultato NCBI**: "Nucleolar dysfunction-mediated leakage of DNA-RNA hybrids primes the innate immune response and is implicated in the inflammation underlying Diamond-Blackfan Anemia" -> https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE316278



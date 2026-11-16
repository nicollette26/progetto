function dataset = prepara_dataset(nomeFile)
    projectDir = fileparts(mfilename('fullpath'));

    if nargin < 1 || isempty(nomeFile)
        nomeFile = fullfile(projectDir, 'blood_count_dataset_clean.csv');
    elseif ~isfile(nomeFile)
       
        nomeFile = fullfile(projectDir, nomeFile);
    end

    if ~isfile(nomeFile)
        error('Dataset non trovato: %s', nomeFile);
    end

    dataset = readtable(nomeFile);

    requiredCols = {'Age', 'Gender', 'Hemoglobin', 'Platelet_Count', ...
                    'White_Blood_Cells', 'Red_Blood_Cells', 'MCV', 'MCH', 'MCHC'};
    missingCols = setdiff(requiredCols, dataset.Properties.VariableNames);

    if ~isempty(missingCols)
        error('Colonne mancanti nel dataset: %s', strjoin(missingCols, ', '));
    end

    dataset = unique(dataset, 'rows');

    valid = true(height(dataset), 1);

    for i = 1:height(dataset)
        hgb = dataset{i, 'Hemoglobin'};
        rbc = dataset{i, 'Red_Blood_Cells'};
        wbc = dataset{i, 'White_Blood_Cells'};
        plt = dataset{i, 'Platelet_Count'};
        mcv = dataset{i, 'MCV'};
        mch = dataset{i, 'MCH'};
        mchc = dataset{i, 'MCHC'};
        age = dataset{i, 'Age'};

        if isempty(hgb) || isempty(rbc) || isempty(wbc) || isempty(plt) || isempty(mcv) || isempty(mch) || isempty(mchc) || isempty(age)
            valid(i) = false;
            continue;
        end

        vals = [hgb, rbc, wbc, plt, mcv, mch, mchc];
        if any(~isfinite(vals)) || any(vals <= 0)
            valid(i) = false;
            continue;
        end
    end

    dataset = dataset(valid, :);

    if height(dataset) > 0
        wbcStd = std(table2array(dataset(:, "White_Blood_Cells")));
        pltStd = std(table2array(dataset(:, "Platelet_Count")));

        if wbcStd < 500
            warning('Dataset troppo poco vario in WBC: considerare un dataset più realistico.');
        end

        if pltStd < 20000
            warning('Dataset troppo poco vario in PLT: considerare un dataset più realistico.');
        end
    end
end

%[appendix]{"version":"1.0"}
%---

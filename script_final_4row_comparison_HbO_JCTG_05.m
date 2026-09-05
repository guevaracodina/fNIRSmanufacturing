%% fNIRS Connectivity Professional Report (4x3 Matrix)
% Comparison: Resting vs Low, Resting vs High, Low vs High
% Metrics: Z-score, p-value, q-value (FDR), T-statistic

clear; clc; close all;

% 1. Cargar datos
load('..\Data\workload_all_significant_connections_HbO.mat');

% 2. Preparar Matrices
R = cat(3, resting_workload.rMatFDR{:});
E = cat(3, easy_workload.rMatFDR{:});
H = cat(3, hard_workload.rMatFDR{:});

groups = {R, E, H};
groupNames = {'Resting', 'Low', 'High'};
comparisons = {[2,1], [3,1], [3,2]}; 
compTitles = {'Low vs Resting', 'High vs Resting', 'High vs Low'};

nCh = size(R, 1);
nComp = length(comparisons);

% 3. Cálculos Estadísticos
zMeans = cell(1,3);
tStats = cell(1,nComp);
pVals  = cell(1,nComp);
qVals  = cell(1,nComp);

for g = 1:3
    zMeans{g} = nanmean(groups{g}, 3);
end

for c = 1:nComp
    idx1 = comparisons{c}(1); idx2 = comparisons{c}(2);
    T_temp = zeros(nCh); P_temp = ones(nCh);
    for i = 1:nCh
        for j = i+1:nCh
            v1 = squeeze(groups{idx1}(i,j,:)); 
            v2 = squeeze(groups{idx2}(i,j,:));
            valid = ~isnan(v1) & ~isnan(v2);
            if sum(valid) > 10
                [~, p, ~, stats] = ttest(v1(valid), v2(valid));
                T_temp(i,j) = stats.tstat; P_temp(i,j) = p;
                T_temp(j,i) = T_temp(i,j); P_temp(j,i) = P_temp(i,j);
            end
        end
    end
    tStats{c} = T_temp;
    pVals{c} = P_temp;
    
    % Corrección FDR
    pVec = P_temp(triu(true(nCh),1));
    [~, ~, ~, qVec] = fdr_bh(pVec, 0.05, 'pdep', 'no');
    Q_temp = ones(nCh);
    Q_temp(triu(true(nCh),1)) = qVec;
    qVals{c} = Q_temp + Q_temp'; 
end

% 4. Graficado Ajustado y Unificado
fig = figure('Color', 'w', 'Units', 'inches', 'Position', [0.5, 0.5, 16, 19]);

% Colormap RdBu personalizado (Azul - Blanco - Rojo)
cmap_rdbu = [linspace(0,1,128)', linspace(0.4,1,128)', ones(128,1); ...
             ones(128,1), linspace(1,0.4,128)', linspace(1,0,128)'];

% --- FILA 1: Z-SCORES INDIVIDUALES (Resting, Low, High) ---
for g = 1:3
    subplot(4, 3, g);
    imagesc(zMeans{g}); axis square; colormap(gca, jet);
    caxis([0 1]); 
    cb = colorbar;
    set(cb, 'FontName', 'Arial', 'FontSize', 12, 'FontWeight', 'bold');
    
    ylabel('z-score', 'FontName', 'Arial', 'FontSize', 16, 'FontWeight', 'bold');
    title(groupNames{g}, 'FontName', 'Arial', 'FontSize', 18, 'FontWeight', 'bold');
    set(gca, 'FontName', 'Arial', 'FontSize', 14, 'FontWeight', 'bold', 'LineWidth', 1.2);
end

% --- FILAS 2, 3 y 4: COMPARACIONES ESTADÍSTICAS ---
for c = 1:nComp
    % --- FILA 2: -log10(p) ---
    subplot(4, 3, c + 3);
    imagesc(-log10(pVals{c})); axis square; colormap(gca, hot);
    caxis([0 3]); 
    cb = colorbar;
    set(cb, 'FontName', 'Arial', 'FontSize', 12, 'FontWeight', 'bold');
    
    ylabel('-log_{10}(p)', 'FontName', 'Arial', 'FontSize', 16, 'FontWeight', 'bold');
    title(compTitles{c}, 'FontName', 'Arial', 'FontSize', 18, 'FontWeight', 'bold');
    set(gca, 'FontName', 'Arial', 'FontSize', 14, 'FontWeight', 'bold', 'LineWidth', 1.2);

    % --- FILA 3: -log10(q) (FDR) ---
    subplot(4, 3, c + 6);
    imagesc(-log10(qVals{c})); axis square; colormap(gca, hot);
    caxis([0 2]); 
    cb = colorbar;
    set(cb, 'FontName', 'Arial', 'FontSize', 12, 'FontWeight', 'bold');
    
    ylabel('-log_{10}(q)', 'FontName', 'Arial', 'FontSize', 16, 'FontWeight', 'bold');
    title(compTitles{c}, 'FontName', 'Arial', 'FontSize', 18, 'FontWeight', 'bold');
    set(gca, 'FontName', 'Arial', 'FontSize', 14, 'FontWeight', 'bold', 'LineWidth', 1.2);

    % --- FILA 4: t-statistic ---
    subplot(4, 3, c + 9);
    imagesc(tStats{c}); axis square; colormap(gca, cmap_rdbu);
    caxis([-4 4]); 
    cb = colorbar;
    set(cb, 'FontName', 'Arial', 'FontSize', 12, 'FontWeight', 'bold');
    
    ylabel('t-statistic', 'FontName', 'Arial', 'FontSize', 16, 'FontWeight', 'bold');
    xlabel('Channel ID', 'FontName', 'Arial', 'FontSize', 16, 'FontWeight', 'bold');
    title(compTitles{c}, 'FontName', 'Arial', 'FontSize', 18, 'FontWeight', 'bold');
    set(gca, 'FontName', 'Arial', 'FontSize', 14, 'FontWeight', 'bold', 'LineWidth', 1.2);
end

% Guardar a 900 DPI
print(fig, '..\Data\Results\Final_4Row_PerfectMatch.png', '-dpng', '-r900');
disp('Proceso completado con éxito.');
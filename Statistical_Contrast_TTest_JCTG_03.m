%% Script 3 Modificado: Diferencia Cualitativa y Mapa T Completo
% Juan Carlos Torres - Análisis de Tendencias

clear; clc; close all;
load('..\Data\workload_all_significant_connections_HbO.mat');

% 1. Promedios Reales
get_avg = @(cellData) nanmean(cat(3, cellData{:}), 3);
avg_R = get_avg(resting_workload.rMatFDR);
avg_H = get_avg(hard_workload.rMatFDR);

% 2. Diferencia Directa (Cualitativa)
diff_map = avg_H - avg_R;

% 3. Cálculo de T-Stats (Sin máscara de p-value para ver todo)
matR = cat(3, resting_workload.rMatFDR{:});
matH = cat(3, hard_workload.rMatFDR{:});
[nCh, ~, nSub] = size(matR);
tStats = zeros(nCh, nCh);

for i = 1:nCh
    for j = i+1:nCh
        [~, ~, ~, stats] = ttest(squeeze(matH(i,j,:)), squeeze(matR(i,j,:)));
        tStats(i,j) = stats.tstat;
        tStats(j,i) = stats.tstat;
    end
end

% 4. Graficado de Tendencias
figure('Color', 'w', 'Units', 'inches', 'Position', [1, 1, 14, 6]);

% Subplot 1: Diferencia de Correlación
subplot(1,2,1);
imagesc(diff_map); axis square; colormap(jet); colorbar;
caxis([-0.2 0.2]); % Escala sensible para ver pequeños cambios
title({'Direct Difference','(High- Resting)'}, 'FontSize', 24);

% Subplot 2: Mapa T Completo (Sin filtro p < 0.05)
subplot(1,2,2);
imagesc(tStats); axis square; colormap(jet); colorbar;
caxis([-2.5 2.5]); % Valores T de tendencia
title({'T-Statistic Map','(Unfiltered Tendency)'}, 'FontSize', 24);

% Estética (Líneas gruesas y texto grande)
for i=1:2
    subplot(1,2,i);
    set(gca, 'FontSize', 14, 'FontWeight', 'bold', 'LineWidth', 4);
    mid = nCh/2 + 0.5;
    line([mid mid], [0.5 nCh+0.5], 'Color', 'w', 'LineStyle', '--', 'LineWidth', 5);
    line([0.5 nCh+0.5], [mid mid], 'Color', 'w', 'LineStyle', '--', 'LineWidth', 5);
end

% Guardar a 900 DPI en la carpeta de resultados
print(gcf, '..\Data\Results\Trend_Analysis_HbO_900dpi.png', '-dpng', '-r900');
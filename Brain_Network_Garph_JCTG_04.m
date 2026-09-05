%% Unified Brain Network Graph (Load, Calculate, & Plot)
% Goal: Create 900 DPI Graph of Hard > Resting (HbO)
% Optimized for noisy/workload data

clear; clc; close all;

% 1. Configuración de Entrada y Salida
resultsDir = '..\Data\Results\';
if ~exist(resultsDir, 'dir'), mkdir(resultsDir); end
savePath = fullfile(resultsDir, 'Brain_Network_Map_HbO_Unificado_900dpi.png');

% 2. Carga Directa de los Resultados de Script 1
% Este archivo DEBE contener rMat_resting y rMat_hard (SujetosxChxCh)
try
    fprintf('Cargando datos de HbO...\n');
    load('..\Data\workload_all_significant_connections_HbO.mat'); 
catch
    error('No se encontró el archivo .mat de HbO. Asegúrate de que Script 1 se ejecutó.');
end

% 3. CÁLCULO DIRECTO DEL T-TEST (Blindaje de variables)
% rMatFDR es una celda {1,30}. Primero la convertimos a matriz 3D.
matResting = cat(3, resting_workload.rMatFDR{:});
matHard    = cat(3, hard_workload.rMatFDR{:});

[nCh, ~, nSub] = size(matResting);
tStats = zeros(nCh, nCh); pValues = ones(nCh, nCh);

fprintf('Calculando T-Tests canal por canal (N=%d sujetos)...\n', nSub);

for i = 1:nCh
    for j = i+1:nCh
        % Extraemos valores para todos los sujetos para este par
        valResting = squeeze(matResting(i, j, :));
        valHard    = squeeze(matHard(i, j, :));
        
        % Eliminamos NaNs (sujetos saltados)
        validIdx = ~isnan(valResting) & ~isnan(valHard);
        
        if sum(validIdx) > nSub/2 % Al menos 50% de sujetos
            [~, p, ~, stats] = ttest(valHard(validIdx), valResting(validIdx));
            tStats(i,j) = stats.tstat;
            pValues(i,j) = p;
            
            % Espejamos la matriz
            tStats(j,i) = tStats(i,j); pValues(j,i) = pValues(i,j);
        end
    end
end

% 4. Configuración del Graficado (Grafo)
fig = figure('Color', 'w', 'Units', 'inches', 'Position', [1, 1, 12, 12]);
hold on;

% --- A. Coordenadas 2D (Reemplaza con tus coordenadas reales si las tienes) ---
% Por defecto, un diseño circular para que se vea el grafo completo
theta = linspace(0, 2*pi, nCh+1); theta(end) = [];
x = cos(theta); y = sin(theta); 

% --- B. Dibujo de la Red (Líneas / Bordes) ---
% UMBRAL DE SIGNIFICANCIA (AJUSTABLE si sale vacío)
alpha_plot = 0.05; % Puedes probar 0.08 si el ruido es muy alto

edgeCounter = 0;
for i = 1:nCh
    for j = i+1:nCh
        % Solo graficamos si es significativo Y si Hard es mayor que Resting
        if pValues(i,j) < alpha_plot && tStats(i,j) > 0
            edgeCounter = edgeCounter + 1;
            
            % Grosor de línea proporcional al T-stat (LineWidth = 3 o más)
            line_w = max(tStats(i,j), 3); % Mínimo 3 ptos
            
            % Línea roja semitransparente (para HD)
            plot([x(i) x(j)], [y(i) y(j)], 'Color', [1 0 0 .5], 'LineWidth', line_w);
        end
    end
end

if edgeCounter == 0
    warning('El grafo salió vacío. Ninguna conexión fue significativa con p < %g.', alpha_plot);
    text(0,0, ['No significant connections (p < ' num2str(alpha_plot) ')'], ...
        'FontSize', 18, 'Color', 'r', 'HorizontalAlignment', 'center');
else
    fprintf('Se graficaron %d conexiones significativas (p < %g).\n', edgeCounter, alpha_plot);
end

% --- C. Dibujo de los Canales (Nodos) ---
scatter(x, y, 900, 'w', 'filled', 'MarkerEdgeColor', 'k', 'LineWidth', 2.5);
for i = 1:nCh
    text(x(i), y(i), num2str(i), 'HorizontalAlignment', 'center', ...
        'FontSize', 16, 'FontWeight', 'bold');
end

% --- D. Estética Final (Inglés) ---
title({'Significant Connectivity Network', ['High Task > Resting State (HbO), p < ' num2str(alpha_plot)]}, ...
    'FontSize', 24, 'FontWeight', 'bold');
axis off; axis equal;

% 5. GUARDAR A 900 DPI (Usa print() para garantizar la resolución)
fprintf('Guardando figura a 900 DPI en %s... Por favor espera.\n', savePath);
print(fig, savePath, '-dpng', '-r900'); 
saveas(gcf, fullfile(resultsDir, 'Brain_Network_Map_HbO_Unificado.fig')); % Copia editable

fprintf('¡Proceso finalizado!\n');
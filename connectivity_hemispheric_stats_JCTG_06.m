%% Intra and Inter-Hemispheric Connectivity Analysis
% Juan Carlos Torres - Análisis de Integración Hemisférica

clear; clc; close all;

outputFolder = 'C:\Universidad\Research Projects\2026 Manufactura\Figures';
if ~exist(outputFolder, 'dir'); mkdir(outputFolder); end

% 1. Definir Canales por Hemisferio 
template_type = 'prefrontal'; % o 'motor'
[LH_idx, RH_idx] = get_channels_from_template(template_type);

% 2. Cargar Datos
try
    load('..\Data\workload_all_significant_connections_HbO.mat');
catch
    error('No se encontró el archivo .mat. Asegúrate de que los datos existan en ..\Data\');
end

R = cat(3, resting_workload.rMatFDR{:});
E = cat(3, easy_workload.rMatFDR{:});
H = cat(3, hard_workload.rMatFDR{:});

groups = {R, E, H};
condNames = {'Resting', 'Low', 'High'};
hemisStats = struct();

for g = 1:3
    data = groups{g}; 
    nSubj = size(data, 3);
    
    intraLH = []; intraRH = []; interH = [];
    
    for s = 1:nSubj
        subjMat = data(:,:,s);
        
        % Extraer conexiones Intra-Hemisféricas 
        matLH = subjMat(LH_idx, LH_idx);
        intraLH(s) = nanmean(matLH(triu(true(size(matLH)),1)));
        
        matRH = subjMat(RH_idx, RH_idx);
        intraRH(s) = nanmean(matRH(triu(true(size(matRH)),1)));
        
        % Extraer conexiones Inter-Hemisféricas (Bloque cruzado LH vs RH)
        matInter = subjMat(LH_idx, RH_idx);
        interH(s) = nanmean(matInter(:));
    end
    
    hemisStats(g).intraLH = intraLH;
    hemisStats(g).intraRH = intraRH;
    hemisStats(g).interH  = interH;
end

% 3. Preparar datos para Graficar
means = []; errs = [];
for g = 1:3
    means(g,:) = [mean(hemisStats(g).intraLH), mean(hemisStats(g).intraRH), mean(hemisStats(g).interH)];
    errs(g,:)  = [std(hemisStats(g).intraLH)/sqrt(nSubj), std(hemisStats(g).intraRH)/sqrt(nSubj), std(hemisStats(g).interH)/sqrt(nSubj)];
end

% 4. Crear Gráfica de Barras Profesional
fig = figure('Color', 'w', 'Name', 'Hemispheric Connectivity');
b = bar(means, 'grouped', 'EdgeColor', 'none');
hold on;

% Estilo de colores
b(1).FaceColor = [0.2 0.4 0.6]; % LH
b(2).FaceColor = [0.8 0.2 0.2]; % RH
b(3).FaceColor = [0.4 0.4 0.4]; % Inter

% Añadir barras de error
[ngroups, nbars] = size(means);
x = nan(nbars, ngroups);
for i = 1:nbars
    x(i,:) = b(i).XEndPoints;
end
errorbar(x', means, errs, 'k', 'linestyle', 'none', 'LineWidth', 3);

% Aumento de letras en ejes y leyenda en Arial Bold
set(gca, 'XTickLabel', condNames, 'FontName', 'Arial', 'FontSize', 20, 'FontWeight', 'bold', 'LineWidth', 1.5);
ylabel('Z-score (Connectivity Strength)', 'FontName', 'Arial', 'FontSize', 22, 'FontWeight', 'bold');
xlabel('Workload Condition', 'FontName', 'Arial', 'FontSize', 22, 'FontWeight', 'bold');

hLeg = legend({'Intra-LH', 'Intra-RH', 'Inter-Hemispheric'}, 'Location', 'northeastoutside');
set(hLeg, 'FontName', 'Arial', 'FontSize', 18, 'FontWeight', 'bold');

title('Connectivity Dynamics by Hemisphere and Workload', 'FontName', 'Arial', 'FontSize', 22, 'FontWeight', 'bold');
grid on; grid minor;

% Guardar a 900 DPI en Figures
savePath = fullfile(outputFolder, 'Intra_Inter_Hemispheric.png');
print(fig, '-dpng', savePath, '-r900');
fprintf('Análisis completado e imagen guardada en: %s\n', savePath);

% --- FUNCIONES AUXILIARES ---
function [chIdxL, chIdxR] = get_channels_from_template(template)
    switch template
        case 'motor'
            chIdxR = [1:2, 4:11];
            chIdxL = [12:13, 15:18, 20, 19, 22, 21];
        case 'prefrontal'
            chIdxR = [1:2, 4:11, 14];
            chIdxL = [23 22 19 17 18 16 21 20 13 12 15];
        otherwise
            error('Template no reconocido');
    end
end
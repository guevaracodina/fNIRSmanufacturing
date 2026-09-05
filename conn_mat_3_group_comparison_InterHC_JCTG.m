function [zMat1Mean,zMat2Mean,zMat3Mean,rMat1Mean,rMat2Mean,rMat3Mean,P_anova,P12,P13,P23] = ...
    conn_mat_3_group_comparison_InterHC(fileGroup1,fileGroup2,fileGroup3,groupNames,saveFileName, ...
                                       chIdxL,chIdxR,group1Color,group2Color,group3Color,alpha)
% Computes inter-hemispheric connectivity at three time-points (same subjects),
% then runs repeated-measures ANOVA and Tukey–Kramer pairwise comparisons.

%% --- CONFIGURACIÓN DE CANALES (REFERENCIA) ---
% Si usas la plantilla MOTOR, los índices que debes pasar al llamar la función son:
% chIdxR = [1, 2, 4, 5, 6, 7, 8, 9, 10, 11];
% chIdxL = [12, 13, 15, 16, 17, 18, 20, 19, 22, 21];
% ----------------------------------------------

%% Load & gather Group 1
load(fileGroup1)  % expects zMatFDR, rMatFDR, keepRun
z1=[]; r1=[];
nRuns = length(zMatFDR); % <--- ESTA LÍNEA DEBE IR AQUÍ
for i=1:nRuns
    if keepRun(i)
        z1=cat(3,z1,zMatFDR{i});
        r1=cat(3,r1,rMatFDR{i}); 
    end
end

%% Load & gather Group 2
% Limpieza de variables temporales para evitar conflictos entre cargas
clearvars -except z1 r1 fileGroup2 fileGroup3 groupNames saveFileName chIdxL chIdxR group1Color group2Color group3Color alpha
load(fileGroup2)
z2=[]; r2=[];
nRuns = length(zMatFDR);
for i=1:nRuns
    if keepRun(i)
        z2=cat(3,z2,zMatFDR{i});
        r2=cat(3,r2,rMatFDR{i});
    end
end

%% Load & gather Group 3
clearvars -except z1 r1 z2 r2 fileGroup3 groupNames saveFileName chIdxL chIdxR group1Color group2Color group3Color alpha
load(fileGroup3)
z3=[]; r3=[];
nRuns = length(zMatFDR);
for i=1:nRuns
    if keepRun(i)
        z3=cat(3,z3,zMatFDR{i});
        r3=cat(3,r3,rMatFDR{i});
    end
end

%% Median connectivity matrices
zMat1Mean = nanmedian(z1,3);
zMat2Mean = nanmedian(z2,3);
zMat3Mean = nanmedian(z3,3);
rMat1Mean = nanmedian(r1,3);
rMat2Mean = nanmedian(r2,3);
rMat3Mean = nanmedian(r3,3);

%% Extract inter-HC per subject
% nCh es la cantidad de pares de canales espejo
nCh = numel(chIdxL);

% Preasignación de vectores de conectividad por sujeto
zVec1 = nan(size(z1,3), nCh);
zVec2 = nan(size(z2,3), nCh);
zVec3 = nan(size(z3,3), nCh);

% Extraer los valores Z para los pares espejo definidos
for s=1:size(z1,3)
    for c=1:nCh
        zVec1(s,c) = z1(chIdxL(c), chIdxR(c), s);
    end
end
for s=1:size(z2,3)
    for c=1:nCh
        zVec2(s,c) = z2(chIdxL(c), chIdxR(c), s);
    end
end
for s=1:size(z3,3)
    for c=1:nCh
        zVec3(s,c) = z3(chIdxL(c), chIdxR(c), s);
    end
end

%% Median per subject (Promedio de todos los pares inter-hemisféricos)
zSubj1 = nanmedian(zVec1,2);
zSubj2 = nanmedian(zVec2,2);
zSubj3 = nanmedian(zVec3,2);

%% Build table for RM ANOVA
% Se asume que los sujetos están en el mismo orden en los 3 archivos
T = table(zSubj1, zSubj2, zSubj3, 'VariableNames', {'G1','G2','G3'});
% Definir el diseño intra-sujeto
TimePoint = categorical(groupNames');
Within = table(TimePoint, 'VariableNames', {'TimePoint'});

%% Fit RM model
rm = fitrm(T, 'G1-G3~1', 'WithinDesign', Within);
R = ranova(rm);
P_anova = R.pValue(1);

%% Pairwise Tukey–Kramer
C = multcompare(rm, 'TimePoint', 'ComparisonType', 'tukey-kramer', 'Alpha', alpha);
P12 = nan; P13 = nan; P23 = nan;

for k = 1:height(C)
    t1 = string(C.TimePoint_1(k));
    t2 = string(C.TimePoint_2(k));
    p  = C.pValue(k);
    
    if (t1 == groupNames{1} && t2 == groupNames{2}) || (t1 == groupNames{2} && t2 == groupNames{1})
        P12 = p;
    elseif (t1 == groupNames{1} && t2 == groupNames{3}) || (t1 == groupNames{3} && t2 == groupNames{1})
        P13 = p;
    elseif (t1 == groupNames{2} && t2 == groupNames{3}) || (t1 == groupNames{3} && t2 == groupNames{2})
        P23 = p;
    end
end

%% Save results
if ~exist(fullfile('..','Data'), 'dir'); mkdir(fullfile('..','Data')); end
save(fullfile('..','Data',[saveFileName '.mat']), ...
    'zMat1Mean', 'zMat2Mean', 'zMat3Mean', ...
    'rMat1Mean', 'rMat2Mean', 'rMat3Mean', ...
    'P_anova', 'P12', 'P13', 'P23');

%% Boxplot
allData = {zSubj1; zSubj2; zSubj3};
groupVec = [ones(size(zSubj1)); 2*ones(size(zSubj2)); 3*ones(size(zSubj3))];
colors = [group1Color; group2Color; group3Color];
markers = {'o', 'x', 's'};

hFig = figure; set(hFig, 'Color', 'w', 'Name', 'Inter-HC Connectivity');
boxplot(cell2mat(allData), groupVec, 'Colors', [0 0 0], 'Symbol', ''); 
hold on;

for g = 1:3
    scatter(repmat(g, numel(allData{g}), 1), allData{g}, 40, ...
            'MarkerEdgeColor', colors(g,:), 'Marker', markers{g}, ...
            'jitter', 'on', 'jitterAmount', 0.15, 'LineWidth', 1.2);
end

set(gca, 'XTick', 1:3, 'XTickLabel', groupNames, 'FontSize', 12);
ylabel('Inter-HC Connectivity (z-score)');
title({['RM-ANOVA p = ', num2str(P_anova, '%.3f')], ...
       ['1v2: p=', num2str(P12, '%.3f'), ' | 1v3: p=', num2str(P13, '%.3f'), ' | 2v3: p=', num2str(P23, '%.3f')]});

%% Save figure
if ~exist(fullfile('..','Figures'), 'dir'); mkdir(fullfile('..','Figures')); end
set(hFig, 'Units', 'inches', 'Position', [1 1 6 5]);
%saveas(hFig, fullfile('..','Figures',[saveFileName '_InterHC.png']));

%fprintf('Análisis Inter-HC completado. p-ANOVA: %.3f\n', P_anova);

%% Save figure
%set(hFig, 'Units', 'inches', 'Position', [0.1 0.1 6 6], 'PaperPosition', [0.1 0.1 6 6]);
print(hFig, '-dpng', fullfile('..','figures',[saveFileName '_InterHC.png']), '-r300');
fprintf('Inter-hemispherical RM-ANOVA done (p=%.3f)\n', P_anova);
end
function [zMat1Mean,zMat2Mean,zMat3Mean,P_anova,P12,P13,P23] = ...
    conn_mat_3_group_comparison_IntraHC(fileGroup1,fileGroup2,fileGroup3,groupNames,saveFileName, ...
                                     chIdxL,group1Color,group2Color,group3Color,alpha)
% Computes intrahemispheric connectivity (left hemisphere) at three time-points,
% then runs repeated-measures ANOVA and Tukey–Kramer pairwise comparisons.

%% Load & gather Group 1
load(fileGroup1)  % expects zMatFDR, keepRun
z1 = [];
nRuns = length(zMatFDR); % Detección automática corregida
for i=1:nRuns
    if keepRun(i)
        z1 = cat(3, z1, zMatFDR{i});
    end
end

%% Load & gather Group 2
clearvars -except z1 fileGroup2 fileGroup3 groupNames saveFileName chIdxL group1Color group2Color group3Color alpha
load(fileGroup2)
z2 = [];
nRuns = length(zMatFDR);
for i=1:nRuns
    if keepRun(i)
        z2 = cat(3, z2, zMatFDR{i});
    end
end

%% Load & gather Group 3
clearvars -except z1 z2 fileGroup3 groupNames saveFileName chIdxL group1Color group2Color group3Color alpha
load(fileGroup3)
z3 = [];
nRuns = length(zMatFDR);
for i=1:nRuns
    if keepRun(i)
        z3 = cat(3, z3, zMatFDR{i});
    end
end

%% Median connectivity matrices (for visualization)
zMat1Mean = nanmedian(z1,3);
zMat2Mean = nanmedian(z2,3);
zMat3Mean = nanmedian(z3,3);

%% Compute intrahemispheric connectivity per subject
% Usamos el tamaño de la tercera dimensión de las matrices ya filtradas
N = size(z1,3); 
zVec1 = nan(N,1);
zVec2 = nan(N,1);
zVec3 = nan(N,1);

for s = 1:N
    % Extraer submatriz del hemisferio izquierdo
    m1 = z1(chIdxL, chIdxL, s);
    m2 = z2(chIdxL, chIdxL, s);
    m3 = z3(chIdxL, chIdxL, s);
    
    % Promedio de conectividad intra-HC (excluyendo la diagonal si es necesario)
    % Usamos nanmean de los elementos que no son 1 (diagonal) o todos los elementos
    zVec1(s) = nanmean(m1(:));
    zVec2(s) = nanmean(m2(:));
    zVec3(s) = nanmean(m3(:));
end

%% Repeated-measures ANOVA
T = table(zVec1, zVec2, zVec3, 'VariableNames', {'G1','G2','G3'});
Within = table(categorical(groupNames)','VariableNames',{'TimePoint'});
rm = fitrm(T, 'G1-G3~1', 'WithinDesign', Within);
R = ranova(rm);
P_anova = R.pValue(1);

%% Pairwise Tukey–Kramer comparisons
C = multcompare(rm, 'TimePoint', 'ComparisonType','tukey-kramer','Alpha',alpha);
P12 = nan; P13 = nan; P23 = nan;
for k = 1:height(C)
    t1 = string(C.TimePoint_1(k)); t2 = string(C.TimePoint_2(k)); p = C.pValue(k);
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
    'zMat1Mean','zMat2Mean','zMat3Mean', ...
    'P_anova','P12','P13','P23');

%% Boxplot of intra-HC across sessions
allData = {zVec1; zVec2; zVec3};
groupVec = [ones(N,1); 2*ones(N,1); 3*ones(N,1)];
colors = [group1Color; group2Color; group3Color];
markers = {'o','x','s'};

hFig = figure; set(hFig,'Color','w', 'Name', 'Intra-HC Left');
boxplot(cell2mat(allData), groupVec, 'Colors', [0 0 0], 'Symbol', ''); hold on;

for g = 1:3
    scatter(repmat(g, numel(allData{g}), 1), allData{g}, 40, ...
            'MarkerEdgeColor', colors(g,:), 'Marker', markers{g}, ...
            'jitter', 'on', 'jitterAmount', 0.15, 'LineWidth', 1.2);
end

set(gca,'XTick',1:3,'XTickLabel',groupNames,'FontSize',16);
ylabel('Intra-HC Connectivity (z-score)');
title({['RM-ANOVA p = ', num2str(P_anova, '%.3f')], ...
       ['1v2: p=', num2str(P12, '%.3f'), ' | 1v3: p=', num2str(P13, '%.3f'), ' | 2v3: p=', num2str(P23, '%.3f')]});

%% Save figure (High Resolution - 900 DPI)
if ~exist(fullfile('..','Figures'), 'dir'); mkdir(fullfile('..','Figures')); end
set(hFig, 'Units', 'inches', 'Position', [1 1 6 5]);
%saveas(hFig, fullfile('..','Figures',[saveFileName '_InterHC.png']));

%fprintf('Análisis Inter-HC completado. p-ANOVA: %.3f\n', P_anova);

%% Save figure
%set(hFig, 'Units', 'inches', 'Position', [0.1 0.1 6 6], 'PaperPosition', [0.1 0.1 6 6]);
print(hFig, '-dpng', fullfile('..','figures',[saveFileName '_IntraHC.png']), '-r300');

fprintf('Intrahemispheric RM-ANOVA completado (p=%.3f). Imagen guardada a 900 DPI.\n', P_anova);
end
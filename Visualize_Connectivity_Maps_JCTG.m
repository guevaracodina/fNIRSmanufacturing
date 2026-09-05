%% High-Resolution Connectivity Matrix Visualization (900 DPI)
% Optimized for Publication - Juan Carlos Torres

clear; clc; close all;

% 1. Load Data
try
    load('..\Data\workload_all_significant_connections_HbO.mat');
catch
    error('File not found in ..\Data\. Run Script 1 first.');
end

% 2. Average Matrices
get_avg = @(cellData) nanmean(cat(3, cellData{:}), 3);
avg_resting = get_avg(resting_workload.rMatFDR);
avg_easy    = get_avg(easy_workload.rMatFDR);
avg_hard    = get_avg(hard_workload.rMatFDR);

matrices = {avg_resting, avg_easy, avg_hard};
titles = {'Resting State', 'Low Task', 'High Task'};

% 3. Create Figure with Specific Size for Resolution
fig = figure('Color', 'w', 'Units', 'inches', 'Position', [1, 1, 18, 7]);

for i = 1:3
    subplot(1, 3, i);
    
    imagesc(matrices{i});
    axis square;
    colormap(jet); 
    
    % Colorbar settings
    h = colorbar;
    set(h, 'FontSize', 16, 'FontWeight', 'bold'); % Larger Colorbar font
    ylabel(h, 'Correlation (r)', 'FontSize', 24, 'FontWeight', 'bold');
    caxis([0 0.7]); 
    
    % Axis and Label Settings (MUCH LARGER)
    title(titles{i}, 'FontSize', 28, 'FontWeight', 'bold');
    xlabel('Channel ID', 'FontSize', 26, 'FontWeight', 'bold');
    if i == 1
        ylabel('Channel ID', 'FontSize', 26, 'FontWeight', 'bold');
    end
    
    set(gca, 'FontSize', 20, 'FontWeight', 'bold', 'LineWidth', 2);
    
    % Hemisphere Division Lines (LineWidth = 3)
    nCh = size(matrices{i}, 1);
    mid = nCh/2 + 0.5;
    line([mid, mid], [0.5, nCh + 0.5], 'Color', 'w', 'LineStyle', '--', 'LineWidth', 3);
    line([0.5, nCh + 0.5], [mid, mid], 'Color', 'w', 'LineStyle', '--', 'LineWidth', 3);
end

% Overall Title
sgtitle(['Functional Connectivity Analysis - ' strContrast], 'FontSize', 28, 'FontWeight', 'bold');

% 4. EXPORT AT 900 DPI
outputDir = '..\Data\Results\';
if ~exist(outputDir, 'dir'), mkdir(outputDir); end

savePath = fullfile(outputDir, ['Connectivity_Comparison_' strContrast '_900dpi.png']);

% Use export_fig if available, otherwise use print
fprintf('Exporting at 900 DPI... please wait.\n');
print(fig, savePath, '-dpng', '-r900'); 

fprintf('High-resolution figure saved in: %s\n', savePath);
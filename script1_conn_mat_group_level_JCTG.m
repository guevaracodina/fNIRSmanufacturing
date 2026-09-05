%% *fNIRS Workload*

%% Compute connectivity matrix for all groups (begin, middle and end of shift)
% This is the first script to be run (1/4)
% Works with SNIRF-compatible files, located in derivatives/homer Homer3 (v1.54.0)

%% channel by channel data for fNIRS Workload 
clear; close all; clc
check_homer_path
disp('fNIRS Workload computing connectivity matrices (channel by channel)')
restingDir  = '..\Data\resting_state\derivatives\homer';
easyDir     = '..\Data\easy_task\derivatives\homer';
hardDir      = '..\Data\hard_task\derivatives\homer';

for iHb = 1:3               % 1=HbO, 2=HbR, 3=HbT
    % Beginning of shift Group
    [resting_workload.rMatFDR, resting_workload.zMatFDR, resting_workload.pMatFDR, resting_workload.pMat, resting_workload.keepRun] = ...
        conn_mat_group_level(restingDir, iHb, 'resting_workloadConn');
    % End of shift Group
    [easy_workload.rMatFDR, easy_workload.zMatFDR, easy_workload.pMatFDR, easy_workload.pMat, easy_workload.keepRun] = ...
        conn_mat_group_level(easyDir, iHb, 'easy_workloadConn');
    % End of shift Group
    [hard_workload.rMatFDR, hard_workload.zMatFDR, hard_workload.pMatFDR, hard_workload.pMat, hard_workload.keepRun] = ...
        conn_mat_group_level(hardDir, iHb, 'hard_workloadConn');
    % Get Hb string label
    strContrast = get_Hb_string(iHb);
    % Save all fc data
    save(fullfile('..\Data\', ['workload_all_significant_connections_' strContrast '.mat']));
end
disp('fNIRS Workload training connectivity matrices (channel by channel) computed!')
%clear; close all; clc

%%
%% *fNIRS Workload*

%% Compute connectivity matrix for all groups (begin, middle and end of shift)
% This is the first script to be run (1/4)
% Works with SNIRF-compatible files, located in derivatives/homer Homer3 (v1.54.0)

%% channel by channel data for fNIRS Workload 
clear; close all; clc
check_homer_path
disp('fNIRS Workload computing connectivity matrices (channel by channel)')
restingDir  = '..\Data\resting_state\derivatives\homer';
easyDir     = '..\Data\easy_task\derivatives\homer';
hardDir      = '..\Data\hard_task\derivatives\homer';

for iHb = 1:3               % 1=HbO, 2=HbR, 3=HbT
    % Beginning of shift Group
    [resting_workload.rMatFDR, resting_workload.zMatFDR, resting_workload.pMatFDR, resting_workload.pMat, resting_workload.keepRun] = ...
        conn_mat_group_level(restingDir, iHb, 'resting_workloadConn');
    % End of shift Group
    [easy_workload.rMatFDR, easy_workload.zMatFDR, easy_workload.pMatFDR, easy_workload.pMat, easy_workload.keepRun] = ...
        conn_mat_group_level(easyDir, iHb, 'easy_workloadConn');
    % End of shift Group
    [hard_workload.rMatFDR, hard_workload.zMatFDR, hard_workload.pMatFDR, hard_workload.pMat, hard_workload.keepRun] = ...
        conn_mat_group_level(hardDir, iHb, 'hard_workloadConn');
    % Get Hb string label
    strContrast = get_Hb_string(iHb);
    % Get Hb string label
    strContrast = get_Hb_string(iHb);

    % Guardar archivo para Grupo 1: RESTING
    % Extraemos los datos de la estructura y los guardamos como variables sueltas
    temp = resting_workload;
    save(fullfile('..\Data\', ['restingConn' strContrast '.mat']), '-struct', 'temp');

    % Guardar archivo para Grupo 2: EASY
    temp = easy_workload;
    save(fullfile('..\Data\', ['easyConn' strContrast '.mat']), '-struct', 'temp');

    % Guardar archivo para Grupo 3: HARD
    temp = hard_workload;
    save(fullfile('..\Data\', ['hardConn' strContrast '.mat']), '-struct', 'temp');
    
    clear temp;
end
disp('Archivos para comparación de grupos generados con éxito!')
%clear; close all; clc


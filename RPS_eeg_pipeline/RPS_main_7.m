%% check if basic variables are defined
if ~exist('sessionStr', 'var')
  cfg           = [];
  cfg.subFolder = '06b_hilbert/';
  cfg.filename  = 'RPS_d01_06b_hilbert20Hz';
  sessionStr    = sprintf('%03d', RPS_getSessionNum( cfg ));                % estimate current session number
end

if ~exist('desPath', 'var')
  desPath       = '/data/pt_01843/eegData/DualEEG_RPS_processedData/';      % destination path for processed data  
end

if ~exist('numOfPart', 'var')                                               % estimate number of participants in segmented data folder
  sourceList    = dir([strcat(desPath, '06b_hilbert/'), ...
                       strcat('*20Hz_', sessionStr, '.mat')]);
  sourceList    = struct2cell(sourceList);
  sourceList    = sourceList(1,:);
  numOfSources  = length(sourceList);
  numOfPart     = zeros(1, numOfSources);

  for i=1:1:numOfSources
    numOfPart(i)  = sscanf(sourceList{i}, ...
                    strcat('RPS_d%d_06b_hilbert20Hz_', sessionStr, '.mat'));
  end
end

%% part 7

cprintf([0,0.6,0], '<strong>[7]  - Estimation of Phase Locking Values (PLV)</strong>\n');
fprintf('\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% general adjustment
choise = false;
while choise == false
  cprintf([0,0.6,0], 'Should rejection of detected artifacts be applied before PLV estimation?\n');
  x = input('Select [y/n]: ','s');
  if strcmp('y', x)
    choise = true;
    artifactRejection = true;
  elseif strcmp('n', x)
    choise = true;
    artifactRejection = false;
  else
    choise = false;
  end
end
fprintf('\n');

% Write selected settings to settings file
file_path = [desPath '00_settings/' sprintf('settings_%s', sessionStr) '.xls'];
if ~(exist(file_path, 'file') == 2)                                         % check if settings file already exist
  cfg = [];
  cfg.desFolder   = [desPath '00_settings/'];
  cfg.type        = 'settings';
  cfg.sessionStr  = sessionStr;
  
  RPS_createTbl(cfg);                                                       % create settings file
end

T = readtable(file_path);                                                   % update settings table
warning off;
T.artRejectPLV(numOfPart) = {x};
warning on;
delete(file_path);
writetable(T, file_path);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Segmentation and Artifact rejection

for i = numOfPart
  fprintf('<strong>Dyad %d</strong>\n\n', i);
  
  % alpha branch %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  cfg             = [];                                                     % load hilbert phase data
  cfg.srcFolder   = strcat(desPath, '06b_hilbert/');
  cfg.sessionStr  = sessionStr;
  cfg.filename    = sprintf('RPS_d%02d_06b_hilbertAlpha', i);
  fprintf('Load hilbert phase data at alpha (8-12Hz)...\n');
  RPS_loadData( cfg );

  cfg           = [];
  cfg.length    = 1;
  cfg.overlap   = 0;
  
  fprintf('<strong>Segmentation of Hilbert phase data at alpha (8-12Hz).</strong>\n');
  data_hseg_alpha  = RPS_segmentation( cfg, data_hilbert_alpha );
  
  % export the segmented hilbert (alpha) data into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '07a_hseg/');
  cfg.filename    = sprintf('RPS_d%02d_07a_hsegAlpha', i);
  cfg.sessionStr  = sessionStr;
 
  
  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('The segmented hilbert data (alpha: 8-12Hz) of dyad %d will be saved in:\n', i); 
  fprintf('%s ...\n', file_path);
  RPS_saveData(cfg, 'data_hseg_alpha', data_hseg_alpha);
  fprintf('Data stored!\n\n');
  clear data_hseg_alpha data_hilbert_alpha
  
  % beta branch %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  cfg             = [];                                                     % load hilbert phase data
  cfg.srcFolder   = strcat(desPath, '06b_hilbert/');
  cfg.sessionStr  = sessionStr;
  cfg.filename    = sprintf('RPS_d%02d_06b_hilbertBeta', i);
  fprintf('Load hilbert phase data at beta (13-30Hz)...\n');
  RPS_loadData( cfg );
    
  cfg           = [];
  cfg.length    = 1;
  cfg.overlap   = 0;
    
  fprintf('<strong>Segmentation of Hilbert phase data at beta (13-30Hz).</strong>\n');
  data_hseg_beta  = RPS_segmentation( cfg, data_hilbert_beta );
  
  % export the segmented hilbert (beta) data into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '07a_hseg/');
  cfg.filename    = sprintf('RPS_d%02d_07a_hsegBeta', i);
  cfg.sessionStr  = sessionStr;
  
  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('The segmented hilbert data (beta: 13-30Hz) of dyad %d will be saved in:\n', i); 
  fprintf('%s ...\n', file_path);
  RPS_saveData(cfg, 'data_hseg_beta', data_hseg_beta);
  fprintf('Data stored!\n\n');
  clear data_hseg_beta data_hilbert_beta
  
  % gamma branch %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  cfg             = [];                                                     % load hilbert phase data
  cfg.srcFolder   = strcat(desPath, '06b_hilbert/');
  cfg.sessionStr  = sessionStr;
  cfg.filename    = sprintf('RPS_d%02d_06b_hilbertGamma', i);
  fprintf('Load hilbert phase data at gamma (31-100Hz)...\n');
  RPS_loadData( cfg );
    
  cfg           = [];
  cfg.length    = 1;
  cfg.overlap   = 0;
    
  fprintf('<strong>Segmentation of Hilbert phase data at gamma (31-100Hz).</strong>\n');
  data_hseg_gamma  = RPS_segmentation( cfg, data_hilbert_gamma );
  
  % export the segmented hilbert (gamma) data into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '07a_hseg/');
  cfg.filename    = sprintf('RPS_d%02d_07a_hsegGamma', i);
  cfg.sessionStr  = sessionStr;
  
  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('The segmented hilbert data (gamma: 31-100Hz) of dyad %d will be saved in:\n', i); 
  fprintf('%s ...\n', file_path);
  RPS_saveData(cfg, 'data_hseg_gamma', data_hseg_gamma);
  fprintf('Data stored!\n\n');
  clear data_hseg_gamma data_hilbert_gamma
    
  % Load Artifact definitions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if artifactRejection == true                                              % load artifact definitions
    cfg             = [];
    cfg.srcFolder   = strcat(desPath, '05b_allart/');
    cfg.filename    = sprintf('RPS_d%02d_05b_allart', i);
    cfg.sessionStr  = sessionStr;
  
    file_path = strcat(cfg.srcFolder, cfg.filename, '_', cfg.sessionStr,...
                     '.mat');
    if ~isempty(dir(file_path))
      fprintf('Loading %s ...\n', file_path);
      RPS_loadData( cfg );                                                  
      artifactAvailable = true;     
    else
      fprintf('File %s is not existent,\n', file_path);
      fprintf('Artifact rejection is not possible!\n');
      artifactAvailable = false;
    end
  fprintf('\n');
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% artifact rejection, PLV and mPLV calculation
  % load segmented hilbert phase data at alpha %%%%%%%%%%%%%%%%%%%%%%%%%%%%
  cfg             = [];
  cfg.srcFolder   = strcat(desPath, '07a_hseg/');
  cfg.sessionStr  = sessionStr;
  cfg.filename    = sprintf('RPS_d%02d_07a_hsegAlpha', i);
  fprintf('Load segmented hilbert data at alpha (8-12Hz)...\n');
  RPS_loadData( cfg );
  
  % artifact rejection at alpha %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if artifactRejection == true
    if artifactAvailable == true
      cfg           = [];
      cfg.artifact  = cfg_allart;
      cfg.reject    = 'complete';
      cfg.target    = 'dual';
  
      fprintf('<strong>Artifact Rejection of Hilbert phase data at alpha (8-12Hz).</strong>\n');
      data_hseg_alpha = RPS_rejectArtifacts(cfg, data_hseg_alpha);
      fprintf('\n');
    end
  end
  
  % calculate PLV and meanPLV at alpha %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  cfg           = [];
  cfg.winlen    = 1;                                                        % window length for one PLV value in seconds
  
  data_plv_alpha  = RPS_phaseLockVal(cfg, data_hseg_alpha);
  data_mplv_alpha = RPS_calcMeanPLV(data_plv_alpha);
  clear data_hseg_alpha
  
  % export number of good trials into a spreadsheet
  cfg           = [];
  cfg.desFolder = [desPath '00_settings/'];
  cfg.dyad = i;
  cfg.type = 'plv';
  cfg.param = 'alpha';
  cfg.sessionStr = sessionStr;
  RPS_writeTbl(cfg, data_plv_alpha);
  
  % export the PLVs into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '07b_plv/');
  cfg.filename    = sprintf('RPS_d%02d_07b_plvAlpha', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('Saving PLVs (alpha: 8-12Hz) of dyad %d in:\n', i); 
  fprintf('%s ...\n', file_path);
  RPS_saveData(cfg, 'data_plv_alpha', data_plv_alpha);
  fprintf('Data stored!\n');
  clear data_plv_alpha
  
  % export the mean PLVs into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '07c_mplv/');
  cfg.filename    = sprintf('RPS_d%02d_07c_mplvAlpha', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('Saving mean PLVs (alpha: 8-12Hz) of dyad %d in:\n', i); 
  fprintf('%s ...\n', file_path);
  RPS_saveData(cfg, 'data_mplv_alpha', data_mplv_alpha);
  fprintf('Data stored!\n\n');
  clear data_mplv_alpha
  
  % load segmented hilbert phase data at beta %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  cfg             = [];
  cfg.srcFolder   = strcat(desPath, '07a_hseg/');
  cfg.sessionStr  = sessionStr;
  cfg.filename    = sprintf('RPS_d%02d_07a_hsegBeta', i);
  fprintf('Load segmented hilbert data at beta (13-30Hz)...\n');
  RPS_loadData( cfg );
  
  % artifact rejection at beta %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if artifactRejection == true
    if artifactAvailable == true
      cfg           = [];
      cfg.artifact  = cfg_allart;
      cfg.reject    = 'complete';
      cfg.target    = 'dual';
  
      fprintf('<strong>Artifact Rejection of Hilbert phase data at beta (13-30Hz).</strong>\n');
      data_hseg_beta = RPS_rejectArtifacts(cfg, data_hseg_beta);
      fprintf('\n');
    end
  end
  
  % calculate PLV and meanPLV at beta %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  cfg           = [];
  cfg.winlen    = 1;                                                        % window length for one PLV value in seconds
  
  data_plv_beta  = RPS_phaseLockVal(cfg, data_hseg_beta);
  data_mplv_beta = RPS_calcMeanPLV(data_plv_beta);
  clear data_hseg_beta
  
  % export number of good trials into a spreadsheet
  cfg           = [];
  cfg.desFolder = [desPath '00_settings/'];
  cfg.dyad = i;
  cfg.type = 'plv';
  cfg.param = 'beta';
  cfg.sessionStr = sessionStr;
  RPS_writeTbl(cfg, data_plv_beta);
  
  % export the PLVs into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '07b_plv/');
  cfg.filename    = sprintf('RPS_d%02d_07b_plvBeta', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('Saving PLVs (beta: 13-30Hz) of dyad %d in:\n', i); 
  fprintf('%s ...\n', file_path);
  RPS_saveData(cfg, 'data_plv_beta', data_plv_beta);
  fprintf('Data stored!\n');
  clear data_plv_beta
  
  % export the mean PLVs into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '07c_mplv/');
  cfg.filename    = sprintf('RPS_d%02d_07c_mplvBeta', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('Saving mean PLVs (beta: 13-30Hz) of dyad %d in:\n', i); 
  fprintf('%s ...\n', file_path);
  RPS_saveData(cfg, 'data_mplv_beta', data_mplv_beta);
  fprintf('Data stored!\n\n');
  clear data_mplv_beta
  
  % load segmented hilbert phase data at gamma %%%%%%%%%%%%%%%%%%%%%%%%%%%%
  cfg             = [];
  cfg.srcFolder   = strcat(desPath, '07a_hseg/');
  cfg.sessionStr  = sessionStr;
  cfg.filename    = sprintf('RPS_d%02d_07a_hsegGamma', i);
  fprintf('Load segmented hilbert data at gamma (31-100Hz)...\n');
  RPS_loadData( cfg );
  
  % artifact rejection at gamma %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if artifactRejection == true
    if artifactAvailable == true
      cfg           = [];
      cfg.artifact  = cfg_allart;
      cfg.reject    = 'complete';
      cfg.target    = 'dual';
  
      fprintf('<strong>Artifact Rejection of Hilbert phase data at gamma (31-100Hz).</strong>\n');
      data_hseg_gamma = RPS_rejectArtifacts(cfg, data_hseg_gamma);
      fprintf('\n');
      
      clear cfg_allart
    end
  end
  
  % calculate PLV and meanPLV at gamma %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  cfg           = [];
  cfg.winlen    = 1;                                                        % window length for one PLV value in seconds
  
  data_plv_gamma  = RPS_phaseLockVal(cfg, data_hseg_gamma);
  data_mplv_gamma = RPS_calcMeanPLV(data_plv_gamma);
  clear data_hseg_gamma
  
  % export number of good trials into a spreadsheet
  cfg           = [];
  cfg.desFolder = [desPath '00_settings/'];
  cfg.dyad = i;
  cfg.type = 'plv';
  cfg.param = 'gamma';
  cfg.sessionStr = sessionStr;
  RPS_writeTbl(cfg, data_plv_gamma);
  
  % export the PLVs into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '07b_plv/');
  cfg.filename    = sprintf('RPS_d%02d_07b_plvGamma', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('Saving PLVs (gamma: 31-100Hz) of dyad %d in:\n', i); 
  fprintf('%s ...\n', file_path);
  RPS_saveData(cfg, 'data_plv_gamma', data_plv_gamma);
  fprintf('Data stored!\n');
  clear data_plv_gamma
  
  % export the mean PLVs into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '07c_mplv/');
  cfg.filename    = sprintf('RPS_d%02d_07c_mplvGamma', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('Saving mean PLVs (gamma: 31-100Hz) of dyad %d in:\n', i); 
  fprintf('%s ...\n', file_path);
  RPS_saveData(cfg, 'data_mplv_gamma', data_mplv_gamma);
  fprintf('Data stored!\n\n');
  clear data_mplv_gamma
end

%% clear workspace
clear cfg file_path sourceList numOfSources i artifactRejection ...
      artifactAvailable x choise T

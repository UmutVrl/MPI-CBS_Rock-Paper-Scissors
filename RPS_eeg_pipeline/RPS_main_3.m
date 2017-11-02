%% check if basic variables are defined and import segmented data
if ~exist('sessionStr', 'var')
  cfg           = [];
  cfg.subFolder = '02_preproc/';
  cfg.filename  = 'RPS_p01_02_preproc';
  sessionStr    = sprintf('%03d', RPS_getSessionNum( cfg ));                % estimate current session number
end

if ~exist('desPath', 'var')
  desPath       = '/data/pt_01843/eegData/DualEEG_RPS_processedData/';      % destination path for processed data  
end

if ~exist('numOfPart', 'var')                                               % estimate number of participants in segmented data folder
  sourceList    = dir([strcat(desPath, '02_preproc/'), ...
                       strcat('*_', sessionStr, '.mat')]);
  sourceList    = struct2cell(sourceList);
  sourceList    = sourceList(1,:);
  numOfSources  = length(sourceList);
  numOfPart     = zeros(1, numOfSources);

  for i=1:1:numOfSources
    numOfPart(i)  = sscanf(sourceList{i}, ...
                    strcat('RPS_p%d_02_preproc_', sessionStr, '.mat'));
  end
end

%% auto artifact detection (threshold +-75 uV)
% verify automatic detected artifacts / manual artifact detection
% export the automatic selected artifacts into a *.mat file
% export the verified and the additional artifacts into a *.mat file

for i = numOfPart
  cfg             = [];
  cfg.srcFolder   = strcat(desPath, '02_preproc/');
  cfg.filename    = sprintf('RPS_p%02d_02_preproc', i);
  cfg.sessionStr  = sessionStr;
  
  fprintf('Dyad %d\n', i);
  fprintf('Load preprocessed data...\n');
  RPS_loadData( cfg );
  
  cfg           = [];
  cfg.chan      = {'Cz', 'O1', 'O2'};
  cfg.minVal    = -75;
  cfg.maxVal    = 75;

  cfg_autoArt   = RPS_autoArtifact(cfg, data_preproc);                      % auto artifact detection
  
  cfg           = [];
  cfg.artifact  = cfg_autoArt;
  cfg.dyad      = i;
  
  cfg_allArt    = RPS_manArtifact(cfg, data_preproc);                       % manual artifact detection                           
  
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '05_autoArt/');
  cfg.filename    = sprintf('RPS_p%02d_05_autoArt', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('\nThe automatic selected artifacts of dyad %d will be saved in:\n', i); 
  fprintf('%s ...\n', file_path);
  RPS_saveData(cfg, 'cfg_autoArt', cfg_autoArt);
  fprintf('Data stored!\n');
  clear cfg_autoArt data_preproc
  
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '06_allArt/');
  cfg.filename    = sprintf('RPS_p%02d_06_allArt', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('The visual verified artifacts of dyad %d will be saved in:\n', i); 
  fprintf('%s ...\n', file_path);
  RPS_saveData(cfg, 'cfg_allArt', cfg_allArt);
  fprintf('Data stored!\n\n');
  clear cfg_allArt
  
  if(i < max(numOfPart))
    selection = false;
    while selection == false
      fprintf('Proceed with the next dyad?\n');
      x = input('\nSelect [y/n]: ','s');
      if strcmp('y', x)
        selection = true;
      elseif strcmp('n', x)
        clear file_path numOfSources sourceList cfg i x selection
        return;
      else
        selection = false;
      end
    end
    fprintf('\n');
  end
end

%% clear workspace
clear file_path numOfSources sourceList cfg i x selection
function RPS_easyPowPlot(cfg, data)
% RPS_EASYPOWPLOT is a function, which makes it easier to plot the
% signal power within a specific condition of the RPS_DATASTRUCTURE
%
% Use as
%   RPS_easyPowPlot(cfg, data)
%
% where the input data have to be a result from RPS_PWELCH.
%
% The configuration options are 
%   cfg.part        = number of participant (default: 1)
%                     0 - plot the averaged data
%                     1 - plot data of participant 1
%                     2 - plot data of participant 2   
%   cfg.condition   = condition (default: 2 or 'PredDiff', see RPS_DATASTRUCTURE)
%   cfg.phase       = phase (default: 11 or 'Prediction', see RPS_DATASTRUCTURE)
%   cfg.electrode   = number of electrodes (default: {'Cz'} repsectively [10])
%                     examples: {'Cz'}, {'F7', 'Fz', 'F8'}, [10] or [2, 1, 3]
%   cfg.avgelec     = plot average over selected electrodes, options: 'yes' or 'no' (default: 'no')
%
% This function requires the fieldtrip toolbox
%
% See also RPS_PWELCH, RPS_DATASTRUCTURE

% Copyright (C) 2018-2019, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
part  = ft_getopt(cfg, 'part', 1);
cond  = ft_getopt(cfg, 'condition', 2);
phase = ft_getopt(cfg, 'phase', 11);
elec  = ft_getopt(cfg, 'electrode', {'Cz'});
avgelec = ft_getopt(cfg, 'avgelec', 'no');

filepath = fileparts(mfilename('fullpath'));                                % add utilities folder to path
addpath(sprintf('%s/../utilities', filepath));

cond = RPS_checkCondition( cond );                                          % check cfg.condition definition   
switch cond
  case 1
    data = data.FP;
  case 2
    data = data.PD;
  case 3
    data = data.PS;
  case 4
    data = data.C;
  otherwise
    error('Condition %d is not valid', cond);
end

if ~ismember(part, [0,1,2])                                                 % check cfg.part definition
  error('cfg.part has to be either 0, 1 or 2');
end

switch part                                                                 % check validity of cfg.part
  case 0
    if isfield(data, 'part1')
      warning backtrace off;
      warning('You are using dyad-specific data. Please specify either cfg.part = 1 or cfg.part = 2');
      warning backtrace on;
      return;
    end
  case 1
    if ~isfield(data, 'part1')
      warning backtrace off;
      warning('You are using data averaged over dyads. Please specify cfg.part = 0');
      warning backtrace on;
      return;
    end
    data = data.part1;
  case 2
    if ~isfield(data, 'part2')
      warning backtrace off;
      warning('You are using data averaged over dyads. Please specify cfg.part = 0');
      warning backtrace on;
      return;
    end
    data = data.part2;
end

trialinfo = data.trialinfo;                                                 % get trialinfo
label     = data.label;                                                     % get labels 

phase = RPS_checkPhase( phase );                                            % check cfg.phase definition    
if isempty(find(trialinfo == phase, 1))
  error('The selected dataset contains no phase %d.', phase);
else
  trialNum = ismember(trialinfo, phase);
end

if isnumeric(elec)                                                          % check cfg.electrode
  for i=1:length(elec)
    if elec(i) < 1 || elec(i) > 32
      error('cfg.elec has to be a numbers between 1 and 32 or a existing labels like {''Cz''}.');
    end
  end
else
  if ischar(elec)
    elec = {elec};
  end
  tmpElec = zeros(1, length(elec));
  for i=1:length(elec)
    tmpElec(i) = find(strcmp(label, elec{i}));
    if isempty(tmpElec(i))
      error('cfg.elec has to be a cell array of existing labels like ''Cz''or a vector of numbers between 1 and 32.');
    end
  end
  elec = tmpElec;
end

if ~ismember(avgelec, {'yes', 'no'})                                        % check cfg.avgelec definition
  error('cfg.avgelec has to be either ''yes'' or ''no''.');
end

% -------------------------------------------------------------------------
% Plot power spectrum
% -------------------------------------------------------------------------
legend('-DynamicLegend');
hold on;

if strcmp(avgelec, 'no')
  for i = 1:1:length(elec)
    plot(data.freq, squeeze(data.powspctrm(trialNum, elec(i),:)), ...
        'DisplayName', data.label{elec(i)});
  end
else
  labelString = strjoin(data.label(elec), ',');
  plot(data.freq, mean(squeeze(data.powspctrm(trialNum, elec,:)), 1), ...
        'DisplayName', labelString);
end

if part == 0                                                                % set figure title
  title(sprintf('Power - Cond.: %d - Phase: %d', cond, phase));
else
  title(sprintf('Power - Part.: %d - Cond.: %d - Phase: %d', ...
        part, cond, phase));
end

xlabel('frequency in Hz');                                                  % set xlabel
ylabel('power in uV^2');                                                    % set ylabel

hold off;

end
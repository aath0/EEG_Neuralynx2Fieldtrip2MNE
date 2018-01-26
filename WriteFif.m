function [] = WriteFIF(p_id, ncsfolder, outputfolder, downfreq, clean_events)

% Write '.fif' files from '.ncs' neuralynx format.
% p_id: participant ID
% ncsfolder: the folder that contains all the '.ncs' files that we want to convert
% outputfolder: the folder where the '.fif' data will be saved
% downfreq: frequency at which the final data will be
% downsampled (optional). Default: no downsampling.
% clean_events (optional). Eliminates events with code = 0. Default: do not
% eliminate any events.
% version 1.0, it required fieldtrip, which can be found here: http://www.fieldtriptoolbox.org/
% also, it requires input-output neuralynx library, which can be found
% here: https://github.com/mvdm/neuraldata-w16/tree/master/shared/io/neuralynx
% make sure that those two are in your matlab path!! 

% Last update: 26.01.2018


addpath('/Users/atzovara/Documents/Matlab/')
addpath('/Users/atzovara/Documents/Matlab/')

% check that the data is there:
ncs_files = ls(fullfile(ncsfolder, '*.ncs'));
if length(ncs_files)>0
    disp(['Found ', num2str(size(ncs_files,1)), ' .ncs files'])
else
    disp(['Error: No .ncs files found. Please change ncsfolder!'])
    return
end

events_file = ls(fullfile(ncsfolder, '*.nev'));
if length(events_file)>0
    disp(['Events file found, continuing with data import'])
else
    disp(['Error: No Events.nev file found. Please provide one!'])
    return
end

disp(['...Importing data...'])

ft_defaults
hdr = ft_read_header(ncsfolder);
event = ft_read_event(ncsfolder);

nSampleStart = 1;
nSampleStop = hdr.nSamples;
cfg                 = [];
cfg.dataset         = ncsfolder;
cfg.trl             = [nSampleStart,nSampleStop,0];
data                = ft_preprocessing(cfg);

% add channel information:
for kk = 1:length(data.hdr.chantype)
    
    data.hdr.chantype{kk} = 'elec';
    data.hdr.chanunit{kk} = '';
end

% optional: resample the data:
ds_ratio = 1; % default: no downsampling
if ~isempty(downfreq)
    cfg =[];
    cfg.resamplefs = downfreq;
    cfg.detrend    = 'no';
    [data]        = ft_resampledata(cfg, data)
    ds_ratio = data.hdr.Fs/downfreq;
    data.hdr.Fs = downfreq;
end

% optional: eliminate events with code = 0:
if ~isempty(clean_events)
    ev_clean = [];
    for ev = 1:length(event)
        if event(ev).value ~= 0
            event(ev).sample = event(ev).sample / ds_ratio;
            ev_clean = [ev_clean event(ev)];
            
        end
    end
    event = ev_clean;
end

data.cfg.event = ev_clean;
    
if ~exist(fullfile(outputfolder, p_id))
    mkdir(fullfile(outputfolder, p_id));
end
fiff_file  = [fullfile(outputfolder, p_id), filesep, 'fif_P_',num2str(p_id), '.fif'];

fieldtrip2fiff(fiff_file, data)


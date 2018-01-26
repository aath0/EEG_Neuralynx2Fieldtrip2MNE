 
% Wrapper function for WriteFif.m
% it takes as input a series of participant IDs and folder locations and
% transforms their data in '.fif' format, which can be imported in 'MNE'
% toolbox, in python.

% The input data are in .ncs (Neuralynx) format. All .ncs files need to be
% in one folder, which also contains a triggers files, usually named
% 'Events.nev'

% Last update: 11.12.2017

participants = {'p2'; 'p2'};

data_path = '/Users/atzovara/Documents/Projects/';
ncsfolder = 'try'; % the folders where all .ncs files are located.
outputfolder = '/Users/atzovara/Documents/Projects/StatReg/StatReg_ImportedData/Raw_fif2/';
downfreq = 2000; %frequency to downsample the data to. Leave [] for no downsampling
clean_events = 1; % eliminate events with code '0'? Leave [] for not eliminating anything.

for pp = 1:length(participants)
    
    p_id = char(participants(pp));
    p_folder = fullfile(data_path, p_id, ncsfolder);
    WriteFif(p_id, p_folder, outputfolder, downfreq, clean_events);
    
end
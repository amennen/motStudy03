% syntax: mot_realtime01(SUBJECT,SESSION,SET_SPEED,scanNum,scanNow)
%
% This is an implementation of a MOT memory experiment designed to
% reactivate memory, adapted from a study by Ken Norman and J. Poppenk. I
% (JP) wrote this before we developed our modern experiment design
% framework and it should not be used as an example of "how to do things"
% -- yet there are times when it is more efficient to adapt awkward,
% functional older code than it is to write nice, tidy new code. It has
% been at least updated to make of the current superpsychtoolbox
% implementation.


%%

function mot_realtime01b(SUBJECT,SESSION,SET_SPEED,scanNum,scanNow,s2)

%SUBJECT: Subject number
%SESSION: task that they're going to do (listed below)
%SET_SPEED: if not empty, debug mode is on
%scanNum: (for MOT use only) if you're going to use fmri scans for real
%time
%scanNow: if you're using the scanner right now (0 if not, 1 if yes) aka
%looking for triggers


% note: TR values begin from t=1 (rather than t=0)
ListenChar(2); %suppress keyboard input to window
KbName('UnifyKeyNames');
% initialization declarations
COLORS.MAINFONTCOLOR = [200 200 200];
COLORS.BGCOLOR = [50 50 50];
WRAPCHARS = 70;
%HideCursor;
%% INITIALIZE EXPERIMENT
NUM_TASK_RUNS = 3;
% orientation session
SETUP = 1; % stimulus assignment 1
FAMILIARIZE = SETUP + 1; % rsvp study learn associates 2
TOCRITERION1 = FAMILIARIZE + 1; % rsvp train to critereon 3
MOT_PRACTICE = TOCRITERION1 + 1;%4
MOT_PREP = MOT_PRACTICE + 1;%5

% day 1
FAMILIARIZE2 = MOT_PREP + 2; % rsvp study learn associates %7
TOCRITERION2 = FAMILIARIZE2 + 1; % rsvp train to critereon
TOCRITERION2_REP = TOCRITERION2 + 1;
RSVP = TOCRITERION2_REP + 1; % rsvp train to critereon

% day 2
SCAN_PREP = RSVP + 2;
MOT_PRACTICE2 = SCAN_PREP + 1; %12
RECALL_PRACTICE = MOT_PRACTICE2 + 1;
%SCAN_PREP = RECALL_PRACTICE + 1;
RSVP2 = RECALL_PRACTICE + 1; % rsvp train to critereon
FAMILIARIZE3 = RSVP2 + 1; % rsvp study learn associates
TOCRITERION3 = FAMILIARIZE3 + 1; % rsvp train to critereon
MOT_LOCALIZER = TOCRITERION3 + 1; % category classification
RECALL1 = MOT_LOCALIZER + 1;
counter = RECALL1 + 1; MOT = [];
for i=1:NUM_TASK_RUNS
    MOT{i} = counter;
    counter = counter + 1;
end
RECALL2 = MOT{end} + 1; % post-scan rsvp memory test
ASSOCIATES = RECALL2 + 1;
%ANATOMICAL_PREP = ASSOCIATES + 1;
% name strings
SESSIONSTRINGS{SETUP} = 'GENERATE PAIRINGS'; % set up rsvp study learn associates
SESSIONSTRINGS{FAMILIARIZE} = 'FAMILIARIZE1'; % rsvp study learn associates
SESSIONSTRINGS{TOCRITERION1} = 'TOCRITERION1'; % rsvp study learn associates
SESSIONSTRINGS{MOT_PRACTICE} = 'MOT_PRACTICE'; % get used to task during anatomical
SESSIONSTRINGS{MOT_PREP} = 'MOT_PREP'; % realtime rsvp

% day 1
SESSIONSTRINGS{FAMILIARIZE2} = 'FAMILIARIZE2'; % rsvp study learn associates
SESSIONSTRINGS{TOCRITERION2} = 'TOCRITERION2'; % learn paired associates to critereon
SESSIONSTRINGS{TOCRITERION2_REP} = 'TOCRITERION2_REP';
SESSIONSTRINGS{RSVP} = 'FRUIT_HARVEST'; % fruit harvest task practice and familiarization of words
SESSIONSTRINGS{MOT_PRACTICE2} = 'PRACTICE WITH MOT LOCALIZER'; % get used to task during anatomical

% day 2
SESSIONSTRINGS{SCAN_PREP} = 'SCANNER PREPARATION'; % scan prep
SESSIONSTRINGS{MOT_PRACTICE} = 'MOT PRACTICE'; % get used to task during anatomical
SESSIONSTRINGS{MOT_PREP} = 'MOT PREP'; % realtime rsvp
SESSIONSTRINGS{RSVP2} = 'FRUIT HARVEST 2'; % fruit harvest task practice and familiarization of words
SESSIONSTRINGS{FAMILIARIZE3} = 'FAMILIARIZE - MOT LOCALIZER'; % rsvp study learn associates
SESSIONSTRINGS{TOCRITERION3} = 'TRAIN TO CRITERION - MOT LOCALIZER'; % get used to task during anatomical
SESSIONSTRINGS{MOT_LOCALIZER} = 'MOT LOCALIZER'; % get used to task during anatomical
SESSIONSTRINGS{RECALL_PRACTICE} = 'DELIBERATE RECALL PRACTICE'; % get used to task during anatomical
for i = 1:NUM_TASK_RUNS
    SESSIONSTRINGS{MOT{i}} = ['MOT RUN ' num2str(i)];
end
SESSIONSTRINGS{RECALL_PRACTICE} = 'DELIBERATE RECALL PRACTICE'; % get used to task during anatomical
SESSIONSTRINGS{RECALL1} = 'RECALL1'; % baseline recollection, used to train recollection classifier
SESSIONSTRINGS{RECALL2} = 'RECALL2'; % post-test recollection, used to measure effectiveness of manipulation
SESSIONSTRINGS{ASSOCIATES} = 'ASSOCIATES TASK'; % face-scene classification
%SESSIONSTRINGS{ANATOMICAL_PREP} = 'ANATOMICAL PREP'; %prepping for first scan
% SETUP: prepare experiment
if ~exist('SUBJECT','var'), SUBJECT = -1; end
if ~exist('SESSION','var'),
    SESSION = -1;
end
if ~exist('SET_SPEED','var') || isempty(SET_SPEED) || SET_SPEED <= 0
    SET_SPEED = -1;
    SPEED = 1;
    debug_mode = false;
else
    SPEED = SET_SPEED;
    debug_mode = true;
end


global CATSTRINGS WORD CAR FACE SCENE NORESP
if SESSION > 0 && SESSION < length(SESSIONSTRINGS)
    exp_string_short = ['textlog_sess' int2str(SESSION)];
    exp_string_long = ['EK' int2str(SESSION)];
else exp_string_short = []; exp_string_long = [];
end
[mainWindow WINDOWSIZE COLORS DEVICE TRIGGER WORKING_DIR LOG_NAME MATLAB_SAVE_FILE ivx fmri SLACK] = ...
    initiate_rt(SUBJECT,SESSION,SESSIONSTRINGS,exp_string_short,exp_string_long,SET_SPEED,COLORS);
if isempty(mainWindow), return; end % quit after printing session map
if ~isempty(strfind(TRIGGER,'=')) || ~isempty(strfind(TRIGGER,'5'))
    CURRENTLY_ONLINE = true; %if scanning
else CURRENTLY_ONLINE = false;
end
if ~scanNow
    CURRENTLY_ONLINE = false; %when we're not looking for triggers
end
%CURRENTLY_ONLINE = false; %change this later!!!
CENTER = WINDOWSIZE.pixels/2;
ALLDEVICES = -1;
if ~fmri && DEVICE == -1 %haven't found device yet
    KEYDEVICES = findInputDevice([],'keyboard');
else
    KEYDEVICES = DEVICE;
end

TIMEOUT = 0.050; %always wait 50 ms for trigger
% find base directory
SUBJ_NAME = num2str(SUBJECT);
documents_path = WORKING_DIR;
% if fmri
%     documents_path = ['/Data1/code/motStudy01/'];
% end
data_dir = fullfile(documents_path, 'BehavioralData');
dicom_dir = fullfile('/Data1/code/motStudy02/', 'data', SUBJ_NAME); %where all the dicom information is FOR THAT SUBJECT
if SESSION >= MOT{1}
    runNum = SESSION - MOT{1} + 1;
    classOutputDir = fullfile(dicom_dir,['motRun' num2str(runNum)], 'classOutput/');
end
if ~exist(data_dir,'dir'), mkdir(data_dir); end
ppt_dir = [data_dir filesep SUBJ_NAME filesep];

if ~exist(ppt_dir,'dir'), mkdir(ppt_dir); end
base_path = [fileparts(which('mot_realtime01.m')) filesep];
MATLAB_SAVE_FILE = [ppt_dir MATLAB_SAVE_FILE];
LOG_NAME = [ppt_dir LOG_NAME];


% SETUP: declarations
%this is where stimuli are stored
% basic session info
stim.session = SESSION;
stim.subject = SUBJECT;
stim.sessionName = SESSIONSTRINGS{SESSION};
stim.num_realtime = 10;
%stim.num_long = 10; %just delete this here?
stim.num_omit = 10;
stim.num_learn = 8;
stim.num_localizer = 16;
stim.num_total = stim.num_realtime + stim.num_omit + stim.num_learn + stim.num_localizer;
stim.runSpeed = SPEED;
stim.TRlength = 2*SPEED;
stim.fontSize = 24;
NUM_MOTLURES = 0; %changed here from 5 6/23
NUM_RECALL_LURES = stim.num_realtime + stim.num_omit;
lureCounter = 1000;
look = 0;
% input mapping
if ~fmri
    THUMB = 'z';
    INDEXFINGER='e';
    MIDDLEFINGER='r';
    RINGFINGER='t';
    PINKYFINGER='y';
else
    KEYDEVICES = DEVICE;
    THUMB='1';
    INDEXFINGER='2';
    MIDDLEFINGER='3';
    RINGFINGER='4';
    PINKYFINGER='5';
    look = 1; % look for audio device
    %     if strcmp(TRIGGER,'5'); should already be set to =
    %         TRIGGER = '=';
    %     end
end
%[keys, valid_map, cresp, cresp_map] = keyCheck(keys,cresp,strict);

% if test
%     KEYDEVICES = ALLDEVICES;
%     DEVICE = ALLDEVICES;
% end
keys = [THUMB INDEXFINGER MIDDLEFINGER RINGFINGER PINKYFINGER];
keyCell = {THUMB, INDEXFINGER, MIDDLEFINGER, RINGFINGER, PINKYFINGER};
if fmri
    allkeys = [keys TRIGGER];
else
    allkeys = keys;
end
% define key names so don't have to do it later
for i = 1:length(allkeys)
    keys.code(i,:) = getKeys(allkeys(i));
    keys.map(i,:) = zeros(1,256);
    keys.map(i,keys.code(i,:)) = 1;
end

% scales and valid key entries
mc_keys = keyCell(2:5);
mc_keycode = keys.code(2:5,:);
mc_map = sum(keys.map(1:5,:));
subj_keys = keyCell;
subj_keycode = keys.code(1:5,:);
subj_map = sum(keys.map(1:5,:));
target_keys = keyCell([1 5]);
target_keycode = keys.code([1 5],:);
target_map = sum(keys.map([1 5],:));
fruit_key = keyCell(2);
fruit_keycode = keys.code(2,:);
fruit_map = keys.map(2,:);
kbTrig_keycode= keys.code(2,:);
if fmri
    TRIGGER_keycode = keys.code(6,:);
end

mc_scale= makeMap({'farL','midL','midR','farR'}, 1:4, mc_keys);
subj_scale = makeMap({'no image', 'generic', '1 detail', '2+ details', 'full'}, 1:5, subj_keys);
target_scale = makeMap({'non-target', 'target'}, [0 1], target_keys);
recog_scale = makeMap({'new','old'}, [0 1], target_keys);
rsvp_scale = makeMap({'target'}, 1, fruit_key);

% stimulus categories
WORD = 1;
CAR = 2;
FACE = 3;
SCENE = 4;

% cue data struct
STIMULI = 1;
CLASS = 2;
EXPOSURE_DUR = 3;
ID = 4;
ACT_READOUT = 5;
EXPOS_DELTA = 6;
LAT_MVT = 7;

% mechanical variables
minimumDisplay = 0.25;
ALLMATERIALS = -1;
MAINPROPORTIONS = [0 0 0 1];
VERTICAL = 2;
HORIZONTAL = 1;
CORRECT = 1;
INCORRECT = 0;
NORESP = -1;
WRITE = 1;
PICDIMS = [256 256];
pic_size = [200 200];
%pic_size = [256 256]; %changed from [200 200]
RESCALE_FACTOR = pic_size/PICDIMS;
% multi choice control
FIXED = 1;
VARIABLE = 0;
CHOICES = 4;

% conditions
REALTIME = 1;
OMIT = 2;
LUREWORD = 3;

% OMIT = 3;
% LUREWORD = 4;

FRUIT = 4;
PRACTICE = 5;

LEARN = 6;
LOC = 7;

% stimulus filepaths
MATLAB_STIM_FILE = [ppt_dir 'mot_realtime01_subj_' num2str(SUBJECT) '_stimAssignment.mat'];
CUELISTFILE = [base_path 'stimuli/text/wordpool.txt'];
CUELISTFILE_TARGETS = [base_path 'stimuli/text/wordpool_targets_anne.txt'];
TRAININGCUELIST = [base_path 'stimuli/text/wordpool_targets_training.txt'];
%      CALIBRATION_TARGET = [base_path 'stimuli/NTB_5cal-10left-5up_1600x1200_black.jpg'];
CALIBRATION_TARGET = [base_path 'stimuli/NTB_5cal-10left-5up_1280x720_black.jpg'];
CUETARGETFILE = [base_path 'stimuli/text/ed_plants.txt'];
DESIGNFILE = [base_path 'khenderson_localizer_design_' int2str(mod(SUBJECT,3)+1) '.csv'];
%CATFILES = {[base_path 'stimuli/bw_words.txt'],[base_path 'stimuli/bw_cars.txt'],[base_path 'stimuli/bw_faces.txt'],[base_path 'stimuli/bw_bedrooms.txt']};
%PICLISTFILE = {[base_path 'stimuli/bw_bedrooms.txt'],CATFILES{2}, CATFILES{3}, CATFILES{4}};
PICLISTFILE = [base_path 'stimuli/SCREENNAMES.txt'];
PICFOLDER = [base_path 'stimuli/STIM/ALLIMAGES' filesep];
TRAININGPICFOLDER = [base_path 'stimuli/STIM/training' filesep];
TRAININGLISTFILE = [base_path 'stimuli/TRAININGSCREEN.txt'];
% present mapping without keylabels if ppt. is in the scanner
if CURRENTLY_ONLINE && SESSION > TOCRITERION3
    KEY_MAPPING = [base_path 'stimuli/bwvividness.jpg'];
else KEY_MAPPING = [base_path 'stimuli/bwvividness.jpg'];
end

% strings
CATSTRINGS = {'word','car','face','scene'};
CONDSTRINGS = {'realtime','omit','lure','fruit','practice','learn','localizer'};
MOTSTRINGS = {'hard-targ','easy-targ','hard-lure','easy-lure',[],[],'prep'};
MOT_RT_STRINGS = {'rt-targ'};
NOTIFY = 'Great work! You finished the task.\n\nPlease notify your experimenter.';
CONGRATS = 'Great work! You finished the task.\n\nPlease wait for further instructions.';

% modify instructions if ppt. is in the scanner
% if CURRENTLY_ONLINE && SESSION > TOCRITERION3
    STILLEXPLAIN = ['Please remember that moving your head even a little during scanning blurs our picture of your brain.'];
    STILLREMINDER = ['The scan is now starting.\n\nMoving your head even a little blurs the image, so '...
        'please try to keep your head totally still until the scanning noise stops.\n\n Do it for science!'];
% else
%     STILLEXPLAIN = [];
%     STILLREMINDER = [];
% end
PROGRESS_TEXT = 'INDEX';
final_instruct_continue = ['\n\n-- Press ' PROGRESS_TEXT ' to begin once you understand these instructions --'];
%end

% timing constants
STABILIZATIONTIME = 2 * stim.TRlength;
STILLDURATION = 3 * stim.TRlength * SPEED;
CONGRATSDURATION = 3*SPEED;
INSTANT = 0.001;

% initialize random seed generator
%s = RandStream('mt19937ar','Seed','shuffle');
seed = randseedwclock();

%RandStream.setGlobalStream(s);
% find a stimulus file if this is not first session
if SESSION ~= SETUP
    try
        load(MATLAB_STIM_FILE);
    catch
        error('No stimulus assignment file detected');
    end
end

%this has to be after you load the actual subject info
if SESSION > MOT_PREP
    if s2 < 0 %put an error message exciting here
        Screen('TextSize',mainWindow,stim.fontSize);
        halfway = ['Thanks so much for participating! Unfortunately, we cannot continue the experiment because you haven''t matched a previous '...
            'subject''s data. This is purely by chance and is in no way a reflection of your performance. Please notify the experimenter now.'];
        displayText(mainWindow,halfway,INSTANT,'center',COLORS.MAINFONTCOLOR,WRAPCHARS);
        WaitSecs(60)
        sca;
        error('Could not continue :(')
    else
    ppt_dir2 = [data_dir filesep num2str(s2) filesep];
    MATLAB_PREV_STIM = [ppt_dir2 'mot_realtime01_subj_' num2str(s2) '_stimAssignment.mat'];
    s_prev = load(MATLAB_PREV_STIM);
    temp = s_prev.preparedCues;
    temp(21:28) = cues{1}{6}{1};
    preparedCues = temp;
    temp = s_prev.pics;
    temp(21:28) = trainPics;
    pics = temp;
    pairIndex = s_prev.pairIndex;
    stimmap = makeMap(preparedCues);
    lureWords = s_prev.lureWords;
    recogLures = s_prev.recogLures;
    save(MATLAB_STIM_FILE, 'cues', 'preparedCues', 'pics', 'pairIndex', 'lureWords', 'recogLures', 'stimmap', 'trainPics');
    clear cues preparedCues pics pairIndex lureWords recogLures stimmap
    load(MATLAB_STIM_FILE);
    end
end
Screen('TextSize',mainWindow,stim.fontSize);

% main experiment session switch
switch SESSION
    %% 0. SETUP
    case SETUP
        %this is where we load the stimuli from the previous subject
%         if SESSION == 7
%         load(MATLAB_PREV_STIM);
%         end

        %don't need a stimulus file for everything because we can just go
        %by session
        trainWords = readStimulusFile(TRAININGCUELIST,stim.num_learn);
        cues{STIMULI}{LEARN}{1} = trainWords;
        trainPics = readStimulusFile_evenIO(TRAININGLISTFILE,stim.num_learn);
                
        % clean up
        system(['cp ' base_path 'mot_realtime01b.m ' ppt_dir 'mot_realtime01b_executed.m']);
        save(MATLAB_STIM_FILE, 'cues', 'trainPics');
        
        mot_realtime01b(SUBJECT,SESSION+1,SET_SPEED,scanNum,scanNow);
        
        
        %% 1. FAMILIARIZATION
    case {FAMILIARIZE, FAMILIARIZE2, FAMILIARIZE3}
        % print headers to file and command window - don't need to wait for
        % trigger pulses here
        header = ['\n\n\n*******************' exp_string_long '*******************\n'];
        header2 = ['SESSION ' int2str(SESSION) ' initiated ' datestr(now) ' for SUBJECT number ' int2str(SUBJECT) '\n\n'];
        printlog(LOG_NAME,['\nSESSION ' int2str(SESSION) ' initiated ' datestr(now) ' for SUBJECT number ' int2str(SUBJECT) '\n\n']);
        
        fprintf(header);
        fprintf(header2);
        % declarations
        stim.cueDuration = 2*SPEED;    % cue word alone for 0ms
        stim.picDuration = 4*SPEED;    % cue with associate for 4000ms
        stim.isiDuration = 2*SPEED;
        stim.textRow = WINDOWSIZE.pixels(2) / 5; %changed from 5, then 3
        stim.picRow = WINDOWSIZE.pixels(2) *5/9;
        NUMRUNS = 1;
        PROGRESS = INDEXFINGER;
        PROGRESS_TEXT = 'INDEX';
        
        
        % initialization
        trial = 0;
        printlog(LOG_NAME,'session\ttrial\tpair\tonset\tdur\tcue         \tassociate   \n');
        

        % open that specific session
        if SESSION == FAMILIARIZE
            [stim.cond stim.condString stimList] = counterbalance_items({cues{STIMULI}{LEARN}{1}},{CONDSTRINGS{LEARN}}); %this just gets the cue words
            picList = lutSort(stimList, cues{STIMULI}{LEARN}{1}, trainPics);
            IDlist = lutSort(stimList, cues{STIMULI}{LEARN}{1}, 1:stim.num_learn);
            config.nTrials = length(stimList);
            stim.stim = stimList;
            stim.picStim = picList;
            stim.id = IDlist;
        else
            % load in previous subject's info
            fname = findNewestFile(ppt_dir2,fullfile(ppt_dir2, ['mot_realtime01_' num2str(s2) '_' num2str(SESSION)  '*.mat']));
            y = load(fname);
            stim.stim = y.stim.stim;
            stim.id = y.stim.id;
            stim.picStim = y.stim.picStim;
            stim.cond = y.stim.cond;
            config.nTrials = y.config.nTrials;
        end
      

        if SESSION == FAMILIARIZE2
            halfway = ['Great job, youre''re halfway there! You can take a stretching or bathroom break if you need to now. \n\n-- press ' PROGRESS_TEXT ' to continue when you''re ready. --'];
            displayText(mainWindow,halfway,INSTANT,'center',COLORS.MAINFONTCOLOR,WRAPCHARS);
            waitForKeyboard(kbTrig_keycode,KEYDEVICES);
        end

        
        instruct = ['NAMED SCENES\n\nToday, you will learn the names of ' num2str(config.nTrials) ' different scenes. ' ...
            'It is important that you learn these now, as you will need to be able to picture each scene based on its name throughout our study.\n\n' ...
            'In this section, you will get a chance to study each name-scene pair, one pair at a time. To help you remember each pair, try to imagine how ' ...
            'each scene got its name - the more vivid and unique, the better your memory will be. However, you will see each scene for only four seconds, ' ...
            'so you will need to work quickly.\n\n-- press ' PROGRESS_TEXT ' to begin --'];
        instruct2 = ['Now we will repeat the NAMED SCENE task from before, but this time we will be using different scenes'];
        displayText(mainWindow,instruct,INSTANT,'center',COLORS.MAINFONTCOLOR,WRAPCHARS);
        
        
        stim.subjStartTime = waitForKeyboard(kbTrig_keycode,KEYDEVICES);
        runStart = GetSecs;
        %first isi here
        config.TR = stim.TRlength;
        config.nTRs.ISI = stim.isiDuration/stim.TRlength;
        config.nTRs.cue = stim.cueDuration/stim.TRlength;
        config.nTRs.pic = stim.picDuration/stim.TRlength;
        %config.nTrials = length(stimList);
        
        config.nTRs.perTrial =  config.nTRs.ISI + config.nTRs.cue + config.nTRs.pic;
        config.nTRs.perBlock = (config.nTRs.perTrial)*config.nTrials+ config.nTRs.ISI; %includes the last ISI and 20 s fixation in the beginning
        % calculate all future onsets
        timing.plannedOnsets.preITI(1:config.nTrials) = runStart + ((0:config.nTrials-1)*config.nTRs.perTrial)*config.TR;
        timing.plannedOnsets.cue(1:config.nTrials) = timing.plannedOnsets.preITI + config.nTRs.ISI*config.TR;
        timing.plannedOnsets.pic(1:config.nTrials) = timing.plannedOnsets.cue + config.nTRs.cue*config.TR;
        timing.plannedOnsets.lastITI = timing.plannedOnsets.pic(end) + config.nTRs.pic*config.TR;
        
        
        
        % repeat trials for full stimulus set
        for n=1:config.nTrials
            
            %present ISI
            timespec = timing.plannedOnsets.preITI(n) - SLACK;
            timing.actualOnsets.preITI(n) = isi_specific(mainWindow,COLORS.MAINFONTCOLOR, timespec);
            fprintf('Flip time error = %.4f\n', timing.actualOnsets.preITI(n) - timing.plannedOnsets.preITI(n));
            
            trial = trial + 1;

            
            
            %present cue
            timespec = timing.plannedOnsets.cue(n) - SLACK; %subtract so it's coming at the next possible refresh
            timing.actualOnsets.cue(n) = displayText_specific(mainWindow,stim.stim{trial},stim.textRow,COLORS.MAINFONTCOLOR,WRAPCHARS, timespec);
            fprintf('Flip time error = %.4f\n', timing.actualOnsets.cue(n) - timing.plannedOnsets.cue(n));
            % prepare cue+associate window
            %RESCALE_FACTOR = (PICDIMS/WINDOWSIZE.pixels)/4;%be 1/4 of the screen
            if SESSION < 6
                picIndex = prepImage(strcat(TRAININGPICFOLDER, stim.picStim{trial}),mainWindow);
            else
                picIndex = prepImage(strcat(PICFOLDER, stim.picStim{trial}),mainWindow);
            end
            topLeft(HORIZONTAL) = CENTER(HORIZONTAL) - (PICDIMS(HORIZONTAL)*RESCALE_FACTOR)/2;
            topLeft(VERTICAL) = stim.picRow - (PICDIMS(VERTICAL)*RESCALE_FACTOR)/2;
            %putting word and image
            
            DrawFormattedText(mainWindow,stim.stim{trial},'center',stim.textRow,COLORS.MAINFONTCOLOR,WRAPCHARS);
            Screen('DrawTexture', mainWindow, picIndex, [0 0 PICDIMS],[topLeft topLeft+PICDIMS.*RESCALE_FACTOR]);
            % show cue with associate
            timespec = timing.plannedOnsets.pic(n) - SLACK;
            timing.actualOnsets.pic(n) = Screen('Flip',mainWindow,timespec);% pass third input to screen flip tell it when you want it to happen
            fprintf('Flip time error = %.4f\n', timing.actualOnsets.pic(n) - timing.plannedOnsets.pic(n));
            
            %Screen('Close',picIndex);
            offsetTime = GetSecs;
            % report trial data
            printlog(LOG_NAME,'%d\t%d\t%d\t%-6s\t%-6s\t%-12s\t%-12s\n',SESSION,trial,stim.id(n),int2str((timing.actualOnsets.cue(n)-stim.subjStartTime)*1000),int2str((offsetTime-timing.actualOnsets.cue(n))*1000),stim.stim{n},stim.picStim{n});
        end
        
        timespec = timing.plannedOnsets.lastITI - SLACK;
        timing.actualOnsets.lastITI = isi_specific(mainWindow,COLORS.MAINFONTCOLOR, timespec);
        fprintf('Flip time error = %.4f\n', timing.actualOnsets.lastITI- timing.plannedOnsets.lastITI);
        WaitSecs(stim.isiDuration);
        % clean up
        save(MATLAB_SAVE_FILE,'stim','config', 'timing');
        
        displayText(mainWindow,CONGRATS,CONGRATSDURATION,'center',COLORS.MAINFONTCOLOR,WRAPCHARS);
        printlog(LOG_NAME,['\n\nSESSION ' int2str(SESSION) ' ended ' datestr(now) ' for SUBJECT number ' int2str(SUBJECT) '\n\n']);
        printlog(LOG_NAME,'\n\n\n******************************************************************************\n');
        % return
        sca
        if SESSION > MOT_PREP
            mot_realtime01b(SUBJECT,SESSION+1,SET_SPEED,scanNum,scanNow,s2);
        else
            mot_realtime01b(SUBJECT,SESSION+1,SET_SPEED,scanNum,scanNow);
        end
        
        %% 2. LEARN TO CRITERION
    case {TOCRITERION1, TOCRITERION2, TOCRITERION2_REP, TOCRITERION3}
        
        % stimulus presentation parameters
        stim.cueDuration = 4*SPEED;
        stim.feedbackDuration = 0.5*SPEED;
        stim.reStudyDuration = 4*SPEED;
        stim.isiDuration = 4*SPEED;
        stim.choiceWidth = WINDOWSIZE.pixels(HORIZONTAL) / (CHOICES+1);
        stim.gapWidth = 10;
        stim.goodFeedback = '!!!';
        stim.badFeedback = 'X';
        stim.textRow = WINDOWSIZE.pixels(2) *(2.5/9); %changed from 5, then 3
        stim.picRow = WINDOWSIZE.pixels(2) *(5/9);
        
        % other constants
        n=0;
        PROGRESS = INDEXFINGER;
        PROGRESS_TEXT = 'INDEX';
        
        % stimulus data fields
        stim.trial = 0;
        stim.triggerCounter = 1;
        stim.missedTriggers = 0;
        stim.loopNumber = 1;
        match = 0;
        % sequence preparation
        if SESSION == TOCRITERION1
            [cond strings stimList] = counterbalance_items({cues{STIMULI}{LEARN}{1}},{CONDSTRINGS{LEARN}});
            condmap = makeMap({'stair'});
            pics = lutSort(stimList, cues{STIMULI}{LEARN}{1}, trainPics);
            pairIndex = lutSort(stimList, cues{STIMULI}{LEARN}{1}, 1:stim.num_learn);
%             preparedCues = stimList; % so this is the stimuli in order we'll present for the first round
            stimmap = makeMap(cues{STIMULI}{LEARN}{1});
            nstim = length(pics);
        else
            match = 1;
            fname = findNewestFile(ppt_dir2,fullfile(ppt_dir2, ['mot_realtime01_' num2str(s2) '_' num2str(SESSION)  '*.mat']));
            y = load(fname);
            fname = findNewestFile(ppt_dir2,fullfile(ppt_dir2,['EK' num2str(SESSION) '*.mat']));
            y2 = load(fname);
            trials = table2cell(y2.datastruct.trials);
            stimID = cell2mat(trials(:,8));
            nstim = length(unique(stimID));
            stim.choicePos = y.stim.choicePos(1:nstim,:); % in (trials, position)
            stimList = preparedCues(stimID(1:nstim));
            pairIndex = stimID(1:nstim);
            pics = pics(stimID(1:nstim));
            prev_cpos = cell2mat(trials(:,22)) -1; %this is the position of the correct choice on every trial
            cond = cell2mat(trials(:,9));
            cond = cond(1:nstim);
            strings = y.stim.condString(1:nstim);
            %y2 has the correct positions!
            %stimmap = makeMap(preparedCues); taking this out because if
            %we take one part of the cues will be different
            %do: make map of preparedCues--but in this cae it's just the
            %list of stimuli but I think they're already ordered in the
            %way they'll be presented? at least in the first round-
            %we could just do this from the start--or just no yoke the
            %first round
            %figure out how to set only those stimuli? maybe just by going
            %through those indices/ look how it was done before
            if SESSION == TOCRITERION2 || SESSION == TOCRITERION2_REP
                %check if this leads to errors with all the loading stim
                condmap = makeMap({'realtime','omit'});
            else
                condmap = makeMap({'localizer'});
            end
        end
        %first pics is all pics, preparedCues is all cues--pics is then
        %the' 
        %stimuli that were used in the run
        
        %stim.gotItem(1:length(preparedCues)) = NORESP;
        stim.gotItem(1:nstim) = NORESP;
        % initialize questions
        mc_promptDur = 3.5 * SPEED;
        mc_listenDur = 0 * SPEED;
        subj_triggerNext = false;
        mc_triggerNext = false;
        subj_promptDur = 4 * SPEED;
        subj_listenDur = 0 * SPEED;
        
        
        % instructions
        instruct1 = ['SCENE TEST\n\nNow we will test your memory. First, we will show a scene name. In your mind''s eye, try to picture the ' ...
            'asssociated scene in as much detail as possible, including any specific objects or features. Try to simulate actually looking ' ...
            'at the picture. Because we are studying mental imagery, it is crucial for our experiment that you really do this, both here and ' ...
            'later on'...
            '\n\n--- Press ' PROGRESS_TEXT ' once you understand these instructions ---'];
        
        instruct2 = ['After you respond, we will show you four scenes. Using your index, middle, ring and pinky fingers ' ...
            '(corresponding to the leftmost to rightmost image), please identify the scene that goes with the current name.\n\nIf you ' ...
            'suspect one scene, select it even if you''re unsure; but if you really have no idea at all which picture is correct, do not guess randomly. ' ...
            'If you have no idea, use your THUMB to SKIP the question. Thus, you should be responding every trial, using either your INDEX ' ...
            'to PINKY fingers to choose an image, or using your THUMB if you don''t know which image to choose. '...
            '\n\nDepending how you answer, you will see a green "!!!" (correct) or a red "X" (incorrect). The task will continue until you have ' ...
            'named all scenes correctly. Good luck!\n\n--- Press ' PROGRESS_TEXT ' to begin ---'];
        
        % present instructions
        if SESSION~= TOCRITERION2_REP
            DrawFormattedText(mainWindow,' ','center','center',COLORS.MAINFONTCOLOR,WRAPCHARS);
            displayText(mainWindow,instruct1,minimumDisplay,'center',COLORS.MAINFONTCOLOR,WRAPCHARS);
            waitForKeyboard(kbTrig_keycode,DEVICE);
            displayText(mainWindow,instruct2,minimumDisplay,'center',COLORS.MAINFONTCOLOR,WRAPCHARS);
        else
            instruct2 = ['We will now repeat the SCENE TEST. You will have to name each scene correctly again. '...
                'Good luck!\n\n--- Press ' PROGRESS_TEXT ' to begin ---'];
            DrawFormattedText(mainWindow,' ','center','center',COLORS.MAINFONTCOLOR,WRAPCHARS);
            displayText(mainWindow,instruct2,minimumDisplay,'center',COLORS.MAINFONTCOLOR,WRAPCHARS);
        end
        
        
        stim.subjStartTime = waitForKeyboard(kbTrig_keycode,KEYDEVICES);
       
        objectiveEK = initEasyKeys([exp_string_long '_OB'], SUBJ_NAME,ppt_dir, ...
            'default_respmap', subj_scale, ...
            'stimmap', stimmap, ...
            'condmap', condmap, ...
            'trigger_next', mc_triggerNext, ...
            'prompt_dur', mc_promptDur, ...
            'listen_dur', mc_listenDur, ...
            'exp_onset', stim.subjStartTime, ...
            'console', false, ...
            'device', DEVICE);
        [objectiveEK] = startSession(objectiveEK);
        
        runStart = GetSecs;
        config.TR = stim.TRlength;
        config.nTRs.ISI = stim.isiDuration/stim.TRlength;
        config.nTRs.cue = stim.cueDuration/stim.TRlength;
        %config.nTRs.vis = subj_promptDur/stim.TRlength;
        config.nTRs.mc = (mc_promptDur + stim.feedbackDuration)/stim.TRlength;
        config.nTRs.reStudy = stim.reStudyDuration/stim.TRlength;
        
        config.nTRs.trial(2) = config.nTRs.ISI + config.nTRs.cue + config.nTRs.mc;
        config.nTRs.trial(1) = config.nTRs.trial(2) + config.nTRs.reStudy;
        
        while n < nstim %cycle through all stimuli
            % initialize trial
            n = n+1;
            if stim.gotItem(n) ~= CORRECT
                stim.gotItem(n) = NORESP;
                stim.trial = stim.trial + 1; %this is different from n!!! n is for stimulus number, stim.trial is trial number
                
                %so basically all the rigging is going to be done in the
                %first round, meaning if the trial number is LEQ the number
                %of stimuli (20) then check these things for choice
                %position and the other stimuli shown with it then
                %otherwise run like normal
                
                timing.plannedOnsets.preITI(stim.trial) = runStart;
                if stim.trial > 1
                    timing.plannedOnsets.preITI(stim.trial) = timing.plannedOnsets.preITI(stim.trial - 1) + config.nTRs.trial(lastacc)*config.TR;
                end
                timespec = timing.plannedOnsets.preITI(stim.trial) - SLACK;
                timing.actualOnsets.preITI(stim.trial) = isi_specific(mainWindow,COLORS.MAINFONTCOLOR,timespec);
                fprintf('Flip time error = %.4f\n', timing.actualOnsets.preITI(stim.trial) - timing.plannedOnsets.preITI(stim.trial));
                
                % show cue window
                stim.stim{stim.trial} = stimList{n};
                stim.associate{stim.trial} = pics{n};
                stim.id(stim.trial) = pairIndex(n);
                stim.cond(stim.trial) = cond(n);
                stim.condString{stim.trial} = strings{n};
                icresp = 3:5;
                cresp = keyCell(icresp);
                cresp_map = sum(keys.map(icresp,:));
                
                timing.plannedOnsets.cue(stim.trial) = timing.plannedOnsets.preITI(stim.trial) + config.nTRs.ISI*config.TR;
                timespec = timing.plannedOnsets.cue(stim.trial) - SLACK;
                timing.actualOnsets.cue(stim.trial) = displayText_specific(mainWindow,stimList{n},'center',COLORS.MAINFONTCOLOR,WRAPCHARS,timespec);
                fprintf('Flip time error = %.4f\n', timing.actualOnsets.cue(stim.trial) - timing.plannedOnsets.cue(stim.trial));
                
                % choose lures
                %yoke if within the first presentation
                if match && stim.trial <= nstim
                    cpos{stim.trial} = prev_cpos(stim.trial);
                    
                    lureIndex = setdiff(1:CHOICES,cpos{stim.trial}); %this is the index in the positioning of the lure images
                    temp_pics = pics; %these are the 5 used in the learning trial
                    numLures = 0;
                    fullidx = 1:length(temp_pics);
                    notidx = n;
                    good_idx = setdiff(fullidx,notidx); %this is the index for all images in the data set
                    inside = isempty(strfind(pics{n}, 'o')); %if this is true, then the trial's image is an indoor image
                    outside = ~inside;
                    allOtherPics = pics;
                    allOtherPics(n) = [];
                    
                    for i=1:CHOICES-1
                        picLures{i} = allOtherPics{stim.choicePos(stim.trial,lureIndex(i))}; %so lure indices(i) should be from 1:npics-1 (all other pics but the correct one)
                        if SESSION < MOT_PREP
                            picIndex(lureIndex(i)) = prepImage(char(strcat(TRAININGPICFOLDER, picLures{i})),mainWindow);
                        else
                            picIndex(lureIndex(i)) = prepImage(char(strcat(PICFOLDER, picLures{i})),mainWindow);
                        end
                        
                    end
                    %then put which were the lures and then their positions
                else
                    cpos{stim.trial} = randi(4);
                    lureIndex = setdiff(1:CHOICES,cpos{stim.trial}); %this is the index in the positioning of the lure images
                    temp_pics = pics; %these are the 5 used in the learning trial
                    numLures = 0;
                    fullidx = 1:length(temp_pics);
                    notidx = n;
                    good_idx = setdiff(fullidx,notidx); %this is the index for all images in the data set
                    inside = isempty(strfind(pics{n}, 'o')); %if this is true, then the trial's image is an indoor image
                    outside = ~inside;
                    allOtherPics = pics;
                    allOtherPics(n) = [];
                    indexC = strfind(allOtherPics, 'o');
                    allOtherOutside = find(not(cellfun('isempty', indexC)));
                    allOtherInside = setdiff(1:length(allOtherPics),allOtherOutside);
                    
                    % choose 2 of each inside/outside
                    if inside %choose 2 outside
                        outsidePics = allOtherOutside(randperm(length(allOtherOutside),2));
                        insidePics = allOtherInside(randperm(length(allOtherInside),1));
                    else % if outside, choose 2 inside
                        outsidePics = allOtherOutside(randperm(length(allOtherOutside),1));
                        insidePics = allOtherInside(randperm(length(allOtherInside),2));
                    end
                    lureIndices = Shuffle([outsidePics insidePics]);
                    
                    for i=1:length(lureIndices)
                        stim.choicePos(stim.trial,lureIndex(i)) = lureIndices(i);
                        picLures{i} = allOtherPics{lureIndices(i)}; %so lure indices(i) should be from 1:npics-1 (all other pics but the correct one)
                        if SESSION < MOT_PREP
                            picIndex(lureIndex(i)) = prepImage(char(strcat(TRAININGPICFOLDER, picLures{i})),mainWindow);
                        else
                            picIndex(lureIndex(i)) = prepImage(char(strcat(PICFOLDER, picLures{i})),mainWindow);
                        end
                    end   
                end
                
                %so go from the beginning getting the correct position
                %cpos--get from stim.cpos, then get indexing for the other
                %pictures that isn't for that stimulus

                % close and replace the lure in the spot that belongs to the target
                if SESSION < 6
                    picIndex(cpos{stim.trial}) = prepImage(strcat(TRAININGPICFOLDER, pics{n}),mainWindow);
                else
                    picIndex(cpos{stim.trial}) = prepImage(strcat(PICFOLDER, pics{n}),mainWindow); %%ooooh here you take the lure out and add target
                end
                stim.choicePos(stim.trial,cpos{stim.trial}) = n;
                
                % draw exemplar options
                destDims = [200 200];
                %destDims = min(PICDIMS*RESCALE_FACTOR,PICDIMS .* (stim.choiceWidth ./ PICDIMS(HORIZONTAL)));
                RESCALE_NEW = destDims(2)/PICDIMS(2);
                topLeft(HORIZONTAL) = CENTER(HORIZONTAL) - (destDims(HORIZONTAL)*CHOICES/2) - (stim.gapWidth*CHOICES/2);
                topLeft(VERTICAL) = stim.picRow - (PICDIMS(VERTICAL)*RESCALE_NEW)/2;
                Screen('FillRect', mainWindow, COLORS.BGCOLOR);
                for i=1:CHOICES
                    Screen('DrawTexture', mainWindow, picIndex(i), [0 0 PICDIMS],[topLeft topLeft+destDims]);
                    topLeft(HORIZONTAL) = topLeft(HORIZONTAL) + destDims(HORIZONTAL) + stim.gapWidth;
                end
                DrawFormattedText(mainWindow,stimList{n},'center',stim.textRow,COLORS.MAINFONTCOLOR,WRAPCHARS);
                %multiple choice
                timing.plannedOnsets.mc(stim.trial) = timing.plannedOnsets.cue(stim.trial) + config.nTRs.cue*config.TR;
                timespec =  timing.plannedOnsets.mc(stim.trial) - SLACK;
                %display multiple choice options here
                timing.actualOnsets.mc(stim.trial) = Screen('Flip',mainWindow, timespec);
                fprintf('Flip time error = %.4f\n', timing.actualOnsets.mc(stim.trial) - timing.plannedOnsets.mc(stim.trial));
                objectiveEK = easyKeys(objectiveEK, ...
                    'onset', timing.actualOnsets.mc(stim.trial), ...
                    'stim', stim.stim{stim.trial}, ...
                    'cond', stim.cond(stim.trial), ...
                    'nesting', [SESSION stim.loopNumber stim.trial], ...
                    'cresp', keyCell(cpos{stim.trial}+1), ...
                    'cresp_map', keys.map(cpos{stim.trial}+1,:), 'valid_map', mc_map) ;
                
                % clean up
                for i=1:CHOICES
                    Screen('Close',picIndex(i));
                end
                
                % score this trial
                timing.plannedOnsets.fb(stim.trial) = timing.plannedOnsets.mc(stim.trial) + mc_promptDur;
                timespec = timing.plannedOnsets.fb(stim.trial) - SLACK;
                if objectiveEK.trials.acc(end) == CORRECT
                    stim.gotItem(n) = CORRECT;
                    timing.actualOnsets.fb(stim.trial) = displayText_specific(mainWindow,stim.goodFeedback,'center',COLORS.GREEN,WRAPCHARS, timespec);
                    lastacc = 2;
                else
                    stim.gotItem(n) = INCORRECT;
                    timing.actualOnsets.fb(stim.trial) = displayText_specific(mainWindow,stim.badFeedback,'center',COLORS.RED,WRAPCHARS, timespec);
                    lastacc = 1;
                end
                
                fprintf('Flip time error = %.4f\n', timing.actualOnsets.fb(stim.trial) - timing.plannedOnsets.fb(stim.trial));
                
                % present cue+associate window
                if stim.gotItem(n) ~= CORRECT
                    if SESSION < 6
                        picIndex(1) = prepImage(strcat(TRAININGPICFOLDER, pics{n}),mainWindow);
                    else
                    picIndex(1) = prepImage(strcat(PICFOLDER, pics{n}),mainWindow);
                    end
                    topLeft(HORIZONTAL) = CENTER(HORIZONTAL) - (PICDIMS(HORIZONTAL)*RESCALE_FACTOR/2);
                    topLeft(VERTICAL) = stim.picRow - (PICDIMS(VERTICAL)*RESCALE_FACTOR)/2;
                    DrawFormattedText(mainWindow,stimList{n},'center',stim.textRow,COLORS.MAINFONTCOLOR,WRAPCHARS);
                    Screen('DrawTexture', mainWindow, picIndex(1), [0 0 PICDIMS],[topLeft topLeft+PICDIMS*RESCALE_FACTOR]);
                    
                    timing.plannedOnsets.reStudy(stim.trial) = timing.plannedOnsets.mc(stim.trial) + config.nTRs.mc*config.TR;
                    timespec = timing.plannedOnsets.reStudy(stim.trial) - SLACK;
                    timing.actualOnsets.reStudy(stim.trial) = Screen('Flip',mainWindow,timespec);
                    fprintf('Flip time error = %.4f\n', timing.actualOnsets.reStudy(stim.trial) - timing.plannedOnsets.reStudy(stim.trial));
                    
                    % Screen('Close',picIndex(1));
                end
                
                
                save(MATLAB_SAVE_FILE,'stim', 'timing', 'config');
            end
            
            
            % present feedback
            if SESSION == TOCRITERION1 && stim.trial <= 3
                
                if lastacc == 2 % if correct
                    WaitSecs(stim.feedbackDuration);
                else
                    WaitSecs(stim.reStudyDuration);
                end
                onFB = GetSecs;
                
                if isnan(objectiveEK.trials.resp(end))
                    displayText(mainWindow,['In the multiple choice section, it looks like you either did not provide a response in ' ...
                        'time, or did not use an appropriate key.\n\nRemember that when you have no idea, you should use your THUMB as a SKIP.\n\nAlso remember that your index, middle, ring or pinky ' ...
                        'finger correspond to left, left middle, right middle and right.\n\n' ...
                        '-- Press ' PROGRESS_TEXT ' to continue --'],minimumDisplay,'center',COLORS.MAINFONTCOLOR,WRAPCHARS);
                    waitForKeyboard(kbTrig_keycode,DEVICE);
                end
                if ~isnan(objectiveEK.trials.resp(end))
                    displayText(mainWindow,['Good work! Your multiple choice response were both detected.\n\n' ...
                        '-- Press ' PROGRESS_TEXT ' to continue --'],minimumDisplay,'center',COLORS.MAINFONTCOLOR,WRAPCHARS);
                    waitForKeyboard(kbTrig_keycode,DEVICE);
                end
                offFB = GetSecs;
                timing.plannedOnsets.preITI(stim.trial) = timing.plannedOnsets.preITI(stim.trial) + (offFB-onFB); %only need to change first one bc it's within a trial that it updates (ohh change this after!)
            end
            save(MATLAB_SAVE_FILE,'stim', 'timing', 'config');
            
            
            % when training to criteron, shuffle and repeat incorrect items on list until all items correct
            if (n == length(stimList)) && (sum(stim.gotItem) < length(stimList)) % do this only on the last time
                n = 0; %reset n to next round!!
                stim.loopNumber = stim.loopNumber + 1;
                revisedOrder = randperm(length(stimList));
                stimList = stimList(revisedOrder);
                pics = pics(revisedOrder);
                cond = cond(revisedOrder);
                strings = strings(revisedOrder);
                pairIndex = pairIndex(revisedOrder);
                stim.gotItem = stim.gotItem(revisedOrder);
            end
            
        end
        
        %must have gotten the last choice right to exit
        timing.plannedOnsets.lastITI = timing.plannedOnsets.mc(stim.trial) + config.nTRs.mc*config.TR;
        timespec = timing.plannedOnsets.lastITI - SLACK;
        timing.actualOnsets.lastITI = isi_specific(mainWindow,COLORS.MAINFONTCOLOR,timespec);
        fprintf('Flip time error = %.4f\n', timing.actualOnsets.lastITI - timing.plannedOnsets.lastITI);
        WaitSecs(stim.isiDuration);
        
        % preserve IV's, DV's for later analysis by writing stuff to file here
        save(MATLAB_SAVE_FILE,'stim', 'timing', 'config');
        
        % clean up
        printlog(LOG_NAME,['\n\nSESSION ' int2str(SESSION) ' ended ' datestr(now) ' for SUBJECT number ' int2str(SUBJECT) '\n\n']);
        printlog(LOG_NAME,'\n\n\n******************************************************************************\n');
        %endSession(subjectiveEK, objectiveEK, CONGRATS);
        endSession(objectiveEK, CONGRATS);
        sca
        %return
        %normally would go to session 4 but instead we want to go to
        if SESSION ~= TOCRITERION3
            if SESSION > MOT_PREP
                mot_realtime01b(SUBJECT,SESSION+1,SET_SPEED,scanNum,scanNow,s2);
            else
                mot_realtime01b(SUBJECT,SESSION+1,SET_SPEED,scanNum,scanNow);
            end
        end
        
        %% 3. PRE/POST MEMORY TEST
    case {RECALL_PRACTICE,RECALL1,RECALL2}
        
        % load previous
        fname = findNewestFile(ppt_dir2,fullfile(ppt_dir2, ['mot_realtime01_' num2str(s2) '_' num2str(SESSION)  '*.mat']));
        y = load(fname);
        
        stim.stim = y.stim.stim;
        stim.cond = y.stim.cond;
        stim.condString = y.stim.condString;
        stim.id = y.stim.id;

        % stimulus presentation parameters
        stim.promptDur = 8*SPEED; % cue word alone
        stim.prepDur = 2*SPEED;
        stim.recordDur = 16*SPEED; % cue for multi choice
        stim.isiDuration = 4*SPEED; %
        stim.fixBlock = 20*SPEED;
        num_digit_qs = 3;
        digits_promptDur = 1.9*SPEED;
        digits_isi = 0.1*SPEED;
        digits_triggerNext = false;
        minimal_format = true;
        stim.TRlength = 2;
        subj_triggerNext = false;
        keymap_image = imread(KEY_MAPPING);
        subj_promptDur = 4 * SPEED;
        subj_listenDur = 0 * SPEED;
        % stimulus data fields
        stim.triggerCounter = 1;
        stim.missedTriggers = 0;
        PROGRESS_TEXT = 'INDEX';
        
        
        % all the instructions
        stim.instruct1 = ['MENTAL PICTURES TASK\n\nThis is a memory test, though it is not multiple choice anymore. When a word appears, picture the scene it names as vividly as if you were looking ' ...
            'at it now. Picture its objects, features, and anything else you can imagine. HOLD the image, letting it continue to mature ' ...
            'and take shape for the entire ' num2str(stim.promptDur) ' seconds it is on the screen. Don''t let it fade, and don''t let ' ...
            'yourself "space out". It is essential you actually do this!\n\n' ...
            '-- Press ' PROGRESS_TEXT ' once you understand these instructions --'];
        stim.instruct2 = ['After you have had several seconds to form an image, we will ask you how detailed it was. This rating is not a "test": ' ...
            'we want to understand your real experience, even if no image formed when you felt you SHOULD have had one. Similarly, you should not ' ...
            'adjust your rating based on how sure you are it''s the correct scene. Please make your rating based only on how much scene detail comes to you, ' ...
            'ignoring other mental imagery (e.g., you pictured a beach). You will use the provided rating scale to indicate details, using all five fingers on the key pad.'...
            '\n\n---- Press ' PROGRESS_TEXT ' once you understand these instructions,\n then press it again when you are done viewing the rating scale ---'];
        stim.instruct3 = ['After the rating, you will verbally describe your mental image. A green cross will appear, signalling that '...
            'the recording is beginning. You will have ' num2str(stim.recordDur) ' seconds to give as detailed an explanation '...
            'as possible. Try your best to use the whole ' num2str(stim.recordDur) ' seconds to share your mental picture! \n\nMake sure to only describe the image itself, '...
            'instead of how it related to the matching word. Your description should be detailed enough for someone else to identify the image against similar scenes. \n\n' ...
            'Finally, you will be prompted to answer a series of odd-even questions in each trial (THUMB for even, PINKY for odd).' ...
            final_instruct_continue];
        
        
        % initialize stimulus order with initial warmup item
        if SESSION == RECALL_PRACTICE
            stim.stim = cues{STIMULI}{LEARN}{1}(1:3);
            stim.cond = [PRACTICE, PRACTICE, PRACTICE];
            condmap = makeMap({'PRACTICE'});
            stim.condString = {CONDSTRINGS{PRACTICE}, CONDSTRINGS{PRACTICE}, CONDSTRINGS{PRACTICE}};
            displayText(mainWindow,['MENTAL PICTURES TASK - PRACTICE\n\nThis is a memory test with some differences ' ...
                'from earlier: you will get only one try per item, there is no feedback, and you will verbally recall the scenes instead of choosing the correct option.' ...
                'Please carefully review today''s instructions, since many things have ' ...
                'changed and it is important you follow them exactly.\n\n' ...
                '-- Please press ' PROGRESS_TEXT ' to briefly review the instructions --'],minimumDisplay,'center',COLORS.MAINFONTCOLOR,WRAPCHARS);
            waitForKeyboard(kbTrig_keycode,DEVICE);
        else
            %[stim.cond stim.condString stim.stim] = counterbalance_items({cues{STIMULI}{REALTIME}{1}, cues{STIMULI}{OMIT}{1}},CONDSTRINGS);
            condmap = makeMap({'realtime','omit'});
            if SESSION ==RECALL1
                displayText(mainWindow,['The experiment will now ONLY involve the stimuli that you studied yesterday, both ' ...
                    'for this next task and the rest of the experiment.\n\n' ...
                    '-- Please press ' PROGRESS_TEXT ' to read the instructions for your next task --'],minimumDisplay,'center',COLORS.MAINFONTCOLOR,WRAPCHARS);
                waitForKeyboard(kbTrig_keycode,DEVICE);
            end
            if SESSION == RECALL2
                displayText(mainWindow,['MENTAL PICTURES TASK\n\nThe format of this task is the same as earlier in today''s session.\n\n' ...
                    '-- Please press ' PROGRESS_TEXT ' to briefly review the instructions again --'],minimumDisplay,'center',COLORS.MAINFONTCOLOR,WRAPCHARS);
                waitForKeyboard(kbTrig_keycode,DEVICE);
            end
        end
        
        %generate stimulus ID's first so can add them easily
%         for i = 1:length(stim.cond)
%             pos = find(strcmp(preparedCues,stim.stim{i}));
%             stim.id(i) = pos;
%         end
        
        % display instructions
        DrawFormattedText(mainWindow,' ','center','center',COLORS.MAINFONTCOLOR,WRAPCHARS);
        displayText(mainWindow,stim.instruct1,minimumDisplay,'center',COLORS.MAINFONTCOLOR,WRAPCHARS);
        waitForKeyboard(kbTrig_keycode,DEVICE);
        displayText(mainWindow,stim.instruct2,minimumDisplay,'center',COLORS.MAINFONTCOLOR,WRAPCHARS);
        
        waitForKeyboard(kbTrig_keycode,DEVICE);
        keymap_image = imread(KEY_MAPPING);
        keymap_prompt = Screen('MakeTexture', mainWindow, keymap_image);
        Screen('DrawTexture',mainWindow,keymap_prompt,[],[],[]); %[0 0 keymap_dims],[topLeft topLeft+keymap_dims]);
        Screen('Flip',mainWindow);
        waitForKeyboard(kbTrig_keycode,DEVICE);
        displayText(mainWindow,stim.instruct3,minimumDisplay,'center',COLORS.MAINFONTCOLOR,WRAPCHARS);
        stim.subjStartTime = waitForKeyboard(kbTrig_keycode,DEVICE);
        
        %last instructions
        if SESSION == RECALL_PRACTICE
            displayText(mainWindow,['To help you get used to the feel of this task, we will ' ...
                'now give you three practice words.\n\n' ...
                '-- Press ' PROGRESS_TEXT ' to begin once you understand these instructions --'], ...
                minimumDisplay,'center',COLORS.MAINFONTCOLOR,WRAPCHARS);
            stim.subjStartTime = waitForKeyboard(kbTrig_keycode,DEVICE);
        end
        
        if CURRENTLY_ONLINE && SESSION > TOCRITERION3
            DrawFormattedText(mainWindow,'Waiting for scanner start, hold tight!','center','center',COLORS.MAINFONTCOLOR,WRAPCHARS);
            Screen('Flip', mainWindow);
        end
        
        subjectiveEK = initEasyKeys([exp_string_long '_SUB'], SUBJ_NAME,ppt_dir, ...
            'default_respmap', subj_scale, ...
            'stimmap', stimmap, ...
            'condmap', condmap, ...
            'trigger_next', subj_triggerNext, ...
            'prompt_dur', subj_promptDur, ...
            'listen_dur', subj_listenDur, ...
            'exp_onset', stim.subjStartTime, ...
            'console', false, ...
            'device', DEVICE);
        
        digits_scale = makeMap({'even','odd'},[0 1],keyCell([1 5]));
        condmap = makeMap({'even','odd'});
        digitsEK = initEasyKeys('odd_even', SUBJ_NAME, ppt_dir,...
            'default_respmap', digits_scale, ...
            'condmap', condmap, ...
            'trigger_next', digits_triggerNext, ...
            'prompt_dur', digits_promptDur, ...
            'device', DEVICE);
        
        [subjectiveEK] = startSession(subjectiveEK);
        
        % fixation period for 20 s
        if CURRENTLY_ONLINE && SESSION > TOCRITERION3
            [timing.trig.wait timing.trig.waitSuccess] = WaitTRPulse(TRIGGER_keycode,DEVICE);
            runStart = timing.trig.wait;
            displayText(mainWindow,STILLREMINDER,STILLDURATION,'center',COLORS.MAINFONTCOLOR,WRAPCHARS);
            DrawFormattedText(mainWindow,'+','center','center',COLORS.MAINFONTCOLOR,WRAPCHARS);
            Screen('Flip', mainWindow)
            config.wait = stim.fixBlock; % stim.fixation - 20 s? so 10 TRs
        else
            runStart = GetSecs;
            config.wait = 0;
        end
        
        config.TR = stim.TRlength;
        config.nTRs.ISI = stim.isiDuration/stim.TRlength;
        config.nTRs.prompt = stim.promptDur/stim.TRlength;
        config.nTRs.vis = subj_promptDur/stim.TRlength;
        config.nTRs.prep = stim.prepDur/stim.TRlength;
        config.nTRs.record = stim.recordDur/stim.TRlength;
        config.nTRs.math = (num_digit_qs*(digits_promptDur + digits_isi))/stim.TRlength;
        config.nTrials = length(stim.stim);
        config.nTRs.perTrial = (config.nTRs.ISI + config.nTRs.prompt + config.nTRs.vis + ...
            config.nTRs.prep + config.nTRs.record + config.nTRs.math);
        config.nTRs.perBlock = config.wait/config.TR + (config.nTRs.perTrial)*config.nTrials+ config.nTRs.ISI; %includes the last ISI
        
        % calculate all future onsets
        timing.plannedOnsets.preITI(1:config.nTrials) = runStart + config.wait + ((0:config.nTrials-1)*config.nTRs.perTrial)*config.TR;
        timing.plannedOnsets.prompt(1:config.nTrials) = timing.plannedOnsets.preITI + config.nTRs.ISI*config.TR;
        timing.plannedOnsets.vis(1:config.nTrials) = timing.plannedOnsets.prompt + config.nTRs.prompt*config.TR;
        timing.plannedOnsets.prep(1:config.nTrials) = timing.plannedOnsets.vis + config.nTRs.vis*config.TR;
        timing.plannedOnsets.record(1:config.nTrials) = timing.plannedOnsets.prep + config.nTRs.prep*config.TR;
        timing.plannedOnsets.math(1:config.nTrials) = timing.plannedOnsets.record + config.nTRs.record*config.TR;
        timing.plannedOnsets.lastITI = timing.plannedOnsets.math(end) + config.nTRs.math*config.TR;%%make sure it pauses for this one
        
        cresp = keyCell(3:5);
        cresp_map = sum(keys.map(3:5,:));
        
        stimID = stim.id;
        stimCond = stim.cond;
        sessionInfoFile = fullfile(ppt_dir, ['SessionInfo' '_' num2str(SESSION)]);
        save(sessionInfoFile, 'stimCond','stimID', 'timing', 'config'); 
        
        for n = 1:length(stim.stim)
            % initialize trial and show cue
            stim.trial = n;
            fprintf(['Trial number: ' num2str(n) '\n']);
            
            %show pre ITI
            if CURRENTLY_ONLINE && SESSION > TOCRITERION3
                [timing.trig.preITI(n), timing.trig.preITI_Success(n)] = WaitTRPulse(TRIGGER_keycode,DEVICE,timing.plannedOnsets.preITI(n));
            end
            timespec = timing.plannedOnsets.preITI(n) - SLACK;
            timing.actualOnsets.preITI(n) = isi_specific(mainWindow,COLORS.MAINFONTCOLOR,timespec);
            fprintf('Flip time error = %.4f\n', timing.actualOnsets.preITI(n) - timing.plannedOnsets.preITI(n));
            
            %display word
            if CURRENTLY_ONLINE && SESSION > TOCRITERION3
                [timing.trig.prompt(n), timing.trig.prompt_Success(n)] = WaitTRPulse(TRIGGER_keycode,DEVICE,timing.plannedOnsets.prompt(n));
            end
            timespec = timing.plannedOnsets.prompt(n)-SLACK;
            timing.actualOnsets.prompt(n) = displayText_specific(mainWindow,stim.stim{stim.trial},'center',COLORS.MAINFONTCOLOR,WRAPCHARS,timespec);
            fprintf('Flip time error = %.4f\n', timing.actualOnsets.prompt(n) - timing.plannedOnsets.prompt(n));
            
            %display visualization score
            keymap_prompt = Screen('MakeTexture', mainWindow, keymap_image);
            Screen('DrawTexture',mainWindow,keymap_prompt,[],[],[]); %[0 0 keymap_dims],[topLeft topLeft+keymap_dims]);
            if CURRENTLY_ONLINE && SESSION > TOCRITERION3
                [timing.trig.vis(n), timing.trig.vis_Success(n)] = WaitTRPulse(TRIGGER_keycode,DEVICE,timing.plannedOnsets.vis(n));
            end
            timespec = timing.plannedOnsets.vis(n) - SLACK;
            timing.actualOnsets.vis(n) = Screen('Flip',mainWindow,timespec);
            fprintf('Flip time error = %.4f\n', timing.actualOnsets.vis(n)-timing.plannedOnsets.vis(n));
            subjectiveEK = easyKeys(subjectiveEK, ...
                'onset', timing.actualOnsets.vis(n), ...
                'stim', stim.stim{stim.trial}, ...
                'cond', stim.cond(stim.trial), ...
                'cresp', cresp, 'cresp_map', cresp_map, 'valid_map', subj_map);
            
            %display prep screen for recording
            if CURRENTLY_ONLINE && SESSION > TOCRITERION3
                [timing.trig.prep(n), timing.trig.prep_Success(n)] = WaitTRPulse(TRIGGER_keycode,DEVICE,timing.plannedOnsets.prep(n));
            end
            timespec = timing.plannedOnsets.prep(n) - SLACK;
            timing.actualOnsets.prep(n) = displayText_specific(mainWindow,'+','center',COLORS.MAINFONTCOLOR,WRAPCHARS,timespec);
            fprintf('Flip time error = %.4f\n', timing.actualOnsets.prep(n)-timing.plannedOnsets.prep(n));
            DrawFormattedText(mainWindow,'+','center','center',COLORS.GREEN,WRAPCHARS);
            
            %display green and start recording
            if CURRENTLY_ONLINE && SESSION > TOCRITERION3
                [timing.trig.record(n), timing.trig.record_Success(n)] = WaitTRPulse(TRIGGER_keycode,DEVICE,timing.plannedOnsets.record(n));
            end
            timespec = timing.plannedOnsets.record(n)-SLACK;
            timing.actualOnsets.record(n) = Screen('Flip',mainWindow,timespec);
            fprintf('Flip time error = %.4f\n', timing.actualOnsets.record(n)-timing.plannedOnsets.record(n));
            wavfilename{n} = [ppt_dir 'SESSION_' num2str(SESSION) '_trial_' num2str(n) '.wav'];
            audiodata{n} = recordaudio(timing.actualOnsets.record(n),stim.recordDur,look);
            %endrecord = GetSecs;
            %display even/odd
            if CURRENTLY_ONLINE && SESSION > TOCRITERION3
                [timing.trig.math(n), timing.trig.math_Success(n)] = WaitTRPulse(TRIGGER_keycode,DEVICE,timing.plannedOnsets.math(n));
            end
            timespec = timing.plannedOnsets.math(n) - SLACK;
            [stim.digitAcc(stim.trial) stim.digitRT(stim.trial) timing.actualOnsets.math(n)] = odd_even(digitsEK,num_digit_qs,digits_promptDur,digits_isi,minimal_format,mainWindow,keyCell([1 5]),COLORS,DEVICE,SUBJ_NAME,[SESSION stim.trial],SLACK,timespec, keys);
            fprintf('Flip time error = %.4f\n', timing.actualOnsets.math(n)-timing.plannedOnsets.math(n));
            
            save(MATLAB_SAVE_FILE,'stim', 'timing', 'config');
        end
        
        %present last ITI
        if CURRENTLY_ONLINE && SESSION > TOCRITERION3
            [timing.trig.lastITI, timing.trig.lastITI_Success] = WaitTRPulse(TRIGGER_keycode,DEVICE,timing.plannedOnsets.lastITI);
        end
        timespec = timing.plannedOnsets.lastITI - SLACK;
        timing.actualOnsets.lastITI = isi_specific(mainWindow,COLORS.MAINFONTCOLOR,timespec);
        fprintf('Flip time error = %.4f\n', timing.actualOnsets.lastITI-timing.plannedOnsets.lastITI);
        
        %save all wave files
        for i = 1:n
            audiowrite(wavfilename{i}, audiodata{i}, 44100);
        end
        if GetSecs - timing.actualOnsets.lastITI < 2
            WaitSecs(2 - (GetSecs - timing.actualOnsets.lastITI));
        end
        %wait in scanner at end of run
        if CURRENTLY_ONLINE && SESSION > TOCRITERION3
            WaitSecs(10);
        end
        
        % clean up
        save(MATLAB_SAVE_FILE,'stim', 'timing', 'config');
        
        printlog(LOG_NAME,['\n\nSESSION ' int2str(SESSION) ' ended ' datestr(now) ' for SUBJECT number ' int2str(SUBJECT) '\n\n']);
        
        if SESSION == RECALL2
            endSession(subjectiveEK,'Congratulations, you have completed the scan! All that is left is a short test outside the scanner. We will come and get you out in just a moment.');
        elseif SESSION == RECALL_PRACTICE
            endSession(subjectiveEK, 'Congratulations, you have completed the practice tasks!');
        else
            endSession(subjectiveEK, CONGRATS)
        end
        sca
        
        %% POST PICTURES TASK
        
    case ASSOCIATES
        
        fname = findNewestFile(ppt_dir2,fullfile(ppt_dir2, ['mot_realtime01_' num2str(s2) '_' num2str(SESSION)  '*.mat']));
        y = load(fname);
        
        % declarations
        stim.promptDur = 0.6*SPEED;
        stim.listenDur = 0.4*SPEED;
        stim.isiDuration = 2*SPEED;
        PROGRESS = INDEXFINGER;
        PROGRESS_TEXT = 'INDEX';
        condmap = makeMap({'realtime','omit','lure'});
        stim.instruct1 = ['NAME MEMORY\n\nYou''re almost done! This is the final task.\n\nWe will show you pictures of various scenes and ask you ' ...
            'whether they are new in this experiment ("' recog_scale.inputs{1} '" key) or ones you have seen earlier ("' recog_scale.inputs{2} '" key). Try to respond ' ...
            'as quickly and accurately as possible.\n\n-- Press ' PROGRESS_TEXT ' once you understand these instructions --'];
        
        % stimulus data fields
        stim.triggerCounter = 1;
        stim.missedTriggers = 0;
        
        % prepare counterbalanced trial sequence (at most 2 in a row)
        %[stim.cond stim.condString stim.associate] = counterbalance_items({cues{STIMULI}{REALTIME}{1}, cues{STIMULI}{OMIT}{1}, recogLures(4:end)},CONDSTRINGS);
        %stim.associate = [recogLures(1:3) stim.associate];
        %stim.cond = [PRACTICE PRACTICE PRACTICE stim.cond];
        %stim.condString = [CONDSTRINGS{PRACTICE} CONDSTRINGS{PRACTICE} CONDSTRINGS{PRACTICE} stim.condString];
        stim.cond = y.stim.cond;
        stim.condString = y.stim.condString;
        stim.associate = y.stim.associate;
        
        % display instructions
        DrawFormattedText(mainWindow,' ','center','center',COLORS.MAINFONTCOLOR,WRAPCHARS);
        displayText(mainWindow,stim.instruct1,minimumDisplay,'center',COLORS.MAINFONTCOLOR,WRAPCHARS);
        stim.subjStartTime = waitForKeyboard(kbTrig_keycode,DEVICE);
        
        % initialize question
        triggerNext = false; use_console = true; make_files = true;
        stimmap = makeMap(pics);
        recogEK = initEasyKeys([exp_string_long '_RECOG'], SUBJ_NAME, ppt_dir,...
            'default_respmap', recog_scale, ...
            'stimmap', stimmap, ...
            'condmap', condmap, ...
            'trigger_next', triggerNext, ...
            'prompt_dur', stim.promptDur, ...
            'listen_dur', stim.listenDur, ...
            'exp_onset', stim.subjStartTime, ...
            'device', DEVICE);
        recogEK = startSession(recogEK);
        runStart = GetSecs;
        
        config.TR = stim.TRlength;
        config.nTRs.ISI = stim.isiDuration/stim.TRlength;
        config.nTRs.cue = (stim.promptDur + stim.listenDur)/stim.TRlength;
        config.nTrials = length(stim.cond);
        config.nTRs.perTrial = config.nTRs.ISI + config.nTRs.cue;
        config.nTRs.perBlock = (config.nTRs.perTrial) * config.nTrials + config.nTRs.ISI;
        
        timing.plannedOnsets.preITI(1:config.nTrials) = runStart + ((0:config.nTrials-1)*config.nTRs.perTrial)*config.TR;
        timing.plannedOnsets.cue(1:config.nTrials) = timing.plannedOnsets.preITI + config.nTRs.ISI*config.TR;
        timing.plannedOnsets.lastITI = timing.plannedOnsets.cue(end) + config.nTRs.cue*config.TR;
        % repeat
        lureProgress = 0;
        for n = 1:length(stim.cond)
            
            timespec = timing.plannedOnsets.preITI(n) - SLACK;
            timing.actualOnsets.preITI(n) = isi_specific(mainWindow,COLORS.MAINFONTCOLOR,timespec);
            fprintf('Flip time error = %.4f\n', timing.actualOnsets.preITI(n) - timing.plannedOnsets.preITI(n));
            
            % initialize trial
            if (stim.cond(n) == LUREWORD) || (stim.cond(n) == PRACTICE)
                stim.pos(n) = lureCounter;
                lureCounter = lureCounter + 1;
                lureProgress = lureProgress + 1;
                stim.id(n) = length(pics)+lureProgress;
                stim.stim{n} = recogLures{lureProgress};
                cresp = recog_scale.inputs(1);
                cresp_map = keys.map(1,:);
                recog.cresp_string{n} = 'new';
            else
                cueSearch = strcmp(preparedCues,stim.associate{n});
                stim.pos(n) = find(cueSearch);
                stim.stim{n} = pics{stim.pos(n)};
                stim.id(n) = stimmap.values(strcmp(stimmap.descriptors,stim.stim{n}));
                cresp = recog_scale.inputs(2);
                cresp_map = keys.map(5,:);
                recog.cresp_string{n} = 'old';
            end
            
            % now present the target
            picIndex = prepImage(strcat(PICFOLDER, stim.stim{n}),mainWindow);
            topLeft(HORIZONTAL) = CENTER(HORIZONTAL) - (PICDIMS(HORIZONTAL)*RESCALE_FACTOR/2);
            topLeft(VERTICAL) = CENTER(VERTICAL) - (PICDIMS(VERTICAL)*RESCALE_FACTOR/2);
            Screen('DrawTexture', mainWindow, picIndex, [0 0 PICDIMS],[topLeft topLeft+PICDIMS*RESCALE_FACTOR]);
            timespec = timing.plannedOnsets.cue(n) - SLACK; %first one will be .4 off but it's because it's not expecting there to be an etra .4 seconds
            timing.actualOnsets.cue(n) = Screen('Flip',mainWindow,timespec);
            fprintf('Flip time error = %.4f\n', timing.actualOnsets.cue(n) - timing.plannedOnsets.cue(n));
            Screen('Close',picIndex);
            
            % free recall judgment
            DrawFormattedText(mainWindow,'+','center','center',COLORS.MAINFONTCOLOR,WRAPCHARS);
            recogEK = easyKeys(recogEK, ...
                'onset', timing.actualOnsets.cue(n), ...
                'stim', stim.stim{n}, ...
                'cond', stim.cond(n), ...
                'cresp', cresp, ...
                'next_window', mainWindow, 'cresp_map', cresp_map, 'valid_map', target_map );
            
            % feedback if needed AH the timing is all screwed up if have
            % this in
            
            if n <= 3
                % WaitSecs(1);
                OnFB = GetSecs;
                if isnan(recogEK.trials.resp(end))
                    displayText(mainWindow,['Oops, you either did not respond in time, or did not ' ...
                        'press an appropriate key. Remember to indicate whether the picture is new in ' ...
                        'this experiment ("' recog_scale.inputs{1} '" key) or one you have seen earlier ("' ...
                        recog_scale.inputs{2} '" key). Try to respond as quickly and accurately as ' ...
                        'possible.\n\n-- Press ' PROGRESS_TEXT ' to continue --'],minimumDisplay,...
                        'center',COLORS.MAINFONTCOLOR,WRAPCHARS);
                    waitForKeyboard(kbTrig_keycode,DEVICE);
                else
                    displayText(mainWindow,['Good work! Your response was detected.\n\n-- Press ' ...
                        PROGRESS_TEXT ' to continue --'],minimumDisplay,'center',COLORS.MAINFONTCOLOR, ...
                        WRAPCHARS);
                    waitForKeyboard(kbTrig_keycode,DEVICE);
                end
                OffFB = GetSecs;
                timing.plannedOnsets.preITI(n+1:end) = timing.plannedOnsets.preITI(n+1:end) + OffFB-OnFB;
                timing.plannedOnsets.cue(n+1:end) = timing.plannedOnsets.cue(n+1:end) + OffFB-OnFB;
                timing.plannedOnsets.lastITI = timing.plannedOnsets.lastITI + OffFB-OnFB;
            end
            
            % rinse, save and repeat
            save(MATLAB_SAVE_FILE,'stim','recog', 'timing', 'config');
        end
        timespec = timing.plannedOnsets.lastITI - SLACK;
        timing.actualOnsets.lastITI = isi_specific(mainWindow,COLORS.MAINFONTCOLOR,timespec);
        fprintf('Flip time error = %.4f\n', timing.actualOnsets.lastITI-timing.plannedOnsets.lastITI);
        WaitSecs(stim.isiDuration);
        
        save(MATLAB_SAVE_FILE,'stim','recog', 'timing', 'config');
        % clean up
        
        printlog(LOG_NAME,['\n\nSESSION ' int2str(SESSION) ' ended ' datestr(now) ' for SUBJECT number ' int2str(SUBJECT) '\n\n']);
        printlog(LOG_NAME,'\n\n\n******************************************************************************\n');
        endSession(recogEK, 'Congratulations, you''ve finished the experiment! Please contact your experimenter.');
        sca;
        %% MOT
    case [MOT_PREP MOT MOT_PRACTICE MOT_PRACTICE2 MOT_LOCALIZER]
        
        
        
        if SESSION == MOT_PRACTICE2
            displayText(mainWindow,['Welcome to your fMRI scanning session!\n\nOnce you''re all the way inside the scanner and can read this text, please reach up to your eyes and ' ...
                'fine-tune the position of your mirror. You want to set it so you can see as much of the screen as comfortably as possible. This will be your last chance to adjust ' ...
                'your mirror, so be sure to set it just right.\n\nOnce you''ve adjusted the mirror to your satisfaction, please press the index finger button to test your button pad.'] ...
                ,minimumDisplay,'center',COLORS.MAINFONTCOLOR,WRAPCHARS);
            waitForKeyboard(kbTrig_keycode,DEVICE);
            displayText(mainWindow,'Great. I detected that button press, which means at least one button works. Now let''s try the rest of them. Please press the middle finger button.' ...
                ,minimumDisplay,'center',COLORS.MAINFONTCOLOR,WRAPCHARS);
            waitForKeyboard(keys.code(3,:),DEVICE);
            displayText(mainWindow,'And now the ring finger button...',minimumDisplay,'center',COLORS.MAINFONTCOLOR,WRAPCHARS);
            waitForKeyboard(keys.code(4,:),DEVICE);
            displayText(mainWindow,'And now the pinky finger button...',minimumDisplay,'center',COLORS.MAINFONTCOLOR,WRAPCHARS);
            waitForKeyboard(keys.code(5,:),DEVICE);
            displayText(mainWindow,'And now the thumb button...',minimumDisplay,'center',COLORS.MAINFONTCOLOR,WRAPCHARS);
            waitForKeyboard(keys.code(1,:),DEVICE);
            displayText(mainWindow,['Good news! It looks like the button pad is working just fine.\n\nJust a reminder that we can hear your voice when the scanner is at rest, so ' ...
                'just speak up to ask or tell us something. During a scan, we will abort right away if you use the squeeze ball, but please do so only if there''s something urgent ' ...
                'we need to address immediately.\n\n-- please press the index finger button to continue --'],minimumDisplay,'center',COLORS.MAINFONTCOLOR,WRAPCHARS);
            waitForKeyboard(kbTrig_keycode,DEVICE);
            displayText(mainWindow,['During the scan today, it is crucial that you keep your head still. Even a tiny head movement, e.g., caused by stretching your legs, will blur ' ...
                'your brain scan. This is for the same reason that moving objects appear blurry in a photograph.\n\nAs it can be uncomfortable to stay still for a long time, please ' ...
                'go ahead and take the opportunity to stretch or scratch whenever the scanner is silent. Just try your best to keep your head in the same place when you do so.\n\n' ...
                '-- please press the index finger button to continue --'],minimumDisplay,'center',COLORS.MAINFONTCOLOR,WRAPCHARS);
            waitForKeyboard(kbTrig_keycode,DEVICE);
            displayText(mainWindow,['We''re now going to start with a five-minute anatomical scan while you complete some training tasks in preparation for later. Please work through these and we''ll get in ' ...
                'touch with you when you finish.\n\n-- please press the index finger button to continue --'],INSTANT,'center',COLORS.MAINFONTCOLOR,WRAPCHARS);
            waitForKeyboard(kbTrig_keycode,DEVICE);
        end

        
        % stimulus presentation parameters
        instant = 0;
        num_dots = 5; %where set total dots
        stim.square_dims = round([20 20] ./ mean(WINDOWSIZE.degrees_per_pixel)); % 20ï¿½ visual angle in pixels
        stim.dot_diameter = 1.5 / mean(WINDOWSIZE.degrees_per_pixel); % 1.5 visual angle in pixels
%         if SESSION < MOT{1}
%             stim.trialDur = 20*SPEED;
%             promptTRs = 3:2:9;
%         else
            stim.trialDur = 30*SPEED; %chaning length from 20 to 30 s or 15 TRs
            promptTRs = 3:2:13; %which TR's to make the prompt active
  %      end
        stim.inter_prompt_interval = 4*SPEED;
        stim.maxspeed = 30;
        stim.minspeed = 0.3; %changed 8/8
        stim.targ_dur = 2*SPEED;
        stim.fixBlock = 20; %time in the beginnning they're staring
        %stim.betweenPrompt = 2;
        %stim.beforePrompt = 4;
        %vis_promptDur = 2*SPEED;
        digits_promptDur = 1.9*SPEED;
        digits_isi = 0.1*SPEED;
        PROGRESS_TEXT = 'INDEX finger';
        probe_promptDur = 2*SPEED;
        probe_listenDur = 0;
        num_digit_qs = 2;
        stim.isiDuration = 2*SPEED;%10*SPEED - stim.TRlength*2 - num_digit_qs*(digits_promptDur + digits_isi);
        stim.mathDur = (digits_promptDur + digits_isi) * num_digit_qs;
        stim.fbDuration = 2*SPEED; %for dot probe choice
        dot_map = keys.map([1 5],:);
        
        %rt parameters 
        Scale = 100; %parameter for function
        OptimalForget = 0.1;
        maxIncrement = 1.25;
        config.initFeedback = 0.1; %make it so there's change in speed for the first 4 TR's
        config.initFunction = tancubed(config.initFeedback,Scale,OptimalForget,maxIncrement);
        
        switch SESSION
            case {MOT_PREP,MOT_PRACTICE}
                mot_conds = {'1_targ'};
                show_words = true;
                minimal_format = false;
                day_2 = false;
                realtime = false;
            case {MOT_PRACTICE2,MOT_LOCALIZER}
                mot_conds = {'targ-hard','targ-easy','lure-hard','lure-easy'};
                show_words = true;
                minimal_format = true;
                day_2 = true;
                realtime = false;
            otherwise
                mot_conds = {'realtime'};
                show_words = true;
                minimal_format = true;
                day_2 = true;
                realtime = true; %use this to make other conditions below!
        end
       
        
        if SESSION == MOT_PRACTICE || SESSION == MOT_PRACTICE2
            stim.header = 'MULTI-TASKING -- PRACTICE';
        elseif SESSION < MOT_PRACTICE2
            stim.header = 'MULTI-TASKING';
        else stim.header = 'MULTI-TASKING';
        end
        instruct_continue = ['\n\n-- Press ' PROGRESS_TEXT ' to continue once you understand these instructions --'];
        stim.instruct1 = [stim.header '\n\nWe will now do a "multi-tasking" twist: we would like you to ' ...
            'try visualizing while also keeping track of moving dots.\n\nDot-tracking works as follows: first, one dot ' ...
            'will appear in red (target) and others in green (non-targets). After two seconds, all dots will turn ' ...
            'green and and move around the screen. Your job is to track the target dot until a "question" dot turns white. ' ...
            'While tracking dots, it is VITAL that you keep your eyes at the center fixation dot for the entire '...
            'time that you are tracking dot motion!!! When the ''question'' dot turns white, you '...
            'can then take your eyes off the center and indicate whether that dot was originally a target (PINKY) or not (THUMB). ' ...
            instruct_continue];
        stim.instruct2 = ['While all this happens, we want you to "multi-task" by visualizing the scene ' ...
            'named by the word in the middle. Every few seconds, the central dot will turn red: this serves to remind '...
            'you to keep your eyes focused at the center dot and keep trying to visualize the named scene. \n\nRemember that mental visualizing is only your second priority: if you lose track ' ...
            'of the dots for even a second, you will get the trial wrong, and we will have to throw out the trial; ' ...
            'and we need as many trials as possible. Getting the target dot correct is your most important task (but make sure '...
            'this is not at the expense of moving your eyes away from the center fixation dot; that would be cheating)! ' ...
            'You should "squeeze in" visualizing when it''s possible. \n\n---- Press ' PROGRESS_TEXT ' once you understand these instructions ----'];
        stim.instruct_summary = [stim.header '\n\nTo summarize this task: you will keep track of target dots moving around the screen while keeping your ' ...
            'eyes fixed on the central dot. The dot-tracking task is your top priority, but you should also try to visualize ' ...
            'the named scene, keeping your eyes fixed on the central blinking dot. The speed of the dots may change in '...
            'different trials and also within a trial. Just try to do your best and keep doing the task no matter the dot speed. '...
            'At the end of the trial, when a dot ' ...
            'turns white, you will first move your eyes to the white dot, then press PINKY (if it''s a target) or THUMB (if it''s ' ...
            'not). (Think YES TARGET = PINKY, NOT TARGET = THUMB.) \n\nThere will also be several even/odd questions after each trial that you should try to complete (using ' ...
            'your THUMB for even and PINKY for odd).' final_instruct_continue];
        stim.fMRI_refresher = ['MULTI-TASKING-- fMRI PRACTICE\n\nDot tracking today will be similar to last time, with two ' ...
            'changes. Firstly, dots in half of trials will be moving slow, while dots in the other half will be moving faster.\n\n' ...
            'Secondly, some of the trials will involve familiar words that are not scene names. On these trials, ' ...
            'because the word is not the name of a scene, there is nothing for you to visualize.\n\nWe will now review the ' ...
            'instructions for the task (with which you are already familiar).' instruct_continue];
        stim.fMRI_instruct = ['MULTI-TASKING-- fMRI, Stage 1 \n\nDot tracking today will involve two changes from yesterday. ' ...
            'Firstly, dots in half of trials will be moving slow, while dots in the other half will be moving faster. \n' ...
            'Secondly, some of the trials will involve familiar words that are not scene names. On these trials, ' ...
            'because the word is not the name of a scene, there is nothing for you to visualize.\n\nWe will now review the ' ...
            'instructions for the task (with which you are already familiar).' instruct_continue];
        stim.RT_instruct = ['MULTI-TASKING-- fMRI, Stage 2 \n\n You will now do the same dot tracking task as earlier. However, '...
            'now every word will have been paired with a scene. Additionally, the dot speed may change within '...
            'a trial. Just try your best to keep tracking the target dot while visualizing the scene as best as you can! You will complete '...
            'three runs of this task.' instruct_continue];
        % stimulus data fields
        stim.triggerCounter = 1;
        stim.missedTriggers = 0;
        stim.normalSize = 36;
        stim.smallSize = 24;
        stim.bigSize = 100;
        stim.keys = keyCell([1 5]);
        queueCheck = -1;
        
        % initilize staircasing
        if SESSION == MOT_PREP
            stair = 1;
        else
            stair = 0;
        end
        tGuess = 15; % guess as to the blend that will give us the our pThreshold
        pThreshold = .85; % probability of a resp=1 that we are aiming for
        beta = 3; % steepness of psychometric function, typically 3
        delta = .1; % fraction of trials on which observer presses blindly
        gamma = .5; % response rate when intensity = 0, typically .5 for forced-choiced questions w/ 2 possible answers
        grain = .1; %changed from 0.02 to .1--too little too step size
        range = 30; % changed from 5-- supposed to be a generous range of possible intensities. centered around initial tGuess
        % during prep, we free up the staircasing algorithm--here we're
        % setting parameters
        if stair
            tGuessSd = 5;
            %on day 2, use params from prior session
        elseif ~stair && SESSION > MOT_PREP %take speed and stop updating afterwards
            matlabOpenFile = []; timeout = true;
            %find_str = [ppt_dir 'stable_subj_' num2str(SUBJECT) '_' num2str(MOT_PREP) '*.mat']; %only look in MOT prep--no more updating
            relative_paths = false;
            %             while timeout
            try
                %will need to add this file to the folder to get it to work
                fileCandidates = dir([ppt_dir 'mot_realtime01_' num2str(SUBJECT) '_' num2str(MOT_PREP)  '*.mat']);
                matlabOpenFile = [ppt_dir fileCandidates(end).name];
                lastRun = load(matlabOpenFile);
                
            catch
                warning(['Could not find a prior run file. Using speed = 15.']);
                pause(1);
                lastRun.stim.tGuess = 15;
            end
            %             end
            finalSpeed = stim.maxspeed - lastRun.stim.tGuess(end);
            %finalSpeed = 15;
        end % stair
        if stair
            questStruct = QuestCreate(tGuess,tGuessSd,pThreshold,beta,delta,gamma,grain,range); %Quest function for face blocks
        end
       % keymap_image = imread(KEY_MAPPING);
      %  keymap_prompt = Screen('MakeTexture', mainWindow, keymap_image);
        
      
      
        % allocate stimuli
        if ~day_2
            %then we want to use practice stim
            stim.lureWords = [];
            stimmap = makeMap(cues{STIMULI}{LEARN}{1});
            if SESSION == MOT_PRACTICE
                [stim.cond stim.condString stim.stim] = counterbalance_items({cues{STIMULI}{LEARN}{1}},{MOTSTRINGS{LEARN}},0);
            else %MOT_PREP
                [stim.cond stim.condString stim.stim] = counterbalance_items({[cues{STIMULI}{LEARN}{1} cues{STIMULI}{LEARN}{1} cues{STIMULI}{LEARN}{1} cues{STIMULI}{LEARN}{1} cues{STIMULI}{LEARN}{1} cues{STIMULI}{LEARN}{1}]},{MOTSTRINGS{LEARN}},0);
            end
            condmap = makeMap({'target'});
        else
            fname = findNewestFile(ppt_dir2,fullfile(ppt_dir2, ['mot_realtime01_' num2str(s2) '_' num2str(SESSION)  '*.mat']));
            y = load(fname);
            stim.stim = y.stim.stim;
            stim.condString = y.stim.condString;
            stim.cond = y.stim.cond;
            stim.lureWords = y.stim.lureWords;
            stim.id = y.stim.id;
            stim.speed = y.stim.speed;
            stimID = stim.id;
            stimCond = stim.cond;
            prevSpeeds = y.stim.motionSpeed;
            if SESSION==MOT_PRACTICE2
                % can specify lure words the same way because we're
                % repeating the lurewords from subjects
                stim.lureWords = lureWords(6:7);
                %             numItems = length(cues{STIMULI}{LOC}{1});
                %             halfItems = numItems / 2;
                [stim.cond stim.condString stim.stim] = counterbalance_items({cues{STIMULI}{LEARN}{1}(1) cues{STIMULI}{LEARN}{1}(2), stim.lureWords(1), stim.lureWords(2)},MOTSTRINGS,1);
                condmap = makeMap({'targ_hard','targ_easy','lure_hard','lure_easy'});
                square_bounds = [CENTER-(stim.square_dims/2) CENTER+(stim.square_dims/2)-1];
                %             stim.condString = condmap.descriptors(stim.cond);
            elseif SESSION == MOT_LOCALIZER
                stim.lureWords = lureWords(8:23);
                %             numItems = length(cues{STIMULI}{LOC}{1});
                %             halfItems = numItems / 2;
                %             [stim.cond stim.condString stim.stim] = counterbalance_items({cues{STIMULI}{LOC}{1}(1:8), cues{STIMULI}{LOC}{1}(9:16), stim.lureWords(1:8), stim.lureWords(9:16)},MOTSTRINGS,1); %looks like he wanted to separate easy/hard conditions
                condmap = makeMap({'targ_hard','targ_easy','lure_hard','lure_easy'});
                square_bounds = [CENTER-(stim.square_dims/2) CENTER+(stim.square_dims/2)-1];
                %             stim.condString = condmap.descriptors(stim.cond);
            else
                %             stim.lureWords = lureWords(1:5);
                %             [stim.cond stim.condString stim.stim] = counterbalance_items({cues{STIMULI}{REALTIME}{1}}, MOT_RT_STRINGS,1);
                condmap = makeMap({'rt-targ'});
            end
        end
        square_bounds = [CENTER-(stim.square_dims/2) CENTER+(stim.square_dims/2)-1];
%         stim.condString = condmap.descriptors(stim.cond);
        stim.repulse = 2;
        % assign parameters based on condition
        lureCounter = 0;
        stim.num_targets = 1;
        repulsor_force_small = 1;
        
        %generate stimulus ID's first so can add them easily
%         for i = 1:length(stim.cond)
%             pos = find(strcmp(preparedCues,stim.stim{i}));
%             if ~isempty(pos)
%                 stim.id(i) = pos;
%             else
%                 stim.id(i) = -1; %so this should never go during MOT
%             end
%         end
        
        % FIGURE OUT HERE WHAT TO DO
        for i=1:length(stim.cond)
            
            if ~day_2 && ~stair
                stim.speed(i) = stim.maxspeed - tGuess; %setting practice speed to initial tGuess
                %stim.repulse(i) = 5/3;
            else
                %right now taking out because we want the speeds to be the
                %same for these (not going to change them after loading)
                if SESSION > 5 && SESSION < MOT{1} %change dot speeds for practice and localizer, but then we want to change dot speed! keep this because we're using an individual's subjects speed not RT
                    switch stim.cond(i)
                        case {1,3} %for either of the hard cases
                            stim.speed(i) = finalSpeed; %will have to load last speed and find the speed here
                            % repulsor_force(i) = repulsor_force_small * finalSpeed/0.5;
                        case {2,4} %for either of the easy cases
                            stim.speed(i) = 0.5;%5;%finalSpeed*.5; %again load last speed found here, change to accept max speed-see what first person has for this to decide
                            %repulsor_force(i) = repulsor_force_small;
                    end
                    if stim.cond(i) > 2
                        lureCounter = lureCounter + 1;
                    end
                    stim.condString{i} = mot_conds{stim.cond(i)};
                else %for MOT real-time trials
                    % repulsor_force(i) = stim.speed;
                    %stim.speed(i) = 2; %initialize each trial here!!!
                    %took this out for YC because we're just going to be
                    %loading the speeds from previous subjects for MOT
                end
            end
            
        end
        stim.num_lures = num_dots - stim.num_targets;
        
        % present instructions: change instructions from MOT PRACTICE TO
        % MOT PREP
        stim.stairInstruct = ['We will now continue with the same task you just did, but for more trials. '...
            'We are going to be adjusting the dot speed in this session, so it is very important for this session that you do not guess randomly. '...
            'If you do fall asleep or weren''t paying attention, do NOT guess randomly; instead '...
            'don''t respond at all! Random guessing will throw off our algorithm.\n\nWe will now review the ' ...
            'instructions for the task (with which you are already familiar).' instruct_continue];
        if SESSION == MOT_PRACTICE
            displayText(mainWindow,stim.instruct1,minimumDisplay,'center',COLORS.MAINFONTCOLOR,WRAPCHARS);
            waitForKeyboard(kbTrig_keycode,DEVICE);
            displayText(mainWindow,stim.instruct2,minimumDisplay,'center',COLORS.MAINFONTCOLOR,WRAPCHARS);
            waitForKeyboard(kbTrig_keycode,DEVICE);
            
        elseif SESSION == MOT_PREP
            displayText(mainWindow,stim.stairInstruct,minimumDisplay,'center',COLORS.MAINFONTCOLOR,WRAPCHARS);
            waitForKeyboard(kbTrig_keycode,DEVICE);
            
        elseif SESSION == MOT_PRACTICE2
            displayText(mainWindow,stim.fMRI_refresher,minimumDisplay,'center',COLORS.MAINFONTCOLOR,WRAPCHARS);
            waitForKeyboard(kbTrig_keycode,DEVICE);
            displayText(mainWindow,stim.instruct1,minimumDisplay,'center',COLORS.MAINFONTCOLOR,WRAPCHARS);
            waitForKeyboard(kbTrig_keycode,DEVICE);
            displayText(mainWindow,stim.instruct2,minimumDisplay,'center',COLORS.MAINFONTCOLOR,WRAPCHARS);
            waitForKeyboard(kbTrig_keycode,DEVICE);
           
        elseif SESSION == MOT_LOCALIZER 
            displayText(mainWindow,stim.fMRI_instruct,minimumDisplay,'center',COLORS.MAINFONTCOLOR,WRAPCHARS);
            waitForKeyboard(kbTrig_keycode,DEVICE);
        elseif SESSION == MOT{1}
            displayText(mainWindow,stim.RT_instruct, minimumDisplay, 'center', COLORS.MAINFONTCOLOR,WRAPCHARS);
            waitForKeyboard(kbTrig_keycode,DEVICE);
        end
        if SESSION == MOT{2} || SESSION == MOT{3}
            stim.instruct_nextMOT = ['You will now continue with the same multitasking task.' final_instruct_continue];
            displayText(mainWindow,stim.instruct_nextMOT,minimumDisplay,'center',COLORS.MAINFONTCOLOR,WRAPCHARS);
            %also load in last session information here
            allLast = findNewestFile(ppt_dir2,[ppt_dir2 'mot_realtime01_' num2str(s2) '_' num2str(SESSION-1) '*']);
            last = load(allLast);
            lastSpeed = last.stim.lastSpeed; %matrix of motRun (1-3), stimID
            lastDecoding = last.stim.lastRTDecoding;
            lastDecodingFunction = last.stim.lastRTDecodingFunction;
            fprintf(['Loaded speed and classification information from ' allLast '\n']);
        else
            displayText(mainWindow,stim.instruct_summary,minimumDisplay,'center',COLORS.MAINFONTCOLOR,WRAPCHARS);
        end
        stim.subjStartTime = waitForKeyboard(kbTrig_keycode,DEVICE);      %make sure the instructions are always to continue
        
        if CURRENTLY_ONLINE && SESSION > TOCRITERION3
            DrawFormattedText(mainWindow,'Waiting for scanner start, hold tight!','center','center',COLORS.MAINFONTCOLOR,WRAPCHARS);
            Screen('Flip', mainWindow);
        end
        
        % initialize mot test
        dotEK = initEasyKeys([exp_string_long '_DOT'], SUBJ_NAME,ppt_dir, ...
            'default_respmap', target_scale, ...
            'stimmap', stimmap, ...
            'condmap', condmap, ...
            'prompt_dur', probe_promptDur, ...
            'listen_dur', probe_listenDur, ...
            'exp_onset', stim.subjStartTime, ...
            'trigger_next', false, ...
            'device', DEVICE);
        [dotEK] = startSession(dotEK);
        
        digits_scale = makeMap({'even','odd'},[0 1],keyCell([1 5]));
        condmap = makeMap({'even','odd'});
        digitsEK = initEasyKeys('odd_even', SUBJ_NAME,ppt_dir, ...
            'default_respmap', digits_scale, ...
            'condmap', condmap, ...
            'trigger_next', false, ...
            'prompt_dur', digits_promptDur, ...
            'device', DEVICE);
        
        % present a fixation for the duration of stim.fixBlock (20 s)
        if CURRENTLY_ONLINE && SESSION > TOCRITERION3
            [timing.trig.wait timing.trig.waitSuccess] = WaitTRPulse(TRIGGER_keycode,DEVICE);
            runStart = timing.trig.wait;
            displayText(mainWindow,STILLREMINDER,STILLDURATION,'center',COLORS.MAINFONTCOLOR,WRAPCHARS);
            DrawFormattedText(mainWindow,'+','center','center',COLORS.MAINFONTCOLOR,WRAPCHARS);
            Screen('Flip', mainWindow)
            config.wait = stim.fixBlock; % stim.fixation - 20 s
        else
            runStart = GetSecs;
            timing.trig.wait = runStart; %for debugging purposes
            config.wait = 0;
        end
        
        config.TR = stim.TRlength;
        config.nTRs.ISI = stim.isiDuration/stim.TRlength;
        %config.nPrompts = 4;
        %config.nTRs.betweenPrompt = stim.betweenPrompt/stim.TRlength;
        config.nTRs.target = stim.targ_dur/stim.TRlength;
        %config.nTRs.prompt = vis_promptDur/stim.TRlength;
        %config.nTRs.beforePrompt = stim.beforePrompt/stim.TRlength;
        config.nTRs.motion = stim.trialDur/stim.TRlength;
        config.nTRs.probe = probe_promptDur/stim.TRlength;
        config.nTRs.feedback = stim.fbDuration/stim.TRlength;
        config.nTRs.math = (num_digit_qs*(digits_promptDur + digits_isi))/stim.TRlength;
        config.nTrials = length(stim.stim);
        
        config.nTRs.perTrial = (config.nTRs.ISI + config.nTRs.target + config.nTRs.motion ...
            + config.nTRs.probe + config.nTRs.feedback + config.nTRs.math);
        config.nTRs.perBlock = config.wait/stim.TRlength + (config.nTRs.perTrial)*config.nTrials+ config.nTRs.ISI; %includes the last ISI and 20 s fixation in the beginning but ...
        % does NOT include that 10 s at the end (last TRs)
        
        % calculate all future onsets
        timing.plannedOnsets.preITI(1:config.nTrials) = runStart + config.wait + ((0:config.nTrials-1)*config.nTRs.perTrial)*config.TR;
        timing.plannedOnsets.target(1:config.nTrials) = timing.plannedOnsets.preITI + config.nTRs.ISI*config.TR;
        %timing.plannedOnsets.motionStart(1:config.nTrials) = timing.plannedOnsets.target + config.nTRs.target*config.TR;
        for mTr = 1:config.nTRs.motion
            if mTr == 1
                timing.plannedOnsets.motion(mTr,1:config.nTrials) = timing.plannedOnsets.target + config.nTRs.target*config.TR;
            else
                timing.plannedOnsets.motion(mTr,1:config.nTrials) = timing.plannedOnsets.motion(mTr-1,:) + config.TR;
            end
        end
        timing.plannedOnsets.probe(1:config.nTrials) = timing.plannedOnsets.motion(1,:) + config.nTRs.motion*config.TR;
        timing.plannedOnsets.feedback(1:config.nTrials) = timing.plannedOnsets.probe + config.nTRs.probe*config.TR;
        timing.plannedOnsets.math(1:config.nTrials) = timing.plannedOnsets.feedback + config.nTRs.feedback*config.TR;
        timing.plannedOnsets.lastITI = timing.plannedOnsets.math(end) + config.nTRs.math*config.TR;%%make sure it pauses for this one
        
        allMotionTRs = convertTR(runStart,timing.plannedOnsets.motion,config.TR); %row,col = mTR,trialnumber
        addTR = 0;
        %showFiles = 1;
        if ~CURRENTLY_ONLINE %we have to add the 10 TR into back to go with prev data
            allMotionTRs = allMotionTRs + 10;
            addTR = 10;
        end
        rtData.classOutputFileLoad = nan(1,config.nTRs.perBlock + addTR);
        rtData.classOutputFile = cell(1,config.nTRs.perBlock + addTR);
        rtData.rtDecoding = nan(1,config.nTRs.perBlock+ addTR);
        rtData.smoothRTDecoding = nan(1,config.nTRs.perBlock+ addTR);
        rtData.rtDecodingFunction = nan(1,config.nTRs.perBlock+ addTR);
        rtData.smoothRTDecodingFunction = nan(1,config.nTRs.perBlock+ addTR);
        rtData.fileList = cell(1,config.nTRs.perBlock + addTR);
        rtData.newestFile = cell(1,config.nTRs.perBlock + addTR);
        % repeat
        stim.lastSpeed = nan(1,stim.num_realtime);%going to save it in a matrix of run,stimID
        stim.lastRTDecoding = nan(1,stim.num_realtime); %file 9 that's applied now
        stim.lastRTDecodingFunction = nan(1,stim.num_realtime);
        stim.changeSpeed = nan(mTr,length(stim.cond));
        stim.motionSpeed = nan(mTr,length(stim.cond));
       
        
        %save the timing, stim ID, and stim conditions here!
        if SESSION > RSVP2
        sessionInfoFile = fullfile(ppt_dir, ['SessionInfo' '_' num2str(SESSION) '.mat']);
        save(sessionInfoFile, 'stimCond','stimID','timing', 'config'); 
        end
        
        for n=1:length(stim.cond)
            stim.trial = n;
            if CURRENTLY_ONLINE && SESSION > TOCRITERION3
                [timing.trig.preITI(n), timing.trig.preITI_Success(n)] = WaitTRPulse(TRIGGER_keycode,DEVICE, timing.plannedOnsets.preITI(n));
            end
            timespec = timing.plannedOnsets.preITI(n) - SLACK;
            timing.actualOnsets.preITI(n) = isi_specific(mainWindow,COLORS.MAINFONTCOLOR,timespec);
            fprintf('Flip time error = %.4f\n', timing.actualOnsets.preITI(n) - timing.plannedOnsets.preITI(n));
            
            % reset quest to prevent us from getting stuck if we had an error in the first few trials
            if stair
                suggestion = QuestQuantile(questStruct);
                if stim.trial <= 4 && (suggestion > stim.maxspeed-8) %this restarts it if they get first 3 wrong
                    questStruct = QuestCreate(tGuess,tGuessSd,pThreshold,beta,delta,gamma,grain,range); %Quest function for face blocks
                    suggestion = QuestQuantile(questStruct);
                end
                % initialize trial
                blend = min(suggestion,stim.maxspeed-0.5);% 30-0.5 is as slow as we're willing to go
                blend = max(blend, 0.5); %29.5 is as fast as we're willing to go
                stim.speed(stim.trial) = stim.maxspeed - blend;
            end
            repulsor_force(stim.trial) = repulsor_force_small * stim.speed(stim.trial);
            %fprintf('For trial %i: speed = %.2d\n', stim.trial,stim.speed(stim.trial));
            dotTarg = []; dotPos = []; dotTargPos = [];
            
%             pos = find(strcmp(preparedCues,stim.stim{stim.trial}));
%             if ~isempty(pos)
%                 stim.id(stim.trial) = pos;
%             else
%                 stim.id(stim.trial) = lureCounter; %so this should never go during MOT
%                 lureCounter = lureCounter + 1;
%             end
            cue = stim.stim{stim.trial};
            
            % initialize dots
            [dots phantom_dots] = initialize_dots(num_dots,stim.num_targets,stim.square_dims,stim.dot_diameter);
            
            % choose a probe
            is_new = logical(randi(2)-1); %either a 1 or 0, if 1; 1 = Z no, 0 = Y
            if is_new, stim.cresp(stim.trial) = 1; else stim.cresp(stim.trial) = 2; end
            if is_new || ~stim.num_targets
                dots(stim.num_targets + randi(num_dots - stim.num_targets)).is_probe = true; %makes it so the first dot can't be the probe
            else dots(randi(stim.num_targets)).is_probe = true; %this forces the first dot index to be the probe, 50% chances
            end
            
            % reveal targets
            if CURRENTLY_ONLINE && SESSION > TOCRITERION3
                [timing.trig.target(n), timing.trig.target_Success(n)] = WaitTRPulse(TRIGGER_keycode,DEVICE, timing.plannedOnsets.target(n));
            end
            timespec = timing.plannedOnsets.target(n) - SLACK;
            show_targs = true; show_probe = false; prompt_active = false;
            targetBin = [];
            [~,timing.actualOnsets.target(n)] = dot_refresh(mainWindow,targetBin,dots,square_bounds,stim.dot_diameter,COLORS,cue,show_targs,show_probe,prompt_active,timespec); %flips but not moving yet
            fprintf('Flip time error = %.4f\n', timing.actualOnsets.target(n) - timing.plannedOnsets.target(n));
            
            % initialize dot following
            show_targs = false;
            stim.frame_counter(stim.trial) = 0;
            
            TRcounter = 0;
            prompt_counter = 0;
            fps = 30;
            current_speed = stim.speed(stim.trial);
            repulse = stim.repulse;
            remainingTR = ones(mTr,1);
            
            prompt_active = 0;
            fs = [];
            
            printTR = ones(1,mTr);
            initFeedback = config.initFeedback;
            initFunction = config.initFunction;
            if SESSION > MOT{1}
                %load the previous last speed for this stimulus and set
                %this as the speed
                initSpeed = lastSpeed(stim.id(stim.trial)); %check the indexing is right!!
                current_speed = initSpeed;
                initFeedback = lastDecoding(stim.id(stim.trial));
                initFunction = lastDecodingFunction(stim.id(stim.trial));
            end
            fileTR = 1;
            waitForPulse = false;
            printlog(LOG_NAME,'trial\tTR\tprompt active\tspeed\tds\tflip error\tfound file\tFileTR\tCategSep\tLastFile\n');
            while abs(GetSecs - timing.plannedOnsets.probe(n)) > 0.050;%SLACK*2 %so this is just constatnly running, stops when it's within a flip
               
                stim.frame_counter(stim.trial) = stim.frame_counter(stim.trial) + 1;
                % here we go!
                % first look for file
                % keep this in so it's still looking for files in real time
                % and everything is saving the same way
                if realtime %just saying it's one of the MOT sessions
                    if TRcounter >= 4 %the first time we're looking is during TR 4
                        thisTR = allMotionTRs(TRcounter,n); %this is the TR we're actually on KEEP THIS WAY--starts on 4, ends on 10
                        fileTR = thisTR - 1; %this is what should be shown in the long arrays--for ex TR 3 found in TR 4 corresponding to TR 1 will be indexed at 3
                        %thisTR = thisTR; %look forward 2 TR's
                        if scanNum %if we should be looking for a file 
                            if ~mod(stim.frame_counter(n),3) && (rtData.classOutputFileLoad(fileTR) ~= 1) % look every 3 frames
                                timing.plannedOnsets.tClassOutputFileTimeout(fileTR) = timing.plannedOnsets.motion(TRcounter,n) + config.TR-.25; %so this is in seconds
                                if (GetSecs < timing.plannedOnsets.tClassOutputFileTimeout(fileTR)) %don't need a min time because we're waiting for TRcounter to be 4
                                    rtData.fileList{thisTR} = ls(classOutputDir);
                                    allFn = dir([classOutputDir 'vol' '*']);
                                    dates = [allFn.datenum];
                                    names = {allFn.name};
                                    [~,newestIndex] = max(dates);
                                    rtData.newestFile{thisTR} = names{newestIndex};
%                                     if showFiles
%                                         ls(classOutputDir) %saved for at the TR we're literally on, what are the available files
%                                     end
                                    [rtData.classOutputFileLoad(fileTR), rtData.classOutputFile{fileTR}] = GetSpecificClassOutputFile(classOutputDir,fileTR);
                                    if rtData.classOutputFileLoad(fileTR)
                                        tempStruct = load(fullfile(classOutputDir, rtData.classOutputFile{fileTR}));
                                        rtData.rtDecoding(fileTR) = tempStruct.classOutput;
                                        rtData.rtDecodingFunction(fileTR) = tancubed(rtData.rtDecoding(fileTR),Scale,OptimalForget,maxIncrement);
                                        %put something exclamatory to
                                        %celebrate finding the file
                                        %fprintf(['FOUND TR ' num2str(dicomTR) ' in motion TR ' num2str(TRcounter) '\n'])
%                                         if TRcounter > 5 %this is the third file collected
%                                             rtData.smoothRTDecoding(fileTR) = nanmean(rtData.rtDecoding(fileTR-1:fileTR)); %changed from 2 to 1 8/8
%                                             rtData.smoothRTDecodingFunction(fileTR) = nanmean(rtData.rtDecodingFunction(fileTR-1:fileTR)); %changed from 2 to 1 8/8
                                        if TRcounter > 4  %this is the second file collected
                                            rtData.smoothRTDecoding(fileTR) = nanmean([rtData.rtDecoding(fileTR-1:fileTR)]);
                                            rtData.smoothRTDecodingFunction(fileTR) = nanmean([rtData.rtDecodingFunction(fileTR-1:fileTR)]);
                                        elseif TRcounter == 4 %this is the first file collected
                                            rtData.smoothRTDecoding(fileTR) = nanmean([initFeedback rtData.rtDecoding(fileTR)]);
                                            rtData.smoothRTDecodingFunction(fileTR) = nanmean([initFunction rtData.rtDecodingFunction(fileTR)]);
                                        end
                                    end
                                else %if timeout, put same conditions of smoothing, this TR is nan
                                    goodPrevious = find(~isnan(rtData.rtDecoding(1:fileTR-1))); %will have max TR - 1 values
%                                     if length(goodPrevious) > 2
%                                         rtData.smoothRTDecoding(fileTR) = nanmean(rtData.rtDecoding(goodPrevious(end-2):goodPrevious(end)));
%                                         rtData.smoothRTDecodingFunction(fileTR) = nanmean(rtData.rtDecodingFunction(goodPrevious(end-2):goodPrevious(end)));
                                    if length(goodPrevious) > 1 %just average over those 2 TR's then
                                        if TRcounter > 4 %now we can average over 2 TR's like normal
                                            rtData.smoothRTDecoding(fileTR) = nanmean(rtData.rtDecoding(goodPrevious(end-1):goodPrevious(end)));
                                            rtData.smoothRTDecodingFunction(fileTR) = nanmean(rtData.rtDecodingFunction(goodPrevious(end-1):goodPrevious(end)));
                                        else %if at TRcounter == 4, include initFeedback/function--this wouldn't happen because it's the first case--oh well
                                            rtData.smoothRTDecoding(fileTR) = nanmean([initFeedback rtData.rtDecoding(goodPrevious(end))]);
                                            rtData.smoothRTDecodingFunction(fileTR) = nanmean([initFunction rtData.rtDecodingFunction(goodPrevious(end))]);
                                        end
                                    elseif length(goodPrevious) ==1 %&& TRcounter > 4 %only use that TR
                                        if TRcounter > 4
                                            rtData.smoothRTDecoding(fileTR) = nanmean(rtData.rtDecoding(goodPrevious(end)));
                                            rtData.smoothRTDecodingFunction(fileTR) = nanmean(rtData.rtDecodingFunction(goodPrevious(end)));
                                        else
                                            rtData.smoothRTDecoding(fileTR) = nanmean([initFeedback rtData.rtDecoding(goodPrevious(end))]);
                                            rtData.smoothRTDecodingFunction(fileTR) = nanmean([initFunction rtData.rtDecodingFunction(goodPrevious(end))]);
                                        end
                                    end
                                end
                            end
                        else %if we're using random data instead of neural data
                            %this won't give errors but it won't be a
                            %smoothed mean at first
                            rtData.rtDecoding(fileTR) = rand(1)*2-1;
                            rtData.rtDecodingFunction(fileTR) = tancubed(rtData.rtDecoding(fileTR),Scale,OptimalForget,maxIncrement);
                            rtData.smoothRTDecoding(fileTR) = nanmean(rtData.rtDecoding(fileTR-1:fileTR));
                            rtData.smoothRTDecodingFunction(fileTR) = nanmean(rtData.rtDecodingFunction(fileTR-1:fileTR));
                        end
                    end
                end
                
                nextTRPos = find(remainingTR,1,'first');
                if ~isempty(nextTRPos)
                    nextTRTime = timing.plannedOnsets.motion(nextTRPos,stim.trial);
                    if abs(GetSecs - nextTRTime) <= 0.050
                        %look for speed update here
                      
                        TRcounter = TRcounter + 1; %update TR count (initialized at 0): so it's the TR that we're currently ON
                        waitForPulse = true;
                        if ismember(TRcounter,promptTRs)
                            prompt_active = 1;
                            prompt_counter = prompt_counter + 1;
                        elseif ismember(TRcounter-1,promptTRs)
                            prompt_active = false;
                        end
                        if realtime %only change speeds with MOT
                            %if TRcounter > 4 && ~isnan(rtData.smoothRTDecodingFunction(allMotionTRs(TRcounter-2,n))) %we look starting in 4, but we update starting at TR 5 AND make sure that it's not nan--if it is don't change speed
                                current_speed = prevSpeeds(TRcounter,n);
                                %current_speed = current_speed + rtData.smoothRTDecodingFunction(allMotionTRs(TRcounter-2,n)); % apply in THIS TR what was from 2 TR's ago (indexed by what file it is) so file 3 will be applied at TR5!
                                %stim.changeSpeed(TRcounter,n) = rtData.smoothRTDecodingFunction(allMotionTRs(TRcounter-2,n)); %speed changed ON that TR
                            %else
                                %stim.changeSpeed(TRcounter,n) = 0;
                            %end
                            % make sure speed is between [stim.minspeed
                            % stim.maxspeed] (0,30) right now
                            %current_speed = min([stim.maxspeed current_speed]);
                            %current_speed = max([stim.minspeed current_speed]);
                           % stim.motionSpeed(TRcounter,n) = current_speed; %speed ON that TR
                            %we want to save the last speed for future
                            %runs--save by id, don't save if not lure trial
                            if TRcounter == config.nTRs.motion %on last TR
                                stim.lastSpeed(stim.id(stim.trial)) = current_speed; %going to save it in a matrix of run,stimID
                                stim.lastRTDecoding(stim.id(stim.trial)) = y.stim.lastRTDecoding(stim.id(stim.trial));%rtData.rtDecoding(allMotionTRs(TRcounter-2,n)); %file 9 that's applied now
                                stim.lastRTDecodingFunction(stim.id(stim.trial)) = y.stim.lastRTDecodingFunction(stim.id(stim.trial)); %rtData.rtDecodingFunction(allMotionTRs(TRcounter-2,n));
                            end
                        end
                        remainingTR(nextTRPos) = 0;
                        stim.motionSpeed(TRcounter,n) = current_speed;
                    end
                end
                
                if TRcounter %only do this once the motion should begin
                    [dots fs] = dot_compute(dots,current_speed,stim.square_dims,stim.dot_diameter,phantom_dots,WINDOWSIZE,repulse,fs,repulsor_force(n));
                    if waitForPulse
                        if CURRENTLY_ONLINE && SESSION >TOCRITERION3 %localizer and up
                            [timing.trig.motion(TRcounter,n), timing.trig.motion_Success(TRcounter,n)] = WaitTRPulse(TRIGGER_keycode,DEVICE, timing.plannedOnsets.motion(TRcounter,n)); %minus 1 because first TR is motionStart
                        end
                        timespec = nextTRTime - SLACK;
                        [targetBin, timing.actualOnsets.motion(TRcounter,n)] = dot_refresh(mainWindow,targetBin,dots,square_bounds,stim.dot_diameter,COLORS,cue,show_targs,show_probe,prompt_active,timespec);
                        %fprintf('Flip time error = %.4f\n', timing.actualOnsets.motion(motion_counter,stim.trial) - timing.plannedOnsets.motion(motion_counter,stim.trial));
                        %fprintf(['mTR ' num2str(motion_counter) '; Speed = ' num2str(current_speed) '\n']);
                        waitForPulse = false;
                        %display report at the end of the TR
                    else
                        [targetBin] = dot_refresh(mainWindow,targetBin,dots,square_bounds,stim.dot_diameter,COLORS,cue,show_targs,show_probe,prompt_active);
                    end
                end
                if TRcounter > 1 && (GetSecs >= timing.plannedOnsets.motion(TRcounter,n) + config.TR-.25) && printTR(TRcounter) %after when should have found file
                    %z = GetSecs - timing.plannedOnsets.motion(TRcounter,n);
                    printlog(LOG_NAME,'%d\t%d\t%d\t\t%5.3f\t%5.3f\t%5.4f\t\t%i\t\t%d\t\t%5.3f\t\t%s\n',n,TRcounter,prompt_active,current_speed,stim.changeSpeed(TRcounter,n),timing.actualOnsets.motion(TRcounter,stim.trial) - timing.plannedOnsets.motion(TRcounter,stim.trial),rtData.classOutputFileLoad(allMotionTRs(TRcounter-1,n)),fileTR,rtData.rtDecoding(fileTR),rtData.newestFile{allMotionTRs(TRcounter,n)});
                    printTR(TRcounter) = 0;
                elseif TRcounter ==1 && (GetSecs >= timing.plannedOnsets.motion(TRcounter,n) + config.TR-.25) && printTR(TRcounter)
                    printlog(LOG_NAME,'%d\t%d\t%d\t\t%5.3f\t%5.3f\t%5.4f\t\t%i\t\t%d\t\t%5.3f\t\t%s\n',n,TRcounter,prompt_active,current_speed,stim.changeSpeed(TRcounter,n),timing.actualOnsets.motion(TRcounter,stim.trial) - timing.plannedOnsets.motion(TRcounter,stim.trial),rtData.classOutputFileLoad(allMotionTRs(TRcounter,n)),fileTR,rtData.rtDecoding(fileTR),rtData.newestFile{allMotionTRs(TRcounter,n)});
                    printTR(TRcounter) = 0;
                end
                
            end  %20 s trial ends here THEN probe
            
            % present targetness probe
            KbQueueRelease;
            if CURRENTLY_ONLINE && SESSION > TOCRITERION3
                [timing.trig.probe(n), timing.trig.probe_Success(n)] = WaitTRPulse(TRIGGER_keycode,DEVICE, timing.plannedOnsets.probe(n));
            end
            show_probe = true; prompt_active = false;
            timespec = timing.plannedOnsets.probe(n) - SLACK;
            [~,timing.actualOnsets.probe(n)] = dot_refresh(mainWindow,[],dots,square_bounds,stim.dot_diameter,COLORS,cue,show_targs,show_probe,prompt_active,timespec);
            fprintf('Flip time error = %.4f\n', timing.actualOnsets.probe(n) - timing.plannedOnsets.probe(n));
            dotEK = easyKeys(dotEK, ...
                'nesting', [SESSION stim.trial], ...
                'stim', stim.stim{stim.trial}, ...
                'cond', stim.cond(stim.trial), ...
                'onset', timing.actualOnsets.probe(n), ...
                'cresp', stim.keys(stim.cresp(stim.trial)), ...
                'cresp_map', dot_map(stim.cresp(stim.trial),:), 'valid_map', target_map );
            
            % log trial
            stim.dur(stim.trial) = GetSecs - timing.actualOnsets.target(n);
            stim.dotLog{n} = dots;
            % stim.vis_train{n} = train;
            clear dots
            
            
            % feedback
            if CURRENTLY_ONLINE && SESSION > TOCRITERION3
                [timing.trig.feedback(n), timing.trig.feedback_Success(n)] = WaitTRPulse(TRIGGER_keycode,DEVICE, timing.plannedOnsets.feedback(n));
            end
            Screen('TextSize',mainWindow,stim.smallSize);
            Screen('TextFont', mainWindow,'Arial');
            timespec = timing.plannedOnsets.feedback(n) - SLACK;
            if dotEK.trials.acc(end)
                timing.actualOnsets.feedback(n) = displayText_specific(mainWindow,'!!!','center',COLORS.GREEN,WRAPCHARS,timespec);
            else
                timing.actualOnsets.feedback(n) = displayText_specific(mainWindow,'X','center',COLORS.RED,WRAPCHARS,timespec);
            end
            fprintf('Flip time error = %.4f\n', timing.actualOnsets.feedback(n) - timing.plannedOnsets.feedback(n));
            
            % PRACTICE FEEDBACK
            
            if SESSION == MOT_PRACTICE && (stim.trial <= 3)
                pause(stim.fbDuration)
                onFB = GetSecs;
                Screen('TextSize',mainWindow,stim.smallSize);
                % mot performance (top priority)
                if dotEK.trials.acc(end)
                    displayText(mainWindow,['Great work! You successfully tracked the target dots and responded correctly.\n\n' ...
                        'Did you remember to keep your eyes fixed on the word in the middle?\n\nAlso, did you remember to move ' ...
                        'your eyes to the white dot at the end of the trial?\n\n' ...
                        '-- Press ' PROGRESS_TEXT ' to continue --'],minimumDisplay,'center',COLORS.MAINFONTCOLOR,WRAPCHARS);
                elseif isnan(dotEK.trials.resp(end))
                    displayText(mainWindow,['Oops, you didn''t respond to the dot-following question in time.\n\n' ...
                        'Press PINKY when the white dot is a target and THUMB ' ...
                        'when the white dot is not a target.(Think YES TARGET = PINKY, NO NOT TARGET = THUMB.)\n\nAlso, remember that although ' ...
                        'you have other jobs to do in this multi-tasking task, keeping track of the target dots is the ' ...
                        'most important thing you have to do.\n\n' ...
                        '-- Press ' PROGRESS_TEXT ' to continue --'],minimumDisplay,'center',COLORS.MAINFONTCOLOR,WRAPCHARS);
                else
                    displayText(mainWindow,['Oops, you guessed incorrectly about whether the question dot was a target.\n\n' ...
                        'Press PINKY when the white dot is a target and THUMB ' ...
                        'when the white dot is not a target. (Think YES TARGET = PINKY, NO NOT TARGET = THUMB.)\n\nAlso, remember that although ' ...
                        'you have other jobs to do in this multi-tasking task, keeping track of the target dots is the ' ...
                        'most important thing you have to do.\n\n' ...
                        '-- Press ' PROGRESS_TEXT ' to continue --'],minimumDisplay,'center',COLORS.MAINFONTCOLOR,WRAPCHARS);
                end
                waitForKeyboard(kbTrig_keycode,DEVICE);
                
                
                % prepare for odd-even
                displayText(mainWindow,['Now get ready for the rapid odd/even calculations: indicate "even" sums with your THUMB and "odd" sums with your PINKY finger.\n\n' ...
                    '-- Press ' PROGRESS_TEXT ' to continue --'],minimumDisplay,'center',COLORS.MAINFONTCOLOR,WRAPCHARS);
                waitForKeyboard(kbTrig_keycode,DEVICE);
                offFB = GetSecs;
                timing.plannedOnsets.preITI(n+1:end) = timing.plannedOnsets.preITI(n+1:end) + (offFB - onFB);
                timing.plannedOnsets.target(n+1:end) = timing.plannedOnsets.target(n+1:end) + (offFB - onFB);
                timing.plannedOnsets.motion(:,n+1:end) = timing.plannedOnsets.motion(:,n+1:end) + (offFB - onFB);
                %timing.plannedOnsets.prompt(:,n+1:end) = timing.plannedOnsets.prompt(:,n+1:end) + (offFB - onFB);
                timing.plannedOnsets.probe(n+1:end) = timing.plannedOnsets.probe(n+1:end) + (offFB - onFB);
                timing.plannedOnsets.feedback(n+1:end)= timing.plannedOnsets.feedback(n+1:end) + (offFB - onFB);
                timing.plannedOnsets.math(n:end) = timing.plannedOnsets.math(n:end) + (offFB - onFB);
                timing.plannedOnsets.lastITI = timing.plannedOnsets.lastITI + (offFB - onFB);
            end
            
            
            %math
            if CURRENTLY_ONLINE && SESSION > TOCRITERION3
                [timing.trig.math(n), timing.trig.math_Success(n)] = WaitTRPulse(TRIGGER_keycode,DEVICE, timing.plannedOnsets.math(n));            end
            timespec = timing.plannedOnsets.math(n) - SLACK;
            [stim.digitAcc(stim.trial), stim.digitRT(stim.trial) timing.actualOnsets.math(n)] = odd_even(digitsEK,num_digit_qs,digits_promptDur,digits_isi,minimal_format,mainWindow,keyCell([1 5]),COLORS,DEVICE,SUBJ_NAME,[SESSION stim.trial], SLACK, timespec, keys);
            fprintf('Flip time error = %.4f\n', timing.actualOnsets.math(n) - timing.plannedOnsets.math(n));
            
            % MOT prep feedback: fight drowsiness
            if SESSION == MOT_PREP && ~mod(n,5)
                pause(digits_isi)
                onFB = GetSecs;
                displayText(mainWindow,['BREAK\n\nYou''re doing great! Feel free to use this opportunity to get up and stretch if you need to. '...
                    'Before continuing, we want to make sure that you''re focused because if you guess randomly '...
                    'you''ll throw off our algorithm and we may not be able to continue with the study.\n Instead, if you''re feeling drowsy, '...
                    'please take a short rest now and resume once you''re ready. \n\n -- Press ' PROGRESS_TEXT ' when you''re ready to continue--'],minimumDisplay,'center',COLORS.MAINFONTCOLOR,WRAPCHARS);
                waitForKeyboard(kbTrig_keycode,DEVICE);
                
                displayText(mainWindow,['Trial ' num2str(stim.trial) ' of ' num2str(length(stim.stim)) ' complete.'],minimumDisplay,'center',COLORS.MAINFONTCOLOR,WRAPCHARS);
                pause(0.05);
                
                offFB = GetSecs;
                timing.plannedOnsets.preITI(n+1:end) = timing.plannedOnsets.preITI(n+1:end) + (offFB - onFB);
                timing.plannedOnsets.target(n+1:end) = timing.plannedOnsets.target(n+1:end) + (offFB - onFB);
                timing.plannedOnsets.motion(:,n+1:end) = timing.plannedOnsets.motion(:,n+1:end) + (offFB - onFB);
                %  timing.plannedOnsets.prompt(:,n+1:end) = timing.plannedOnsets.prompt(:,n+1:end) + (offFB - onFB);
                timing.plannedOnsets.probe(n+1:end) = timing.plannedOnsets.probe(n+1:end) + (offFB - onFB);
                timing.plannedOnsets.feedback(n+1:end)= timing.plannedOnsets.feedback(n+1:end) + (offFB - onFB);
                timing.plannedOnsets.math(n+1:end) = timing.plannedOnsets.math(n+1:end) + (offFB - onFB);
                timing.plannedOnsets.lastITI = timing.plannedOnsets.lastITI + (offFB - onFB);
            end
            
            % report
            stim.expDuration = (GetSecs - stim.subjStartTime) / 60; % experiment time in mins
            if ~isnan(dotEK.trials.resp(end)) &&  stair
                % update questStruct only if we got a response
                questStruct=QuestUpdate(questStruct,blend,dotEK.trials.acc(end));
            end
            if stair
                stim.tGuess(stim.trial) = QuestMean(questStruct);
                stim.tGuess_sd(stim.trial) = QuestSd(questStruct);
            end
            
            clear train;
            save(MATLAB_SAVE_FILE,'stim', 'timing', 'config');
        end
        if CURRENTLY_ONLINE && SESSION > TOCRITERION3
            [timing.trig.lastITI, timing.trig.lastITI_Success] = WaitTRPulse(TRIGGER_keycode,DEVICE, timing.plannedOnsets.lastITI);
        end
        timespec = timing.plannedOnsets.lastITI - SLACK;
        timing.actualOnsets.lastITI = isi_specific(mainWindow,COLORS.MAINFONTCOLOR,timespec);
        fprintf('Flip time error = %.4f\n', timing.actualOnsets.lastITI - timing.plannedOnsets.lastITI);
        if GetSecs - timing.actualOnsets.lastITI < 2
            WaitSecs(2 - (GetSecs - timing.actualOnsets.lastITI));
        end
        
        %wait in scanner at end of run
        if CURRENTLY_ONLINE && SESSION > TOCRITERION3
            WaitSecs(10);
        end

        if SESSION < MOT{1}
            save(MATLAB_SAVE_FILE,'stim', 'timing', 'config');
        else
            save(MATLAB_SAVE_FILE, 'stim', 'timing', 'config', 'rtData');
        end
        
        % wrap up
        if SESSION == MOT_PREP
            
            %displayText(mainWindow,CONGRATS,CONGRATSDURATION,'center',COLORS.MAINFONTCOLOR,WRAPCHARS);
            endSession(dotEK, CONGRATS);
            load(MATLAB_SAVE_FILE);
            %subplot(1,2,1)
            figure;
            plot(stim.maxspeed-stim.tGuess);
            %subplot(1,2,2)
            %plot(stim.avg_vis_resp);
            sca
        else
            %displayText(mainWindow,CONGRATS,CONGRATSDURATION,'center',COLORS.MAINFONTCOLOR,WRAPCHARS);
            endSession(dotEK, CONGRATS);
            if SESSION < MOT_LOCALIZER
                if SESSION > MOT_PREP
                    mot_realtime01b(SUBJECT,SESSION+1,SET_SPEED,scanNum,scanNow,s2);
                else
                    mot_realtime01b(SUBJECT,SESSION+1,SET_SPEED,scanNum,scanNow);
                end
            end
        end
        sca;
        
        %% FRUIT HARVEST
    case {RSVP,RSVP2}
        
        fname = findNewestFile(ppt_dir2,fullfile(ppt_dir2, ['mot_realtime01_' num2str(s2) '_' num2str(SESSION)  '*.mat']));
        y = load(fname);
        %also have to open trial information
%         fname = findNewestFile(ppt_dir2,fullfile(ppt_dir2, ['EK' num2str(SESSION)  '*.mat']));
%         p = load(fname);
        %usedWords = table2cell(p.datastruct.stimmap);
        %usedWords = [usedWords(:,1)];
        %trials = table2cell(p.datastruct.trials);
        %durations = cell2mat(trials(:,20));
        %stimid = cell2mat(trials(:,8));
        %shownwords = usedWords(stimid);
        %usedWords = stim.stim;
        % stimulus presentation parameters
        secs_per_item = 8*SPEED; % secs per item
        stim.targetLatencyMean = 12*SPEED; % time between target exposures for use in distribution. count on this being about 0.5s longer than specified, since filler items will spill over
        stim.targetLatencySd = 0*SPEED; % no jitter
        stim.shortest_expos = 0.300*SPEED;
        stim.longest_expos = 0.750*SPEED;
        stim.nminus1 = 0.5*SPEED; % trial before cue presentation
        stim.fruit_extradelay = 0;
        stim.detectKey = {INDEXFINGER};
        stim.isiDuration = 2*SPEED;
        % session-based declarations
        instruct = ['THE GREAT FRUIT HARVEST\n\nIn this task, words will flash up on the screen very quickly, one after another. If you notice a word that is a ' ...
            'type of fruit, please press the INDEX finger.\n\nNote: there are very few fruit, so make sure to catch them!\n\n-- Press INDEX to begin --'];
        stim.condDuration(REALTIME) = 0; stim.condDuration(OMIT)= 0;
        exposure = 1;
        
        % load or initialize exclusion words and cue durations
        relative_paths = 1; % for use with file search functions
        stim.exclusionList = [preparedCues];
        
        % during practice, filler is going to be a small set of repeated words to familiarize
%         if SESSION == RSVP
%             stim.fillerCues = lureWords(1:7);
%         else stim.fillerCues = lureWords(8:23);
%         end
        stim.num_short = 0; stim.num_long = 0; stim.num_omit = 0;
        PROGRESS = INDEXFINGER;
        % final initialization
        %fillerCueTargets = readStimulusFile(CUETARGETFILE,ALLMATERIALS);
        triggerNext = false;
        condmap = makeMap({'realtime','omit','lure','fruit'});
        fruitHarvestEK = initEasyKeys([exp_string_long '_FH'], SUBJ_NAME, ppt_dir,...
            'default_respmap', rsvp_scale, ...
            'condmap', condmap, ...
            'trigger_next', triggerNext, ...
            'device', DEVICE);
        fruitHarvestEK = startSession(fruitHarvestEK);
        stim.trial = 0;
        %countdown = 0;
        
        stim.fillerCues = y.stim.fillerCues;
        stim.availableFruit = round(length(stim.fillerCues) * 0.5);

        stim.scanLength = secs_per_item * length(stim.fillerCues) + stim.availableFruit;
        
        % display or skip instructions, depending on session
        displayText(mainWindow,instruct,minimumDisplay,'center',COLORS.MAINFONTCOLOR,WRAPCHARS);
        stim.subjStartTime = waitForKeyboard(kbTrig_keycode,DEVICE);
        
        stim.sessionStartTime = GetSecs();
        %[~,ision] = isi(mainWindow,stim.TRlength,COLORS.MAINFONTCOLOR);
        isi(mainWindow,stim.isiDuration,COLORS.MAINFONTCOLOR); %cange this to be actual ISI
        %lastCue = GetSecs() - 4; %initialize so it will present maybe 8 s later
        %idealLag = normrnd(stim.targetLatencyMean,stim.targetLatencySd);
        stim.enterLoop = GetSecs;
        stim.expDuration = 0;
        stim.stim = y.stim.stim;
        % keep pumping out filler words until the time is up
        while stim.trial < length(stim.stim) %stim.expDuration < ((stim.scanLength)/60) %4 seconds less changed so it stops after the right number of stim
            % initialize trial
            stim.trial = stim.trial + 1;
            stim.cond(stim.trial) = y.stim.cond(stim.trial);
            stim.promptDur(stim.trial) = y.stim.promptDur(stim.trial);
            %cueDistance = GetSecs() - lastCue; % rear-view mirror
            %if countdown, countdown = countdown - 1; end
            
            % figure out if there are any cues left
%             if ~stim.availableFruit %if there are no more fruit
%                 timeToCue = inf;
%             else % if there are cues left, check whether it's nearly time to present one
%                 timeToCue =  idealLag - cueDistance;
%                 buffer_time = unifrnd(stim.shortest_expos,stim.longest_expos);
%                 if ~countdown && timeToCue < stim.nminus1+buffer_time
%                     countdown = 2; % step 5 is sync to TR; step 4 is 0.5s constant filler; step 3 is cue; then two fillers and back to normal
%                 end
%             end
            
            % get stimulus, make sure it wasn't just used
%             stim.stim{stim.trial} = [];
%             while isempty(stim.stim{stim.trial})
%                 candidate = [];
%                 while isempty(candidate)
%                     candidate = stim.fillerCues{randi(length(stim.fillerCues))};
%                     if stim.trial > 1
%                         if strcmp(stim.stim{stim.trial-1},candidate)
%                             candidate = [];
%                         end
%                     end
%                 end
%                 stim.stim{stim.trial} = candidate;
%             end
            % by default, words are filler with random duration
            %stim.cond(stim.trial) = LUREWORD;
            cresp = {nan};
            cresp_map = zeros(1,256);
            valid_map = keys.map(2,:);
            %stim.promptDur(stim.trial) = unifrnd(stim.shortest_expos,stim.longest_expos);
            
            if stim.cond(stim.trial) == FRUIT
                cresp = {INDEXFINGER};
                cresp_map = keys.map(2,:);
            end
            % now override details based on real item type
%             switch countdown
%                 case 1 % target--if the countdown is 1, make it a fruit with 1 s duration (and 33% of the time)
%                     % what condition will the cue come from?
%                     if stim.availableFruit && (rand() < 0.33) %1/3 of the time take a fruit (stim.availableFruit / (stim.num_short + stim.num_long + stim.availableFruit - cueIndex(EASY) - cueIndex(HARD))))
%                         cresp = {INDEXFINGER};
%                         cresp_map = keys.map(2,:);
%                         stim.cond(stim.trial) = FRUIT;
%                         stim.stim{stim.trial} = fillerCueTargets{randi(length(fillerCueTargets))};
%                         stim.promptDur(stim.trial) = 1;
%                         lastCue = GetSecs() + duration + stim.fruit_extradelay; % assures us a reasonable buffer before memory cue is presented
%                         stim.availableFruit = stim.availableFruit - 1;
%                         idealLag = normrnd(stim.targetLatencyMean,stim.targetLatencySd);
%                         
%                     end
%                 case 2 % filler with n-1 duration
%                     stim.promptDur(stim.trial) = stim.nminus1;
%             end
            %stim.condString{stim.trial} = CONDSTRINGS{stim.cond(stim.trial)};
            
            trial_message = ['sess' num2str(SESSION) '_trial' num2str(stim.trial) '_cond' num2str(stim.cond(stim.trial))];
            
            
            % present stimulus
            if  stim.promptDur(stim.trial) > 0.025 % don't bother drawing less than 25ms--this is the only time we'll draw
                DrawFormattedText(mainWindow,stim.stim{stim.trial},'center','center',COLORS.MAINFONTCOLOR,WRAPCHARS);
                if stim.trial-1 > 0 %if it's not the first trial, check to see when th elast trial happened to determine best flip time
                    if stim.promptDur(stim.trial-1)>0.025 %if the last trial occured
                        timing.plannedOnsets.cue(stim.trial) = timing.actualOnsets.cue(stim.trial-1) + stim.promptDur(stim.trial-1);
                        timespec = timing.plannedOnsets.cue(stim.trial)-SLACK; %the onset should be the last onset + the duration
                    elseif promptDur(stim.trial-1)<0.025 && stim.trial-2>0
                        timing.plannedOnsets.cue(stim.trial) = timing.actualOnsets.cue(stim.trial-2) + stim.promptDur(stim.trial-2);
                        timespec = timing.plannedOnsets.cue(stim.trial)-SLACK; %if last trial didn't occur, send it at the last onset
                    else %if it's not the first trial, the last trial didn't happen, and two trials ago didn't happen (unlikely)
                        timing.plannedOnsets.cue(stim.trial) = GetSecs;
                        timespec = timing.plannedOnsets.cue(stim.trial) - SLACK;
                    end
                else %if it's the first trial, flip now
                    timing.plannedOnsets.cue(stim.trial) = GetSecs;
                    timespec = timing.plannedOnsets.cue(stim.trial) - SLACK;
                end
                timing.actualOnsets.cue(stim.trial) = Screen('Flip',mainWindow,timespec);
                fprintf('Flip time error = %.4f\n', timing.actualOnsets.cue(stim.trial) - timing.plannedOnsets.cue(stim.trial));
                
                fruitHarvestEK = easyKeys(fruitHarvestEK, ...
                    'onset', timing.actualOnsets.cue(stim.trial), ...
                    'stim', stim.stim{stim.trial}, ...
                    'cond', stim.cond(stim.trial), ...
                    'cresp', cresp, ...
                    'nesting', [SESSION stim.trial], ...
                    'prompt_dur', stim.promptDur(stim.trial), ...
                    'cresp_map', cresp_map, 'valid_map', valid_map);
                
            else
                fprintf('skip')
            end
            
            % report
            % log the stimulus and compute prior exposures
            stim.expDuration = (GetSecs() - stim.sessionStartTime) / 60;
            stim.harvest_rate = mean(fruitHarvestEK.trials.acc(stim.cond == FRUIT)); %fix these!!
            stim.false_fruit = sum(1-fruitHarvestEK.trials.acc(stim.cond ~= FRUIT));
            
            % save to file
            if mod(stim.trial,10)==0 || (stim.enterLoop >= (stim.scanLength-(STABILIZATIONTIME)))
                stim.expDuration = (GetSecs - stim.enterLoop) / 60; % experiment time in mins
                save(MATLAB_SAVE_FILE,'stim','timing');
                
            end
            
        end
        isi(mainWindow,stim.isiDuration,COLORS.MAINFONTCOLOR); %cange this to be actual ISI
        
        % present participant with feedback
        taskSummary = ['Fruit harvest rate: ' num2str(round(stim.harvest_rate*100)) '%\nFalse fruit: ' num2str(stim.false_fruit) ' items'];
        feedbackString = ['Run complete! Your performance in this run:\n\n' taskSummary ]; % Your overall performance:\n\n' overallSummary '\n\n
        displayText(mainWindow,feedbackString,CONGRATSDURATION,'center',COLORS.MAINFONTCOLOR,WRAPCHARS);
        printlog(LOG_NAME,['\n\nSESSION ' int2str(SESSION) ' ended ' datestr(now) ' for SUBJECT number ' int2str(SUBJECT) '\n\n']);
        printlog(LOG_NAME,'\n\n\n******************************************************************************\n');
        
        save(MATLAB_SAVE_FILE,'stim', 'timing');
        
        % wrap up
        if (SESSION == RSVP)
            endSession(fruitHarvestEK, NOTIFY);
            sca
        else
            endSession(fruitHarvestEK, CONGRATS);
            if SESSION > MOT_PREP
                mot_realtime01b(SUBJECT,SESSION+1,SET_SPEED,scanNum,scanNow,s2);
            else
                mot_realtime01b(SUBJECT,SESSION+1,SET_SPEED,scanNum,scanNow);
            end
        end
        
        %% SCAN PREP
        
    case SCAN_PREP
        % instructions
%         displayText(mainWindow,['Welcome to your fMRI scanning session!\n\nOnce you''re all the way inside the scanner and can read this text, please reach up to your eyes and ' ...
%             'fine-tune the position of your mirror. You want to set it so you can see as much of the screen as comfortably as possible. This will be your last chance to adjust ' ...
%             'your mirror, so be sure to set it just right.\n\nOnce you''ve adjusted the mirror to your satisfaction, please press the index finger button to test your button pad.'] ...
%             ,minimumDisplay,'center',COLORS.MAINFONTCOLOR,WRAPCHARS);
%         waitForKeyboard(kbTrig_keycode,DEVICE);
%         displayText(mainWindow,'Great. I detected that button press, which means at least one button works. Now let''s try the rest of them. Please press the middle finger button.' ...
%             ,minimumDisplay,'center',COLORS.MAINFONTCOLOR,WRAPCHARS);
%         waitForKeyboard(keys.code(3,:),DEVICE);
%         displayText(mainWindow,'And now the ring finger button...',minimumDisplay,'center',COLORS.MAINFONTCOLOR,WRAPCHARS);
%         waitForKeyboard(keys.code(4,:),DEVICE);
%         displayText(mainWindow,'And now the pinky finger button...',minimumDisplay,'center',COLORS.MAINFONTCOLOR,WRAPCHARS);
%         waitForKeyboard(keys.code(5,:),DEVICE);
%         displayText(mainWindow,'And now the thumb button...',minimumDisplay,'center',COLORS.MAINFONTCOLOR,WRAPCHARS);
%         waitForKeyboard(keys.code(1,:),DEVICE);
%         displayText(mainWindow,['Good news! It looks like the button pad is working just fine.\n\nJust a reminder that we can hear your voice when the scanner is at rest, so ' ...
%             'just speak up to ask or tell us something. During a scan, we will abort right away if you use the squeeze ball, but please do so only if there''s something urgent ' ...
%             'we need to address immediately.\n\n-- please press the index finger button to continue --'],minimumDisplay,'center',COLORS.MAINFONTCOLOR,WRAPCHARS);
%         waitForKeyboard(kbTrig_keycode,DEVICE);
%         displayText(mainWindow,['During the scan today, it is crucial that you keep your head still. Even a tiny head movement, e.g., caused by stretching your legs, will blur ' ...
%             'your brain scan. This is for the same reason that moving objects appear blurry in a photograph.\n\nAs it can be uncomfortable to stay still for a long time, please ' ...
%             'go ahead and take the opportunity to stretch or scratch whenever the scanner is silent. Just try your best to keep your head in the same place when you do so.\n\n' ...
%             '-- please press the index finger button to continue --'],minimumDisplay,'center',COLORS.MAINFONTCOLOR,WRAPCHARS);
%         waitForKeyboard(kbTrig_keycode,DEVICE);
        displayText(mainWindow,['Great job! Now, we''re now going to have a short functional run before you complete various tasks. Please work through these and we''ll get in ' ...
             'touch with you when you finish.\n\n-- please press the index finger button to continue --'],INSTANT,'center',COLORS.MAINFONTCOLOR,WRAPCHARS);
        waitForKeyboard(kbTrig_keycode,DEVICE);
        DrawFormattedText(mainWindow,'Waiting for scanner start, hold tight!','center','center',COLORS.MAINFONTCOLOR,WRAPCHARS);
        Screen('Flip', mainWindow);
        
        if CURRENTLY_ONLINE
        [timing.trig.wait timing.trig.waitSuccess] = WaitTRPulse(TRIGGER_keycode,DEVICE);
        runStart = timing.trig.wait;
        displayText(mainWindow,STILLREMINDER,STILLDURATION,'center',COLORS.MAINFONTCOLOR,WRAPCHARS);
        DrawFormattedText(mainWindow,'+','center','center',COLORS.MAINFONTCOLOR,WRAPCHARS);
        Screen('Flip', mainWindow)
        else
            runStart = GetSecs;
        end
       % runStart = timing.trig.wait;
        config.wait = 16; % we want this to be up for 8 seconds to collect sample TR's
        config.TR = 2;
        timing.plannedOnsets.offEx = runStart + config.wait;
        DrawFormattedText(mainWindow,'Done!','center','center',COLORS.MAINFONTCOLOR,WRAPCHARS);
        timespec = timing.plannedOnsets.offEx-SLACK;
        timing.actualOnsets.offEx = Screen('Flip',mainWindow,timespec);
        fprintf('Flip time error = %.4f\n', timing.actualOnsets.offEx-timing.plannedOnsets.offEx);
        
        save(MATLAB_SAVE_FILE,'timing');
        WaitSecs(2) %wait a little before closing
        sca
        %mot_realtime01(SUBJECT,SESSION+1,SET_SPEED,scanNum,scanNow);
        
        % session switch
end
return

%% get image ready for presentation (filename should include path info)
function imageHandle = prepImage(imageFilename,window,scramble)

imageData = imread(imageFilename);
dims = size(imageData);
if exist('scramble','var') && ~isempty(scramble) && scramble %only if you're scrambling images!!
    imageData = reshape(imageData(randperm(numel(imageData))),dims);
end
imageHandle = Screen('MakeTexture', window, imageData);


return

%% quick computation of TR and experiment time relative to experiment start (note: time=0s -> TR1
function [TR timePassed] = calcOnsetTR(trialStartSecs,expStartSecs,trlengthSecs)
timePassed = trialStartSecs-expStartSecs;
TR = ((round((((timePassed)*1000) / (trlengthSecs*1000))*10)/10))+1;
return


function [targetBin,timeon] = dot_refresh(window,targetBin,dots,square_bounds,dot_dia,COLORS,cue,show_targs,show_probe,prompt_active,timespec)

% prepare time-gating
target_frame_rate = 30;
time_bins = 0:1000/target_frame_rate:1000;

% define colors for drawing
square_col = COLORS.BLACK;
targ_col = COLORS.RED;
normal_col = COLORS.GREEN;
probe_col = COLORS.WHITE;
font_col = COLORS.WHITE;
centerdot_size = 5;

% determine if we want a picture or black background
if isempty(cue) || ischar(cue)
    picture_mode = false;
    fix_col = COLORS.GREY;
    bumper_size = 0;
else
    picture_mode = true;
    fix_col = COLORS.BLACK;
    bumper_size = 2;
end
if prompt_active
    fix_col = COLORS.RED;
end

% draw square
offset = square_bounds(1:2);
if picture_mode
    bg_texture = Screen('MakeTexture', window, cue);
    Screen('DrawTexture', window, bg_texture, [0 0 size(cue)], square_bounds, []);
else
    Screen('FillRect', window, square_col, square_bounds)
end

% collect dots to draw
drawTargs = []; drawProbe = []; drawNormal = []; drawShadow = [];
trial = find(~isnan(dots(1).pos(:,1)),1,'last');
for i=1:length(dots)
    if picture_mode
        drawShadow = [drawShadow; [round(dots(i).pos(trial,1)+offset(1)) round(dots(i).pos(trial,2)+offset(2))]];
    end
    if show_targs && dots(i).is_target
        drawTargs = [drawTargs; [round(dots(i).pos(trial,1)+offset(1)) round(dots(i).pos(trial,2)+offset(2))]];
    elseif show_probe && dots(i).is_probe
        drawProbe = [drawProbe; [round(dots(i).pos(trial,1)+offset(1)) round(dots(i).pos(trial,2)+offset(2))]];
    else
        drawNormal = [drawNormal; [round(dots(i).pos(trial,1)+offset(1)) round(dots(i).pos(trial,2)+offset(2))]];
    end
end

% draw the dots
if ~isempty(drawShadow)
    Screen('FillOval',window,COLORS.BLACK,[drawShadow(:,1:2)-(dot_dia/2)-bumper_size drawShadow(:,1:2)+dot_dia/2 + bumper_size]',dot_dia+ (bumper_size*2))
end
if ~isempty(drawTargs)
    Screen('FillOval',window,targ_col,[drawTargs(:,1:2)-(dot_dia/2) drawTargs(:,1:2) + dot_dia/2]',dot_dia)
end
if ~isempty(drawProbe)
    Screen('FillOval',window,probe_col,[drawProbe(:,1:2)-(dot_dia/2) drawProbe(:,1:2) + dot_dia/2]',dot_dia)
end
if ~isempty(drawNormal)
    Screen('FillOval',window,normal_col,[drawNormal(:,1:2)-(dot_dia/2) drawNormal(:,1:2) + dot_dia/2]',dot_dia)
end

% cue or fixation
Screen('TextSize', window,36);
Screen('TextFont', window,'Arial');
if ~isempty(cue) && ~picture_mode && ischar(cue)
    DrawFormattedText(window,cue,'center','center',font_col);
end

% draw fixation point
center = [(square_bounds(1)+square_bounds(3))/2 (square_bounds(2)+square_bounds(4))/2 + 4]';
center_fix_pos = [center - centerdot_size; center + centerdot_size];
Screen('FillOval',window,fix_col,center_fix_pos,dot_dia)

% show the result
Screen('DrawingFinished', window);
if picture_mode, Screen('Close', bg_texture); end

% control dot-drawing refresh rate
if isempty(targetBin)
    now = round(mod(GetSecs(),1)*1000);
    targetBin = histc(now,time_bins) + 1;
else
    bin = 0;
    while bin ~= targetBin
        now = round(mod(GetSecs(),1)*1000);
        bin = histc(now,time_bins);
        if bin ~= targetBin
            pause(0.01);
        end
    end
    targetBin = bin + 1;
end
if ~exist('timespec', 'var')
    timeon = Screen('Flip', window);
else
    timeon = Screen('Flip',window,timespec);
    %    fprintf('Flip time error = %.4f\n', timeon - timespec);
end

return

function [dots,framestart] = dot_compute(dots,speed,square_dims,dot_dia,phantom_dots,windowSize,repulse,framestart,repulsor_force)

% parameters
fps = 30;
%speed = 25;
%speed = mean(windowSize.pixels)*2;
%repulse = 7/3;
rate = speed * (1 / fps) / mean(windowSize.degrees_per_pixel);
%rate = mean(windowSize.pixels)*2/fps; this is the eqn to get 1 Hz
%motion****
%speed_limit = speed * (2 / fps) / mean(windowSize.degrees_per_pixel); % frame-wise speed limit in degrees (0.119 for 33.33ms draw rate)
repulsor_focus = 2;
%repulsor_force = 0;
%repulsor_force = speed * 0.1;
%repulsor_force = 2;
repulsor_distance = dot_dia*repulse; %4/3 first
bumper_limit = dot_dia*1.5;
%bumper_limit = dot_dia*proximity;
% initialize
num_dots = length(dots);
prev_trial = find(~isnan(dots(1).pos(:,1)),1,'last');
trial = prev_trial + 1;
dotList = zeros(num_dots,2);

% randomly update all dot trajectories
for i = 1:num_dots
    
    %dots(i).trajectory(trial,:) = dots(i).trajectory(prev_trial,:) + (([rand() rand()]-0.5)*rate); %negative .5 to +.5
    %dots(i).trajectory(trial,:) = dots(i).trajectory(prev_trial,:);
    vx = (rand-0.5)*(rate);
    vy = sign(rand-0.5)*sqrt(rate^2 - vx^2);
    if prev_trial == 1
        dots(i).trajectory(trial,:) = [vx vy];
    else
        dots(i).trajectory(trial,:) = dots(i).trajectory(prev_trial,:); %keep it in the same direction unless acted upon by outside force!!
    end
    dots(i).pos(trial,:) = dots(i).pos(prev_trial,:) + dots(i).trajectory(trial,:) ;
    dotList(i,:) = dots(i).pos(trial,:); % accumulate dot positions
end
%bigDotList = [dotList; phantom_dots];
bigDotList = [dotList];
% imminent collision detector
distances = ipdm(dotList) + (eye(size(dotList,1)) + tril(ones(size(dotList,1))))*bumper_limit;
collisions = distances < bumper_limit;
if any(any(collisions))
    [dot1 dot2] = find(collisions); %do this for every collision
    for i=1:length(dot1)
        %first we're going to find the direction that they collided with on
        %the past trial
        % to catch bad behavior, we're assuming they collided in prev_trial
        %PASS = 0;
        if trial > 2 %check for bad behavior
            
            D1 = dots(dot1(i)).pos(trial-1:trial,:);
            D2 = dots(dot2(i)).pos(trial-1:trial,:);
            
            lastDistance = pdist([D1(1,:); D2(1,:)]);
            currentDistance = pdist([D1(2,:); D2(2,:)]);
            D1pos = D1(2,:);
            D2pos = D2(2,:);
            subtractpositions = abs(D1 - D2);
            %find which direction they're colliding in
            
            %velocities = [dots(dot1(i)).trajectory(trial,:); dots(dot2(i)).trajectory(trial,:)];
            %x_collision = sign(prod(velocities(:,1))) < 0;
            %y_collision = sign(prod(velocities(:,2))) < 0;
            x_collision = subtractpositions(1,1) - subtractpositions(2,1) > 0;
            y_collision = subtractpositions(1,2) - subtractpositions(2,2) > 0;
            %collision on the last refresh
            %xvel = [dots(dot1(i)).trajectory(trial-2,1) dots(dot1(i)).trajectory(trial-1,1)];
            % yvel = [dots(dot1(i)).trajectory(trial-2,1) dots(dot1(i)).trajectory(trial-1,1)];
            
            if currentDistance < lastDistance %|| (sign(prod(xvel)) > 0) || (sign(prod(yvel)) > 0) %this means they're getting closer
                % 3/20/16: try to make it so dots ALWAYS move away from
                % each other instead of just reversing direction
                
                
                if x_collision %&&  sign(prod(xvel(:,1))) > 0;%check if they didn't also flip signs in x velocity 2 trials ago
                    if D1pos(1) < D2pos(1) %if first ball is to the left, move it to the left
                        dots(dot1(i)).trajectory(trial,1) = abs(dots(dot1(i)).trajectory(prev_trial,1)) * -1;
                        dots(dot2(i)).trajectory(trial,1) = abs(dots(dot2(i)).trajectory(prev_trial,1));
                    else %if the first dot is to the right
                        dots(dot1(i)).trajectory(trial,1) = abs(dots(dot1(i)).trajectory(prev_trial,1));
                        dots(dot2(i)).trajectory(trial,1) = abs(dots(dot2(i)).trajectory(prev_trial,1)) * -1;
                        %dots(dot1(i)).trajectory(trial,1) = dots(dot1(i)).trajectory(prev_trial,1) * -1;
                        %dots(dot2(i)).trajectory(trial,1) = dots(dot2(i)).trajectory(prev_trial,1) * -1;
                    end
                end
                if y_collision %&& sign(prod(yvel(:,1))) > 0;
                    if D1pos(2) < D2pos(2) %if the first dot is higher
                        dots(dot1(i)).trajectory(trial,2) = abs(dots(dot1(i)).trajectory(prev_trial,2)) * -1;
                        dots(dot2(i)).trajectory(trial,2) = abs(dots(dot2(i)).trajectory(prev_trial,2));
                    else
                        dots(dot1(i)).trajectory(trial,2) = abs(dots(dot1(i)).trajectory(prev_trial,2));
                        dots(dot2(i)).trajectory(trial,2) = abs(dots(dot2(i)).trajectory(prev_trial,2)) * -1;
                    end
                    
                    %dots(dot1(i)).trajectory(trial,2) = dots(dot1(i)).trajectory(prev_trial,2) * -1;
                    %dots(dot2(i)).trajectory(trial,2) = dots(dot2(i)).trajectory(prev_trial,2) * -1;
                    
                end
                %               if ~x_collision && ~y_collision
                %                   %stop here and figure it out
                %                   %see why this would be the case--look for clues
                %                   daldsaljsld
                %               end
                
            else %make sure if you're not reversing that the dots aren't moving towards one another
                fprintf('saved?!?!?!?')
                % framestart(i,1) = trial;
                % framestart(i,2) = dot1;
                % framestart(i,3) = dot2;
                %dots(dot1(i)).trajectory(trial,:) = dots(dot1(i)).trajectory(prev_trial,:);
                %dots(dot2(i)).trajectory(trial,:) = dots(dot2(i)).trajectory(prev_trial,:);
            end
            % dots(dot1(i)).pos(trial,:) = dots(i).pos(prev_trial,:) + dots(dot1(i)).trajectory(trial,:);
        end
    end
end
% if  ~isempty(framestart) && trial >= framestart(1,1) + 10
%    % sldlad
% elseif isempty(framestart)
%     framestart = [];
% end
% reflect at the edges

%repulsor_force = 40;
% apply force fields based on dot distances
distances = ipdm(bigDotList) - repulsor_distance;
distances(distances<0) = NaN;
for i = 1:num_dots
    my_pos = dots(i).pos(trial,:);
    pos_diff = -1 * bsxfun(@minus,bigDotList,my_pos);
    for j = 1:length(pos_diff)
        pos_diff_norm(j,:) = pos_diff(j,:)/norm(pos_diff(j,:));
    end
    dist_factor = distances(i,:) .^ -repulsor_focus; %magnitude difference
    vecs = bsxfun(@times,pos_diff_norm,dist_factor');
    %they hit and then here tellin?
    %repulsor_force*sum(vecs(~isnan(vecs(:,1)),:),1);
    newroute = dots(i).trajectory(trial,:) + repulsor_force*sum(vecs(~isnan(vecs(:,1)),:),1);
    
    C = sqrt(rate^2/(newroute(1)^2 + newroute(2)^2));
    dots(i).trajectory(trial,:) = C*newroute;
    %dots(i).trajectory(trial,:) = ratio*newroute;
end

edge_dist = 2/3;

for i = 1:num_dots
    reflect =  [(dots(i).pos(trial,:) < dot_dia*edge_dist) ; (dots(i).pos(trial,:) > square_dims - dot_dia*edge_dist)];
    %reflect = -1 * ((dots(i).pos(trial,:) < dot_dia/1.5) + (dots(i).pos(trial,:) > square_dims - dot_dia/1.5));
    if sum(sum(reflect))~=0
        [rows cols] = find(reflect~=0);
        if sum(reflect(1,:)) ~=0 %this means too small so set trajectory positive in that direction
            coords = find(reflect(1,:)~=0);
            dots(i).trajectory(trial,coords) = abs(dots(i).trajectory(trial,coords)); %make positive
        elseif sum(reflect(2,:)~=0) %here too big so make negative
            coords = find(reflect(2,:)~=0);
            dots(i).trajectory(trial,coords) = -1*abs(dots(i).trajectory(trial,coords));
        end
        %reflect(reflect == 0) = 1;
        %dots(i).trajectory(trial,:) = dots(i).trajectory(prev_trial,:) .* reflect;
        % dots(i).pos(trial,:) = dots(i).pos(prev_trial,:) + dots(i).trajectory(trial,:);
    end
end

%     % don't break the speed limit
%     for i = 1:num_dots
%         speeding_ticket = abs(dots(i).trajectory(trial,:)) > speed_limit;
%         if any(speeding_ticket);
%             bigger_val = max(abs(dots(i).trajectory(trial,:)));
%             dots(i).trajectory(trial,:) = dots(i).trajectory(trial,:) / bigger_val * speed_limit;
%             dots(i).pos(trial,:) = dots(i).pos(prev_trial,:) + dots(i).trajectory(trial,:);
%         end
%     end
%
%
return

function [dots phantom_dots] = initialize_dots(num_dots,num_targets,square_dims,dot_dia)

% params
min_boundary = dot_dia;
min_distance = dot_dia*2;
safe_dims = square_dims - (min_boundary*2);

% phantom dots
phantom_dots(1,:) = square_dims / 2;
phantom_dots(end+1,:) = [1 1];
phantom_dots(end+1,:) = square_dims;
phantom_dots(end+1,:) = [square_dims(1) 1];
phantom_dots(end+1,:) = [1 square_dims(2)];

% initialize
is_good = false;

% keep trying to generate dots until we get it right
while ~is_good
    dotPosList = phantom_dots; targetList = false(length(phantom_dots),1);
    
    % create new dots iteratively
    for dot = 1:num_dots
        % begin will null metadata
        if dot <= num_targets
            dots(dot).is_target = true;
        else
            dots(dot).is_target = false;
        end
        dots(dot).is_probe = false;
        dots(dot).pos = nan(600,2);
        dots(dot).trajectory = nan(600,2);
        dots(dot).trajectory(1,:) = 0;
        
        % initialize position
        good_dot = false;
        while ~good_dot
            for d = 1:2
                dots(dot).pos(1,d) = rand()*safe_dims(d)+min_boundary;
            end
            distance = ipdm(dots(dot).pos(1,:),dotPosList);
            if all(distance > min_distance)
                good_dot = true;
            end
        end
        
        % log the new dot
        dots(dot).log = dots(dot).pos(1,:);
        dotPosList = [dotPosList; dots(dot).pos(1,:)];
        targetList = [targetList; dots(dot).is_target];
    end % dot
    
    % on-multi-target trials, reject the selection if there is bunching of targets
    if sum(targetList) > 1
        % assess general dot distances in ten 5-subset samples of dots
        for i = 1:10
            for j = 1:5
                choice(j) = randi(10);
            end
            general_distance(i) = mean(mean(ipdm(dotPosList(choice,:))));
        end
        general_distance = mean(general_distance);
        
        % compare this to the distance in our target subsample
        inter_targ_distance = mean(mean(ipdm(dotPosList(targetList,:))));
        if abs(inter_targ_distance - general_distance) < (general_distance * 0.2)
            is_good = true;
        end
    else
        is_good = true;
    end
end % is_good

return


function [acc rt timefirst] = odd_even(digitsEK,num_qs,q_dur,isi_dur,min_format,window,keys,COLORS,DEVICE,SUBJ_NAME, nest_info,SLACK,timespecFirst, keysObject)

% initialize
old_keys = [1 5];
triggerNext = false; %changed because presentation has to be the same!!!!
console = false;
files = false;

acc = nan; rt = nan;
CORRECT_COLOR = COLORS.GREEN;
INCORRECT_COLOR = COLORS.RED;
% loop over digit probes
for digit_q = 1:num_qs
    
    % prepare trial data
    digit_picks = [0 0];
    while sum(digit_picks) <= 10
        digit_picks = [randi(9) randi(9)];
    end
    is_odd = mod(sum(digit_picks),2);
    if min_format
        digit_prompt = [num2str(digit_picks(1)) '  +  ' num2str(digit_picks(2))];
    else
        digit_prompt = [num2str(digit_picks(1)) '  +  ' num2str(digit_picks(2)) '\n\n'];
        prompt_white = '\n\nEVEN                              ODD';
    end
    cresp = is_odd + 1;
    
    % execute
    DrawFormattedText(window,digit_prompt,'center','center',COLORS.MAINFONTCOLOR,0);
    if ~min_format
        DrawFormattedText(window,prompt_white,'center','center',COLORS.MAINFONTCOLOR,0);
    end
    if digit_q == 1
        onset = Screen('Flip',window,timespecFirst);
        timefirst = onset;
    else
        timespec = ision(digit_q-1) + isi_dur - SLACK;
        onset = Screen('Flip',window,timespec);
    end
    digitsEK = easyKeys(digitsEK, ...
        'onset', onset, ...
        'stim', digit_prompt, ...
        'nesting', [nest_info digit_q], ...
        'cresp', keys(cresp), 'cresp_map', keysObject.map(old_keys(cresp),:), 'valid_map', sum(keysObject.map(old_keys,:)));
    timespec = onset + q_dur - SLACK;
    ision(digit_q) = isi_specific(window,COLORS.MAINFONTCOLOR,timespec);
end % loop over q's

% summary stats
acc = mean(digitsEK.trials.acc);
valid_rts = ~isnan(digitsEK.trials.rt);
if sum(valid_rts) > 0
    rt = mean(digitsEK.trials.rt(valid_rts));
else rt = nan;
end


return
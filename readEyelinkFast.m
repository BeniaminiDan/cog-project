function [SAMPLES, triggers, FIXATIONS, SACCADES, BLINKS, start_recording, stop_recording] = ...
    readEyelinkFast(file_name,varargin)
% [samples triggers]=readEyelinkFast(file)
% Read an EyeLink Eye-Tracker data file and return an array of samples and
% an array of triggers:
% SAMPLES: Nsamp X Nchannels matrix of samples. The 7 channels are:
%     1. Time [ms]
%     2. Left Horizontal (Xl)   [pixels]
%     3. Left Vertical (Yl)         [pixels]
%     4. Left Pupil Size
%     5. Right Horizontal (Xr) [pixels]
%     6. Right Vertical (Yr)      [pixels]
%     7. Right Pupil Size
% triggers: Ntrig X 2 vector of trigger data. The two columns are:
%     1. Time [ms]
%     2. Trigger code
% fixations:
% saccades:
% blinks:
%
%
% Optional input:
% readEyelinkFast_mine(...,'readEyes','lr'):    Optional 'recordedEyes' input 'lr','r','l'.
%                                                    Default is 'lr' both eyes.
% readEyelinkFast_mine(...,'show_output',false):    Show output. Default true.
% readEyelinkFast_mine(...,'fixations',true):       Read Eyelink defined fixations. Default true.
% readEyelinkFast_mine(...,'saccades',true):        Read Eyelink defined saccades. Default true.
% readEyelinkFast_mine(...,'blinks',true):          Read Eyelink defined blinks. Default true.

% initialize optional arguments
readEyes = 'lr';
show_output = 1;
fixations = true;
saccades = true;
blinks = true;
warning('off','MATLAB:iofun:UnsupportedEncoding');

FIXATIONS = []; SACCADES = []; BLINKS = [];
samples = []; triggers = [];

%% Handle input
narg = size(varargin,2);
arg  = 1;
if narg>0
    while arg <= narg
        if ischar(varargin{arg})
            switch varargin{arg}
                case 'readEyes'
                    if narg > arg && isvector(varargin{arg+1}) && ischar(varargin{arg+1})
                        if strcmp(varargin{arg+1},'rl') || strcmp(varargin{arg+1},'lr')
                            readEyes = 'lr'; readColumns = 2:7;
                        elseif strcmp(varargin{arg+1},'l'); readEyes = 'LEFT';readColumns = 2:4;
                        elseif strcmp(varargin{arg+1},'r'); readEyes = 'RIGHT';
                        else
                            error('readEyelinkFast: ''readEyes'' should be followed by ''lr'',''r'',''l''');
                        end
                        arg = arg + 2;
                    else
                        error('readEyelinkFast: ''readEyes'' should be followed by ''lr'',''r'',''l''');
                    end
                case 'show_output'
                    if narg > arg && (islogical(varargin{arg+1}) || ismember(varargin{arg+1},[0 1]))
                        show_output = logical(varargin{arg+1});
                        arg = arg + 2;
                    else
                        error('readEyelinkFast: ''show_output'' should be followed by true/false or 0/1');
                    end
                case 'fixations'
                    if narg > arg && (islogical(varargin{arg+1}) || ismember(varargin{arg+1},[0 1]))
                        fixations = logical(varargin{arg+1});
                        arg = arg + 2;
                    else
                        error('readEyelinkFast: ''fixations'' should be followed by true/false or 0/1');
                    end
                case 'saccades'
                    if narg > arg && (islogical(varargin{arg+1}) || ismember(varargin{arg+1},[0 1]))
                        saccades = logical(varargin{arg+1});
                        arg = arg + 2;
                    else
                        error('readEyelinkFast: ''saccades'' should be followed by true/false or 0/1');
                    end
                case 'blinks'
                    if narg > arg && (islogical(varargin{arg+1}) || ismember(varargin{arg+1},[0 1]))
                        blinks = logical(varargin{arg+1});
                        arg = arg + 2;
                    else
                        error('readEyelinkFast: ''blinks'' should be followed by true/false or 0/1');
                    end
                otherwise
                    error(['Unknown argument: ' varargin{arg}]);
            end
        else
            error('Arguments must be preceded by indicative optional string description.');
        end
    end
end
%% Open and read text file
fid = fopen(file_name);

% Read file into cell matrix
if show_output;fprintf('\nReading ASCII file... ');end
tic;
DATA = textscan(fid,'%s %s %s %s %s %s %s %s %s %s %s %*[^\n]','headerLines',11);
t = toc;

if show_output;fprintf(['Done in ' num2str(t) ' seconds.\n']);end
% nLines = size(DATA{1},1);

% Extract triggers
if show_output;fprintf('Extracting triggers...');end
trigLines1 = find(strcmp('INPUT',DATA{1}));
trigLines2=[]; %trigLines2 = find(strcmp('MSG',DATA{1})); %If triggers were sent as
% messages then they were not sent via the trigger splitter
trigLines = [trigLines1 ;trigLines2];
trigTimes = str2double(DATA{2}(trigLines));
trigCodes = str2double(DATA{3}(trigLines));
keeprows = ~isnan(trigCodes) & trigCodes~=0; %delete nan rows due to other mssages
triggers = [trigTimes(keeprows) trigCodes(keeprows)];
if show_output;fprintf('Done\n');end

startLines = find(strcmp('START',DATA{1}));
endLines = find(strcmp('END',DATA{1}));
start_recording = str2double(DATA{2}(startLines));
stop_recording = str2double(DATA{2}(endLines));
% If right eye was recorded, find the correct colums to use throught the
% experiment (left is always the first colums, but if both eyes were recorded at
% first and then only the right was recorded, the colums for the right eye
% data will change during the experiment)
if strcmpi(readEyes,'RIGHT')
    if show_output;fprintf('Right eye recorded, finding correct colums to read');end
    %check for transfer from 2 recorded eyes to one. 
    recEyes(:,1) = DATA{3}(startLines); %first eye
    recEyes(:,2) = DATA{4}(startLines); %second eye
    [~,~,ChangeFirstEye] = unique(recEyes(:,1));
    [~,~,ChangeSecondEye] = unique(recEyes(:,2)); % if the unique here is not only 'RIGHT' then there is a transfer
    
    Breaks{1} = find(diff(ChangeFirstEye)~=0)+1; 
    Breaks{2} = find(diff(ChangeSecondEye)~=0)+1;
    diffNums = cellfun(@length,Breaks);
    % if there are the same amount of changes in each column
    choice = '';
    if range(diffNums)~=0
        choice = questdlg([' You want to get right data but there was a section'...
            'only left was recorded. keep left data here or only right'],'','only right','left for this part','only right');
        Breaks = cell2mat(Breaks(2));
    else
        Breaks(2) = []; Breaks = cell2mat(Breaks);
    end
    %now add the first startline idx
    Breaks(end+1) = 1; Breaks = circshift(Breaks,1);
    BREAKS = recEyes(Breaks,2);
    BREAKS(strcmpi(BREAKS(:,1),'RIGHT'),2) = {5:7};
    if all(~strcmpi(BREAKS(:,1),'RIGHT'));OneEyeRec = true; else; OneEyeRec = false;end
    if strcmp(choice,'only right');  BREAKS(~strcmpi(BREAKS(:,1),'RIGHT'),2) = {0};
    else; BREAKS(~strcmpi(BREAKS(:,1),'RIGHT'),2) = {2:4}; end
    BREAKS(:,3) = num2cell(Breaks); clear Breaks
    if show_output;fprintf('Found colums for Recorded eye: %s. Done\n',readEyes);end
else
    BREAKS(1,2:3) = ({readColumns,1});
end

if show_output;fprintf('Extracting timestamps...');end
strc = char(DATA{1});
% This is to get rid of numerics in the format XXXe-XX which screw up sscanf:
strc(1:startLines(1),:) = repmat('X',startLines(1),size(strc,2));
for i = 1:(length(startLines)-1)
    strc(endLines(i):startLines(i+1),:) = repmat('X',startLines(i+1)-endLines(i)+1,size(strc,2));
end
strc(endLines(end):end,:) = repmat('X',size(strc,1)-endLines(end)+1,size(strc,2));
% Get rid of non-numerics:
numeric = (strc(:,1) == '0' | strc(:,1) == '1' | strc(:,1) == '2' | strc(:,1) == '3' | strc(:,1) == '4' | strc(:,1) == '5' | strc(:,1) == '6' | strc(:,1) == '7' | strc(:,1) == '8' | strc(:,1) == '9');
strc(~numeric,:) = repmat('0',sum(~numeric),size(strc,2));
strc(startLines,end) = repmat('9',length(startLines),1);
% Add spaces, concatenate and convert to numbers using sscanf:
strc = [strc repmat(' ',size(strc,1),1)];
strc = reshape(strc',1,[]);
timeStamps = sscanf(strc,'%f');
% Alternative, this works but it's much slower:
% timeStamps = str2double(DATA{1});
% timeStamps(isnan(timeStamps)) = 0;
if show_output;fprintf('Done\n');end

%break up data if recorded eyes changed in the middle (size(BREAK,1)~=1)
%init vars
TIMESTAMPS = cell(size(BREAKS,1),1); relDATA = cell(size(BREAKS,1),1); 
validSampIdx = cell(size(BREAKS,1),1); samples = cell(size(BREAKS,1),1); 
valid_samples = cell(size(BREAKS,1),1);

for b = 1:size(BREAKS,1) 
    if b==size(BREAKS,1);END = endLines(end);
    else; END = endLines(BREAKS{b+1,3}-1); end
    TIMESTAMPS{b} = timeStamps(startLines(BREAKS{b,3}):END);
    relDATA{b} = cellfun(@(x) x(startLines(BREAKS{b,3}):END), ...
        DATA,'UniformOutput',false); %DATA{c}(validSampIdx{b}
    TIMESTAMPS{b}(TIMESTAMPS{b}==9) = 0; %dont need to mark the start lines anymore
    validSampIdx{b} = (~~TIMESTAMPS{b} & TIMESTAMPS{b}); % The sample lines are those with non-zero sample times:    
end

for b = 1:size(BREAKS,1)
    nSamp = sum(validSampIdx{b});
    samples{b} = nan(nSamp,7);
    readColumns = BREAKS{b,2};
    if all(readColumns==0); continue; end %this was a section where only one eye tracked and not the dominant
    valid_samples{b} = true(size(samples{b}));
    samples{b}(:,1) = TIMESTAMPS{b}(validSampIdx{b});
%     validSampIdxLim = length(validSampIdx);
%     samplesIdxLim = length(samples(:,1));
    for c = 1:size(readColumns,2)
        if show_output
            if c==1;fprintf(['Reading samples, column ' num2str(readColumns(c))]);
            elseif c==size(readColumns,2); fprintf([', column ' num2str(readColumns(c)) '\n']);
            else;fprintf([', column ' num2str(readColumns(c))]); 
            end
        end
        str = char(relDATA{b}{readColumns(c)}(validSampIdx{b}));  % covert to characters
        valid_samples{b}(:,readColumns(c)) = str(:,1)~='.' & all(str(:,1)~='...',2) & all(str(:,1)~=' ',2);  % find valid samples '...' is when suddenly only one eye tracked
        str = str(valid_samples{b}(:,readColumns(c)),:);  % take only valid (numeric) strings
        strc = [str repmat(' ',size(str,1),1)]; %  add white space at the end of each string
        strc = reshape(strc',1,[]);  % concatenate strings
        assert(length(sscanf(strc,'%f'))==sum(valid_samples{b}(:,readColumns(c))))
        insertCols = readColumns(c);
        if strcmpi(readEyes,'RIGHT') & OneEyeRec; insertCols = readColumns(c)+ 3; end %to put it in the location of the right eye.
        samples{b}(valid_samples{b}(:,readColumns(c)),insertCols) = sscanf(strc,'%f');  % convert to numbers
    end    
end
if size(samples,1)==1; SAMPLES = samples{1};
else; SAMPLES=[];
    for b=1:size(samples,1)
        SAMPLES = [SAMPLES ; samples{b}(:,[1 BREAKS{b,2}])];
    end     
end
if strcmpi(readEyes,'RIGHT') && size(SAMPLES,2)==4
    SAMPLES = [SAMPLES(:,1), nan(size(SAMPLES,1),3), SAMPLES(:,2:4)]; %right eye data shold be cols 5:7
end
%% Extract timeStamps of Eye events - Fixations/Saccades/Blinks
EYES = {'L','R'};
if fixations %start times,end times,duration,X,Y
    if show_output;fprintf('Extracting Fixation data...');end
    Table = cell(size(EYES));
    for e = 1:length(EYES)
        StartFixTime = (strcmp('EFIX',DATA{1}) & strcmp(EYES{e},DATA{2}));
        EndFixTime = str2double(DATA{4}(StartFixTime));
        DurFix = str2double(DATA{5}(StartFixTime));
        XFix = str2double(DATA{6}(StartFixTime));
        YFix = str2double(DATA{7}(StartFixTime));
        StartFixTime = str2double(DATA{3}(StartFixTime));
        eval(sprintf('VariableNames = {''StartFixTime%s'',''EndFixTime%s'',''DurFix%s'',''XFix%s'',''YFix%s''};',...
            EYES{e},EYES{e},EYES{e},EYES{e},EYES{e}))
        Table{e} = table(StartFixTime,EndFixTime,DurFix,XFix,YFix,'VariableNames',VariableNames);
        if isempty(Table{e})
            Table{e} = table(nan,nan,nan,nan,nan,'VariableNames',VariableNames);
        end
        clear VariableNames
    end
    
    [Y,I] = max([size(Table{1},1),size(Table{2},1)]); I=find(~ismember([1 2],I));
    nanTable = array2table(nan(Y-size(Table{I},1),size(Table{I},2)));
    nanTable.Properties.VariableNames = Table{I}.Properties.VariableNames;
    Table{I} = [Table{I} ; nanTable];
    if I==1;FIXATIONS = [Table{I}, Table{2}];else;FIXATIONS = [Table{1}, Table{I}];end
    
    clear Table
end
if saccades
    if show_output;fprintf('Extracting Saccade data...');end
    Table = cell(size(EYES));
    for e = 1:length(EYES)
        %start times,end times,duration,startX,startY, endX,endY,visual angle amplitude,peakvelocity
        StartSaccTime = (strcmp('ESACC',DATA{1}) & strcmp(EYES{e},DATA{2}));
        EndSaccTime = str2double(DATA{4}(StartSaccTime));
        DurSacc = str2double(DATA{5}(StartSaccTime));
        StartSaccX = str2double(DATA{6}(StartSaccTime));
        StartSaccY = str2double(DATA{7}(StartSaccTime));
        EndSaccX = str2double(DATA{8}(StartSaccTime));
        EndSaccY = str2double(DATA{9}(StartSaccTime));
        visAngleAmp = str2double(DATA{10}(StartSaccTime));
        peakVelocity = str2double(DATA{11}(StartSaccTime));
        StartSaccTime = str2double(DATA{3}(StartSaccTime));
        eval(sprintf('VariableNames = {''StartSaccTime%s'',''EndSaccTime%s'',''DurSacc%s'',''StartSaccX%s'',''StartSaccY%s'',''EndSaccX%s'',''EndSaccY%s'',''visAngleAmp%s'',''peakVelocity%s''};',...
            EYES{e},EYES{e},EYES{e},EYES{e},EYES{e},EYES{e},EYES{e},EYES{e},EYES{e}))
        Table{e} = table(StartSaccTime,EndSaccTime,DurSacc,StartSaccX,...
            StartSaccY,EndSaccX,EndSaccY,visAngleAmp,peakVelocity,'VariableNames',VariableNames);
        if isempty(Table{e})
            Table{e} = table(nan,nan,nan,nan,nan,nan,nan,nan,nan,'VariableNames',VariableNames);
        end
        clear VariableNames
    end
    
    [Y,I] = max([size(Table{1},1),size(Table{2},1)]); I=find(~ismember([1 2],I));
    nanTable = array2table(nan(Y-size(Table{I},1),size(Table{I},2)));
    nanTable.Properties.VariableNames = Table{I}.Properties.VariableNames;
    Table{I} = [Table{I} ; nanTable];
    if I==1;SACCADES = [Table{I}, Table{2}];else;SACCADES = [Table{1}, Table{I}];end
    
    clear Table
end
if blinks %start times,end times
    if show_output;fprintf('Extracting Blink data...');end
    Table = cell(size(EYES));
    for e = 1:length(EYES)
        StartBlinkTime = (strcmp('EBLINK',DATA{1}) & strcmp(EYES{e},DATA{2}));
        EndBlinkTime = str2double(DATA{4}(StartBlinkTime));
        StartBlinkTime = str2double(DATA{3}(StartBlinkTime));
        eval(sprintf('VariableNames = {''StartBlinkTime%s'',''EndBlinkTime%s''};',...
            EYES{e},EYES{e}))
        Table{e} = table(StartBlinkTime,EndBlinkTime,'VariableNames',VariableNames);
        if isempty(Table{e})
            Table{e} = table(nan,nan,'VariableNames',VariableNames);
        end
        clear VariableNames
    end
    
    [Y,I] = max([size(Table{1},1),size(Table{2},1)]); I=find(~ismember([1 2],I));
    nanTable = array2table(nan(Y-size(Table{I},1),size(Table{I},2)));
    nanTable.Properties.VariableNames = Table{I}.Properties.VariableNames;
    Table{I} = [Table{I} ; nanTable];
    if I==1;BLINKS = [Table{I}, Table{2}];else;BLINKS = [Table{1}, Table{I}];end
    
    clear Table
end

if show_output;fprintf('Done.\n');end

warning('on','MATLAB:iofun:UnsupportedEncoding');

end
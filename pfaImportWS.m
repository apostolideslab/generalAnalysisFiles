function [ephysData,headerInfo] = pfaImportWS

%this function imports your wavesurfer electrophysiology files so you can
%analyze them in Matlab. pfa 20180512.
%This has been tested on data collected with the following Wavesurfer
%releases: 0.946, 0.964

%Thank you to Adam L. Taylor for help with an earlier
%version of this script.

%open UI dialog to select a list of files, or alternatively an entire
%folder containing your electrophysiology data.
promptStr = {'select file','select folder'} ;
promptChoice = listdlg('PromptString','Select option:','SelectionMode','single','ListString',promptStr) ;

if promptChoice == 1
    [fileName,pathName] = uigetfile('*.h5','MultiSelect','On') ;
    userChoice = 0 ;
else
    pathName = uigetdir ;
    userChoice = 1 ;
end

%cd to the directory
cd(pathName);

%% asks the user whether they're importing a single file or folder
switch userChoice
    
    case 0 %if the user wants to select files
        
        if ischar(fileName) %test if the user selects a single file
            fileNameList = strcat(pathName,fileName);
        elseif iscell(fileName)
            for a = 1:numel(fileName) %test if the user selects multiple files
                fileNameList{a} = strcat(pathName,fileName{a});
            end
            
        end
        
    case 1 %if the user selects an entire directory
        %make a list of the file names that have been selected and store it in a
        %cell array
        dirContents = dir('*.h5') ;
        fileNameList = {dirContents(:).name} ;
        for aa = 1:numel(fileNameList)
            fileNameList{aa} = strcat(pathName,'/',fileNameList{aa}) ;
        end
end


%% import here
if ischar(fileNameList)
    
    wsData = ws.loadDataFile(fileNameList) ;
    header = wsData.header ;
    
    %after this, save the header into a cell array called headerInfo. This
    %is the way I like to do it, but different end users might have different
    %preferences.
    headerInfo{1} = header ;
    
    %call loopThroughSweeps to do exactly that, loop through the
    %sweeps and generate the ephysData structure.
    ephysData = loopThroughSweeps(wsData,header) ;
    
    
elseif iscell(fileNameList)
    
    %initialize wsData
    ephysData = struct ;
    
    for a = 1:numel(fileNameList)
        
        wsData = ws.loadDataFile(fileNameList{a}) ;
        header = wsData.header ;
        
        %As above, save the header info separately.
        headerInfo{a} = wsData.header ;
        
        %call loopThroughSweeps
        tempEphysData = loopThroughSweeps(wsData,header) ;
        
        %and now concatenate that to the ephysData structure
        if isempty(fieldnames(ephysData))
            ephysData = tempEphysData ;
        else
            ephysData = [ephysData,tempEphysData] ;
        end
        
    end
    
    
end
end

%% subfunction to generate the ephysData structure
function ephysData = loopThroughSweeps(wsData,header)

%remove the header from wsData for the rest of these processes.
if isfield(wsData,'header')
    wsData = rmfield(wsData,'header') ;
end

%initialize ephysData structure
ephysData = struct ;

%pull out the sweep names
sweepNames = fieldnames(wsData) ;

%loop through the sweeps and start creating the ephysData
%structure.
for a = 1:numel(fieldnames(wsData))
    
    %pull out the currentSweep
    currentSweep = sweepNames{a} ;
    
    %save information regarding sweep name and sample rate first
    ephysData(a).sweepName = currentSweep ;
    
    %different WS versions name fields differently in the header.
    try
        ephysData(a).sampleRate = header.AcquisitionSampleRate ;
    catch
        ephysData(a).sampleRate = header.Acquisition.SampleRate ;
    end
    
    %now save the recorded data and channel names
    ephysData(a).analogScans = wsData.(currentSweep).analogScans ;
    
    if isfield(header,'AIChannelNames')
        ephysData(a).analogChannelNames = header.AIChannelNames ;
    else
        ephysData(a).analogChannelNames = header.Acquisition.AnalogPhysicalChannelNames;
    end
    
    if isfield(wsData.(currentSweep),'digitalScans')
        ephysData(a).digitalScans = wsData.(currentSweep).digitalScans ;
        
        if isfield(header,'DIChannelNames')
            ephysData(a).digitalChannelNames = header.DIChannelNames ;
        else
            ephysData(a).digitalChannelNames = header.Acquisition.DigitalChannelNames ;
        end
        
    else
        ephysData(a).digitalScans = [] ;
        ephysData(a).digitalChannelNames = {} ;
    end
    
    %save the timestamp too
    ephysData(a).timestamp = wsData.(currentSweep).timestamp ;
    
    %make a timebase for each sweep
    nTimePoints = size(ephysData(a).analogScans,1) ;
    ephysData(a).ephysTimeBase = linspace(0,nTimePoints/ephysData(a).sampleRate,nTimePoints)';
    
end
end

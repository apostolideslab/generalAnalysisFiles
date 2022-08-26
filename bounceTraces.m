function [dimensions,traces] = bounceTraces(ephysData)

%bounces out a 3D matrix of your ephysData struct imported with
%pfaImportWS.
%numSamples x numTrials x numChannels. 

%If sweeps are of different lengths/sample rates, the shorter ones get
%padded with 0s...

%pfa

%find the sweep with the most number of samples and channels
lengthArray = zeros(numel(ephysData),1);
chanArray = zeros(numel(ephysData),1);

for a = 1:numel(ephysData)
    
    [numSamps,numChan]=size(ephysData(a).analogScans);
    
    lengthArray(a) = numSamps;
    
    chanArray(a) = numChan;
    
end

[~,I] = max(lengthArray); % find the longest sweep
[maxChan,I2] = max(chanArray); %find the max number of Channels

traces = zeros(lengthArray(I),length(lengthArray),chanArray(I2));
dimensions = [lengthArray(I),length(lengthArray),chanArray(I2)];

%loop through the traces
for b = 1:numel(ephysData)
    
    for c = 1:maxChan
        
        currentTrace = ephysData(b).analogScans(:,c);
        lengthOfTrace = length(currentTrace); %get the length so you don't go out of bounds
        
        traces(1:lengthOfTrace,b,c) = currentTrace; %save the data
    end
end

end

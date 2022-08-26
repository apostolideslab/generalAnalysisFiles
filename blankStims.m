function tracesBlanked = blankStims(traces,onsetTime,numStim,stimFreq,durationToBlank,sampleRate)

%blanks your stimulus artifact via linear interpolation. can be
%used for single stim or periodically repeating stimuli. traces should be a
%numSamples x numTrials matrix

%onsetTime is time of first stim an (in s)
%numStim and stimFreq are in Hz
%durationToBlank (in s)

%pfa

[numSamples,numTrials]=size(traces);
tracesBlanked = zeros(numSamples,numTrials);

for a = 1:numTrials
    
    %Convert the user inputs into samples
    %rather than seconds
    onsetTimeSamp = onsetTime * sampleRate;
    sampsToBlank = durationToBlank * sampleRate;
    sampsBetweenStims = 1/stimFreq * sampleRate;

        currentTrace = traces(:,a); %pull out the trace
        
        %loop through all stims
        for b = 1:numStim
            
            firstSamp = onsetTimeSamp + (sampsBetweenStims * (b-1)) + 1 ;
            lastSamp = onsetTimeSamp + (sampsBetweenStims * (b-1)) + sampsToBlank ;
            
            xVals=[1,lastSamp-firstSamp+1] ;
            points = xVals(1):xVals(2) ;
            
            yVals=[currentTrace(firstSamp),currentTrace(lastSamp)] ;
            
            currentTrace(firstSamp:lastSamp) = interp1(xVals,yVals,points,'linear') ;
            
        end
        
        %save
        tracesBlanked(:,a) = currentTrace ;
        
    
end

end
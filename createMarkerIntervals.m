function intervals = createMarkerIntervals(signal)

sigInt  = find(diff(signal)>0) + 1;
sigVal = signal(sigInt,1);

if round(size(sigInt,1)/2) ~= size(sigInt,1)/2
    sigInt = [sigInt; length(signal)];
    sigVal = [sigVal; 1];
end

% assert(round(size(sigInt,1)/2)==size(sigInt,1)/2,'MT:UnequalMarkers','Unequal amount of markers found. Please check your file.')

if size(sigInt,1) > 0
    intervals = [sigInt,sigVal];
    startMark(:,1:2) = intervals(1:2:end,:);
    endMark(:,1:2) = intervals(2:2:end,:);
    
    intervals = [startMark(:,1),endMark];
    
else
    intervals = [1,length(signal),1];
end


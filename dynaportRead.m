function [varargout] = dynaportRead(fileName,varargin)
% click <a href="matlab:web dynaportRead.html">here</a> for help

%% no output or input
if nargout == 0 || nargin == 0
    if ~(~isempty(varargin) && strcmp(varargin{1},'cleanup'))
        help dynaportRead;
        return;
    end
end
%% Initialize input arguments
if size(varargin,2) < 5
    paramList = [];% dynaportInfo = []
    if size(varargin,2) < 4
        paramList = {[],paramList}; % startSample = [], will be filled later on
        if size(varargin,2) < 3
            paramList = {[],paramList{:}}; % mm = [], will be filled later on
            if size(varargin,2) < 2
                paramList = {[],paramList{:}};% endSample = []. will be filled later on
                if size(varargin,2) < 1
                    paramList = {0,paramList{:}};% dataReadSwitch = 0
                end
            end
        end
    end
    if size(paramList,2)<2
        paramList = {[]};
    end
end

if size(varargin,2) < 5
    varargin = {varargin{:},paramList{:}};
end

dataReadSwitch = varargin{1};
[path,name,ext] = fileparts(fileName);
tempPath = [getenv('TEMP'),'\mcRoberts\matlab\'];
dynaportInfo = varargin{5};
if ~isempty(dynaportInfo)
    if isfield(dynaportInfo,'fileHash')
        fileHash = dynaportInfo(1).mmInfo.fileHash;
    else
        fileHash = calcHash2(fileName);
    end
else
    fileHash = calcHash2(fileName);
end

%% Cleanup
if strcmp(varargin{1},'cleanup') % cleanup
    if exist([tempPath,fileHash],'dir')
        status = rmdir([tempPath,fileHash],'s');
        if status == 0
            fns = [];
            fids = fopen('all');
            for iFid = 1:size(fids,2)
                fn = fopen(fids(iFid));
                if ~isempty(regexp(fn,'.ac3', 'once')) || ~isempty(regexp(fn,'.user_interval', 'once')) ||...
                        ~isempty(regexp(fn,'.mmInfo', 'once'))
                    status = fclose(fids(iFid));
                    if status ==-1
                        if ~isempty(fns)
                            fns = strcat(fns,', "',fn,'"');
                        else
                            fns = strcat('"',fn,'"');
                        end
                    end
                end
            end
            status = rmdir([tempPath,fileHash],'s');
            if status == 0
                if ~isempty(fns)
                    errstr = sprintf('files %s could not be removed, please remove manually',fns);
                else
                    errstr = 'there are no files to remove';
                end
                disp(errstr);
            end
        end
    end
    return
end
%% read data
switch ext % read data
    case {'.3ac','.bac',[]}        
        % file handling
        if isempty(ext) && size(name,2)~=32
            error('dynaportRead:noHash','');
        end   
        tempDir = [tempPath,fileHash];
        if ~exist(tempDir,'dir')
            mkdir(tempDir)
        end        
        dataFile = ls([tempDir,'\*.ac3']);
        if size(dataFile,1) > 1
            error('dynaportRead:multiac3','');
        end        
        if isempty(dataFile)
            unpack2(fileName,tempDir)
            dataFile = ls([tempDir,'\*.ac3']);
        end
        dataFile  = [tempDir,'\',dataFile];
        
        % get file info
        mmInfoFiles = ls([tempPath,fileHash,'\*.mmInfo']);        
        if ~strcmp(mmInfoFiles,'') && isempty(varargin{5})
            dynaportInfo = mmInfo2mmPackage2([tempPath,fileHash,'\',deblank(mmInfoFiles(1,:))]);
            if isfield(dynaportInfo.measurements.hwInfo,'batt') && ...
                    ~isempty(regexp(dynaportInfo.measurements.hwInfo.FwVersion,'H','once'))
                varargin{5} = dynaportInfo;                
            end
        end
               
        % read signal
        [sig,dynaportInfo] = dynaportDataRead2(dataFile,varargin{:});        
        
        % read markers
        markerFiles = ls([tempPath,fileHash,'\*.user_interval']);
        for iMF = 1:size(markerFiles,1)
            markerFile = [tempPath,fileHash,'\',deblank(markerFiles(iMF,:))];
            intervals= ReadIntervals2(markerFile);
            dynaportInfo(iMF).measurements.markers = struct('intervals',intervals);
        end
    case {'.ac3','.bin'}
        [sig,dynaportInfo] = dynaportDataRead2(fileName,varargin{:});
    otherwise
        disp([ext,' file extension is not recognized']);
end
dynaportInfo(1).mmInfo.fileHash = fileHash;

%% assign output
switch nargout
    case 1
        dataReadSwitch = varargin{1};
        if dataReadSwitch == 1
            if size(sig,2)>1
                varargout(1) = {sig};
            else
                varargout(1) = sig;
            end
        else
            varargout(1) = {dynaportInfo};
        end
    case 2
        if dataReadSwitch
            if size(sig,2)>1
                varargout(1) = {sig};
            else
                varargout(1) = sig;
            end
        else
            varargout(1) = {[]};
        end
        varargout(2) = {dynaportInfo};
end

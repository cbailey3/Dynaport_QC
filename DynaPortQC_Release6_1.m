function varargout = DynaPortQC_Release6_1(varargin)
% DYNAPORTQC_RELEASE3 MATLAB code for DynaPortQC_Release3.fig
%      DYNAPORTQC_RELEASE3, by itself, creates a new DYNAPORTQC_RELEASE3 or raises the existing
%      singleton*.
%
%      H = DYNAPORTQC_RELEASE3 returns the handle to a new DYNAPORTQC_RELEASE3 or the handle to
%      the existing singleton*.
%
%      DYNAPORTQC_RELEASE3('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DYNAPORTQC_RELEASE3.M with the given input arguments.
%
%      DYNAPORTQC_RELEASE3('Property','Value',...) creates a new DYNAPORTQC_RELEASE3 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DynaPortQC_Release3_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DynaPortQC_Release3_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DynaPortQC_Release3

% Last Modified by GUIDE v2.5 16-May-2018 12:23:56

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DynaPortQC_Release3_OpeningFcn, ...
                   'gui_OutputFcn',  @DynaPortQC_Release3_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before DynaPortQC_Release3 is made visible.
function DynaPortQC_Release3_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DynaPortQC_Release3 (see VARARGIN)

% Choose default command line output for DynaPortQC_Release3
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DynaPortQC_Release3 wait for user response (see UIRESUME)
% uiwait(handles.figure1);

clearvars -global;
global totalperformances;
% this should be read in from configuration file eventually.


global qcstarttime;


global perfnames;
perfnames{1} =     '8FT_1';
perfnames{2} =     '8FT_2';
perfnames{3} =     'EO';
perfnames{4} =     'T360_1';
perfnames{5} =     'LLEG';
perfnames{6} =     'T360_2';
perfnames{7} =     'EC';
perfnames{8} =     'TUG_1';
perfnames{9} =     'RLEG';
perfnames{10} =     'TUG_2';
perfnames{11} =     'TANDEM';
perfnames{12} =     '32FT';
perfnames{13} =     'TOES';
perfnames{14} =     'COG_TUG_1';
perfnames{15} =     'COG_TUG_2';

totalperformances = length(perfnames);


global epochstart;
global defaultstartmark;
% this should also be read in from config file, as ac3 and 3ac differ in
% where the first actual mark shows up in the record.
defaultstartmark = 2;

global prev_path;

% --- Outputs from this function are returned to the command line.
function varargout = DynaPortQC_Release3_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in fileSelectButton.
function fileSelectButton_Callback(hObject, eventdata, handles)
% hObject    handle to fileSelectButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global epochstart;
global defaultstartmark;
global markerbegin;
% rjd 11/30/15
% user selects omx files
[infilename, inpathname] = uigetfile({'*.omx','DynaPort Files (*.omx)'}, 'Choose Dynaport file(s)', 'MultiSelect', 'on');

prev_str = get(handles.pendingFileList, 'String');

% if prev_str contains only one line of text, it may not be a cell; make it
% a cell
if ~iscell(prev_str)
    temptext = prev_str;
    
    prev_str = cell(1);
    prev_str{1} = temptext;
end

global prev_path;

% may need to create it as cell
if ~exist('prev_path', 'var')
    prev_path = cell(1);
elseif ~iscell(prev_path)
    temptext = prev_path;
    
    prev_path = cell(1);
    prev_path{1} = temptext;
end


% if infilename contains only a single filename, it may not be a cell; make
% it a cell if it contains a single filename
if ~iscell(infilename) && ~isnumeric(infilename)
    temptext = infilename;
    
    infilename = cell(1);
    infilename{1} = temptext;
end

% if a file was selected (ie, user did not press cancel button on get file
% ui) then add file to list. otherwise do nothing.
if iscell(infilename)

    % determine number of genuine files already displayed by checking length of
    % prev_str, keeping in mind that if length = 1, the single line could
    % contain either the default "no file selected" message or a genuine
    % filename
    if length(prev_str) > 1
        curlength = length(prev_str);
    elseif strcmp('.ac3', prev_str{1}(length(prev_str{1})-3:length(prev_str{1}))) || strcmp('.3ac', prev_str{1}(length(prev_str{1})-3:length(prev_str{1}))) || strcmp('.omx', prev_str{1}(length(prev_str{1})-3:length(prev_str{1}))) || strcmp('.OMX', prev_str{1}(length(prev_str{1})-3:length(prev_str{1})))
        curlength = 1;
    else
        curlength = 0;
    end
    
    for i = 1 : length(infilename)
        prev_str{i+curlength} = infilename{i};
        prev_path{i+curlength} = inpathname;
    end

    % finally add composed list to listbox
    set(handles.pendingFileList, 'String', prev_str, 'Value', length(prev_str));
    
    % note: need to specify the conditions under which new data should be
    % loaded, in particular I think it should only load new data if the
    % currently displayed data is removed from the list (either with the
    % remove button or after saving the qc file)
    if curlength == 0 %this means "if there was not already a valid file in the list"
        plotFlag = loadNewData(prev_path{1}, prev_str{1});

        plotGlobalView(0);
        drawEpoch(0);
        if plotFlag
            plotGlobalView(1);
            h = findobj('Style', 'edit', 'Tag', 'startmarktext');
            set(h, 'String', num2str(defaultstartmark));
            startmarktext_Callback(h, eventdata, handles);
            updatePerfStatusText(1);
        
            h = findobj('Tag', 'perfstatlistbox');
            set(h, 'Value', 1);
            drawEpoch(1);
        end
    end
end











% 
% 
% % if a file was selected (i.e. user did not select cancel)
% if infilename ~= 0
%     % after selecting file(s), the list box displaying all the pending
%     % files needs to be updated
%     
%     % first task is to figure out how many files, if any, are already in the
%     % listbox.
%     % prev_str is "previous string", ie what appeared in list box before this
%     % potential alteration
%     
%     prev_str = get(handles.pendingFileList, 'String');
%     % if prev_str contains only one line of text, it may not be a cell; make it
%     % a cell
%     if ~iscell(prev_str)
%         temptext = prev_str;
%         
%         prev_str = cell(1);
%         prev_str{1} = temptext;
%     end
%     
%     % the path list needs to be a global variable so it survives outside of
%     % this function, because this info is not stored as text in the pending
%     % file list box.
%     global prev_path;
%     
%     % may need to create prev_path as cell, too
%     if ~exist('prev_path', 'var')
%         prev_path = cell(1);
%     elseif ~iscell(prev_path)
%         temptext = prev_path;
%         
%         prev_path = cell(1);
%         prev_path{1} = temptext;
%     end
%     
%     
%     % if infilename contains only a single filename, it may not be a cell; make
%     % it a cell if it contains a single filename
%     if ~iscell(infilename) && ~isnumeric(infilename)
%         temptext = infilename;
%         
%         infilename = cell(1);
%         infilename{1} = temptext;
%     end
%     
%     % determine number of genuine files already displayed by checking length of
%     % prev_str, keeping in mind that if length == 1, the single line could
%     % contain either the default "no file selected" message or a genuine
%     % filename
%     if length(prev_str) > 1
%         curlength = length(prev_str);
%     elseif strcmp('.ac3', prev_str{1}(length(prev_str{1})-3:length(prev_str{1}))) || strcmp('.3ac', prev_str{1}(length(prev_str{1})-3:length(prev_str{1}))) || strcmp('.omx', prev_str{1}(length(prev_str{1})-3:length(prev_str{1})))
%         curlength = 1;
%     else
%         curlength = 0;
%     end
%     
%     % now we know how many valid files are in the pending file list box
%     % can add files to the end of this list then:
%     for i = 1 : length(infilename)
%         prev_str{i+curlength} = infilename{i};
%         prev_path{i+curlength} = inpathname;
%     end
% 
%     % finally add composed list to listbox
%     set(handles.pendingFileList, 'String', prev_str, 'Value', length(prev_str));
%     
%     % if there were already file(s) in the listbox, something should
%     % already be plotted out and there's no need to plot data. however, if
%     % there was previously no files in this list (i.e. this is the first
%     % file added to the list), then we need to plot a file out.
%     % this really entails four things, as listed below:
%     if curlength == 0 %this means "if there was not already a valid file in the list"
%         % 1) run loadnewdata fxn to read in data
%         loadNewData(prev_path{1}, prev_str{1});
%         % 2) plot it out in the global view; this plot will receive
%         % additions and subtractions (annotations)
%         plotGlobalView(1);
%         % 3) plot the first epoch in the epoch view and put red rectangle
%         % on global view
%         h = findobj('Style', 'edit', 'Tag', 'startmarktext');
%         set(h, 'string', defaultstartmark);
%         startmarktext_Callback(h, eventdata, handles);
%         drawEpoch(1);
%         % NOTE -- must figure out whether the first epoch
%                              % starts from beginning of file or first
%                              % visible mark (or is that essentially the
%                              % same thing?)
%         % 4) update the performance statuses (ie, set all to blank)
%         updatePerfStatusText(1);
%         
%         % may eventually choose to do 5) check for existing qc'ed files so
%         % as to avoid overwriting, but currently not implemented
%     end
% end
%     


%rjd function 11/30/15
function [plotFlag] = loadNewData(path, file)

global qcstarttime;
qcstarttime = datetime;

filename = [path file];

% have to clear out all these global variables and recreate them
clearvars -global signal;
clearvars -global dynaportInfo;
clearvars -global markerbegin;
clearvars -global markerend;
clearvars -global qcpass;
clearvars -global startsample;
clearvars -global endsample;
clearvars -global userdefinedstart;
clearvars -global userdefinedend;
clearvars -global epochstart;
clearvars -global epochend;
clearvars -global rectcoords;
clearvars -global textcoords;
clearvars -global failreason;
clearvars -global dyrectorcoords;
clearvars -global dyrectorstarttime;
clearvars -global dyrectorendtime;
clearvars -global pn;


global signal;
global dynaportInfo;
global markerbegin;
global markerend;
global epochstart;
global epochend;
global qcpass;
global totalperformances;
global startsample;
global endsample;
global dyrectorstarttime;
global dyrectorendtime
global userdefinedstart;
global userdefinedend;
global rectcoords;
global textcoords;
global dyrectorcoords;
global failreason;
global devID;
global devType;
global pn;



rectcoords = gobjects(totalperformances, 1);
textcoords = gobjects(totalperformances, 1);

for i = 1:totalperformances
    qcpass(i, 1) = -1; %means there's not yet any qc pass/fail info.
    failreason(i, 1) = 0;
    userdefinedstart(i, 1) = -1;
    userdefinedend(i, 1) = -1;
    startsample(i, 1) = -1;
    endsample(i, 1) = -1;
end

updatePerfStatusText(1);
h = findobj('Tag', 'perfstatlistbox');
set(h, 'Value', 1);




dynaportInfo = getMetaData(filename);
devID = dynaportInfo.deviceId;
devType = 'MT';
if isfield(dynaportInfo, 'metadata')
    pn = dynaportInfo.metadata;
    ixS = strfind(pn, 'pn=');
    ixE = strfind(pn, ';sn');
    pn = pn(ixS+3:ixE-1);
else
    pn = dynaportInfo.identifiers.offline;
    ixS = strfind(pn, 'pn');
    pn = pn(ixS+2:ixS+9);
end


hProjID = findobj('Style', 'edit', 'Tag', 'projID');
set(hProjID, 'String', pn);


[markers, signal] = dynaportOmxRead(filename);

if ~isempty(markers.markers)
    markersStart = markers.markers(:,1)';
    markersEnd = markers.markers(:,2)';
    dyrectorstarttime = (markersStart - 1)/100;
    dyrectorendtime = (markersEnd - 1)/100;

    epochstart = markersStart(1);
    epochend = markersEnd(1);

    markerbegin = [1, size(signal,1), markersStart, markersEnd];
    markerbegin = sort(markerbegin);
    markerend = markerbegin;

    numdyrectorintervals = length(dyrectorendtime);
    dyrectorcoords = gobjects(numdyrectorintervals, 1);


    %Add seventh column to signal for marker data
    signal = [signal, zeros(size(signal,1),1)];
    signal(markerbegin,7) = 1;
    plotFlag = 1;
else
    errmsg = ['File ' file ' (projid: ' pn ') has no markers'];
    errordlg(errmsg, 'File Error', 'modal');
    
    plotFlag = 0;
end
   



%rjd function
function plotGlobalView(realdataflag)
% to be clear, the entire record is always plotted in the globabl view (subject to 
% user-controlled zooming).
% had tried to make lowsample and
% highsample input parameters to control what is highlighted in the global
% view, and what is plotted in the epoch view as well, but now this is
% accomplished instead with global vars epochstart and epochend. ok for now


if realdataflag %for the case that there's a valid current file

    global signal;
    global dynaportInfo;
    global markerbegin; % this is a vector of marker beginning times (ie initial button press)
    global markerend; % this is a mostly useles vector of marker ending times (ie button releases)
    global timevec;
    global epochstart;
    global epochend;
    global defaultstartmark;
    global dyrectorstarttime;
    global dyrectorendtime;
    
    
    
    timevec = linspace(0.0, (length(signal)-1)/100, length(signal));
    
    
    hgnav = findobj('Type', 'axes', 'Tag', 'gnav');
    
    
    cla(hgnav);
    axes(hgnav);
    line(timevec, signal(:,1), 'Color', 'k');
    set(hgnav, 'XLim', [0 timevec(length(timevec))], 'YLim', [0 2]); %here's where to control y extents if necessary
    
    % insert vertical lines to denote marker locations (diagonal from lower
    % left to upper right, horizontal span defined by duration of button press)
    
    for i = 1:length(markerbegin)
        mlinex = [markerbegin(i) markerend(i)] / 100 - 1/100;
        mliney = get(hgnav, 'YLim');
%         
%         mlinex
%         mliney
%         hgnav
        
        line(mlinex, mliney,'Color', 'b');
    end
     
    if exist('dyrectorendtime')
        for i = 1:length(dyrectorendtime)
            dyrectorcoords(i) = rectangle('Position', [dyrectorstarttime(i), 0, dyrectorendtime(i) - dyrectorstarttime(i), 2], 'EdgeColor', [0 0 0], 'LineStyle', 'none', 'FaceColor', [1 .72 .72]);
        
            uistack(dyrectorcoords(i), 'bottom');
        end
    end

   
else % for the case that it's null data (there is no valid file in the pending file list)
    hgnav = findobj('Type', 'axes', 'Tag', 'gnav');
    cla(hgnav);
    axes(hgnav);
    set(hgnav, 'XLim', [0 60], 'YLim', [0 2]);
end

function drawEpoch(realdataflag)

global epochstart;
global epochend;
global timevec;
global signal;
global dynaportInfo;

if realdataflag
    %vertical acceleration
    h = findobj('Type', 'axes', 'Tag', 'vertacc');
    cla(h);
    axes(h);
    line(timevec(epochstart:epochend), signal(epochstart:epochend, 1), 'Color', 'r');
    set(h, 'XLim', [timevec(epochstart) timevec(epochend)], 'YLim', [0 2]);
    
    %forward acceleration
    h = findobj('Type', 'axes', 'Tag', 'foracc');
    cla(h);
    axes(h);
    line(timevec(epochstart:epochend), signal(epochstart:epochend, 3), 'Color', 'g');
    set(h, 'XLim', [timevec(epochstart) timevec(epochend)], 'YLim', [-1 1]);
    
    %yaw about vertical axis
    h = findobj('Type', 'axes', 'Tag', 'yaw');
    cla(h);
    axes(h);
    line(timevec(epochstart:epochend), signal(epochstart:epochend, 4), 'Color', 'm');
    set(h, 'XLim', [timevec(epochstart) timevec(epochend)], 'YLim', [-90 90]);
    
    %pitch about horizontal left-right axis
    h = findobj('Type', 'axes', 'Tag', 'pitch');
    cla(h);
    axes(h);
    line(timevec(epochstart:epochend), signal(epochstart:epochend, 5), 'Color', 'c');
    set(h, 'XLim', [timevec(epochstart) timevec(epochend)], 'YLim', [-90 90]);
else
        %vertical acceleration
    h = findobj('Type', 'axes', 'Tag', 'vertacc');
    cla(h);
    axes(h);
    set(h, 'XLim', [0 60], 'YLim', [0 2]);
    
    %forward acceleration
    h = findobj('Type', 'axes', 'Tag', 'foracc');
    cla(h);
    axes(h);
    set(h, 'XLim', [0 60], 'YLim', [-1 1]);
    
    %yaw about vertical axis
    h = findobj('Type', 'axes', 'Tag', 'yaw');
    cla(h);
    axes(h);
    set(h, 'XLim', [0 60], 'YLim', [-90 90]);
    
    %pitch about horizontal left-right axis
    h = findobj('Type', 'axes', 'Tag', 'pitch');
    cla(h);
    axes(h);
    set(h, 'XLim', [0 60], 'YLim', [-90 90]);
end



function updatePerfStatusText(realdataflag)

global totalperformances;
global qcpass; % this global vector is holding pass/fail status for each performance:
               % -1 for not filled in yet, 0 for fail, 1 for pass
global markerbegin;
global markerend;
global failreason;
global perfnames;


if realdataflag %this is for the case when there is a file open to be QC'd

    % no loop here because in future each performance will have text like '8-ft
    % walk' or 'up and go', not 'performance 1, performance 2, etc.', so we
    % need to manually write them anyway
    
    for j = 1:totalperformances
        perfstatustext{j} = [perfnames{j}];
        for k = 1:(15-length(perfnames{j}))
            perfstatustext{j} = [perfstatustext{j} '.'];
        end
    end
    
    for i = 1:totalperformances
        switch qcpass(i)
            case -1
                perfstatustext{i} = perfstatustext{i};
            case 0
                switch failreason(i)
                    case 1
                        perfstatustext{i} = [perfstatustext{i} '   Fail: No Data'];
                    case 2
                        perfstatustext{i} = [perfstatustext{i} '   Fail: Other'];
                    case 3
                        perfstatustext{i} = [perfstatustext{i} '   Fail: No Marker'];
                end
            case 1
                perfstatustext{i} = [perfstatustext{i} 'Pass'];
                
        end
    end
else % this is for the case when no more files are in the list
    perfstatustext{1} = 'No file is open for QC.';
    h = findobj('Style', 'listbox', 'Tag', 'perfstatlistbox');
    set(h, 'Value', 1);
    
    if length(perfstatustext) > 1
        perfstatustext(2:length(perfstatustext)) = [];
    end 
end

h = findobj('Style', 'listbox', 'Tag', 'perfstatlistbox');
set(h, 'String', perfstatustext);








% --- Executes on selection change in pendingFileList.
function pendingFileList_Callback(hObject, eventdata, handles)
% hObject    handle to pendingFileList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pendingFileList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pendingFileList


% --- Executes during object creation, after setting all properties.
function pendingFileList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pendingFileList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in removefile.
function removefile_Callback(hObject, eventdata, handles)
% hObject    handle to removefile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

prev_str = get(handles.pendingFileList, 'String');
toremove = get(handles.pendingFileList, 'Value');
toremove = sort(toremove, 'descend');

if ~iscell(prev_str)
    temptext = prev_str;
    
    prev_str = cell(1);
    prev_str{1} = temptext;
end

global prev_path;
global defaultstartmark;

if ~iscell(prev_path)
    temptext = prev_path;
    
    prev_path = cell(1);
    prev_path{1} = temptext;
end

if length(toremove) == length(prev_path)
    removeall = true;
else
    removeall = false;
end

% this is a loop in case more than one file is selected
for i = length(toremove):-1:1
    
    
    if ( strcmp('.ac3', prev_str{i}(length(prev_str{i})-3:length(prev_str{i}))) || strcmp('.3ac', prev_str{i}(length(prev_str{i})-3:length(prev_str{i}))) || strcmp('.omx', prev_str{i}(length(prev_str{i})-3:length(prev_str{i}))) || strcmp('.OMX', prev_str{i}(length(prev_str{i})-3:length(prev_str{i}))))
      
        
        if toremove(i) == 1 && removeall == false %this means if first file in list was removed, then need to load
                            %data for the next file in list if there is
                            %one, 
                   %or load null data if there's not one
            prev_str(toremove(i)) = [];
            prev_path(toremove(i)) = [];
            updatePerfStatusText(1);
            loadNullData();
            plotFlag = loadNewData(prev_path{1}, prev_str{1});
            plotGlobalView(plotFlag);       
            
            if plotFlag
                h = findobj('Style', 'edit', 'Tag', 'startmarktext');
                set(h, 'String', num2str(defaultstartmark))
                startmarktext_Callback(h, eventdata, handles);
                drawEpoch(1);
            else
                drawEpoch(0);
            end
        elseif toremove(i) == 1 && removeall == true
            prev_str{1} = 'No files selected.';
            clearvars -global prev_path;
            updatePerfStatusText(0);
            loadNullData();
            plotGlobalView(0);
            drawEpoch(0);
        elseif toremove(i) ~= 1
            prev_str(toremove(i)) = [];
            prev_path(toremove(i)) = [];
        end
          
    end
end

if toremove(1) > length(prev_str)
    selection = toremove(1)-1;
else
    selection = toremove(1);
end

set(handles.pendingFileList, 'String', prev_str, 'Value', selection);

function loadNullData()
%there are probably other things to do in this function besides clear a few
%global vars. should clear other things as well.

clearvars -global signal;
clearvars -global dynaportInfo;
clearvars -global timevec;  
clearvars -global markerbegin;
clearvars -global markerend;
clearvars -global qcpass;
clearvars -global failreason;
clearvars -global epochstart;
clearvars -global epochend;
clearvars -global userdefinedstart;
clearvars -global userdefinedend;
clearvars -global startsample;
clearvars -global endsample;
clearvars -global dyrectorcoords;
clearvars -global dyrectorstarttime;
clearvars -global dyrectorendtime;
clearvars -global pn;


hgnav = findobj('Type', 'axes', 'Tag', 'gnav');
cla(hgnav);


% --- Executes on button press in malpositioned.
function malpositioned_Callback(hObject, eventdata, handles)
% hObject    handle to malpositioned (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of malpositioned


% --- Executes on button press in otherflag.
function otherflag_Callback(hObject, eventdata, handles)
% hObject    handle to otherflag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of otherflag


% --- Executes on button press in saveqc.
function saveqc_Callback(hObject, eventdata, handles)
% hObject    handle to saveqc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global qcpass;
global qcstarttime;

qcendtime = datetime;

if sum(qcpass == -1) == 0 && length(get(handles.qcid, 'String')) == 3
    %main qc save operations
    
    
    % write qc file and segmented text files
    %
    %
    %
    %
    prev_str = get(handles.pendingFileList, 'String');
  
    if ~iscell(prev_str)
        temptext = prev_str;
        
        prev_str = cell(1);
        prev_str{1} = temptext;
    end
    
    global prev_path;
    global totalperformances;
    global perfnames;
    global failreason;
    global startsample;
    global endsample;
    global userdefinedstart;
    global userdefinedend;
    global signal;
    global devID;
    global devType;
    global pn;
    
    % may need to create it as cell
    if ~exist('prev_path', 'var')
        prev_path = cell(1);
    elseif ~iscell(prev_path)
        temptext = prev_path;
        
        prev_path = cell(1);
        prev_path{1} = temptext;
    end
    
    newdir = [prev_path{1} '/qc'];
    if exist(newdir, 'dir') ~= 7
        mkdir(newdir);
    end
    
    filename = [newdir '/' prev_str{1}];
    filename(length(filename)-3:length(filename)) = '.qcd';
    fpout = fopen(filename, 'w');
    
    fprintf(fpout, 'DynaPort QC for file %s\n', pn);
    fprintf(fpout, 'Device Model: %s\n', devType);
    fprintf(fpout, 'Device ID: %s\n', devID);
    fprintf(fpout, 'Total performances expected (according to QC protocol) = %d\n', totalperformances);
    fprintf(fpout, 'Total performances passing QC = %d\n', sum(qcpass == 1));
    
    if get(handles.malpositioned, 'Value')
        fprintf(fpout, 'Malpositioned flag = TRUE\n');
    else
        fprintf(fpout, 'Malpositioned flag = FALSE\n');
    end
    
    if get(handles.otherflag, 'Value')
        fprintf(fpout, 'Other flag = TRUE\n');
    else
        fprintf(fpout, 'Other flag = FALSE\n');
    end
    
    if get(handles.markerflag, 'Value')
        fprintf(fpout, 'Missing markers = TRUE\n');
    else
        fprintf(fpout, 'Missing markers = FALSE\n');
    end
        
    stimestr = ['QC start time = ' datestr(qcstarttime) '\n'];
    etimestr = ['QC end time = ' datestr(qcendtime) '\n'];
    
    fprintf(fpout, stimestr);
    fprintf(fpout, etimestr);
    
    qcduration = between(qcstarttime, qcendtime, 'time');
    qcdurationvec = datevec(qcduration);
    
    if sum(qcdurationvec(1:3)) > 0
        qcdurationminutes = -1;
    else
        qcdurationminutes = qcdurationvec(4)*60 + qcdurationvec(5) + qcdurationvec(6)/60;
    end
    
    qcdurationstr = ['QC duration = ' num2str(qcdurationminutes) ' min\n'];
    
    fprintf(fpout, qcdurationstr);

    
   

    performqastr = ['Performing QC = ' get(handles.qcid, 'String') '\n\n'];
    fprintf(fpout, performqastr);
    
    f = cell(8,1);
    f{1} = 'PerformanceNumber';
    f{2} = 'PerformanceDescription';
    f{3} = 'QCPass';
    f{4} = 'QCFailReason';
    f{5} = 'StartSample';
    f{6} = 'EndSample';
    f{7} = 'UserDefinedStart';
    f{8} = 'UserDefinedEnd';
    
    for i = 1:8
        fprintf(fpout, '%s \t', f{i});
    end
    
    fprintf(fpout, '\n');
    
    for i = 1:totalperformances
        clear e;
        e = cell(8,1);
        
        e{1} = num2str(i);
        e{2} = perfnames{i};
        e{3} = num2str(qcpass(i));
        e{4} = num2str(failreason(i));
        e{5} = num2str(startsample(i));
        e{6} = num2str(endsample(i));
        e{7} = num2str(userdefinedstart(i));
        e{8} = num2str(userdefinedend(i));
        
        
        for j = 1:8
            fl = length(f{j});
            el = length(e{j});
            
            for k = 1:(fl - el)
                e{j} = [e{j} ' '];
            end
            
            fprintf(fpout, '%s \t', e{j});
        end
        
        fprintf(fpout, '\n');
    end
    
    fclose(fpout);
    
    
    newdir = [prev_path{1} '/segmented'];
    if exist(newdir, 'dir') ~= 7
        mkdir(newdir);
    end
    
   % this is where we might choose to go with an alternate directory tree;
   % right now it is is .../segmented/12345678_00_151208_8FT_1.txt but
   % might be better to have something like
   % .../segmented/8FT_1/12345678_00_151208_8FT_1.txt. Depends what's
   % easier to upload/download
        
   for i = 1:totalperformances
       filename = [newdir '/' prev_str{1}];
       filename = [filename(1:length(filename)-4) '_' perfnames{i} '.txt'];
       
       if qcpass(i) > 0
           ss = startsample(i) - 500;
           if ss < 1
               ss = 1;
           end
           
           es = endsample(i) + 300;
           if es > length(signal)
               es = length(signal);
           end
           
           briefmat = signal(ss:es,:);
           
           save(filename, 'briefmat', '-ascii');
       end
   end
    
    
    
    % remove file from pendingFileList
    % that should take care of loading in the next data as well
    set(handles.pendingFileList, 'Value', 1);
    h = findobj('Style', 'pushbutton', 'Tag', 'removefile');
    removefile_Callback(h, eventdata, handles);
    
    
    
    % clear the global qc action checkboxes too
    set(handles.malpositioned, 'Value', 0);
    set(handles.otherflag, 'Value', 0);
    set(handles.markerflag, 'Value', 0);
    
    
    
    
elseif sum(qcpass == -1) > 0
    errordlg('Not all performances have been checked yet. Mark each as a pass or fail.','QC Not Complete','modal')
elseif  length(get(handles.qcid, 'String')) ~= 3
    errordlg('Specify your 3-digit ID before saving.','QC Personnel Not Selected','modal')
end


function edit23_Callback(hObject, eventdata, handles)
% hObject    handle to edit23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit23 as text
%        str2double(get(hObject,'String')) returns contents of edit23 as a double


% --- Executes during object creation, after setting all properties.
function edit23_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit24_Callback(hObject, eventdata, handles)
% hObject    handle to edit24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit24 as text
%        str2double(get(hObject,'String')) returns contents of edit24 as a double


% --- Executes during object creation, after setting all properties.
function edit24_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in recfail.
function recfail_Callback(hObject, eventdata, handles)
% hObject    handle to recfail (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global totalperformances;
global qcpass;
global startsample;
global endsample;
global userdefinedstart;
global userdefinedend;
global failreason;
global rectcoords;
global textcoords;

% see which performance is currently highlighted in performance status
% listbox
h = findobj('Style', 'listbox', 'Tag', 'perfstatlistbox');
perfnum = get(h,'Value'); %returns selected item number from perfstatlistbox

if get(findobj('Style', 'checkbox', 'Tag', 'failbox1'), 'Value') + get(findobj('Style', 'checkbox', 'Tag', 'failbox2'), 'Value') + get(findobj('Style', 'checkbox', 'Tag', 'failbox3'), 'Value') == 1
        
    qcpass(perfnum) = 0;
    userdefinedstart(perfnum) = 0;
    userdefinedend(perfnum) = 0;
    
    delete(rectcoords(perfnum));
    delete(textcoords(perfnum));
    
    %check on fail boxes
    if get(findobj('Style', 'checkbox', 'Tag', 'failbox1'), 'Value')
        failreason(perfnum) = 1;
    elseif get(findobj('Style', 'checkbox', 'Tag', 'failbox2'), 'Value')
        failreason(perfnum) = 2;
    elseif get(findobj('Style', 'checkbox', 'Tag', 'failbox3'), 'Value')
            failreason(perfnum) = 3;
    end
    
    
    startsample(perfnum) = -1;
    endsample(perfnum) = -1;
    
    updatePerfStatusText(1);
    
    
     % auto advance to next epoch after recording qc fail unless the 'data
    % not recorded' fail reason was selected. this is because there's a
    % good chance the next performance corresponds to already displayed
    % epoch
    if get(findobj('Style', 'checkbox', 'Tag', 'failbox2'), 'Value')
        h = findobj('Style', 'pushbutton', 'Tag', 'nextbutton');
        nextbutton_Callback(h, eventdata, handles);
        nextbutton_Callback(h, eventdata, handles);
    end   
    

    
    % auto advance in the performance status listbox after recording a qc
    % failure
    if sum(qcpass == -1) > 0
        
        % highlight next unchecked performance on the list if it's next
        % automatically move to next performance
        moved = false;
        i = 1;
        
        % this goes through all the performances (starting from the next one
        % and then wrapping around back to the first one if necessary) to find
        % the next one that's not been checked yet
        while moved == false && i <= totalperformances
            perfnum = mod(perfnum + i, totalperformances);
            if perfnum == 0
                perfnum = totalperformances;
            end
            
            if qcpass(perfnum) == -1
                h = findobj('Style', 'listbox', 'Tag', 'perfstatlistbox');
                set(h, 'Value', perfnum);
                moved = true;
            end
        end
        
    end    
elseif get(findobj('Style', 'checkbox', 'Tag', 'failbox1'), 'Value') + get(findobj('Style', 'checkbox', 'Tag', 'failbox2'), 'Value') + get(findobj('Style', 'checkbox', 'Tag', 'failbox3'), 'Value') == 0
    errordlg('You must select exactly one reason for QC failure. Zero reasons currently selected.','Bad Input','modal')%error message saying you need to select a fail reason
  
elseif get(findobj('Style', 'checkbox', 'Tag', 'failbox1'), 'Value') + get(findobj('Style', 'checkbox', 'Tag', 'failbox2'), 'Value') + get(findobj('Style', 'checkbox', 'Tag', 'failbox3'), 'Value') > 1
    errordlg('You must select exactly one reason for QC failure. More than one reason currently selected','Bad Input','modal')%error message saying you need to select only one reason

end















% --- Executes on button press in failbox1.
function failbox1_Callback(hObject, eventdata, handles)
% hObject    handle to failbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of failbox1


% --- Executes on button press in failbox2.
function failbox2_Callback(hObject, eventdata, handles)
% hObject    handle to failbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of failbox2


% --- Executes on button press in missingstartcheckbox.
function missingstartcheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to missingstartcheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of missingstartcheckbox

if get(hObject, 'Value') == 0
    %run the startboxtext function callback
    h = findobj('Style', 'edit', 'Tag', 'startmarktext');
    

    % note: this is a call to function, not function definition.
    startmarktext_Callback(h, eventdata, handles);
    
%else
   %pay attention to the edit box, but really this is 'do nothing' 
end



function startmarktext_Callback(hObject, eventdata, handles)
% hObject    handle to startmarktext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of startmarktext as text
%        str2double(get(hObject,'String')) returns contents of startmarktext as a double


global epochstart;
global epochend;
global markerbegin;
global markerend;
global signal;
global defaultstartmark;
global timevec;
%global hgnav;
global recth;

h = findobj('Style', 'checkbox', 'Tag', 'missingstartcheckbox');
set(h,'Value', 0.0);


user_entry = str2double(get(hObject,'string'));

if mod(user_entry,1) ~= 0 || length(user_entry) > 1 || user_entry > length(markerbegin) || user_entry < 1
    errordlg('You must enter a single, positive, integer value less than the number of marks.','Bad Input','modal')
    
    %revert to default starting value-- this could be a little buggy in
    %case the previous epochstart time was not on an originally placed marker
  
            set(hObject, 'string', defaultstartmark);
    
    return
end

% otherwise Proceed with callback...

epochstart = markerbegin(user_entry);
h = findobj('Style', 'edit', 'Tag', 'specstart');
set(h,'String', num2str(timevec(epochstart)));

if user_entry == length(markerbegin)
    epochend = length(signal);
    h = findobj('Style', 'edit', 'Tag', 'startmarktext');
    set(h, 'string', length(markerbegin)-1);
else
    epochend = markerend(user_entry + 1);
    h = findobj('Style', 'edit', 'Tag', 'endmarktext');
    set(h, 'string', user_entry + 1);
    endmarktext_Callback(h, eventdata, handles);
end


%importantly, draw a box around the epoch in question, first deleting any
%previous instance that might exist.

hgnav = findobj('Type', 'axes', 'Tag', 'gnav');
axes(hgnav);
if exist('recth', 'var')
    delete(recth);
end

if epochend > epochstart
    recth = rectangle('Position', [timevec(epochstart), 0, timevec(epochend) - timevec(epochstart), 2], 'EdgeColor', [1 0 0], 'LineWidth', 1.0);
end



drawEpoch(1);






function specstart_Callback(hObject, eventdata, handles)
% hObject    handle to specstart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of specstart as text
%        str2double(get(hObject,'String')) returns contents of specstart as a double

global timevec;
global epochstart;
global epochend;
global recth;
%global hgnav;


% first get the value typed in the box
spectime = str2double(get(hObject,'String'));

% then find the sample number closest to that value

timeresid = abs(timevec - spectime);
[C I] = min(timeresid);

% after checking that it's not too high or low
% a value
if I < epochend
    % change the text to that time value
    set(hObject, 'String', num2str(timevec(I)));

    % also set the missing marker checkbox to selected
    hmissingstartcheckbox = findobj('Style', 'checkbox', 'Tag', 'missingstartcheckbox');
    set(hmissingstartcheckbox, 'Value', 1);
    
    % change the epochstart global 
    epochstart = I;
    
    % draw new in epoch view
    drawEpoch(1);
    
    % draw new red box
    hgnav = findobj('Type', 'axes', 'Tag', 'gnav');
    axes(hgnav);
    if exist('recth', 'var')
        delete(recth);
    end
    
    if epochend > epochstart
        recth = rectangle('Position', [timevec(epochstart), 0, timevec(epochend) - timevec(epochstart), 2], 'EdgeColor', [1 0 0], 'LineWidth', 1.0);
    end
else
    
    set(hObject, 'String', num2str(timevec(epochstart)));
    
end








% --- Executes during object creation, after setting all properties.
function specstart_CreateFcn(hObject, eventdata, handles)
% hObject    handle to specstart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in missingendcheckbox.
function missingendcheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to missingendcheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of missingendcheckbox


if get(hObject, 'Value') == 0
    %run the endboxtext function callback
    h = findobj('Style', 'edit', 'Tag', 'endmarktext');
    

    % note: this is a call to function, not function definition.
    endmarktext_Callback(h, eventdata, handles)
    
%else
   %pay attention to the edit box, but really this is 'do nothing' 
end



function endmarktext_Callback(hObject, eventdata, handles)
% hObject    handle to endmarktext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of endmarktext as text
%        str2double(get(hObject,'String')) returns contents of endmarktext as a double




global epochstart;
global epochend;
global markerbegin;
global markerend;
global signal;
global defaultstartmark;
global timevec;
%global hgnav;
global recth;

user_entry = str2double(get(hObject,'string'));

h = findobj('Style', 'checkbox', 'Tag', 'missingendcheckbox');
set(h,'Value', 0.0);


if mod(user_entry,1) ~= 0 || length(user_entry) > 1 || user_entry > length(markerbegin) || user_entry < 2
    errordlg('You must enter a single, positive, integer value corresponding to a mark past the currently selected start mark.','Bad Input','modal')
    
    h = findobj('Style', 'edit', 'Tag', 'startmarktext');
    temp = str2double(get(h, 'string'));
    set(hObject, 'string', temp);
    
    return
end

% otherwise Proceed with callback...

epochend = markerbegin(user_entry);
h = findobj('Style', 'edit', 'Tag', 'specend');
set(h,'String', num2str(timevec(epochend)));


%importantly, draw a box around the epoch in question, first deleting any
%previous instance that might exist.

hgnav = findobj('Type', 'axes', 'Tag', 'gnav');
axes(hgnav);
if exist('recth', 'var')
    delete(recth);
end

if epochend > epochstart
    recth = rectangle('Position', [timevec(epochstart), 0, timevec(epochend) - timevec(epochstart), 2], 'EdgeColor', [1 0 0], 'LineWidth', 1.0);
end


drawEpoch(1);



% --- Executes during object creation, after setting all properties.
function startmarktext_CreateFcn(hObject, eventdata, handles)
% hObject    handle to startmarktext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end







% --- Executes during object creation, after setting all properties.
function endmarktext_CreateFcn(hObject, eventdata, handles)
% hObject    handle to endmarktext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function specend_Callback(hObject, eventdata, handles)
% hObject    handle to specend (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of specend as text
%        str2double(get(hObject,'String')) returns contents of specend as a double

global timevec;
global epochstart;
global epochend;
global recth;
%global hgnav;


% first get the value typed in the box
spectime = str2double(get(hObject,'String'));

% then find the sample number closest to that value

timeresid = abs(timevec - spectime);
[C I] = min(timeresid);

% after checking that it's not too high or low
% a value
if I > epochstart
    % change the text to that time value
    set(hObject, 'String', num2str(timevec(I)));

    % also set the missing marker checkbox to selected
    hmissingendcheckbox = findobj('Style', 'checkbox', 'Tag', 'missingendcheckbox');
    set(hmissingendcheckbox, 'Value', 1);
    
    % change the epochend global 
    epochend = I;
    
    % draw new in epoch view
    drawEpoch(1);
    
    % draw new red box
    hgnav = findobj('Type', 'axes', 'Tag', 'gnav');
    axes(hgnav);
    if exist('recth', 'var')
        delete(recth);
    end
    
    if epochend > epochstart
        recth = rectangle('Position', [timevec(epochstart), 0, timevec(epochend) - timevec(epochstart), 2], 'EdgeColor', [1 0 0], 'LineWidth', 1.0);
    end
else
    
    set(hObject, 'String', num2str(timevec(epochstart)));
    
end


% --- Executes during object creation, after setting all properties.
function specend_CreateFcn(hObject, eventdata, handles)
% hObject    handle to specend (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in recpass.
function recpass_Callback(hObject, eventdata, handles)
% hObject    handle to recpass (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global totalperformances;
global qcpass;
global startsample;
global endsample;
global userdefinedstart;
global userdefinedend;
%global hgnav;
global rectcoords;
global textcoords;
global epochstart;
global epochend;
global timevec;
global failreason;
global perfnames;

% see which performance is currently highlighted in performance status
% listbox
h = findobj('Style', 'listbox', 'Tag', 'perfstatlistbox');
perfnum = get(h,'Value'); %returns selected item number from perfstatlistbox

% if user has checked any of the "fail boxes", then a message should pop up
% saying "you selected pass even though this is a fail: uncheck fail boxes
% or record as a fail", not just indiscriminantly record as pass without
% checking first (but right now that's how it is)
qcpass(perfnum) = 1;
failreason(perfnum) = 0;
startsample(perfnum) = epochstart; 
endsample(perfnum) = epochend; 


h = findobj('Style', 'checkbox', 'Tag', 'missingstartcheckbox');
if get(h, 'Value')
    userdefinedstart(perfnum) = 1;
else
    userdefinedstart(perfnum) = 0;
end

h = findobj('Style', 'checkbox', 'Tag', 'missingendcheckbox');
if get(h, 'Value')
    userdefinedend(perfnum) = 1;
else
    userdefinedend(perfnum) = 0;
end

% update the performance status list to show a 'pass'

updatePerfStatusText(1);

% draw  a green box on the global view and ?annotate with performance
% name abbreviation?

hgnav = findobj('Type', 'axes', 'Tag', 'gnav');
axes(hgnav);

delete(rectcoords(perfnum));
delete(textcoords(perfnum));

if epochend > epochstart
    rectcoords(perfnum) = rectangle('Position', [timevec(epochstart), 0, timevec(epochend)-timevec(epochstart), 2], 'EdgeColor', [0 1 0], 'LineWidth', 1.0);
end
textcoords(perfnum) = text(timevec(epochstart), 0, perfnames{perfnum}, 'Rotation', 90, 'Color', 'magenta');

% if no performances are unchecked
% don't do anything past here

if sum(qcpass == -1) > 0

% highlight next unchecked performance on the list if it's next
% automatically move to next performance 
    moved = false;
    i = 1;
    
    % this goes through all the performances (starting from the next one
    % and then wrapping around back to the first one if necessary) to find
    % the next one that's not been checked yet
    while moved == false && i <= totalperformances
        perfnum = mod(perfnum + i, totalperformances);
        if perfnum == 0
            perfnum = totalperformances;
        end
        
        if qcpass(perfnum) == -1
            h = findobj('Style', 'listbox', 'Tag', 'perfstatlistbox');
            
            set(h, 'Value', perfnum);
            moved = true;
        end
    end
  % advance epoch view twice (to skip over dead period)
  
    h = findobj('Style', 'pushbutton', 'Tag', 'nextbutton');
    nextbutton_Callback(h, eventdata, handles);
    nextbutton_Callback(h, eventdata, handles);
end


 


% --- Executes on selection change in perfstatlistbox.
function perfstatlistbox_Callback(hObject, eventdata, handles)
% hObject    handle to perfstatlistbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns perfstatlistbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from perfstatlistbox


% --- Executes during object creation, after setting all properties.
function perfstatlistbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to perfstatlistbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in nextbutton.
function nextbutton_Callback(hObject, eventdata, handles)
% hObject    handle to nextbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global epochstart;
global epochend;
global markerbegin;
global markerend;


% what marker are we currently on or which markers are we currently
% between? (talking about the marker for the beginning of epoch)
% this is figured out by looking at the epochstart time in relation to the
% marker times. we use the markerbegin times just because that is what I
% consider the "real" marker time, ie the time of initial button press.
% slight problem with getting to last epoch which will not have an end marker, just
% end of file, but could conceivably have useful data if RA forgot to press
% button at end -- solved this by adding an artificial button press in very
% last sample, regardless of whether there was actually a button press or
% not.
for i = 1:length(markerbegin) - 2
    if epochstart >= markerbegin(i)
        startmark = i + 1;
    end
end

epochstart = markerbegin(startmark);

h = findobj('Style', 'edit', 'Tag', 'startmarktext');
set(h, 'string', startmark);

% note: this is a call to function, not function definition.
startmarktext_Callback(h, eventdata, handles)



% --- Executes on button press in prevbutton.
function prevbutton_Callback(hObject, eventdata, handles)
% hObject    handle to prevbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global epochstart;
global epochend;
global markerbegin;
global markerend;

% as above, added in an artificial button press in first sample regardless
% of whether there was actually one or not, to simplify assumptions here
for i = length(markerbegin):-1:2
    if epochstart <= markerbegin(i) 
        startmark = i - 1;
    end
end

epochstart = markerbegin(startmark);

h = findobj('Style', 'edit', 'Tag', 'startmarktext');
set(h, 'string', startmark);

% note: this is a call to function, not function definition.
startmarktext_Callback(h, eventdata, handles)











function edit17_Callback(hObject, eventdata, handles)
% hObject    handle to edit17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit17 as text
%        str2double(get(hObject,'String')) returns contents of edit17 as a double


% --- Executes during object creation, after setting all properties.
function edit17_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit18_Callback(hObject, eventdata, handles)
% hObject    handle to edit18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit18 as text
%        str2double(get(hObject,'String')) returns contents of edit18 as a double


% --- Executes during object creation, after setting all properties.
function edit18_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on selection change in qcid.
function qcid_Callback(hObject, eventdata, handles)
% hObject    handle to qcid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns qcid contents as cell array
%        contents{get(hObject,'Value')} returns selected item from qcid


% --- Executes during object creation, after setting all properties.
function qcid_CreateFcn(hObject, eventdata, handles)
% hObject    handle to qcid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in startxhairtoggle.
function startxhairtoggle_Callback(hObject, eventdata, handles)
% hObject    handle to startxhairtoggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of startxhairtoggle

hothertoggle = findobj('Style', 'togglebutton', 'Tag', 'endxhairtoggle');
set(hothertoggle, 'Value', 0);

h = findobj('Type', 'axes', 'Tag', 'vertacc');

while get(hObject, 'Value') == 1
    clicklock = ginput(1);
    
    htext = findobj('Style', 'edit', 'Tag', 'specstart');
    
    set(htext, 'String', num2str(clicklock(1)));
    % note: this is a call to function, not function definition.
    specstart_Callback(htext, eventdata, handles);
    
    set(hObject, 'Value', 0);
end



% --- Executes on button press in endxhairtoggle.
function endxhairtoggle_Callback(hObject, eventdata, handles)
% hObject    handle to endxhairtoggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of endxhairtoggle

hothertoggle = findobj('Style', 'togglebutton', 'Tag', 'startxhairtoggle');
set(hothertoggle, 'Value', 0);

h = findobj('Type', 'axes', 'Tag', 'vertacc');

while get(hObject, 'Value') == 1
    clicklock = ginput(1);
    
    htext = findobj('Style', 'edit', 'Tag', 'specend');
    
    set(htext, 'String', num2str(clicklock(1)));
    % note: this is a call to function, not function definition.
    specend_Callback(htext, eventdata, handles);
    
    set(hObject, 'Value', 0);
end



function projID_Callback(hObject, eventdata, handles)
% hObject    handle to projID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of projID as text
%        str2double(get(hObject,'String')) returns contents of projID as a double


% --- Executes during object creation, after setting all properties.
function projID_CreateFcn(hObject, eventdata, handles)
% hObject    handle to projID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in markerflag.
function markerflag_Callback(hObject, eventdata, handles)
% hObject    handle to markerflag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of markerflag


% --- Executes on button press in failbox3.
function failbox3_Callback(hObject, eventdata, handles)
% hObject    handle to failbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of failbox3

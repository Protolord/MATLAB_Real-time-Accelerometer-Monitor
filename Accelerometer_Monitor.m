function varargout = Accelerometer_Monitor(varargin)

% Retrieves data from 3 sensors uploaded in ThingSpeak. Data from these
% sensors are being uploaded in real-time.

% Features:
%   - Data can be plotted in Time Domain or Frequency Domain
%   - Easy switching of plot view between sensor nodes.
%   - Plot viewing within a certain Time Frame.
%   - Allows saving of data into local file system.
%   - Allows loading of saved data from local file system.

% Mapua Institute of Technology
% School of Electrical, Electronics and Computer Engineering

%To do:
% - Add clear current node channels button.

% Last Modified by GUIDE v2.5 08-Feb-2017 16:41:19

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Accelerometer_Monitor_OpeningFcn, ...
                   'gui_OutputFcn',  @Accelerometer_Monitor_OutputFcn, ...
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


% --- Executes just before Accelerometer_Monitor is made visible.
%-------------------------------------------------------------------------%
function Accelerometer_Monitor_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<INUSL>
%-------------------------------------------------------------------------%
global channel;
global plotType;
global node;
global tData;
global xData;
global yData;
global zData;
global timeF;
global timeL;
global gmt;
global statusDisplay;
global nodeDisplay;
% Choose default command line output for Accelerometer_Monitor
handles.output = hObject;
datacursormode(handles.mainFigure, 'on')

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Accelerometer_Monitor wait for user response (see UIRESUME)
% uiwait(handles.mainFigure);

%Load Configuration.mat
try
    load('Configuration.mat', 'timeF');
    load('Configuration.mat', 'timeL');
    load('Configuration.mat', 'channel');
    load('Configuration.mat', 'gmt');
catch
    timeF = datenum('01-Jan-2017 00:00:01');
    timeL = now;
    channel = zeros(3, 15);
    gmt = 0;
end
%GUI Handles Initial Properties
set(handles.xPlot_axes,'xtick',[],'ytick',[]);
set(handles.yPlot_axes,'xtick',[],'ytick',[]);
set(handles.zPlot_axes,'xtick',[],'ytick',[]);
set(handles.BTNReload, 'Visible', 'off');
set(handles.BTNTimePlot, 'Visible', 'off');
set(handles.BTNFreqPlot, 'Visible', 'off');
set(handles.BTNSensorLeft, 'Visible', 'off');
set(handles.BTNSensorRight, 'Visible', 'off');
%Initial plotting properties
plotType = 0;
statusDisplay = uicontrol(handles.mainFigure, 'Style', 'Text',...
                                              'String', 'No connection',...
                                              'Position', [850 415 120 30],...
                                              'FontSize', 13);     
set(statusDisplay, 'Visible', 'on');
nodeDisplay = uicontrol(handles.mainFigure, 'Style', 'Text',...
                                            'String', 'Node 1',...
                                            'Position', [872 178 80, 20],...
                                            'FontSize', 12);  
set(nodeDisplay, 'Visible', 'off');
node = 1;
%Initialize variables in plotting
tData = zeros(3, 0);
xData = zeros(3, 0);
yData = zeros(3, 0);
zData = zeros(3, 0);

% --- Outputs from this function are returned to the command line.
%-------------------------------------------------------------------------%
function varargout = Accelerometer_Monitor_OutputFcn(hObject, eventdata, handles)  %#ok<INUSL>
%-------------------------------------------------------------------------%

% Get default command line output from handles structure
varargout{1} = handles.output;
movegui(handles.mainFigure, 'north');

%==========================================================================
%============================ CORE FUNCTIONS ==============================
%==========================================================================

%-------------------------------------------------------------------------%
function TimePlot(n, handles)
%-------------------------------------------------------------------------%
global timeF;
global timeL;
global tData;
global xData;
global yData;
global zData;
%Time plot  
b = tData >= timeF & tData <= timeL;
finder = find(b(n,:));
if isempty(finder)
    cla(handles.xPlot_axes);
    cla(handles.yPlot_axes);
    cla(handles.zPlot_axes);
    set(handles.xPlot_axes,'xtick',[],'ytick',[]);
    set(handles.yPlot_axes,'xtick',[],'ytick',[]);
    set(handles.zPlot_axes,'xtick',[],'ytick',[]);
    msgbox(horzcat('No data found on Node ', int2str(n), '!'), 'No Data', 'error');
else
    f = finder(1);
    l = finder(end);
    plot(handles.xPlot_axes, tData(n,f:l), xData(n,f:l)/255, 'r');
    plot(handles.yPlot_axes, tData(n,f:l), yData(n,f:l)/255, 'g');
    plot(handles.zPlot_axes, tData(n,f:l), zData(n,f:l)/255, 'b');
    datetick(handles.xPlot_axes, 'x','HH:MM:SS', 'keepticks');
    datetick(handles.yPlot_axes, 'x','HH:MM:SS', 'keepticks');
    datetick(handles.zPlot_axes, 'x','HH:MM:SS', 'keepticks');
    xlabel(handles.xPlot_axes, 'Time (HH:MM:SS)');
    ylabel(handles.xPlot_axes, 'Magnitude (g)');
    xlabel(handles.yPlot_axes, 'Time (HH:MM:SS)');
    ylabel(handles.yPlot_axes, 'Magnitude (g)');
    xlabel(handles.zPlot_axes, 'Time (HH:MM:SS)');
    ylabel(handles.zPlot_axes, 'Magnitude (g)');
    set(handles.xPlot_axes, 'XGrid', 'on');
    set(handles.xPlot_axes, 'YGrid', 'on');
    set(handles.yPlot_axes, 'XGrid', 'on');
    set(handles.yPlot_axes, 'YGrid', 'on');
    set(handles.zPlot_axes, 'XGrid', 'on');
    set(handles.zPlot_axes, 'YGrid', 'on');
    drawnow;
end

%-------------------------------------------------------------------------%
function FreqPlot(n, handles)
%-------------------------------------------------------------------------%
global timeF;
global timeL;
global tData;
global xData;
global yData;
global zData;
%Time plot  
b = tData(n,:) >= timeF & tData(n,:) <= timeL;
finder = find(b(n,:));
if isempty(finder)
    cla(handles.xPlot_axes);
    cla(handles.yPlot_axes);
    cla(handles.zPlot_axes);
    set(handles.xPlot_axes,'xtick',[],'ytick',[]);
    set(handles.yPlot_axes,'xtick',[],'ytick',[]);
    set(handles.zPlot_axes,'xtick',[],'ytick',[]);
    msgbox('No Data Found!', 'No Data', 'error');
else
    f = finder(1);
    l = finder(end);
    L = length(finder);
    peaksNum = 6;
    %X
    y = xData(n,f:l)/255;
    [psd, fs] = periodogram(y - mean(y), [], [], L);
    fs = 25*fs/fs(end);
    [pks, locs] = findpeaks(psd, fs, 'SortStr', 'descend');
    last = min(peaksNum, length(pks));
    plot(handles.xPlot_axes, fs, psd, 'r');
    hold(handles.xPlot_axes, 'on')
    for i = 1:last
        text(handles.xPlot_axes, locs(i), pks(i), horzcat('  P', num2str(i)), 'FontSize', 8, 'Clipping', 'on');
        plot(handles.xPlot_axes, locs(i), pks(i), '*');
    end
    hold(handles.xPlot_axes, 'off')
    xlim(handles.xPlot_axes, [0 25]);
    ylim(handles.xPlot_axes, [0 1.1*pks(1)]);
    %Y
    y = yData(n,f:l)/255;
    [psd, fs] = periodogram(y - mean(y), [], [], L);
    fs = 25*fs/fs(end);
    [pks, locs] = findpeaks(psd, fs, 'SortStr', 'descend');
    last = min(peaksNum, length(pks));
    plot(handles.yPlot_axes, fs, psd, 'g');
    hold(handles.yPlot_axes, 'on')
    for i = 1:last
        text(handles.yPlot_axes, locs(i), pks(i), horzcat('  P', num2str(i)), 'FontSize', 8, 'Clipping', 'on');
        plot(handles.yPlot_axes, locs(i), pks(i), '*');
    end
    hold(handles.yPlot_axes, 'off')
    xlim(handles.yPlot_axes, [0 25]);
    ylim(handles.yPlot_axes, [0 1.1*pks(1)]);
    %Z
    y = zData(n,f:l)/255;
    [psd, fs] = periodogram(y - mean(y), [], [], L);
    fs = 25*fs/fs(end);
    [pks, locs] = findpeaks(psd, fs, 'SortStr', 'descend');
    last = min(peaksNum, length(pks));
    plot(handles.zPlot_axes, fs, psd, 'b');
    hold(handles.zPlot_axes, 'on')
    for i = 1:last
        text(handles.zPlot_axes, locs(i), pks(i), horzcat('  P', num2str(i)), 'FontSize', 8, 'Clipping', 'on');
        plot(handles.zPlot_axes, locs(i), pks(i), '*');
    end
    hold(handles.zPlot_axes, 'off')
    xlim(handles.zPlot_axes, [0 25]);
    ylim(handles.zPlot_axes, [0 1.1*pks(1)]);
    
    %-------------------------------------
    set(handles.xPlot_axes, 'XGrid', 'on');
    set(handles.xPlot_axes, 'YGrid', 'on');
    set(handles.yPlot_axes, 'XGrid', 'on');
    set(handles.yPlot_axes, 'YGrid', 'on');
    set(handles.zPlot_axes, 'XGrid', 'on');
    set(handles.zPlot_axes, 'YGrid', 'on');
    xlabel(handles.xPlot_axes, 'Frequency (Hz)');
    ylabel(handles.xPlot_axes, 'Magnitude (g^2)');
    xlabel(handles.yPlot_axes, 'Frequency (Hz)');
    ylabel(handles.yPlot_axes, 'Magnitude (g^2)');
    xlabel(handles.zPlot_axes, 'Frequency (Hz)');
    ylabel(handles.zPlot_axes, 'Magnitude (g^2)');
    drawnow;
end

%-------------------------------------------------------------------------%
function x = UpdateData(n, handles)
%-------------------------------------------------------------------------%
global tData;
global xData;
global yData;
global zData;
global channel;
global gmt;
global statusDisplay;
set(statusDisplay, 'String', 'Downloading...', 'Fontsize', 12);
wb = waitbar(0, horzcat('Downloading Data for Node ', int2str(n), '(0.00%)'));

oldest = zeros(1,15);   %oldest time per channel
pointer = zeros(1,15);  %points to the current feeds index per channel
index = zeros(1,3);     %latest data index for each node
oldestAll = now;        %oldest time in all channels
oldestIndex = 1;        %index of oldest time in all channels

ch = 15;
for i = 1:ch
    checker = 5;
    while(true)
        url = horzcat('http://api.thingspeak.com/channels/', int2str(channel(n,i)), '/feed.json');
        try
            s(i) = webread(url); %#ok<AGROW>
            break;
        catch
            disp(horzcat('Retrying connection to ', url));
        end
        checker = checker - 1;
        if checker == 0
            if ishandle(wb)
                delete(wb);
            end
            %clear plot areas
            cla(handles.xPlot_axes);
            cla(handles.yPlot_axes);
            cla(handles.zPlot_axes);
            set(handles.xPlot_axes,'xtick',[],'ytick',[]);
            set(handles.yPlot_axes,'xtick',[],'ytick',[]);
            set(handles.zPlot_axes,'xtick',[],'ytick',[]);
            set(statusDisplay, 'String', 'Connection Timeout', 'Fontsize', 10);
            msgbox(horzcat('Cannot connect to ThingSpeak Channel: ', int2str(channel(n, i))), 'Connection Timeout', 'error');
            beep;
            x = 0;
            return;
        end
    end
    %Find oldest data
    firstT = s(i).feeds(1).created_at;
    firstT = firstT(1:end-1);
    oldest(i) = datenum(firstT, 'yyyy-mm-ddTHH:MM:SS') + 0.041666666666*gmt;
    if oldest(i) < oldestAll
        oldestAll = oldest(i);
        oldestIndex = i;
    end
    pointer(i) = 1;
    if ishandle(wb)
        percent = i/ch;
        waitbar(percent, wb, horzcat('Downloading Data for Node ', num2str(n), ' (', num2str(100*percent, 3), '%)'));
    end
end
if ishandle(wb)
    delete(wb);
end
set(statusDisplay, 'String', 'Processing Data...', 'Fontsize', 10);
pause(0.1);
index(n) = 1;
done = 0;
wb = waitbar(0, 'Processing Data (0.00%)');
%calculate total indices
total = 0;
for i = 1:ch
    total = total + length(s(i).feeds);
end
ctr = 0;
while(done < ch)
    %Append oldest to data
    p = pointer(oldestIndex);   %temp pointer of oldestIndex
    dataX = s(oldestIndex).feeds(p).field1;
    dataY = s(oldestIndex).feeds(p).field2;
    dataZ = s(oldestIndex).feeds(p).field3;
    time = oldestAll;
    xparsed = regexp(dataX, ',', 'split');
    yparsed = regexp(dataY, ',', 'split');
    zparsed = regexp(dataZ, ',', 'split');
    %Safety Check
    xL = length(xparsed);
    yL = length(yparsed);
    zL = length(zparsed);
    for k = 1:50
        xData(n,index(n)) = str2double(xparsed(min(k, xL)));
        yData(n,index(n)) = str2double(yparsed(min(k, yL)));
        zData(n,index(n)) = str2double(zparsed(min(k, zL)));
        tData(n,index(n)) = time;
        time = time + 2.314336597919464e-07;
        index(n) = index(n) + 1;
    end
    %Move pointer
    p = p + 1; 
    pointer(oldestIndex) = p;
    %Reassign oldest
    %If that was not the last pointer
    if p <= length(s(oldestIndex).feeds)
        %Move oldest(oldestIndex)
        firstT = s(oldestIndex).feeds(p).created_at;
        firstT = firstT(1:end-1);
        oldest(oldestIndex) = datenum(firstT, 'yyyy-mm-ddTHH:MM:SS') + 0.041666666666*gmt;
    else
        oldest(oldestIndex) = now;
        done = done + 1;
    end
    %Reassign oldestAll and oldestIndex
    oldestAll = now; 
    for i = 1:ch
        %Find oldest data again
        if oldest(i) < oldestAll
            oldestAll = oldest(i);
            oldestIndex = i;
        end
    end
    if ishandle(wb)
        percent = ctr/total;
        waitbar(percent, wb, horzcat('Processing Data (', num2str(100*percent, 3), '%)'));
    end
    ctr = ctr + 1;
end
if ishandle(wb)
    delete(wb);
end
set(statusDisplay, 'String', 'Idle', 'Fontsize', 12);
x = 1;
return;


function RefreshPlot(handles)
global plotType;
global node;
if plotType
    FreqPlot(node, handles);
else
    TimePlot(node, handles);
end

%==========================================================================
%=========================== BUTTON CALLBACKS =============================
%==========================================================================

% --- Executes on button press in BTNConnect.
%-------------------------------------------------------------------------%
function BTNConnect_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
%-------------------------------------------------------------------------%
global node;
global nodeDisplay;
global statusDisplay;
%Status Bar
counter = 0;
tf = false;
%Check internet connection
set(statusDisplay, 'String', 'Connecting...', 'Fontsize', 12);
wb = waitbar(0, 'Connecting to ThingSpeak.com');
while(~tf && counter < 5)
    try
        url = java.net.InetAddress.getByName('www.thingspeak.com'); %#ok<NASGU>
        tf = true;
    catch
        disp('Failed to connect to thingspeak.com');
    end
    counter = counter + 1;
    pause(1);
    if ishandle(wb)
        waitbar(counter/5, wb);
    end
end
if (~tf)
    delete(wb);
    %clear plot areas
    cla(handles.xPlot_axes);
    cla(handles.yPlot_axes);
    cla(handles.zPlot_axes);
    set(handles.xPlot_axes,'xtick',[],'ytick',[]);
    set(handles.yPlot_axes,'xtick',[],'ytick',[]);
    set(handles.zPlot_axes,'xtick',[],'ytick',[]);
    set(statusDisplay, 'String', 'No Connection', 'Fontsize', 12);
    msgbox('Cannot connect to ThingSpeak Server', 'Connection Timeout', 'error');
    beep;
    return;
end
if ishandle(wb)
    waitbar(1, wb);
end
set(statusDisplay, 'String', 'Connected', 'Fontsize', 12);
pause(0.1);
if ishandle(wb)
    delete(wb);
end

proceed = true;
%Web scrapping
for n = 1:1 %3
    proceed = UpdateData(n, handles);
    if ~proceed
        break;
    end
end

if proceed
    %Default node
    node = 1; 
    %Static text handles
    set(nodeDisplay, 'Visible', 'on');
    set(nodeDisplay, 'String', 'Node 1');

    %GUI Handles manipulation
    set(handles.BTNReload, 'Visible', 'on');
    set(handles.BTNConnect, 'Visible', 'off');
    set(handles.BTNFreqPlot, 'Visible', 'on');
    set(handles.BTNSensorLeft, 'Visible', 'on');
    set(handles.BTNSensorRight, 'Visible', 'on');
    set(handles.uipushtoolsave, 'Visible', 'on');
    %Plot default node
    TimePlot(node, handles);
end

% --- Executes on button press in BTNReload.
%-------------------------------------------------------------------------%
function BTNReload_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
%-------------------------------------------------------------------------%
global node;
UpdateData(node, handles);
RefreshPlot(handles);


% --- Executes on button press in BTNTimePlot.
%-------------------------------------------------------------------------%
function BTNTimePlot_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
%-------------------------------------------------------------------------%
global plotType;
global node;
%GUI Handles manipulation
set(handles.BTNTimePlot, 'Visible', 'off');
set(handles.BTNFreqPlot, 'Visible', 'on');
%If the plotting is paused and the plot type is in frequency domain
if (plotType)
    TimePlot(node, handles);
    plotType = 0;
end


% --- Executes on button press in BTNFreqPlot.
%-------------------------------------------------------------------------%
function BTNFreqPlot_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
%-------------------------------------------------------------------------%
global plotType;
global node;
%GUI Handles manipulation
set(handles.BTNTimePlot, 'Visible', 'on');
set(handles.BTNFreqPlot, 'Visible', 'off');
%If the plot type is in time domain
if (~plotType)
    FreqPlot(node, handles);
    plotType = 1;
end


% --- Executes on button press in Refresh.
%-------------------------------------------------------------------------%
function Refresh_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
%-------------------------------------------------------------------------%
RefreshPlot(handles);

% --- Executes on button press in BTNSensorLeft.
%-------------------------------------------------------------------------%
function BTNSensorLeft_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
%-------------------------------------------------------------------------%
global node;
global nodeDisplay;
node = node - 1;
if node == 0
    node = 3;
end
set(nodeDisplay, 'String', horzcat('Node ', int2str(node)));
RefreshPlot(handles);

% --- Executes on button press in BTNSensorRight.
%-------------------------------------------------------------------------%
function BTNSensorRight_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
%-------------------------------------------------------------------------%
global node;
global nodeDisplay;
node = node + 1;
if node == 4
    node = 1;
end
set(nodeDisplay, 'String', horzcat('Node ', int2str(node)));
RefreshPlot(handles);

%-------------------------------------------------------------------------%
function SaveConfig(varargin)
%-------------------------------------------------------------------------%
global timeF;
global timeL;
global channel;
global config;
global gmt;
timeF = datenum(get(config.in_from, 'String'));
timeL = datenum(get(config.in_to, 'String'));
gmt = str2double(get(config.in_gmt, 'String'));
for n = 1:3
    for i = 1:15
        channel(n,i) = str2double(get(config.ch(n,i), 'String'));
    end
end
save('Configuration.mat', 'timeF');
save('Configuration.mat', 'timeL', '-append');
save('Configuration.mat', 'channel', '-append');
save('Configuration.mat', 'gmt', '-append');
close(config.fig);

% --- Executes on button press in BTNConfig.
%-------------------------------------------------------------------------%
function BTNConfig_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
%-------------------------------------------------------------------------%
global timeF;
global timeL;
global channel;
global gmt;
global config;

% Read saved configuration
config.fig = figure('Position',[300 100 700 500],...
                    'MenuBar', 'None',...
                    'Numbertitle','Off',...
                    'Name','Configuration',...
                    'Resize','off');
config.save = uicontrol('Style','Push',...
                        'Position',[25 15 650 40],...
                        'Fontsize',12,...
                        'String','Save',...
                        'Callback',@SaveConfig);
config.stc_timeFrame = uicontrol('Style', 'Text',...
                                 'Position', [280 470 150 30],...
                                 'Fontsize', 16,...
                                 'FontWeight', 'Bold',...
                                 'String', 'Time Frame');
config.stc_from = uicontrol('Style', 'Text',...
                            'Position', [5 425 120 30],...
                            'Fontsize', 13,...
                            'String', 'From: ');
config.stc_to = uicontrol('Style', 'Text',...
                          'Position', [250 425 120 30],...
                          'Fontsize', 13,...
                          'String', 'To: ');
config.stc_gmt = uicontrol('Style', 'Text',...
                           'Position', [480 425 150 30],...
                           'Fontsize', 13,...
                           'String', 'GMT:');
config.in_from = uicontrol('Style', 'Edit',...
                           'Position', [90 430 175 30],...
                           'Fontsize', 13,...
                           'String', datestr(timeF));
config.in_to = uicontrol('Style', 'Edit',...
                         'Position', [330 430 175 30],...
                         'Fontsize', 13,...
                         'String', datestr(timeL));
config.in_gmt = uicontrol('Style', 'Edit',...
                          'Position', [580 430 50 30],...
                          'Fontsize', 13,...
                          'String', int2str(gmt));
config.stc_sensorData = uicontrol('Style', 'Text',...
                                  'Position', [280 380 150 30],...
                                  'Fontsize', 16,...
                                  'FontWeight', 'Bold',...
                                  'String', 'Sensor Data');
config.stc_sensor1 = uicontrol('Style', 'Text',...
                               'Position', [50 350 150 30],...
                               'Fontsize', 13,...
                               'String', 'Node 1');
config.stc_sensor2 = uicontrol('Style', 'Text',...
                               'Position', [275 350 150 30],...
                               'Fontsize', 13,...
                               'String', 'Node 2');
config.stc_sensor3 = uicontrol('Style', 'Text',...
                               'Position', [500 350 150 30],...
                               'Fontsize', 13,...
                               'String', 'Node 3');
for n = 1:3
    for i = 1:15
        if i > 8
            config.ch(n,i) = uicontrol('Style', 'Edit',...
                                       'Position', [(120 + 240*(n - 1)) (640 - 35*i) 100 30],...
                                       'Fontsize', 12,...
                                       'String', channel(n,i));
        else
            config.ch(n,i) = uicontrol('Style', 'Edit',...
                                       'Position', [(10 + 240*(n - 1)) (360 - 35*i) 100 30],...
                                       'Fontsize', 12,...
                                       'String', channel(n,i));
        end
    end
end


% --------------------------------------------------------------------
function uipushtoolsave_ClickedCallback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
global tData; %#ok<NUSED>
global xData; %#ok<NUSED>
global yData; %#ok<NUSED>
global zData; %#ok<NUSED>
[file,path] = uiputfile('*.mat','Save Data');
complete = horzcat(path, file);
save(complete, 'tData');
save(complete, 'xData', '-append');
save(complete, 'yData', '-append');
save(complete, 'zData', '-append');

% --------------------------------------------------------------------
function uipushtoolopen_ClickedCallback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
global tData;
global xData;
global yData;
global zData;
global node;
global nodeDisplay;
[file,path] = uigetfile('*.mat','Load Data');
complete = horzcat(path, file);
try
    load(complete, 'tData');
    load(complete, 'xData');
    load(complete, 'yData');
    load(complete, 'zData');
    %Default node
    node = 1; 
    %Static text handles
    set(nodeDisplay, 'Visible', 'on');
    set(nodeDisplay, 'String', 'Node 1');

    %GUI Handles manipulation
    set(handles.BTNReload, 'Visible', 'on');
    set(handles.BTNConnect, 'Visible', 'off');
    set(handles.BTNFreqPlot, 'Visible', 'on');
    set(handles.BTNSensorLeft, 'Visible', 'on');
    set(handles.BTNSensorRight, 'Visible', 'on');
    set(handles.uipushtoolsave, 'Visible', 'on');
catch
    tData = zeros(3, 1);
    xData = zeros(3, 1);
    yData = zeros(3, 1);
    zData = zeros(3, 1);
end
RefreshPlot(handles);

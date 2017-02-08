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
% - Do actions for clear channel data.
% - Do not rely on movegui, initially correctly place handles.mainFigure
% from the start.
% - Make handles.mainFigure uncontrollable until error msgbox is gone.

% Last Modified by GUIDE v2.5 09-Feb-2017 00:21:30

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
global plotType;
global node;
global tData;
global xData;
global yData;
global zData;
global timeF;
global timeL;
global channel;
global gmt;
global writeAPI;
global statusDisplay;
global nodeDisplay;

% Choose default command line output for Accelerometer_Monitor
handles.output = hObject;


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Accelerometer_Monitor wait for user response (see UIRESUME)
% uiwait(handles.mainFigure);

%Load Configuration.mat
try
    load('Configuration.mat', 'timeF');
    if isempty(timeF)
        timeF = datenum('01-Jan-2017 00:00:01');
    end
catch
    timeF = datenum('01-Jan-2017 00:00:01');
end
try
    load('Configuration.mat', 'timeL');
    if isempty(timeL)
        timeL = now;
    end
catch
    timeL = now;
end
try
    load('Configuration.mat', 'channel');
    if isempty(channel)
        channel = zeros(3, 15);
    end
catch
    channel = zeros(3, 15);
end
try
    load('Configuration.mat', 'gmt');
    if isempty(gmt)
        gmt = 0;
    end
catch
    gmt = 0;
end
try
    load('Configuration.mat', 'writeAPI');
    if isempty(writeAPI)
        writeAPI = zeros(3, 15);
    end
catch
    writeAPI = zeros(3, 15);
end

%GUI Handles Initial Properties
set(handles.xPlot_axes,'xtick',[],'ytick',[]);
set(handles.yPlot_axes,'xtick',[],'ytick',[]);
set(handles.zPlot_axes,'xtick',[],'ytick',[]);
set(handles.BTN_Reload, 'Visible', 'off');
set(handles.BTN_TimePlot, 'Visible', 'off');
set(handles.BTN_FreqPlot, 'Visible', 'off');
set(handles.BTN_SensorLeft, 'Visible', 'off');
set(handles.BTN_SensorRight, 'Visible', 'off');
set(handles.BTN_ClearChannels, 'Visible', 'off');
%Initial plotting properties
plotType = 0;
statusDisplay = uicontrol(handles.mainFigure, 'Style', 'Text',...
                                              'String', 'No connection',...
                                              'Position', [845 410 130 40],...
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
%Initially select Zoom toolbar button
zoom(handles.mainFigure, 'on');

% --- Executes when user attempts to close mainFigure.
%-------------------------------------------------------------------------%
function mainFigure_CloseRequestFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
%-------------------------------------------------------------------------%
global confirm;
global timeConfig;
global thingspeakConfig;
if ishandle(confirm.fig)
    close(confirm.fig);
end
if ishandle(timeConfig.fig)
    close(timeConfig.fig);
end
if ishandle(thingspeakConfig.fig)
    close(thingspeakConfig.fig);
end
delete(hObject);

%==========================================================================
%============================ CORE FUNCTIONS ==============================
%==========================================================================
function ClearAxes(handles)
cla(handles.xPlot_axes);
cla(handles.yPlot_axes);
cla(handles.zPlot_axes);
set(handles.xPlot_axes,'xtick',[],'ytick',[]);
xlabel(handles.xPlot_axes, '');
ylabel(handles.xPlot_axes, '');
set(handles.yPlot_axes,'xtick',[],'ytick',[]);
xlabel(handles.yPlot_axes, '');
ylabel(handles.yPlot_axes, '');
set(handles.zPlot_axes,'xtick',[],'ytick',[]);
xlabel(handles.zPlot_axes, '');
ylabel(handles.zPlot_axes, '');

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
b = tData(n,:) >= timeF & tData(n,:) <= timeL;
finder = find(b);
if isempty(finder)
    ClearAxes(handles);
    msgbox('No Data Found!', 'No Data', 'error');
    return;
end
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
finder = find(b);
if isempty(finder)
    ClearAxes(handles);
    msgbox('No Data Found!', 'No Data', 'error');
    return;
end
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

% --- Executes on button press in BTN_Connect.
%-------------------------------------------------------------------------%
function BTN_Connect_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
%-------------------------------------------------------------------------%
global node;
global nodeDisplay;
global statusDisplay;
set(handles.BTN_Connect, 'Visible', 'off');
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
    set(handles.BTN_Connect, 'Visible', 'on');
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
for n = 1:1 % Can be changed depending on how many should be initialized
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
    set(handles.BTN_Reload, 'Visible', 'on');
    set(handles.BTN_FreqPlot, 'Visible', 'on');
    set(handles.BTN_SensorLeft, 'Visible', 'on');
    set(handles.BTN_SensorRight, 'Visible', 'on');
    set(handles.BTN_ClearChannels, 'Visible', 'on');
    set(handles.TBB_Save, 'Visible', 'on');
    %Plot default node
    TimePlot(node, handles);
end

% --- Executes on button press in BTN_Reload.
%-------------------------------------------------------------------------%
function BTN_Reload_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
%-------------------------------------------------------------------------%
global node;
UpdateData(node, handles);
RefreshPlot(handles);


% --- Executes on button press in BTN_TimePlot.
%-------------------------------------------------------------------------%
function BTN_TimePlot_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
%-------------------------------------------------------------------------%
global plotType;
global node;
%GUI Handles manipulation
set(handles.BTN_TimePlot, 'Visible', 'off');
set(handles.BTN_FreqPlot, 'Visible', 'on');
%If the plotting is paused and the plot type is in frequency domain
if (plotType)
    TimePlot(node, handles);
    plotType = 0;
end


% --- Executes on button press in BTN_FreqPlot.
%-------------------------------------------------------------------------%
function BTN_FreqPlot_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
%-------------------------------------------------------------------------%
global plotType;
global node;
%GUI Handles manipulation
set(handles.BTN_TimePlot, 'Visible', 'on');
set(handles.BTN_FreqPlot, 'Visible', 'off');
%If the plot type is in time domain
if (~plotType)
    FreqPlot(node, handles);
    plotType = 1;
end


% --- Executes on button press in BTN_Refresh.
%-------------------------------------------------------------------------%
function BTN_Refresh_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
%-------------------------------------------------------------------------%
RefreshPlot(handles);

% --- Executes on button press in BTN_SensorLeft.
%-------------------------------------------------------------------------%
function BTN_SensorLeft_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
%-------------------------------------------------------------------------%
global node;
global nodeDisplay;
node = node - 1;
if node < 1
    node = 3;
end
set(nodeDisplay, 'String', horzcat('Node ', int2str(node)));
RefreshPlot(handles);

% --- Executes on button press in BTN_SensorRight.
%-------------------------------------------------------------------------%
function BTN_SensorRight_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
%-------------------------------------------------------------------------%
global node;
global nodeDisplay;
node = node + 1;
if node > 3
    node = 1;
end
set(nodeDisplay, 'String', horzcat('Node ', int2str(node)));
RefreshPlot(handles);

%-------------------------------------------------------------------------%
function SaveTimeConfig(varargin)
%-------------------------------------------------------------------------%
global timeConfig;
global timeF;
global timeL;
global gmt;
timeF = datenum(get(timeConfig.in_from, 'String'));
timeL = datenum(get(timeConfig.in_to, 'String'));
gmt = str2double(get(timeConfig.in_gmt, 'String'));
save('Configuration.mat', 'timeF');
save('Configuration.mat', 'timeL', '-append');
save('Configuration.mat', 'gmt', '-append');
close(timeConfig.fig);

%-------------------------------------------------------------------------%
function SaveThingSpeakConfig(varargin)
%-------------------------------------------------------------------------%
global thingspeakConfig;
global channel;
global writeAPI;
for n = 1:3
    for i = 1:15
        channel(n,i) = str2double(get(thingspeakConfig.ch(n,i), 'String'));
        writeAPI(n,i) = str2double(get(thingspeakConfig.api(n,i), 'String'));
    end
end
save('Configuration.mat', 'channel', '-append');
save('Configuration.mat', 'writeAPI', '-append');
close(thingspeakConfig.fig);

% --- Executes on button press in TBB_Save_ClickedCallback.
%-------------------------------------------------------------------------%
function TBB_Save_ClickedCallback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
%-------------------------------------------------------------------------%
global tData; %#ok<NUSED>
global xData; %#ok<NUSED>
global yData; %#ok<NUSED>
global zData; %#ok<NUSED>
[file,path] = uiputfile('*.mat','Save Data');
complete = horzcat(path, file);
if complete(1) ~= 0 && complete(2) ~= 0
    save(complete, 'tData');
    save(complete, 'xData', '-append');
    save(complete, 'yData', '-append');
    save(complete, 'zData', '-append');
end


% --- Executes on button press in TBB_Load_ClickedCallback.
%-------------------------------------------------------------------------%
function TBB_Load_ClickedCallback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
%-------------------------------------------------------------------------%
global tData;
global xData;
global yData;
global zData;
global node;
global nodeDisplay;
global statusDisplay;
[file,path] = uigetfile('*.mat','Load Data');
complete = horzcat(path, file);
if complete(1) ~= 0 && complete(2) ~= 0
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
        set(handles.BTN_FreqPlot, 'Visible', 'on');
        set(handles.BTN_SensorLeft, 'Visible', 'on');
        set(handles.BTN_SensorRight, 'Visible', 'on');
        set(handles.TBB_Save, 'Visible', 'on');
        set(handles.BTN_ClearChannels, 'Visible', 'on');
    catch
        tData = zeros(3, 1);
        xData = zeros(3, 1);
        yData = zeros(3, 1);
        zData = zeros(3, 1);
    end
    set(statusDisplay, 'String', horzcat('Loaded ', file), 'Fontsize', 12 - length(file)/6);
    RefreshPlot(handles);
end

% --- Executes on button press in TBB_TimeConfig_ClickedCallback.
%-------------------------------------------------------------------------%
function TBB_TimeConfig_ClickedCallback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
%-------------------------------------------------------------------------%
global timeConfig;
global timeF;
global timeL;
global gmt;

timeConfig.fig = figure(...
    'Position',[300 500 700 150],...
    'MenuBar', 'None',...
    'Numbertitle','Off',...
    'Name','Time Settings',...
    'Resize','off');
timeConfig.save = uicontrol(...
    'Style','Push',...
    'Position',[15 15 670 40],...
    'Fontsize',12,...
    'String','Save',...
    'Callback',@SaveTimeConfig);
timeConfig.panel_timeFrame = uipanel(...
    'Title', 'Time Frame',...
    'Units', 'Pixels',...;
    'FontSize', 14,...
    'TitlePosition', 'centertop',...
    'Position', [20 60 550 90]);
timeConfig.stc_from = uicontrol(...
    'Style', 'Text',...
    'Position', [25 75 50 30],...
    'Fontsize', 13,...
    'String', 'From: ');
timeConfig.stc_to = uicontrol(...
    'Style', 'Text',...
    'Position', [300 75 60 30],...
    'Fontsize', 13,...
    'String', 'To: ');
timeConfig.stc_gmt = uicontrol(...
    'Style', 'Text',...
    'Position', [575 75 50 30],...
    'Fontsize', 13,...
    'String', 'GMT:');
timeConfig.in_from = uicontrol(...
    'Style', 'Edit',...
    'Position', [75 80 200 30],...
    'Fontsize', 13,...
    'String', datestr(timeF));
timeConfig.in_to = uicontrol(...
    'Style', 'Edit',...
    'Position', [350 80 200 30],...
    'Fontsize', 13,...
    'String', datestr(timeL));
timeConfig.in_gmt = uicontrol(...
    'Style', 'Edit',...
    'Position', [625 80 50 30],...
    'Fontsize', 13,...
    'String', int2str(gmt));

% --- Executes on button press in TBB_ThingSpeakConfig_ClickedCallback.
%-------------------------------------------------------------------------%
function TBB_ThingSpeakConfig_ClickedCallback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
%-------------------------------------------------------------------------%
global thingspeakConfig;
global channel;
global writeAPI;

thingspeakConfig.fig = figure(...
    'Position',[300 60 710 675],...
    'MenuBar', 'None',...
    'Numbertitle','Off',...
    'Name','ThingSpeak Settings',...
    'Resize','off');
thingspeakConfig.save = uicontrol(...
    'Style','Push',...
    'Position',[30 5 655 30],...
    'Fontsize',12,...
    'String','Save',...
    'Callback',@SaveThingSpeakConfig);
for n = 1:3
    thingspeakConfig.panel_node(n) = uipanel(...
        'Title', horzcat('Node ', num2str(n)),...
        'Units', 'Pixels',...;
        'FontSize', 14,...
        'TitlePosition', 'centertop',...
        'Position', [(5 + 235*(n-1)) 37.5 225 640]);
    thingspeakConfig.stc_channel(n) = uicontrol(...
        'Style', 'Text',...
        'Position', [(50 + 235*(n-1)) 622.5 150 30],...
        'Fontsize', 12,...
        'String', 'Channels');
    thingspeakConfig.stc_apiKeys(n) = uicontrol(...
        'Style', 'Text',...
        'Position', [(50 + 235*(n-1)) 315 150 30],...
        'Fontsize', 12,...
        'String', 'Write API Keys');
    for i = 1:15
        if i > 8
            thingspeakConfig.ch(n,i) = uicontrol(...
                'Style', 'Edit',...
                'Position', [(120 + 235*(n - 1)) (910 - 35*i) 100 30],...
                'Fontsize', 12,...
                'String', num2str(channel(n,i)));
            thingspeakConfig.api(n,i) = uicontrol(...
                'Style', 'Edit',...
                'Position', [(120 + 235*(n - 1)) (605 - 35*i) 100 30],...
                'Fontsize', 12,...
                'String', num2str(writeAPI(n,i)));
        else
            thingspeakConfig.ch(n,i) = uicontrol(...
                'Style', 'Edit',...
                'Position', [(15 + 235*(n - 1)) (630 - 35*i) 100 30],...
                'Fontsize', 12,...
                'String', num2str(channel(n,i)));
            thingspeakConfig.api(n,i) = uicontrol(...
                'Style', 'Edit',...
                'Position', [(15 + 235*(n - 1)) (325 - 35*i) 100 30],...
                'Fontsize', 12,...
                'String', num2str(writeAPI(n,i)));                   
        end
    end
end

%-------------------------------------------------------------------------%
function ClearChannels(varargin)
%-------------------------------------------------------------------------%
global node;
global confirm;
global writeAPI;
close(confirm.fig);
wb = waitbar(0, horzcat('Clearing Node ', num2str(node), ' channels'));
for i=1:15
    pause(0.25);
    percent = i/15;
    waitbar(percent, wb, horzcat('Clearing Node ', num2str(node), ' channels (', num2str(100*percent, 3), '%)'));
end
pause(0.1);
if ishandle(wb)
    delete(wb);
end

%-------------------------------------------------------------------------%
function NotClearChannels(varargin)
%-------------------------------------------------------------------------%
global confirm;
close(confirm.fig);

% --- Executes on button press in BTN_ClearChannels.
%-------------------------------------------------------------------------%
function BTN_ClearChannels_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
%-------------------------------------------------------------------------%
global node;
global confirm;
beep;
confirm.fig = figure(...
    'Position',[500 400 300 150],...
    'MenuBar', 'None',...
    'Numbertitle','Off',...
    'Name','Clear Channel Data',...
    'Resize','off');
confirm.stc_question = uicontrol(...
    'Style', 'Text',...
    'Position', [25 0 250 125],...
    'Fontsize', 12,...
    'String', horzcat('Are you sure you want to clear all channel data for Node ', num2str(node), '?'));
confirm.yes = uicontrol(...
    'Style','Push',...
    'Position',[15 15 125 40],...
    'Fontsize',12,...
    'String','Yes',...
    'Callback',@ClearChannels);
confirm.no = uicontrol(...
    'Style','Push',...
    'Position',[160 15 125 40],...
    'Fontsize',12,...
    'String','No',...
    'Callback',@NotClearChannels);


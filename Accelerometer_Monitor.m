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
% - Make channel clearing autonomous instead of redirecting to ThingSpeak
% login page.
% - Pressing 'Enter' in settings should be equivalent to clicking Save
% button.

% Last Modified by GUIDE v2.5 12-Feb-2017 02:45:39

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
set(handles.TBB_Save, 'Enable', 'off');
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


%-------------------------------------------------------------------------%
function FigureEnable(handles, flag)
%-------------------------------------------------------------------------%
global statusDisplay;
set(handles.BTN_Connect, 'Enable', flag);
set(handles.BTN_Reload, 'Enable', flag);
set(handles.BTN_Refresh, 'Enable', flag);
set(handles.BTN_TimePlot, 'Enable', flag);
set(handles.BTN_FreqPlot, 'Enable', flag);
set(handles.BTN_SensorLeft, 'Enable', flag);
set(handles.BTN_SensorRight, 'Enable', flag);
set(handles.BTN_ClearChannels, 'Enable', flag);
set(handles.TBB_Load, 'Enable', flag);
set(handles.TBB_ZoomIn, 'Enable', flag);
set(handles.TBB_ZoomOut, 'Enable', flag);
set(handles.TBB_Pan, 'Enable', flag);
set(handles.TBB_DataCursor, 'Enable', flag);
set(handles.TBB_TimeConfig, 'Enable', flag);
set(handles.TBB_ThingSpeakConfig, 'Enable', flag);
if ~strcmp(get(statusDisplay, 'String'), 'No connection')
    set(handles.TBB_Save, 'Enable', flag);
end

%-------------------------------------------------------------------------%
function CloseWindow(srt, evt, handles) %#ok<INUSL>
%-------------------------------------------------------------------------%
FigureEnable(handles, 'on');
delete(srt);

%-------------------------------------------------------------------------%
function ClearAxes(handles)
%-------------------------------------------------------------------------%
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
ClearAxes(handles);
%Time plot  
b = tData(n,:) >= timeF & tData(n,:) <= timeL;
finder = find(b);
if isempty(finder)
    errordlg('No Data Found!', 'No Data', 'modal');
    return;
end
f = finder(1);
l = finder(end);
xmin = min(xData(n,f:l))/255;
ymin = min(yData(n,f:l))/255;
zmin = min(zData(n,f:l))/255;
xmax = max(xData(n,f:l))/255;
ymax = max(yData(n,f:l))/255;
zmax = max(zData(n,f:l))/255;
tdiff = max(tData(n,l)) - min(tData(n,f));
xdiff = xmax - xmin;
ydiff = ymax - ymin;
zdiff = zmax - zmin;
plot(handles.xPlot_axes, tData(n,f:l), xData(n,f:l)/255, 'r');
plot(handles.yPlot_axes, tData(n,f:l), yData(n,f:l)/255, 'g');
plot(handles.zPlot_axes, tData(n,f:l), zData(n,f:l)/255, 'b');
xlim(handles.xPlot_axes, [tData(n,f) tData(n,l)]);
ylim(handles.xPlot_axes, [xmin-0.2*xdiff xmax+0.2*xdiff]);
xlim(handles.yPlot_axes, [tData(n,f) tData(n,l)]);
ylim(handles.yPlot_axes, [ymin-0.2*ydiff ymax+0.2*ydiff]);
xlim(handles.zPlot_axes, [tData(n,f) tData(n,l)]);
ylim(handles.zPlot_axes, [zmin-0.2*zdiff zmax+0.2*zdiff]);
%Change time limits based on min and max tData
%Less than 3 seconds
if tdiff < 3*1.157412771135569e-05
    d = datestr(tData(n,f), 'mmm-dd');
    datetick(handles.xPlot_axes, 'x','HH:MM:SS.FFF', 'keepticks');
    datetick(handles.yPlot_axes, 'x','HH:MM:SS.FFF', 'keepticks');
    datetick(handles.zPlot_axes, 'x','HH:MM:SS.FFF', 'keepticks');
    xlabel(handles.xPlot_axes, horzcat(d, ' Time (HH:MM:SS.FFF)'));
    xlabel(handles.yPlot_axes, horzcat(d, ' Time (HH:MM:SS.FFF)'));
    xlabel(handles.zPlot_axes, horzcat(d, ' Time (HH:MM:SS.FFF)'));
elseif tdiff < 1
    d = datestr(tData(n,f), 'mmm-dd');
    datetick(handles.xPlot_axes, 'x','HH:MM:SS', 'keepticks');
    datetick(handles.yPlot_axes, 'x','HH:MM:SS', 'keepticks');
    datetick(handles.zPlot_axes, 'x','HH:MM:SS', 'keepticks');
    xlabel(handles.xPlot_axes, horzcat(d, ' Time (HH:MM:SS)'));
    xlabel(handles.yPlot_axes, horzcat(d, ' Time (HH:MM:SS)')); 
    xlabel(handles.zPlot_axes, horzcat(d, ' Time (HH:MM:SS)'));
elseif tdiff < 2
    datetick(handles.xPlot_axes, 'x','mmm.dd HH:MM', 'keepticks');
    datetick(handles.yPlot_axes, 'x','mmm.dd HH:MM', 'keepticks');
    datetick(handles.zPlot_axes, 'x','mmm.dd HH:MM', 'keepticks');
    xlabel(handles.xPlot_axes, 'Time (Month.Day HH:MM)');
    xlabel(handles.yPlot_axes, 'Time (Month.Day HH:MM)');  
    xlabel(handles.zPlot_axes, 'Time (Month.Day HH:MM)');
else
    datetick(handles.xPlot_axes, 'x','mmm-dd', 'keepticks');
    datetick(handles.yPlot_axes, 'x','mmm-dd', 'keepticks');
    datetick(handles.zPlot_axes, 'x','mmm-dd', 'keepticks');
    xlabel(handles.xPlot_axes, 'Time (Month-Day)');
    xlabel(handles.yPlot_axes, 'Time (Month-Day)');  
    xlabel(handles.zPlot_axes, 'Time (Month-Day)');
end
ylabel(handles.xPlot_axes, 'Magnitude (g)');
ylabel(handles.yPlot_axes, 'Magnitude (g)');
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
ClearAxes(handles);
%Time plot  
b = tData(n,:) >= timeF & tData(n,:) <= timeL;
finder = find(b);
if isempty(finder)
    errordlg('No Data Found!', 'No Data', 'modal');
    return;
end
f = finder(1);
l = finder(end);
L = 2^nextpow2(length(finder));
freq = 50*(0:L/2)/L;
peaksNum = 6;
%X
Y = fft((xData(n,f:l) - mean(xData(n,f:l)))/255, L);
P2 = abs(Y/L);
P1 = P2(1:int64(L/2 - 0.5) + 1);
P1(2:end-1) = 2*P1(2:end-1);
try
    [pks, locs] = findpeaks(P1, freq, 'SortStr', 'descend');
    last = min(peaksNum, length(pks));
    plot(handles.xPlot_axes, freq, P1, 'r');
    hold(handles.xPlot_axes, 'on')
    for i = 1:last
        text(handles.xPlot_axes, locs(i), pks(i), horzcat('  P', num2str(i)), 'FontSize', 8, 'Clipping', 'on');
        plot(handles.xPlot_axes, locs(i), pks(i), '*');
    end
    hold(handles.xPlot_axes, 'off')
    xlim(handles.xPlot_axes, [0 25]);
    ylim(handles.xPlot_axes, [0 1.1*pks(1)]);
catch
    errordlg('Too much ''X'' data! Lower the Time Frame!', 'Data overload', 'modal');
end
%Y
Y = fft((yData(n,f:l) - mean(yData(n,f:l)))/255, L);
P2 = abs(Y/L);
P1 = P2(1:int64(L/2 - 0.5) + 1);
P1(2:end-1) = 2*P1(2:end-1);
try
    [pks, locs] = findpeaks(P1, freq, 'SortStr', 'descend');
    last = min(peaksNum, length(pks));
    plot(handles.yPlot_axes, freq, P1, 'g');
    hold(handles.yPlot_axes, 'on')
    for i = 1:last
        text(handles.yPlot_axes, locs(i), pks(i), horzcat('  P', num2str(i)), 'FontSize', 8, 'Clipping', 'on');
        plot(handles.yPlot_axes, locs(i), pks(i), '*');
    end
    hold(handles.yPlot_axes, 'off')
    xlim(handles.yPlot_axes, [0 25]);
    ylim(handles.yPlot_axes, [0 1.1*pks(1)]);
catch
    errordlg('Too much ''Y'' data! Lower the Time Frame!', 'Data overload', 'modal');
end
%Z
Y = fft((zData(n,f:l) - mean(zData(n,f:l)))/255, L);
P2 = abs(Y/L);
P1 = P2(1:int64(L/2 - 0.5) + 1);
P1(2:end-1) = 2*P1(2:end-1);
try
    [pks, locs] = findpeaks(P1, freq, 'SortStr', 'descend');
    last = min(peaksNum, length(pks));
    plot(handles.zPlot_axes, freq, P1, 'b');
    hold(handles.zPlot_axes, 'on')
    for i = 1:last
        text(handles.zPlot_axes, locs(i), pks(i), horzcat('  P', num2str(i)), 'FontSize', 8, 'Clipping', 'on');
        plot(handles.zPlot_axes, locs(i), pks(i), '*');
    end
    hold(handles.zPlot_axes, 'off')
    xlim(handles.zPlot_axes, [0 25]);
    ylim(handles.zPlot_axes, [0 1.1*pks(1)]);
catch
    errordlg('Too much ''Z'' data! Lower the Time Frame!', 'Data overload', 'modal');
end

%-------------------------------------
set(handles.xPlot_axes, 'XGrid', 'on');
set(handles.xPlot_axes, 'YGrid', 'on');
set(handles.yPlot_axes, 'XGrid', 'on');
set(handles.yPlot_axes, 'YGrid', 'on');
set(handles.zPlot_axes, 'XGrid', 'on');
set(handles.zPlot_axes, 'YGrid', 'on');
xlabel(handles.xPlot_axes, 'Frequency (Hz)');
ylabel(handles.xPlot_axes, 'Magnitude (g)');
xlabel(handles.yPlot_axes, 'Frequency (Hz)');
ylabel(handles.yPlot_axes, 'Magnitude (g)');
xlabel(handles.zPlot_axes, 'Frequency (Hz)');
ylabel(handles.zPlot_axes, 'Magnitude (g)');
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
x = 0;
set(statusDisplay, 'String', 'Downloading...', 'Fontsize', 12);
wb = waitbar(0, horzcat('Downloading Data for Node ', int2str(n), '(0.00%)'), 'WindowStyle', 'modal');

oldest = zeros(1,15);   %oldest time per channel
pointer = zeros(1,15);  %points to the current feeds index per channel
index = zeros(1,3);     %latest data index for each node
oldestAll = now;        %oldest time in all channels
oldestIndex = 1;        %index of oldest time in all channels

ch = 15;
for i = 1:ch
    pause(0.01);    % Frees some time to process closed handles.mainFigure
    if ~ishandle(handles.mainFigure)
        return;
    end
    checker = 5;
    while(true)
        pause(0.01);    % Frees some time to process closed handles.mainFigure
        url = horzcat('http://api.thingspeak.com/channels/', int2str(channel(n,i)), '/feed.json');
        try
            s(i) = webread(url); %#ok<AGROW>
            break;
        catch
            disp(horzcat('Retrying connection to ', url));
            if ~ishandle(handles.mainFigure)
                return;
            end
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
            errordlg(horzcat('Cannot connect to ThingSpeak Channel: ', int2str(channel(n, i))), 'Connection Timeout', 'modal');
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
wb = waitbar(0, 'Processing Data (0.00%)', 'WindowStyle', 'modal');
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
pause(0.01);    % Frees some time to process closed handles.mainFigure
if ~ishandle(handles.mainFigure)
    return;
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
FigureEnable(handles, 'off');
%Status Bar
counter = 0;
tf = false;
%Check internet connection
set(statusDisplay, 'String', 'Connecting...', 'Fontsize', 12);
wb = waitbar(0, 'Connecting to ThingSpeak.com', 'WindowStyle', 'modal');
while(~tf && counter < 5)
    try
        url = java.net.InetAddress.getByName('api.thingspeak.com'); %#ok<NASGU>
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
    FigureEnable(handles, 'on');
    delete(wb);
    %clear plot areas
    cla(handles.xPlot_axes);
    cla(handles.yPlot_axes);
    cla(handles.zPlot_axes);
    set(handles.xPlot_axes,'xtick',[],'ytick',[]);
    set(handles.yPlot_axes,'xtick',[],'ytick',[]);
    set(handles.zPlot_axes,'xtick',[],'ytick',[]);
    set(statusDisplay, 'String', 'No Connection', 'Fontsize', 12);
    errordlg('Cannot connect to ThingSpeak Server', 'Connection Timeout', 'modal');
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
    FigureEnable(handles, 'on');
    %Default node
    node = 1; 
    %Static text handles
    set(nodeDisplay, 'Visible', 'on');
    set(nodeDisplay, 'String', 'Node 1');

    %GUI Handles manipulation
    set(handles.BTN_Connect, 'Visible', 'off');
    set(handles.BTN_Reload, 'Visible', 'on');
    set(handles.BTN_FreqPlot, 'Visible', 'on');
    set(handles.BTN_SensorLeft, 'Visible', 'on');
    set(handles.BTN_SensorRight, 'Visible', 'on');
    set(handles.BTN_ClearChannels, 'Visible', 'on');
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
global statusDisplay;
%GUI Handles manipulation
s = get(statusDisplay, 'String');
size = get(statusDisplay, 'FontSize');
set(statusDisplay, 'String', 'Busy...', 'FontSize', 13);
pause(0.01);
set(handles.BTN_TimePlot, 'Visible', 'off');
set(handles.BTN_FreqPlot, 'Visible', 'on');
%If the plotting is paused and the plot type is in frequency domain
if (plotType)
    TimePlot(node, handles);
    plotType = 0;
end
set(statusDisplay, 'String', s, 'FontSize', size);

% --- Executes on button press in BTN_FreqPlot.
%-------------------------------------------------------------------------%
function BTN_FreqPlot_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
%-------------------------------------------------------------------------%
global plotType;
global node;
global statusDisplay;
%GUI Handles manipulation
s = get(statusDisplay, 'String');
size = get(statusDisplay, 'FontSize');
set(statusDisplay, 'String', 'Busy...', 'FontSize', 13);
pause(0.01);
set(handles.BTN_TimePlot, 'Visible', 'on');
set(handles.BTN_FreqPlot, 'Visible', 'off');
%If the plot type is in time domain
if (~plotType)
    FreqPlot(node, handles);
    plotType = 1;
end
set(statusDisplay, 'String', s, 'FontSize', size);

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
function SaveTimeConfig(srt, evt, handles) %#ok<INUSL>
%-------------------------------------------------------------------------%
global timeConfig;
global timeF;
global timeL;
global gmt;
global channel; %#ok<NUSED>
timeF = datenum(get(timeConfig.in_from, 'String'));
timeL = datenum(get(timeConfig.in_to, 'String'));
gmt = str2double(get(timeConfig.in_gmt, 'String'));
save('Configuration.mat', 'timeF');
save('Configuration.mat', 'timeL', '-append');
save('Configuration.mat', 'gmt', '-append');
save('Configuration.mat', 'channel', '-append');
RefreshPlot(handles);
close(timeConfig.fig);

%-------------------------------------------------------------------------%
function SaveThingSpeakConfig(srt, evt, handles) %#ok<INUSL>
%-------------------------------------------------------------------------%
global thingspeakConfig;
global timeF; %#ok<NUSED>
global timeL; %#ok<NUSED>
global gmt; %#ok<NUSED>
global channel;
for n = 1:3
    for i = 1:15
        channel(n,i) = str2double(get(thingspeakConfig.ch(n,i), 'String'));
    end
end
save('Configuration.mat', 'timeF');
save('Configuration.mat', 'timeL', '-append');
save('Configuration.mat', 'gmt', '-append');
save('Configuration.mat', 'channel', '-append');
RefreshPlot(handles);
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
        set(handles.TBB_Save, 'Enable', 'on');
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
function TBB_TimeConfig_ClickedCallback(hObject, eventdata, handles) %#ok<,DEFNU>
%-------------------------------------------------------------------------%
global timeConfig;
global timeF;
global timeL;
global gmt;
if gmt >= 0
    sign = '+';
else
    sign = '';
end
FigureEnable(handles, 'off');
timeConfig.fig = figure(...
    'Position',[300 585 700 150],...
    'MenuBar', 'None',...
    'Numbertitle','Off',...
    'Name','Time Settings',...
    'Resize','off',...
    'WindowStyle', 'modal',...
    'CloseRequestFcn', {@CloseWindow, handles});
timeConfig.save = uicontrol(...
    'Style','Push',...
    'Position',[15 15 670 40],...
    'Fontsize',12,...
    'String','Save',...
    'Callback',{@SaveTimeConfig, handles});
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
    'String', horzcat(sign, int2str(gmt)));

% --- Executes on button press in TBB_ThingSpeakConfig_ClickedCallback.
%-------------------------------------------------------------------------%
function TBB_ThingSpeakConfig_ClickedCallback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
%-------------------------------------------------------------------------%
global thingspeakConfig;
global channel;
FigureEnable(handles, 'off');
thingspeakConfig.fig = figure(...
    'Position',[300 360 710 375],...
    'MenuBar', 'None',...
    'Numbertitle','Off',...
    'Name','ThingSpeak Settings',...
    'Resize','off',...
    'WindowStyle', 'modal',...
    'CloseRequestFcn', {@CloseWindow, handles});
thingspeakConfig.save = uicontrol(...
    'Style','Push',...
    'Position',[30 5 655 40],...
    'Fontsize',12,...
    'String','Save',...
    'Callback',{@SaveThingSpeakConfig, handles});
for n = 1:3
    thingspeakConfig.panel_node(n) = uipanel(...
        'Title', horzcat('Node ', num2str(n), ' Channels'),...
        'Units', 'Pixels',...;
        'FontSize', 14,...
        'TitlePosition', 'centertop',...
        'Position', [(5 + 235*(n-1)) 50 225 320]);
    for i = 1:15
        if i > 8
            thingspeakConfig.ch(n,i) = uicontrol(...
                'Style', 'Edit',...
                'Position', [(120 + 235*(n - 1)) (620 - 35*i) 100 30],...
                'Fontsize', 12,...
                'String', num2str(channel(n,i)));
        else
            thingspeakConfig.ch(n,i) = uicontrol(...
                'Style', 'Edit',...
                'Position', [(15 + 235*(n - 1)) (340 - 35*i) 100 30],...
                'Fontsize', 12,...
                'String', num2str(channel(n,i)));                
        end
    end
end

%-------------------------------------------------------------------------%
function ClearChannels(srt, evt, flag) %#ok<INUSL>
%-------------------------------------------------------------------------%
global confirm;
close(confirm.fig);
if flag
    web('https://thingspeak.com/channels', '-browser');
end

% --- Executes on button press in BTN_ClearChannels.
%-------------------------------------------------------------------------%
function BTN_ClearChannels_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
%-------------------------------------------------------------------------%
global node;
global confirm;
FigureEnable(handles, 'off');
beep;
confirm.fig = figure(...
    'Position',[500 400 300 150],...
    'MenuBar', 'None',...
    'Numbertitle','Off',...
    'Name','Clear Channel Data',...
    'Resize','off',...
    'WindowStyle', 'modal',...
    'CloseRequestFcn', {@CloseWindow, handles});
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
    'Callback',{@ClearChannels, true});
confirm.no = uicontrol(...
    'Style','Push',...
    'Position',[160 15 125 40],...
    'Fontsize',12,...
    'String','No',...
    'Callback', {@ClearChannels, false});

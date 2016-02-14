function varargout = RealTime_Accelerometer_Monitor(varargin)
% REALTIME_ACCELEROMETER_MONITOR MATLAB code for RealTime_Accelerometer_Monitor.fig
%      REALTIME_ACCELEROMETER_MONITOR, by itself, creates a new REALTIME_ACCELEROMETER_MONITOR or raises the existing
%      singleton*.
%
%      H = REALTIME_ACCELEROMETER_MONITOR returns the handle to a new REALTIME_ACCELEROMETER_MONITOR or the handle to
%      the existing singleton*.
%
%      REALTIME_ACCELEROMETER_MONITOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in REALTIME_ACCELEROMETER_MONITOR.M with the given input arguments.
%
%      REALTIME_ACCELEROMETER_MONITOR('Property','Value',...) creates a new REALTIME_ACCELEROMETER_MONITOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before RealTime_Accelerometer_Monitor_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to RealTime_Accelerometer_Monitor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help RealTime_Accelerometer_Monitor

% Last Modified by GUIDE v2.5 14-Feb-2016 23:35:49

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @RealTime_Accelerometer_Monitor_OpeningFcn, ...
                   'gui_OutputFcn',  @RealTime_Accelerometer_Monitor_OutputFcn, ...
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



% --- Executes just before RealTime_Accelerometer_Monitor is made visible.
function RealTime_Accelerometer_Monitor_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to RealTime_Accelerometer_Monitor (see VARARGIN)
global t;
global plotType;
global pausePlot;
% Choose default command line output for RealTime_Accelerometer_Monitor
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes RealTime_Accelerometer_Monitor wait for user response (see UIRESUME)
% uiwait(handles.figure1);

%Timer Initialization
t = timer;
t.Period = 0.02;
t.TimerFcn = {@MainUpdate,hObject,handles};
t.ExecutionMode = 'fixedRate';
%GUI Handles Initial Properties
set(handles.xPlot_axes,'xtick',[],'ytick',[]);
set(handles.yPlot_axes,'xtick',[],'ytick',[]);
set(handles.zPlot_axes,'xtick',[],'ytick',[]);
set(handles.BTNDisconnect, 'Visible', 'off');
set(handles.BTNResumePlot, 'Visible', 'off');
set(handles.BTNPausePlot, 'Visible', 'off');
set(handles.BTNTimePlot, 'Visible', 'off');
set(handles.BTNFreqPlot, 'Visible', 'off');
%Initial plotting properties
plotType = 0;
pausePlot = 0;

%Initially create Log folder
if ~(exist('Log', 'file') == 7)
    mkdir('Log');
end

% --- Outputs from this function are returned to the command line.
function varargout = RealTime_Accelerometer_Monitor_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function serialPort_Callback(hObject, eventdata, handles)
% hObject    handle to serialPort (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of serialPort as text
%        str2double(get(hObject,'String')) returns contents of serialPort as a double


% --- Executes during object creation, after setting all properties.
function serialPort_CreateFcn(hObject, eventdata, handles)
% hObject    handle to serialPort (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% function SerialDataAvailable
% % --- Executes when serial data terminator is at the buffer
% global s;
% if (s.BytesAvailable > 0)
%     data = fscanf(s);
% end

function MainUpdate(obj,event,hObject,handles)
% System Core
global xData;
global index;
global time;
global plotType;   %0 for time domain, 1 for freq domain
global pausePlot;
global t;
global lastLog;     %index at time of when the last data logging.
global lastLogMinute;

%********************* OBTAINING DATA ***********************
%Update Time
time = [time now];
%Update Data
sec = second(now);
%new value, currently simulated, it should be taken from the sensor
newValue = sin(2*pi*2*sec) + sin(2*pi*3*sec) + sin(2*pi*sec);
xData = [xData newValue];
index = index + 1;

%********************** PLOTTING ***************************
if ~(pausePlot)
    if (plotType)
        %FFT
        nfft = 2^nextpow2(index);
        magnitude = fft(xData, nfft)/index;
        freq = (1/t.period)*linspace(0, 1, nfft/2 + 1)/2;
        %Frequency Plot
        plot(handles.xPlot_axes, freq, 2*abs(magnitude(1:nfft/2 + 1)), 'r');
        xlabel(handles.xPlot_axes, 'Frequency (Hz)');
        ylabel(handles.xPlot_axes, 'Magnitude');
    else
        %Time plot
        plot(handles.xPlot_axes, time, xData, 'r');
        datetick(handles.xPlot_axes, 'x','HH:MM:SS', 'keepticks');
        xlabel(handles.xPlot_axes, strcat('Time at ', {' '}, datestr(clock, 'dd-mmm-yyyy')));
        ylabel(handles.xPlot_axes, 'Magnitude');
    end
    drawnow;
end

%********************* DATA LOGGING ************************
currentMinute = minute(now);
if (~mod(currentMinute, 2) && currentMinute > lastLogMinute) %Log data every 2 minutes
    lastLogMinute = currentMinute;
    %Create a file and store Data(lastLog:index)
    logFile = fopen(strcat('Log\', datestr(time(lastLog), 'dd-mmm-yyyy HH.MM.SS'), '.log'), 'w+');
    fprintf(logFile, 'Accelerometer Sensor Data:\r\n%s\r\n', datestr(now, 'dd-mmm-yyyy'));
    fprintf(logFile, 'Time\t\tX-Axis\t\tY-Axis\t\tZ-Axis\r\n');
    for i = lastLog:index
        fprintf(logFile, '%s\t%f\r\n', datestr(time(i), 'HH:MM:SS.FFF'), xData(i));
    end
    fclose(logFile);

    lastLog = index;
end


%==========================================================================
%=========================== BUTTON CALLBACKS =============================
%==========================================================================

% --- Executes on button press in BTNConnect.
function BTNConnect_Callback(hObject, eventdata, handles)
% hObject    handle to BTNConnect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%global s;
global t; %timer
global index;
global xData;
global time;
global lastLog;
global lastLogMinute;
%Initialize variables in plotting
index = 1;
time = now;
lastLog = index;
lastLogMinute = minute(now);
xData = sin(second(now));

%GUI Handles manipulation
set(handles.BTNDisconnect, 'Visible', 'on');
set(handles.BTNConnect, 'Visible', 'off');
set(handles.BTNPausePlot, 'Visible', 'on');
set(handles.BTNFreqPlot, 'Visible', 'on');

%Status Bar
wb = waitbar(0, 'Connecting to Accelerometer device...');

%Serial IO
% s = serial(get(handles.serialPort, 'String'), 'BaudrRate', 9600);
% if (s.Status == 'closed')
%     s.BytesAvailableFcnMode = 'terminator';
%     s.BytesAvailableFcn = @SerialDataAvailable;
%     if (fopen(s) == 'closed')
%         msgbox('Serial Port failed to connect', 'Connection Failed', 'error');
%     else
%         waitbar(1, wb);
%     end
% end
delete(wb);
%Start the Single-thread periodic timer
start(t);

% --- Executes on button press in BTNDisconnect.
function BTNDisconnect_Callback(hObject, eventdata, handles)
% hObject    handle to BTNDisconnect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global t;
global index
global time;
global lastLog;
global xData;
stop(t);
%GUI Handles manipulation
set(handles.BTNDisconnect, 'Visible', 'off');
set(handles.BTNConnect, 'Visible', 'on');
%Serial IO
% global s;
% if (s.Status == 'open')
%     fclose(s);
% end
% delete(s);
% clear s;

%Log the remaining data
logFile = fopen(strcat('Log\', datestr(time(lastLog), 'dd-mmm-yyyy HH.MM.SS'), '.log'), 'w+');
fprintf(logFile, 'Accelerometer Sensor Data:\r\n%s\r\n', datestr(now, 'dd-mmm-yyyy'));
fprintf(logFile, 'Time\t\tX-Axis\t\tY-Axis\t\tZ-Axis\r\n');
for i = lastLog:index
    fprintf(logFile, '%s\t%f\r\n', datestr(time(i), 'HH:MM:SS.FFF'), xData(i));
end
fclose(logFile);



% --- Executes on button press in BTNTimePlot.
function BTNTimePlot_Callback(hObject, eventdata, handles)
% hObject    handle to BTNTimePlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global plotType;
global pausePlot;
global time;
global xData;
global indexAtPause;

%GUI Handles manipulation
set(handles.BTNTimePlot, 'Visible', 'off');
set(handles.BTNFreqPlot, 'Visible', 'on');

%If the plotting is paused and the plot type is in frequency domain
if (pausePlot && plotType)
    %Then update the axes
    plot(handles.xPlot_axes, time(1:indexAtPause), xData(1:indexAtPause), 'r');
    datetick(handles.xPlot_axes, 'x','HH:MM:SS', 'keepticks');
    xlabel(handles.xPlot_axes, strcat('Time at ', {' '}, datestr(clock, 'dd-mmm-yyyy')));
    ylabel(handles.xPlot_axes, 'Magnitude');
end
plotType = 0;

% --- Executes on button press in BTNFreqPlot.
function BTNFreqPlot_Callback(hObject, eventdata, handles)
% hObject    handle to BTNFreqPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global plotType;
global pausePlot;
global t;
global xData;
global indexAtPause;

%GUI Handles manipulation
set(handles.BTNTimePlot, 'Visible', 'on');
set(handles.BTNFreqPlot, 'Visible', 'off');

%If the plotting is paused and the plot type is in time domain
if (pausePlot && ~plotType)
    %Then update the axes
    nfft = 2^nextpow2(indexAtPause);
    magnitude = fft(xData(1:indexAtPause), nfft)/indexAtPause;
    freq = (1/t.period)*linspace(0, 1, nfft/2 + 1)/2;
    %Frequency Plot
    plot(handles.xPlot_axes, freq, 2*abs(magnitude(1:nfft/2 + 1)), 'r');
    xlabel(handles.xPlot_axes, 'Frequency (Hz)');
    ylabel(handles.xPlot_axes, 'Magnitude');
end
plotType = 1;

% --- Executes on button press in BTNPausePlot.
function BTNPausePlot_Callback(hObject, eventdata, handles)
% hObject    handle to BTNPausePlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global pausePlot;
global indexAtPause;
global index;

if ~(pausePlot)     %Only on the first click
    indexAtPause = index;
end
pausePlot = 1;
set(handles.BTNPausePlot, 'Visible', 'off');
set(handles.BTNResumePlot, 'Visible', 'on');


% --- Executes on button press in BTNResumePlot.
function BTNResumePlot_Callback(hObject, eventdata, handles)
% hObject    handle to BTNResumePlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global pausePlot;
pausePlot = 0;
set(handles.BTNPausePlot, 'Visible', 'on');
set(handles.BTNResumePlot, 'Visible', 'off');


% --- Executes on button press in BTNBrowse.
function BTNBrowse_Callback(hObject, eventdata, handles)
% hObject    handle to BTNBrowse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global index;
global indexAtPause;
global time;
global xData;
global plotType;
global pausePlot;
global t;
pausePlot = 1;
%If not connected, then proceed, else show error message
[filename pathname] = uigetfile({'*.log'},'Browse Log File');
logFile = fopen(strcat(pathname, filename), 'r');
tline = fgets(logFile);
lineCtr = 1;
index = 1;
while ischar(tline)
    dataStr = cell2mat(cellstr(tline));
    if (lineCtr == 2)
        try
            dateArray = datevec(dataStr);
        catch
            msgbox('Cannot read log date', 'Read Error', 'error');
            break;
        end
    elseif (lineCtr >= 4)
        splitLine = regexp(dataStr, '\s', 'split');
        timeStr = regexp(cell2mat(splitLine(1)), '[:]', 'split');
        try
            timeValues = str2double(timeStr);
            xData(index) = str2double(splitLine(2));
        catch
            msgbox('Cannot read log time', 'Read error', 'error');
            break;
        end
        %Add the time value to the dateArray
        dateArray = [dateArray(1:3) timeValues];
        time(index) = datenum(dateArray);
        index = index + 1;
    end
    %update the new tLine
    tline = fgets(logFile);
    lineCtr = lineCtr + 1;
end
fclose(logFile);
indexAtPause = index - 1;

%GUI Handles Manipulation
set(handles.BTNFreqPlot, 'Visible', 'on');

%Plot
if (plotType)
    %FFT
    nfft = 2^nextpow2(index);
    magnitude = fft(xData, nfft)/index;
    freq = (1/t.period)*linspace(0, 1, nfft/2 + 1)/2;
    %Frequency Plot
    plot(handles.xPlot_axes, freq, 2*abs(magnitude(1:nfft/2 + 1)), 'r');
    xlabel(handles.xPlot_axes, 'Frequency (Hz)');
    ylabel(handles.xPlot_axes, 'Magnitude');
else
    %Time plot
    plot(handles.xPlot_axes, time, xData, 'r');
    datetick(handles.xPlot_axes, 'x','HH:MM:SS', 'keepticks');
    xlabel(handles.xPlot_axes, strcat('Time at ', {' '}, datestr(clock, 'dd-mmm-yyyy')));
    ylabel(handles.xPlot_axes, 'Magnitude');
end
drawnow;
%else throw an error message
%msgbox('Cannot browse file on active connection!', 'Browsing Failed','error');

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

% Last Modified by GUIDE v2.5 13-Feb-2016 23:16:08

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

% Choose default command line output for RealTime_Accelerometer_Monitor
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes RealTime_Accelerometer_Monitor wait for user response (see UIRESUME)
% uiwait(handles.figure1);

t = timer;
t.Period = 0.1;
t.TimerFcn = {@MainUpdate,hObject,handles};
t.ExecutionMode = 'fixedRate';
%GUI Axes properties
set(handles.xPlot_axes,'xtick',[],'ytick',[]);
set(handles.yPlot_axes,'xtick',[],'ytick',[]);
set(handles.zPlot_axes,'xtick',[],'ytick',[]);

% --- Outputs from this function are returned to the command line.
function varargout = RealTime_Accelerometer_Monitor_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in BTNTimePlot.
function BTNTimePlot_Callback(hObject, eventdata, handles)
% hObject    handle to BTNTimePlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in BTNFreqPlot.
function BTNFreqPlot_Callback(hObject, eventdata, handles)
% hObject    handle to BTNFreqPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global frequency;



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

%Update Time
time = [time now];
%Update Data
xData = [xData sin(index)];
plot(handles.xPlot_axes, time, xData);
datetick(handles.xPlot_axes, 'x','HH:MM:SS', 'keepticks');
index = index + 1
drawnow;
msg='drawing ends'


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
%Initialize variables in plotting
index = 1;
time = now;
xData = 0;
%Start the Single-thread periodic timer
start(t);


%Serial IO
% s = serial(get(handles.serialPort, 'String'), 'BaudrRate', 9600);
% if (s.Status == 'closed')
%     s.BytesAvailableFcnMode = 'terminator';
%     s.BytesAvailableFcn = @SerialDataAvailable;
%     if (fopen(s) == 'closed')
%         msgbox('Serial Port failed to connect');
%     end
% end


% --- Executes on button press in BTNDisconnect.
function BTNDisconnect_Callback(hObject, eventdata, handles)
% hObject    handle to BTNDisconnect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global t;
%Serial IO
% global s;
% if (s.Status == 'open')
%     fclose(s);
% end
% delete(s);
% clear s;
stop(t);
msg='timer stopped'
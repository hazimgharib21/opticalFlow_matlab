function varargout = gui(varargin)
% GUI MATLAB code for gui.fig
%      GUI, by itself, creates a new GUI or raises the existing
%      singleton*.
%
%      H = GUI returns the handle to a new GUI or the handle to
%      the existing singleton*.
%
%      GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI.M with the given input arguments.
%
%      GUI('Property','Value',...) creates a new GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui

% Last Modified by GUIDE v2.5 17-Aug-2018 19:51:17

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_OutputFcn, ...
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

addpath('mex');

% Set global variables


% --- Executes just before gui is made visible.
function gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui (see VARARGIN)

% Choose default command line output for gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in loadVideoFileButton.
function loadVideoFileButton_Callback(hObject, eventdata, handles)
% hObject    handle to loadVideoFileButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    runOpticalFlow(hObject, eventdata, handles, false);


% --- Executes on button press in applyButton.
function applyButton_Callback(hObject, eventdata, handles)
% hObject    handle to applyButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in opticalFlowButton.
function opticalFlowButton_Callback(hObject, eventdata, handles)
% hObject    handle to opticalFlowButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    set(handles.logText1, 'string', 'User close windows');
    

function runOpticalFlow(hObject, eventdata, handles, online)

    resizeScl = str2double(get(handles.resizeScale, 'string'));
    flowThresh = str2double(get(handles.flowThreshold, 'string'));
    global alpha;
    global ratio;
    global minWidth;
    global nOuterFPIterations;
    global nInnerFPIterations;
    global nSORIterations;
    warning = false;
    fileNum = 0;
    
    alpha = 0.012;
    ratio = 0.75;
    minWidth = 20;
    nOuterFPIterations = 7;
    nInnerFPIterations = 1;
    nSORIterations = 30;
    
    para = [alpha,ratio,minWidth,nOuterFPIterations,nInnerFPIterations,nSORIterations];
    global vidIn;
    if(~online)
        set(handles.logText1, 'string', 'Select a video file');
        [file,path] = uigetfile('E:\Cloud\Google Drive\projectMdmAzlin\*.avi;*.mp4',...
            'Select a video file');
        
        if isequal(file,0)
            set(handles.logText1, 'string', 'No Video File Selected...');
            return;
        else
            disp(['User selected ', fullfile(path,file)]);
        end
        
        set(handles.logText1, 'string', 'Loading Video File...');
        vidIn = VideoReader(fullfile(path,file));
        info = get(vidIn);
        width = info.Width;
        height = info.Height;
        
        width = width / resizeScl;
        height = height / resizeScl;
    else
        
    end

    if hasFrame(vidIn)
        last_frame = readFrame(vidIn);
    end
    if exist('output','dir')~=7
        mkdir('output');
    end
    set(handles.logText1, 'string', 'Playing Video File...');
    while hasFrame(vidIn)
        cur_frame = readFrame(vidIn);
        im1 = imresize(last_frame,[height, width],'bicubic');
        im2 = imresize(cur_frame,[height, width],'bicubic');
    
        tic;
        [vx,vy,warpI2] = Coarse2FineTwoFrames(im1,im2,para);
        time = toc;
    
        clear flow;
        
        flow(:,:,1) = vx;
        flow(:,:,2) = vy;
        [imflow, maxrad, minu, maxu, minv, maxv] = flowToColor(flow);
        str1 = sprintf('Elapsed time: %.4f max flow: %.4f', time, maxrad);
        str2 = sprintf('flow range: u = %.3f .. %.3f; v = %.3f .. %.3f\n',minu, maxu, minv, maxv);
        set(handles.logText1, 'string', str1);
        set(handles.logText2, 'string', str2);
        if (maxrad > flowThresh)
            if(warning == false)
                fileNum = fileNum+1;
                fileNumStr = int2str(fileNum);
                fileNumOutStr = strcat(fileNumStr,'_input.gif');
                clear volume;
                volume(:,:,:,1) = last_frame;
                volume(:,:,:,2) = cur_frame;
                frame2gif(volume,fullfile('output',fileNumOutStr));
                
                warn = 'Warning!!!';
                set(handles.logText3, 'string', warn);
                
                warning = true;
            end
            fileNum = fileNum+1;
            fileNumStr = int2str(fileNum);
            fileNumOutStr = strcat(fileNumStr,'_input.gif');
            clear volume;
            volume(:,:,:,1) = last_frame;
            volume(:,:,:,2) = cur_frame;
            frame2gif(volume,fullfile('output',fileNumOutStr));
            
            warn = 'Warning!!!';
            set(handles.logText3, 'string', warn);
            
            
        else
            warning = false;
            set(handles.logText3, 'string', '-');
        end
        
        try
            figure(1); imshow(cur_frame);
            %figure(2); imshow(warpI2);
            %figure(3); imshow(imflow);
            
        catch
            set(handles.logText1, 'string', 'User close windows');
            delete(figure(1));
            delete(figure(2));
            break;
        end
        last_frame = cur_frame;
    end
        



function resizeScale_Callback(hObject, eventdata, handles)
% hObject    handle to resizeScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of resizeScale as text
%        str2double(get(hObject,'String')) returns contents of resizeScale as a double


% --- Executes during object creation, after setting all properties.
function resizeScale_CreateFcn(hObject, eventdata, handles)
% hObject    handle to resizeScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function flowThreshold_Callback(hObject, eventdata, handles)
% hObject    handle to flowThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of flowThreshold as text
%        str2double(get(hObject,'String')) returns contents of flowThreshold as a double


% --- Executes during object creation, after setting all properties.
function flowThreshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to flowThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function varargout = SkinImageEnhancer(varargin)
% SKINIMAGEENHANCER MATLAB code for SkinImageEnhancer.fig
%      SKINIMAGEENHANCER, by itself, creates a new SKINIMAGEENHANCER or raises the existing
%      singleton*.
%
%      H = SKINIMAGEENHANCER returns the handle to a new SKINIMAGEENHANCER or the handle to
%      the existing singleton*.
%
%      SKINIMAGEENHANCER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SKINIMAGEENHANCER.M with the given input arguments.
%
%      SKINIMAGEENHANCER('Property','Value',...) creates a new SKINIMAGEENHANCER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SkinImageEnhancer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SkinImageEnhancer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SkinImageEnhancer

% Last Modified by GUIDE v2.5 13-Mar-2019 13:42:44

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SkinImageEnhancer_OpeningFcn, ...
                   'gui_OutputFcn',  @SkinImageEnhancer_OutputFcn, ...
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


% --- Executes just before SkinImageEnhancer is made visible.
function SkinImageEnhancer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SkinImageEnhancer (see VARARGIN)

% Choose default command line output for SkinImageEnhancer
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SkinImageEnhancer wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SkinImageEnhancer_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in input_Image.
function input_Image_Callback(hObject, eventdata, handles)
% hObject    handle to input_Image (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    
    [filename, pathname] = uigetfile('*.*','All Files');
    img_old = imread([pathname filename]);
    handles.img_old= img_old;
    guidata(hObject, handles);
    axes(handles.axes1);
    imshow(img_old);
    
    %fprintf('\nMSE: %7.2f ', MSE);
    %fprintf('\nPSNR: %9.7f dB', PSNR);

% --- Executes on button press in Enhancer.
function Enhancer_Callback(~, ~, handles)
% hObject    handle to Enhancer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%h = waitbar(2,'Please wait');
x = 0.1;
h = waitbar(x, 'Enhancing Please Wait...');
r=7;
se1_para = 3;
se2_para = 2;
if isfield(handles,'img_old')
    [x,y,z] = size(handles.img_old);
end
img = rgb2gray(handles.img_old);
se1 = strel('disk',se1_para);
img_c = imclose(img,se1);
waitbar(x+0.1,h,'Please wait.....');
%figure(2), imshow(img_c,[]);
img_fur = double(img_c) - double(img);
%figure(3),imshow(img_fur,[]);
[X, Y]=meshgrid(1:x);
tt=(X-280).^2+(Y-280).^2<280^2;
thresh =double( otsu(img_fur(tt),sum(tt(:))));
waitbar(x+0.1,h,'Please wait.....');
img_b = (img_fur>thresh);
%figure(4),imshow(img_b);
se2 = strel('disk',se2_para);
img_b =imdilate(img_b,se2);
waitbar(x+0.1,h,'Please wait.....');
%figure(5),imshow(img_b);
img_new = uint8(zeros(x,y,z));
waitbar(x+0.5,h,'Just a Moment');
for i = 1:x 
  for j = 1:y        
      if img_b(i,j) == false  
          img_new(i,j,:) = handles.img_old(i,j,:);
      else           
          ttt = handles.img_old(max(1,i-r):min(i+r,x),max(j-r,1):min(j+r,y),:);
          no_efficient_pix = cat(3,img_b(max(1,i-r):min(i+r,x),max(j-r,1):min(j+r,y)),img_b(max(1,i-r):min(i+r,x),max(j-r,1):min(j+r,y)));
          no_efficient_pix = any(no_efficient_pix,3);
          ttt = ttt.*repmat(uint8(not(no_efficient_pix)),[1,1,3]);
          efficient_pix_num = (2*r+1)^2-sum(no_efficient_pix(:));
          img_new(i,j,:) = uint8(sum(sum(ttt))./efficient_pix_num);           
      end       
  end   
end
%figure(6),imshow(img_new,[]);
close(h);
axes(handles.axes2);
imshow(img_new);
handles.img_new = img_new;




% --- Executes on button press in Save.
function Save_Callback(~, eventdata, handles)
% hObject    handle to Save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isfield(handles,'new_image')
    toBeSaved = imread(handles.img_new);
end
    assignin('base','toBeSaved',toBeSaved);
    [fileName, filePath] = uiputfile('*.jpg*', 'Save As');
    fileName = fullfile(filePath, fileName);
    imwrite(toBeSaved, fileName, 'jpg');
    guidata(hObject, handles);

function edit3_Callback(~, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, ~, ~)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

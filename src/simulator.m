function varargout = simulator(varargin)
% SIMULATOR MATLAB code for simulator.fig
%      SIMULATOR, by itself, creates a new SIMULATOR or raises the existing
%      singleton*.
%
%      H = SIMULATOR returns the handle to a new SIMULATOR or the handle to
%      the existing singleton*.
%
%      SIMULATOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SIMULATOR.M with the given input arguments.
%
%      SIMULATOR('Property','Value',...) creates a new SIMULATOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before simulator_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to simulator_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help simulator

% Last Modified by GUIDE v2.5 25-Nov-2020 12:01:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @simulator_OpeningFcn, ...
                   'gui_OutputFcn',  @simulator_OutputFcn, ...
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


% --- Executes just before simulator is made visible.
function simulator_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to simulator (see VARARGIN)

% Choose default command line output for simulator
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes simulator wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = simulator_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in button.
function button_Callback(hObject, eventdata, handles)
% hObject    handle to button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    N_s = str2double(get(handles.N_s, "string"));
    V_g = str2double(get(handles.V_g, "string"));
    K_s = str2double(get(handles.K_s, "string"));
    K_ox = str2double(get(handles.K_ox, "string"));
    % Temp = str2double(get(handles.Temp, "string"));
    Temp = 300;
    T_ox = str2double(get(handles.T_ox, "string"));
    L = str2double(get(handles.L, "string"));
    phi_m = str2double(get(handles.phi_m, "string"));
    % phi_p = str2double(get(handles.phi_p, "string"));
    phi_p = 5.0;
    V_fb = phi_m - phi_p;
    V_a = V_g - V_fb;

    % get electric field
    f = MOS_callback_fns("get_electric_field");
    [E, x] = f(N_s, K_s, K_ox, L, T_ox, Temp, phi_m, phi_p, V_g);
    axes(handles.axes1);
    plot(x, E);
    xlabel("x (m)");
    ylabel("E field (m⋅kg⋅s(−3)⋅A(−1))");
    grid on;

    f = MOS_callback_fns("get_voltage_junction");
    potential = f(N_s, K_s, K_ox, L, T_ox, Temp, V_a, phi_m, phi_p, V_g);
    axes(handles.axes3);
    plot(x, potential);
    xlabel("x (m)");
    ylabel("V (V)");
    grid on;
    
    f = MOS_callback_fns("get_charge_density");
    Q_density = f(N_s, K_s, K_ox, L, T_ox, phi_m, phi_p, Temp, V_g);
    axes(handles.axes6);
    plot(x, Q_density);
    xlabel("x (m)");
    ylabel("Q_d (C m(-3))");
    grid on;
    
    f = MOS_callback_fns("get_energy_band");
    [E_f, E_c, E_i, E_v, E_fm, V_th, phi_s, phi_f, W] = f(N_s, K_s, K_ox, L, T_ox, phi_m, phi_p, Temp, V_g);
    
    s = size(E_f);
    mid = int16(s(2) / 2);
    axes(handles.axes5);
    plot(x(mid:end), E_c(mid:end));
    hold on;
    plot(x(mid:end), E_v(mid:end));
    plot(x(mid:end), E_i(mid:end));
    plot(x(mid:end), E_f(mid:end));
    plot(x(1:mid), E_fm(1:mid));
    hold off;
    xlabel("x (m)");
    ylabel("Energy band (J)");
    grid on;

    output = sprintf('V_th: %d\nV_fb: %d\nphi_s: %d\nphi_f: %d\nDepletion width: %d', V_th, V_fb, phi_s, phi_f, W);
    set(handles.info, "string", output)


function N_s_Callback(hObject, eventdata, handles)
% hObject    handle to N_s (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of N_s as text
%        str2double(get(hObject,'String')) returns contents of N_s as a double


% --- Executes during object creation, after setting all properties.
function N_s_CreateFcn(hObject, eventdata, handles)
% hObject    handle to N_s (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function N_d_Callback(hObject, eventdata, handles)
% hObject    handle to N_d (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of N_d as text
%        str2double(get(hObject,'String')) returns contents of N_d as a double


% --- Executes during object creation, after setting all properties.
function N_d_CreateFcn(hObject, eventdata, handles)
% hObject    handle to N_d (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function V_g_Callback(hObject, eventdata, handles)
% hObject    handle to V_g (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of V_g as text
%        str2double(get(hObject,'String')) returns contents of V_g as a double


% --- Executes during object creation, after setting all properties.
function V_g_CreateFcn(hObject, eventdata, handles)
% hObject    handle to V_g (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function K_s_Callback(hObject, eventdata, handles)
% hObject    handle to K_s (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of K_s as text
%        str2double(get(hObject,'String')) returns contents of K_s as a double


% --- Executes during object creation, after setting all properties.
function K_s_CreateFcn(hObject, eventdata, handles)
% hObject    handle to K_s (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function T_ox_Callback(hObject, eventdata, handles)
% hObject    handle to T_ox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of T_ox as text
%        str2double(get(hObject,'String')) returns contents of T_ox as a double


% --- Executes during object creation, after setting all properties.
function T_ox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to T_ox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function K_ox_Callback(hObject, eventdata, handles)
% hObject    handle to K_ox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of K_ox as text
%        str2double(get(hObject,'String')) returns contents of K_ox as a double


% --- Executes during object creation, after setting all properties.
function K_ox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to K_ox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Temp_Callback(hObject, eventdata, handles)
% hObject    handle to Temp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Temp as text
%        str2double(get(hObject,'String')) returns contents of Temp as a double


% --- Executes during object creation, after setting all properties.
function Temp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Temp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function phi_s_Callback(hObject, eventdata, handles)
% hObject    handle to phi_s (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of phi_s as text
%        str2double(get(hObject,'String')) returns contents of phi_s as a double


% --- Executes during object creation, after setting all properties.
function phi_s_CreateFcn(hObject, eventdata, handles)
% hObject    handle to phi_s (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function phi_m_Callback(hObject, eventdata, handles)
% hObject    handle to phi_m (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of phi_m as text
%        str2double(get(hObject,'String')) returns contents of phi_m as a double


% --- Executes during object creation, after setting all properties.
function phi_m_CreateFcn(hObject, eventdata, handles)
% hObject    handle to phi_m (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function L_Callback(hObject, eventdata, handles)
% hObject    handle to L (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of L as text
%        str2double(get(hObject,'String')) returns contents of L as a double


% --- Executes during object creation, after setting all properties.
function L_CreateFcn(hObject, eventdata, handles)
% hObject    handle to L (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function phi_p_Callback(hObject, eventdata, handles)
% hObject    handle to phi_p (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of phi_p as text
%        str2double(get(hObject,'String')) returns contents of phi_p as a double


% --- Executes during object creation, after setting all properties.
function phi_p_CreateFcn(hObject, eventdata, handles)
% hObject    handle to phi_p (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

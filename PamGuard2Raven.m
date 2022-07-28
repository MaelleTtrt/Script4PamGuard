%% Fonction qui permet de transformer les résultats de détection de PAMGuard
% dans les fichiers binaires en Selection Table de Raven
clear;clc
main_path = cd;

%Selection of the folder including the PAMGuard functions
addpath(genpath(uigetdir('','Select folder contening PAMGuard MATLAB functions')));

% [audio_name, audio_path] = uigetfile('*.wav','Select wav file');
%Select the wav folder
folder_data_wav = uigetdir('','Select folder contening wav files');

%List of all .wav dates
wavList = dir(fullfile(folder_data_wav, '*.wav'));
wavNames = '';
wavDates = "";
for i = 1:length(wavList)
    wavNames(i,:) = (wavList(i).name);
    wavDates(i,:) = (wavNames(i,end-15:end-4));
end

wavDates_formated = datetime(wavDates, 'InputFormat', 'yyMMddHHmmss', 'Format', 'yyyy MM dd - HH mm ss');
[FirstDate, posMin] = min(wavDates_formated);

% [audio_name, folder_data_wav] = uigetfile('*.wav','Select wav file');

% % % %addpath(genpath(uigetdir));
% % % % Datenum de la date de début du 1er fichier 
% % % % datenum_1stF = datenum(2022,08,01,00,00,00);
% % % datenum_year = str2double(inputdlg('Year ? (YYYY)'));
% % % datenum_month = str2double(inputdlg('Month ? (MM)'));
% % % datenum_day = str2double(inputdlg('Day ? (DD)'));
% % % datenum_hour = str2double(inputdlg('Hour ? (HH)'));
% % % datenum_minute = str2double(inputdlg('Minute ? (MM)'));
% % % datenum_second = str2double(inputdlg('Second ? (SS)'));
% % % datenum_1stF = datenum(datenum_year,datenum_month,datenum_day, datenum_hour,datenum_minute,datenum_second);



wavinfo = audioinfo(strcat(folder_data_wav,"\",string(wavNames(posMin,:))));
% % % % Durée des fichiers audio en secondes
% % % duration_files = wavinfo.Duration;
% Fréquence d'échantillonnage
Fs = wavinfo.SampleRate;
% % % % Nombre d'échantillons par fichier
% % % nb_samples_files = wavinfo.TotalSamples;


%% Load data PAMGuard
folder_data_PG = uigetdir('','Select folder contening PAMGuard binary results');

% % % % % %List of all .pgdf files so the user can choose which PG output to analyse
% % % % % fileList = dir(fullfile(folder_data_PG, '*.pgdf'));
% % % % % fileNames = "";
% % % % % for i = 1:length(fileList)
% % % % %     fileNames(i,:) = string(fileList(i).name);
% % % % % end
% % % % % msg='Select The detector to analyse';

%Ici, fair een sorte de prendre la premiere date du dossier (si plusieurs
%wav dans le dossier) puis demander à l'utilisateur quel type de detecteur
%est utilisé
%List of all .pgdf dates
PG_List = dir(fullfile(folder_data_PG, '*.pgdf'));
PG_Names_temp = '';
PG_Names = "";
PG_Dates = "";
for i = 1:length(PG_List)
    PG_Names_temp = (PG_List(i).name);
    PG_Dates(i,:) = (PG_Names_temp(1,end-19:end-5));
    PG_Names(i,1) = string(PG_Names_temp);
end

PG_Dates_formated = datetime(PG_Dates, 'InputFormat', 'yyyyMMdd_HHmmss', 'Format', 'yyyy MM dd - HH mm ss');
[FirstDate, posMin] = min(PG_Dates_formated);
datenum_1stF = datenum(FirstDate);



%The lines below allow the user to choose the detector to analyse
FirstDate_f = string(datetime(FirstDate, 'InputFormat','yyyy MM dd - HH mm ss' , 'Format','yyyyMMdd_HHmmss'));
PG_Names_choice = contains(PG_Names, FirstDate_f);
k=find(PG_Names_choice==1);
detectorNames = "";
detectorChar = '';
detectorNames2 = "";
for i =1:length(k)
    detectorNames(i,1) = PG_Names(k(i));
    detectorChar = convertStringsToChars(detectorNames(i));
    detectorNames2(i,1) = string(detectorChar(1,1:end-21));
end


msg='Select The detector to analyse';
opts=[detectorNames2];
selection_type_data=menu(msg,opts);

type_data = opts(selection_type_data);

%% [type_data, folder_data_PG] = uigetdir('*.pgdf','Select PAMGuard binary database');
% data = loadPamguardBinaryFolder(folder_data_PG, convertStringsToChars(type_data));
data = loadPamguardBinaryFolder(folder_data_PG, convertStringsToChars("WhistlesMoans_Whistle_and_Moan_Detector_0_Contours*.pgdf"));

% datenum_files : variable avec les dates des d?tections en MATLAB
datenum_det={data(1:end).date};
datenum_det = cell2mat(datenum_det);
% duration_det : variable contenant les dur?e de chaque detection en
% secondes
duration_det = {data(1:end).sampleDuration};
duration_det = cell2mat(duration_det)/Fs;
% Nombre de secondes entre le d?but de la liste de fichiers et le d?but de chaque detection 
Beg_sec = (datenum_det-datenum_1stF)*24*60*60;
% Nombre de secondes entre le d?but de la liste de fichiers et la fin de chaque detection 
End_sec = Beg_sec + duration_det;
% Fr?quences limites de chaque d?tection
freqs={data(1:end).freqLimits};
freqs = cell2mat(freqs);
Low_freq = freqs(1:2:end);
High_freq = freqs(2:2:end);

% Generate Raven selection Table with appropriate format
L = length(data);
Selection = [1:L]';
View = ones(L,1);
Channel = ones(L,1);

C = [Selection, View, Channel, Beg_sec', End_sec', Low_freq', High_freq']';

file_name = [strcat(folder_data_wav,'\', wavNames(1,1:end-4), ' - PamGuard2Raven Selection Table.txt')];
selec_table = fopen(file_name, 'wt');     % create a text file with the same name than the manual selection table + SRD at the end
fprintf(selec_table,'%s\t%s\t%s\t%s\t%s\t%s\t%s\n', 'Selection', 'View', 'Channel', 'Begin Time (s)', 'End Time (s)', 'Low Freq (Hz)', 'High Freq (Hz)');
fprintf(selec_table,'%.0f\t%.0f\t%.0f\t%.9f\t%.9f\t%.1f\t%.1f\n',C);
fclose('all');
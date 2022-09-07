function [data_table, data_path, data_name] = importBinary(folder_data_wav, folder_data_PG)
%Fonction qui permet d'extraire et de convertir les résultats de détection de PAMGuard binaires

%Selection of the folder including the PAMGuard functions
% addpath(genpath(uigetdir('','Select folder contening PAMGuard MATLAB functions')));
% addpath(genpath('C:\Users\dupontma2\Pamguard\pgmatlab'));


% List of all .wav dates
wavList = dir(fullfile(folder_data_wav, '*.wav'));
wavNames = string(extractfield(wavList, 'name')');
splitDates = split(wavNames, '.',2);
wavDates = splitDates(:,2);
wavDates_formated = datetime(wavDates, 'InputFormat', 'yyMMddHHmmss', 'Format', 'yyyy MM dd - HH mm ss');
for i = 1:length(wavList)
    wavinfo(i) = audioinfo(strcat(folder_data_wav,"\",string(wavNames(i,:))));
end

% Sampling frequency
Fs = wavinfo(1).SampleRate;


%List of all .pgdf dates
PG_List = dir(fullfile(folder_data_PG, '*.pgdf'));
PG_Names_temp = cell2mat(extractfield(PG_List,'name')');
PG_Dates = PG_Names_temp(:,end-19:end-5);
PG_Names = string(PG_Names_temp);
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

if selection_type_data ~= 0
    type_data = opts(selection_type_data);
else
    clc; disp("selection_type_data - Error");
    return
end

% Load the data
data = loadPamguardBinaryFolder(folder_data_PG, convertStringsToChars(strcat(type_data,"*.pgdf")));

% datenum_files : variable avec les dates des detections en MATLAB
datenum_det={data(1:end).date};
datenum_det = cell2mat(datenum_det);

% duration_det : variable contenant les durees de chaque detection en secondes
duration_det = {data(1:end).sampleDuration};
duration_det = cell2mat(duration_det)/Fs;
% Nombre de secondes entre le debut de la liste de fichiers et le debut de chaque detection 
Beg_sec = (datenum_det-datenum_1stF)*24*60*60;
% Nombre de secondes entre le debut de la liste de fichiers et la fin de chaque detection 
End_sec = Beg_sec + duration_det;
% Frequences limites de chaque detection
freqs={data(1:end).freqLimits};
freqs = cell2mat(freqs);
Low_freq = freqs(1:2:end);
High_freq = freqs(2:2:end);

datetime_begin = string(datestr(datenum_det));
datetime_end =  string(datestr( ((datenum_det*24*3600)+(duration_det))/(3600*24) ));


data_table = [ array2table([Beg_sec', End_sec', Low_freq', High_freq'],...
    'VariableNames',{'Begin_time','End_time','Low_Freq','High_Freq'})...
    , table(datetime_begin, datetime_end), array2table([End_sec-Beg_sec]','VariableNames',{'Duration (s)'}')];

clc

end


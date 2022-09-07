function [] = export_time2Raven(folder_data_wav, time_vector, time_bin, last_bin)

% duration_det : variable contenant les durees de chaque detection en secondes
if last_bin == 0
    duration_det = ones(length(time_vector),1)*time_bin;
elseif last_bin > 0
    duration_det = [ones(length(time_vector)-2,1)*time_bin; last_bin];
end

wavList = dir(fullfile(folder_data_wav, '*.wav'));
wavNames = cell2mat(extractfield(wavList, 'name')');
splitDates = split(string(wavNames), '.',2);
wavDates = splitDates(:,2);
wavDates_formated = datetime(wavDates, 'InputFormat', 'yyMMddHHmmss', 'Format', 'yyyy MM dd - HH mm ss');


% Début de chaque detection en s (ref 0s)
Beg_sec = time_vector(1:end-1) - time_vector(1);


% Fin de chaque detection en s (ref 0s)
End_sec = Beg_sec + duration_det;


% Generate Raven selection Table with appropriate format
L = height(time_vector)-1;
Selection = [1:L]';
View = ones(L,1);
Channel = ones(L,1);

% Frequency of each timebox
Low_freq = zeros(L,1);
High_freq = ones(L,1)*50000;

C = [Selection, View, Channel, Beg_sec, End_sec, Low_freq, High_freq]';

file_name = [strcat(folder_data_wav,'\', wavNames(1,1:end-4),' ', ' time_vector.txt')];
selec_table = fopen(file_name, 'wt');
fprintf(selec_table,'%s\t%s\t%s\t%s\t%s\t%s\t%s\n', 'Selection', 'View', 'Channel', 'Begin Time (s)', 'End Time (s)', 'Low Freq (Hz)', 'High Freq (Hz)');
fprintf(selec_table,'%.0f\t%.0f\t%.0f\t%.9f\t%.9f\t%.1f\t%.1f\n',C);
fclose('all');
clc; disp("Time_vector table created");
end


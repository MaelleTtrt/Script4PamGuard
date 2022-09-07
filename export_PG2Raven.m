function [outputArg1,outputArg2] = export_PG2Raven(data, folder_data_wav, string1)

if nargin < 3
    string1 = strcat(' - PamGuard2Raven Selection Table.txt');
end


% Generate Raven selection Table with appropriate format
L = height(data);
Selection = [1:L]';
View = ones(L,1);
Channel = ones(L,1);

C = [Selection, View, Channel, data.Begin_time, data.End_time, data.Low_Freq, data.High_Freq]';


wavList = dir(fullfile(folder_data_wav, '*.wav'));
wavNames = '';
wavDates = "";
for i = 1:length(wavList)
    wavNames(i,:) = (wavList(i).name);
    wavDates(i,:) = (wavNames(i,end-15:end-4));
end

wavDates_formated = datetime(wavDates, 'InputFormat', 'yyMMddHHmmss', 'Format', 'yyyy MM dd - HH mm ss');


%Print Result to txt file
data_name = strcat(wavNames(1,1:end-4), ' ', string1);
file_name = [strcat(folder_data_wav,'\', data_name)];
selec_table = fopen(file_name, 'wt');     % create a text file with the same name than the manual selection table + SRD at the end
fprintf(selec_table,'%s\t%s\t%s\t%s\t%s\t%s\t%s\n', 'Selection', 'View', 'Channel', 'Begin Time (s)', 'End Time (s)', 'Low Freq (Hz)', 'High Freq (Hz)');
fprintf(selec_table,'%.0f\t%.0f\t%.0f\t%.9f\t%.9f\t%.1f\t%.1f\n',C);
fclose('all');

clc; disp("PG2Raven table created");


end


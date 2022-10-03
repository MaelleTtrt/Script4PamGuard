%% This script compares PG detections vs Manual Aplose annotations
%3 vectors are created :
% % % % % %-A time vector is created from the 1st measurement to the end of the last
% % % % % %measurement with a user defined time bin
% % % % % %-An Aplose vector with the timestamps of each annotation
% % % % % %-A PG vector with the timestamps of each detection, the latter is then
% % % % % %formatted so that when one or more detection are present within an
% % % % % %Aplose box, a PG box with the same timestamps is created.
%The formatted PG vector and Aplose vector are then compared to estimate the performances of the PG detector   

% Computation time ~1min for a 24h period

clear;clc

%Add path with matlab functions from PG website
addpath(genpath('U:\Documents\Pamguard\pgmatlab'));
%Add path with matlab functions from PG website
addpath(genpath('L:\acoustock\Bioacoustique\DATASETS\APOCADO\Code_MATLAB'));


%wav folder
folder_data_wav= uigetdir('','Select folder contening wav files');
if folder_data_wav == 0
    clc; disp("Select folder contening wav files - Error");
    return
end

%Infos from wav files
WavFolderInfo.wavList = dir(fullfile(folder_data_wav, '*.wav'));
WavFolderInfo.wavNames = string(extractfield(WavFolderInfo.wavList, 'name')');
WavFolderInfo.splitDates = split(WavFolderInfo.wavNames, [".","_"," - "],2);

%%%%%%%%%%%% TO ADAPT ACCORDING TO FILENAME%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
WavFolderInfo.wavDates = WavFolderInfo.splitDates(:,2); %APOCACO
WavFolderInfo.wavDates_formated = datetime(WavFolderInfo.wavDates, 'InputFormat', 'yyMMddHHmmss', 'Format', 'yyyy MM dd - HH mm ss'); %APOCADO
% WavFolderInfo.wavDates = strcat(WavFolderInfo.splitDates(:,2),'-',WavFolderInfo.splitDates(:,3)); %CETIROISE
% WavFolderInfo.wavDates_formated = datetime(WavFolderInfo.wavDates, 'InputFormat', 'yyyy-MM-dd-HH-mm-ss', 'Format', 'yyyy MM dd - HH mm ss');%CETIROISE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


for i = 1:length(WavFolderInfo.wavList)
    WavFolderInfo.wavinfo(i) = audioinfo(strcat(folder_data_wav,"\",string(WavFolderInfo.wavNames(i,:))));
end

Firstname = char(WavFolderInfo.wavNames(1));
WavFolderInfo.txt_filename = string(Firstname(1,1:end-4));

%data folder
folder_data = fileparts(folder_data_wav);

%Binary folder
folder_data_PG = uigetdir(folder_data,'Select folder contening PAMGuard binary results');
if folder_data_PG == 0
    clc; disp("Select folder contening PAMGuard binary results - Error");
    return
end

%If choice = 1, all the wave are analysed
%If choice = 2, the user define a range of study
%TODO : gérer erreurs input
choice = 1;

switch choice
    case 2
    input1 = string(inputdlg("Date & Time beginning (dd MM yyyy HH mm ss) :"));
    input2 = string(inputdlg("Date & Time ending (dd MM yyyy HH mm ss) :"));
end

%Time vector resolution
% time_bin = str2double(inputdlg("time bin ? (s)"));
time_bin = 10; %Same size than Aplose annotations


%Aplose annotation csv file
[Ap_data_name, Ap_datapath] = uigetfile(strcat(fileparts(folder_data_wav),'/*.csv'),'Select Aplose annotations');
if Ap_data_name == 0
    clc; disp("Select Aplose annotations - Error");
    return
end


%% Time vector creation
tic

for i = 1:length(WavFolderInfo.wavList)
    nb_bin_int(i,1) = fix(WavFolderInfo.wavinfo(i).Duration/time_bin); %number of complete aplose time bins per wav file
    last_bins(i,1) = mod(WavFolderInfo.wavinfo(i).Duration,time_bin); %last time bin per wav file
    bins(:,i) = [ones(nb_bin_int(i),1)*time_bin; last_bins(i)];
end
duration_time = bins(:); %All the time bins of the campaign
index_exclude = find(duration_time~=time_bin); %for now, one have to exlude those indexes for Aplose does not include them in the annotation campaign

time_vector =  [WavFolderInfo.wavDates_formated(1); WavFolderInfo.wavDates_formated(1) + cumsum(seconds(duration_time))];
datenum_time = datenum(time_vector);

elapsed_time.time_vector_creation = toc;



%% Creation of Aplose annotation vector
Ap_Annotation = importAploseSelectionTable(strcat(Ap_datapath,Ap_data_name),WavFolderInfo, time_vector, index_exclude);

%Selection of the annotator
msg_annotator='Select the annotator';
if length(unique(Ap_Annotation.annotator))>1
    opts=[unique(Ap_Annotation.annotator );"all"];
    selection_annotator=menu(msg_annotator,opts);
    annotator_selected = opts(selection_annotator);
    tic
    if annotator_selected ~= "all"
        counter_annotator = find(Ap_Annotation.annotator ~= annotator_selected);
        Ap_Annotation(counter_annotator,:)=[]; %Deletion of the annotations not correponding to the selected annotator
    end
else
    annotator_selected = unique(Ap_Annotation.annotator);
end

%Selection of the annotation type
msg_annotation='Select the annotion type to analyse';
opts=[unique(Ap_Annotation.annotation )];
selection_type_data=menu(msg_annotation,opts);
type_selected = opts(selection_type_data);
counter_annotation = find(Ap_Annotation.annotation ~= type_selected);
Ap_Annotation(counter_annotation,:)=[]; %Deletion of the annotations not correponding to the type of annotation selected by user

Ap_Annotation = sortrows(Ap_Annotation, 5);

%If several annotators, delete duplicate annotations
if annotator_selected == "all"
    [Ap_unique idx_unique CC]=unique(Ap_Annotation.start_datetime);
    Ap_Annotation = Ap_Annotation(idx_unique,:);
end

%Deletion of annotation not within the wanted datetimes
date_inf = datetime('2022 07 07 - 00 00 00','InputFormat', 'yyyy MM dd - HH mm ss', 'Format', 'yyyy MM dd - HH mm ss');
date_sup = datetime('2022 07 08 - 00 00 00','InputFormat', 'yyyy MM dd - HH mm ss', 'Format', 'yyyy MM dd - HH mm ss');

idx1 = find(Ap_Annotation.start_datetime > date_inf == 0);
idx2 = find(Ap_Annotation.end_datetime < date_sup== 0);

if ~isempty(idx1)
    Ap_Annotation(idx1,:) = [];
end
if ~isempty(idx2)
    Ap_Annotation(idx2,:) = [];
end


datenum_begin_Ap = datenum(Ap_Annotation.start_datetime);
datenum_end_Ap = datenum(Ap_Annotation.end_datetime);

duration_Ap = Ap_Annotation.end_time - Ap_Annotation.start_time;

datenum_Ap = [datenum_begin_Ap, datenum_end_Ap]; %in second

elapsed_time.Ap_vector_creation = toc;

%% Creation of PG annotations vector
tic
PG_Annotation = importBinary(folder_data_wav, WavFolderInfo, folder_data_PG, index_exclude);
if exist('PG_Annotation','var') == 0
    clc; disp("Select PG detections - Error");
    return
end

datenum_begin_PG = datenum(PG_Annotation.datetime_begin);
datenum_end_PG = datenum(PG_Annotation.datetime_end);
datenum_PG = [datenum_begin_PG, datenum_end_PG]; %in second


elapsed_time.PG_vector_creation = toc;


%% Output Aplose
tic

interval_Ap = [datenum_begin_Ap+(0.1*time_bin/3600/24), datenum_end_Ap-(0.1*time_bin/3600/24)]; %Aplose annotations intervals +/-10% of time bin in order to avoid any overlap on several timebin
interval_time = [ datenum_time((1:end-1),1), datenum_time((2:end),1)]; %Time intervals

output_Ap = [];
for i = 1:length(interval_time)
    for j = 1:length(interval_Ap)
        inter(j,1) = intersection_vect(interval_time(i,:), interval_Ap(j,:))  ;
    end
    idx_overlap = find(inter==1); %indexes of overlapping Ap annotations(j) with timebox(i)
    
    if length(idx_overlap) > 1 %More than 1 overlap
        disp(['More than one overlap at interval_Ap(j) with j =  ',num2str(j)])
        return
    elseif length(idx_overlap) == 1
        output_Ap(i,1) = 1;
    elseif length(idx_overlap) == 0
        output_Ap(i,1) = 0;
    end
    clc;disp([num2str(i),'/',num2str(length(interval_time))])
end

elapsed_time.output_Ap = toc;

%% Output PG
tic

interval_PG = [datenum_begin_PG, datenum_end_PG]; %PG detection intervals
interval_time = [ datenum_time((1:end-1),1), datenum_time((2:end),1)]; %Time intervals

output_PG = [];
for i = 1:length(interval_time)
    for j = 1:length(interval_PG)
        inter(j,1) = intersection_vect(interval_time(i,:), interval_PG(j,:))  ;
    end
    idx_overlap = find(inter==1); %indexes of overlapping PG detections(j) with timebox(i)
    
    if length(idx_overlap) >= 1 %More than 1 overlap
        output_PG(i,1) = 1;
    elseif length(idx_overlap) == 0
        output_PG(i,1) = 0;
    end
    clc;disp([num2str(i),'/',num2str(length(interval_time))])
end


%Conversion from PG detection to Aplose equivalent boxes
start_time = zeros( sum(output_PG),1 );
start_frequency = zeros( sum(output_PG),1 );
end_time = ones( sum(output_PG),1 )*time_bin;
end_frequency = ones( sum(output_PG),1 )*60000;
annotation = repmat(type_selected,[sum(output_PG),1]);

interval_PG_formatted = interval_time(find(output_PG),:);
for i = 1:length(interval_PG_formatted)
    start_datetime(i,1) = datetime(interval_PG_formatted(i,1), 'ConvertFrom', 'datenum');
    end_datetime(i,1) = datetime(interval_PG_formatted(i,2), 'ConvertFrom', 'datenum');
end
PG_Annotation_formatted = table(start_time, end_time, start_frequency, end_frequency, start_datetime, end_datetime, annotation); %export format Aplose des detections PG

elapsed_time.output_PG = toc;
elapsed_time.total_elapsed  = elapsed_time.time_vector_creation + elapsed_time.Ap_vector_creation +elapsed_time.PG_vector_creation +elapsed_time.output_Ap +elapsed_time.output_PG;

%% Results

comparison = "";
for i = 1:length(output_PG)
    if output_PG(i) == 1
        if output_Ap(i) == 1
            comparison(i,1) = "VP";
        elseif output_Ap(i) == 0
            comparison(i,1) = "FP";
        else
            comparison(i,1) = "erreur999";
        end
    elseif output_PG(i) == 0
        if output_Ap(i) == 1
            comparison(i,1) = "FN";
        elseif output_Ap(i) == 0
            comparison(i,1) = "VN";
        else
            comparison(i,1) = "erreur998";
        end
    else
        comparison(i,1) = "erreur997";
    end
end

results.nb_total = length(output_PG);
results.nb_VN = length(find(comparison == "VN"));
results.nb_VP = length(find(comparison == "VP"));
results.nb_FP = length(find(comparison == "FP"));
results.nb_FN = length(find(comparison == "FN"));
results.nb_e = length(find(comparison == "erreur999"))+length(find(comparison == "erreur998"))+length(find(comparison == "erreur997"));

results.precision = results.nb_VP/(results.nb_VP + results.nb_FP);
results.recall = results.nb_VP/(results.nb_VP + results.nb_FN);

clc
% disp(['Precision : ', num2str(results.precision), '; Recall : ', num2str(results.recall)])
% disp(results)
% disp(elapsed_time)

%% Save results
date_folder = char(datetime(now,'ConvertFrom','datenum','Format','MM-dd_HH-mm-ss'));
folder_result = strcat(folder_data_wav, '\Results\', annotator_selected);
mkdir(folder_result);

%
D = [results.nb_total, results.nb_VP, results.nb_FP, results.nb_VN, results.nb_FN, results.precision, results.recall  ];

file_name = [strcat(folder_result,'\', WavFolderInfo.txt_filename, ' - results_',date_folder,'.csv')];
selec_table = fopen(file_name, 'wt');
fprintf(selec_table,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n %.0f\t%.0f\t%.0f\t%.0f\t%.0f\t%.0f\t%.0f\t%.4f\t%.4f\t%.0f\t', ...
    'nb_total','nb_annotation','nb_detection', 'VP', 'FP', 'VN', 'FN', 'Precision', 'Recall', 'Elapsed time',...
    results.nb_total, sum(output_Ap), sum(output_PG), results.nb_VP, results.nb_FP, results.nb_VN, results.nb_FN, results.precision, results.recall, elapsed_time.total_elapsed);
fclose('all');

%
x = [1:1:length(output_Ap)]';
y = [x, output_Ap, output_PG]';
fileID = fopen(strcat(folder_result,'\', WavFolderInfo.txt_filename, ' - output_',date_folder,'.csv'),'w');
fprintf(fileID,'%s \t%s \t%s\r\n','x','output_Ap','output_PG');
fprintf(fileID,'%.0f\t %.0f\t %.0f\r\n', y);
fclose(fileID);

%
export_time2Raven(folder_result, WavFolderInfo, time_vector, time_bin, duration_time) %Time vector as a Raven Table

export_Aplose2Raven(WavFolderInfo, Ap_Annotation, Ap_datapath, Ap_data_name, folder_result)

export_PG2Raven(PG_Annotation, folder_result, WavFolderInfo)

export_Aplose2Raven(WavFolderInfo, PG_Annotation_formatted, Ap_datapath, Ap_data_name, folder_result, ' - PamGuard2Raven formatted Selection Table.txt')

clc;disp("Results and tables saved");

% clearvars -except results elapsed_time output_PG output_Ap PG_Annotation Ap_Annotation folder_data_wav annotator_selected WavFolderInfo

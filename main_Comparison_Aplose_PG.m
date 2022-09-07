%% This script compares PG detections vs Manual Aplose annotations
%3 vectors are created :
% % % % % %-A time vector is created from the 1st measurement to the end of the last
% % % % % %measurement with a user defined time bin
% % % % % %-An Aplose vector with the timestamps of each annotation
% % % % % %-A PG vector with the timestamps of each detection, the latter is then
% % % % % %formatted so that when one or more detection are present within an
% % % % % %Aplose box, a PG box with the same timestamps is created.
%The formatted PG vector and Aplose vector are then compared to estimate the performances of the PG detector   

clear;clc

%Add path with matlab functions from PG website
addpath(genpath('C:\Users\dupontma2\Pamguard\pgmatlab'));

%wav folder
folder_data_wav= uigetdir('','Select folder contening wav files');
if folder_data_wav == 0
    clc; disp("Select folder contening wav files - Error");
    return
end

%Aplose annotation csv file
[Ap_data_name, Ap_datapath] = uigetfile(strcat(folder_data_wav,'/*.csv'),'Select Aplose annotations');
if Ap_data_name == 0
    clc; disp("Select Aplose annotations - Error");
    return
end

%Binary folder
folder_data_PG = uigetdir(folder_data_wav,'Select folder contening PAMGuard binary results');
if folder_data_PG == 0
    clc; disp("Select folder contening PAMGuard binary results - Error");
    return
end

%% Time vector creation
tic

wavList = dir(fullfile(folder_data_wav, '*.wav'));
wavNames = string(extractfield(wavList, 'name')');
splitDates = split(wavNames, '.',2);
wavDates = splitDates(:,2);
wavDates_formated = datetime(wavDates, 'InputFormat', 'yyMMddHHmmss', 'Format', 'yyyy MM dd - HH mm ss');
for i = 1:length(wavList)
    wavinfo(i) = audioinfo(strcat(folder_data_wav,"\",string(wavNames(i,:))));
end

% time_bin = str2double(inputdlg("time bin ? (s)"));
time_bin = 60; %Same size than Aplose annotations


%Creation of a time vector from beginning of 1st file to end of last file with time_bin as a time step
nb_sec_begin_time = datenum(wavDates_formated(1))*24*3600; %in second
nb_sec_end_time = nb_sec_begin_time + sum(cell2mat({wavinfo(:).Duration})); %in second
% nb_sec_end_time = datenum(wavDates_formated(end))*24*3600 + wavinfo(end).Duration; %idk why this doesn't work the same

total_duration = nb_sec_end_time - nb_sec_begin_time;
last_bin = mod(total_duration,time_bin);

%When creating the time vector, the last bin might not me stricly equal to the time_bin (e.i. 9.9s instead
%of 10s for example) so we "manually" add the last timebin to the time vector. Otherwise, the time vector would lack the last bin
time_vector = [[nb_sec_begin_time:time_bin:nb_sec_end_time]'; nb_sec_end_time+last_bin ];

export_time2Raven(folder_data_wav, time_vector, time_bin, last_bin) %Time vector as a Raven Table - For the sake of control

elapsed_time.time_vector_creation = toc;
%% Creation of Aplose annotation vector

Ap_Annotation = importAploseSelectionTable(strcat(Ap_datapath,Ap_data_name));

msg='Select The annotion type to analyse';
opts=[unique(Ap_Annotation.annotation )];
selection_type_data=menu(msg,opts);
type_selected = opts(selection_type_data);
tic
counter = find(Ap_Annotation.annotation ~= type_selected);
Ap_Annotation(counter,:)=[]; %Deletion of the annotations not correponding to the type of annotation selected by user


nb_sec_begin_Ap = datenum(Ap_Annotation.start_datetime)*24*3600;
duration_det = Ap_Annotation.end_time - Ap_Annotation.start_time;
nb_sec_end_Ap = nb_sec_begin_Ap + duration_det;
datenum_Ap = [nb_sec_begin_Ap, nb_sec_end_Ap]; %in second

% Creation of Aplose annotation table in Raven output format
export_Aplose2Raven(Ap_Annotation, Ap_datapath, Ap_data_name, folder_data_wav, time_vector)

elapsed_time.Ap_vector_creation = toc;
%% Creation of PG annotations vector
tic
PG_Annotation = importBinary(folder_data_wav, folder_data_PG);
if exist('PG_Annotation','var') == 0
    clc; disp("Select PG detections - Error");
    return
end

nb_sec_begin_PG = datenum(PG_Annotation.datetime_begin) *24*3600;
nb_sec_end_PG = datenum(PG_Annotation.datetime_end) *24*3600;
datenum_PG = [nb_sec_begin_PG, nb_sec_end_PG]; %in second

% Creation of PG detection table in Raven output format
export_PG2Raven(PG_Annotation, folder_data_wav)

elapsed_time.PG_vector_creation = toc;

%% Output Aplose
tic

interval_Ap = [nb_sec_begin_Ap, nb_sec_end_Ap]; %Aplose annotations intervals
interval_time = [ time_vector((1:end-1),1), time_vector((2:end),1)]; %Time intervals

%this loop is used if an Aplose interval overlaps more than one time
%interval, it should not happen. It might happen if the Aplose interval
%overlap on one single value (?) of the following/previous time frame.
%To get rid of this, the overlap rate is calcultated between the aplose
%interval and the overlapping time intervals. If the overlap_rate is below
%a defined treshold (60% here for instance), it is not considered as an
%overlap, the time interval is not kept.
output_Ap = [];
for i = 1:length(interval_time)
    for j = 1:length(interval_Ap)
        inter(j,1) = intersection_vect(interval_time(i,:), interval_Ap(j,:))  ;
    end
    idx_overlap = find(inter==1); %indexes of overlapping Ap annotations with timebox(i)
    
    if length(idx_overlap) >= 1 %More than 1 overlap
        output_Ap(i,1) = 1;
    elseif length(idx_overlap) == 0
        output_Ap(i,1) = 0;
    end
    clc;disp([num2str(i),'/',num2str(length(interval_time))])
end

elapsed_time.output_Ap = toc;

%% Output PG
tic

interval_PG = [nb_sec_begin_PG, nb_sec_end_PG]; %Aplose annotations intervals
interval_time = [ time_vector((1:end-1),1), time_vector((2:end),1)]; %Time intervals

output_PG = [];
for i = 1:length(interval_time)
    for j = 1:length(interval_PG)
        inter(j,1) = intersection_vect(interval_time(i,:), interval_PG(j,:))  ;
    end
    idx_overlap = find(inter==1); %indexes of overlapping PG detections with timebox(i)
    
    if length(idx_overlap) >= 1 %More than 1 overlap
        output_PG(i,1) = 1;
    elseif length(idx_overlap) == 0
        output_PG(i,1) = 0;
    end
    clc;disp([num2str(i),'/',num2str(length(interval_time))])
end


% [interval_time, output_Ap, output_PG]

%Conversion from PG detection to Aplose equivalent boxes
start_time = zeros( sum(output_PG),1 );
start_frequency = zeros( sum(output_PG),1 );
end_time = ones( sum(output_PG),1 )*time_bin;
end_frequency = ones( sum(output_PG),1 )*60000;
annotation = repmat(type_selected,[sum(output_PG),1]);

interval_Ap_formatted = interval_time(find(output_PG),:);
for i = 1:length(interval_Ap_formatted)
    start_datetime(i,1) = datetime(interval_Ap_formatted(i,1)/(24*3600), 'ConvertFrom', 'datenum');
    end_datetime(i,1) = datetime(interval_Ap_formatted(i,2)/(24*3600), 'ConvertFrom', 'datenum');
end
PG_Annotation_formatted = table(start_time, end_time, start_frequency, end_frequency, start_datetime, end_datetime, annotation); %export format Aplose des detections PG

export_Aplose2Raven(PG_Annotation_formatted, Ap_datapath, Ap_data_name, folder_data_wav, time_vector, ' - PamGuard2Raven formatted Selection Table.txt')
elapsed_time.output_PG = toc

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

nb_VN = length(find(comparison == "VN"));
nb_VP = length(find(comparison == "VP"));
nb_FP = length(find(comparison == "FP"));
nb_FN = length(find(comparison == "FN"));

Precision = nb_VP/(nb_VP + nb_FP);
Recall = nb_VP/(nb_VP + nb_FN);

clc
disp(['Precision : ', num2str(Precision), '; Recall : ', num2str(Recall)])
elapsed_time


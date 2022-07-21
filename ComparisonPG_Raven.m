clear;clc
main_path = cd;

% Get wav file
[audio_name, audio_path] = uigetfile('*.wav','Select wav file');
wavinfo = audioinfo(strcat(audio_path,audio_name));
% Durée des fichiers audio en secondes
duration_files = wavinfo.Duration;
% Fréquence d'échantillonnage
Fs = wavinfo.SampleRate;
% Nombre d'échantillons par fichier
nb_samples_files = wavinfo.TotalSamples;

%Vector creation
Time_bin = str2double(inputdlg('Time bin ? (s)'));

%Import formatted PG detections
[PG_data, PG_datapath] = uigetfile('*.txt');
PG_Annotation = sortrows(importRavenSelectionTable(strcat(PG_datapath,PG_data)),1);
PG_begin_time = PG_Annotation(:,1);
PG_end_time = PG_Annotation(:,2);

%Import Raven detections
[R_data, R_datapath] = uigetfile('*.txt');
R_Annotation = sortrows(importRavenSelectionTable(strcat(R_datapath,R_data)),1);
R_begin_time = R_Annotation(:,1);
R_end_time = R_Annotation(:,2);

%Intersections dectection
A_R1 = R_Annotation(1,:);
A_PG1 = PG_Annotation(1,:);

interval_PG = fixed.Interval(A_PG1(1), A_PG1(2) );
interval_R = fixed.Interval(A_R1(1), A_R1(2) );
overlaps(interval_PG, interval_R)

%%
k=1;
output_R = NaN(length(R_Annotation),1);
output_PG = NaN(length(PG_Annotation),1);

for i = 1:length(R_Annotation)
   for j = k:length(PG_Annotation) 
        interval_R = fixed.Interval(R_Annotation(i,1), R_Annotation(i,2) );
        interval_PG = fixed.Interval(PG_Annotation(j,1), PG_Annotation(j,2) );
        output_PG(j,1) = overlaps(interval_PG, interval_R);
   end
   a=k;
   k=find(output_PG==1,1,'last')+1;
        if isempty(k) == 1
            k = 1;
        end
     if isempty(output_PG(a:k-1)) == 0
         output_R(i)=1;
     elseif isempty(output_PG(a:k-1)) == 1
         output_R(i)=0;
     end
end




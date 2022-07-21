%% Fonction qui permet de transformer les r�sultats de d�tection de PAMGuard
% dans les fichiers binaires en Selection Table de Raven

DATASET_NAME = 'Glider_SPAms_60files_test_PAMGuard';
Label= 'whistle and moan';
Annotator = 'PAMGuard Whistle and Moan detector';
Fs = 48000;
timezone = '+00:00';
% Load data PAMGuard
folder_data_PG = 'C:\Users\torterma\Documents\Projets_Osmose\1_EvaluationOfDetectionClassification\PAMGuard\Results\20190302';
type_data = 'WhistlesMoans_Whistle_and_Moan_Detector_Contours_*.pgdf';
data = loadPamguardBinaryFolder(folder_data_PG, type_data);

L = length(data);



%% Create DataFrame au format APLOSE
% dataset,filename,start_time,end_time,start_frequency,end_frequency,annotation,annotator,start_datetime,end_datetime

list_dataset(1:L,1) = string(DATASET_NAME);
% Liste des fichiers audio dans lesquels sont les d�tections + liste des d�but et fin 
% des d�tection par rapport au d�but du fichier : infos pas
% dispo avec PAMGuard (ou alors il faut cocher des param�tres dans
% PAMGuard, � voir) donc on ne remplit pas cette info, mais on la fair
% apparaitre quand m�me dans le csv de r�sultat pour qu'il ait la m�me
% forme qu'un csv de r�sultat APLOSE
list_files(1:L,1)= [NaN];
list_start_time(1:L,1)= [NaN];
list_end_time(1:L,1)= [NaN];
% Fr�quences limites de chaque d�tection
freqs={data(1:end).freqLimits};
freqs = cell2mat(freqs);
list_start_frequency = freqs(1:2:end);
list_end_frequency = freqs(2:2:end);
list_annotation(1:L,1) = string(Label);
list_annotators(1:L,1) = string(Annotator);

%% datenum_det : variable avec les dates des d�tections en MATLAB
datenum_det={data(1:end).date};
datenum_det = cell2mat(datenum_det);
list_start_datetime=string(datestr(datenum_det, ['yyyy-mm-ddTHH:MM:SS.FFF' timezone]));
% duration_det : variable contenant les dur�e de chaque detection en
% secondes
duration_det = {data(1:end).sampleDuration};
duration_det = cell2mat(duration_det)/Fs;
% date fin de d�tection
datenum_det_end = (datenum_det + duration_det/(24*60*60)) ;
list_end_datetime=string(datestr(datenum_det_end, ['yyyy-mm-ddTHH:MM:SS.FFF' timezone]));
C = [list_dataset, list_files,list_start_time, list_end_time, list_start_frequency', list_end_frequency',list_annotation,list_annotators, list_start_datetime, list_end_datetime];

%% Generate APLOSE csv

file_name = ['test.csv']
selec_table = fopen(file_name, 'wt');     % create a text file with the same name than the manual selction table + SRD at the end
    
fprintf(selec_table,'%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n', 'dataset','filename','start_time','end_time','start_frequency','end_frequency','annotation','annotator','start_datetime','end_datetime');
fprintf(selec_table,'%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n',C');
fclose('all');

























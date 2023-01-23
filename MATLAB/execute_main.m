%Get main_PG parameters
clear;clc

% User inputs
infoAplose.annotator = "PAMGuard";
infoAplose.annotation = "Whistle and moan detector";
infoAplose.dataset = "APOCADO C2D4 ST6632(10_144000)";
% GeneralFolderWav = 'L:\acoustock\Bioacoustique\DATASETS\CETIROISE\DATA\B_Sud Fosse Ouessant\Phase_1\Sylence';
GeneralFolderWav = 'L:\acoustock\Bioacoustique\DATASETS\APOCADO\PECHEURS_2022_PECHDAUPHIR_APOCADO\Campagne 2\IROISE\335556632\wav';
% GeneralFolderBinary = 'L:\acoustock\Bioacoustique\DATASETS\CETIROISE\ANALYSE\PAMGUARD_threshold_7\PHASE_1_POINT_B\Binary';
GeneralFolderBinary = 'L:\acoustock\Bioacoustique\DATASETS\APOCADO\PECHEURS_2022_PECHDAUPHIR_APOCADO\Campagne 2\IROISE\335556632\analysis\C2D4\PG Binary';


% Get files - Automatic
GeneralFolderWavInfo = dir(fullfile(GeneralFolderWav, '/**/*.wav'));
subFoldersWav = string(unique(extractfield(GeneralFolderWavInfo, 'folder')'));

GeneralFolderBinaryInfo = dir(fullfile(GeneralFolderBinary, '/**/*.pgdf'));
subFoldersBinary = string(unique(extractfield(GeneralFolderBinaryInfo, 'folder')'));




%% Execution of main
%if all the data of a folder is to be analyzed, use the function main_PG
%if only certains dates are to be analyzed in the data folder, create list
%of selected data and use main_PG in a loop
% /!\ input parameters 2 and 3 must be char type, not string type

main_PG(infoAplose, GeneralFolderWav, GeneralFolderBinary);



% Manual file selection
% subFoldersWav = subFoldersWav(74:81);
% subFoldersBinary = subFoldersBinary(74:81);
% for i = 1:length(subFoldersWav)
%     main_PG(infoAplose, char(subFoldersWav(i)), char(subFoldersBinary(i)));
%     main_PG(infoAplose, char(subFoldersWav(i)), GeneralFolderBinary);
% end



%% Raven listing

list_Raven = string(extractfield(GeneralFolderWavInfo, 'folder')') + '\' + string(extractfield(GeneralFolderWavInfo, 'name')');

%Manual selection
list_Raven_C2D1 = list_Raven(1:end);
list_Raven_C2D2 = list_Raven(27:62);
list_Raven_C2D3 = list_Raven(62:96);
list_Raven_C2D4 = list_Raven(95:178);
file_name = [strcat(GeneralFolderWav,'\Raven_list_C2D4', '.txt')];
selec_table = fopen(file_name, 'wt');     % create a text file with the same name than the manual selection table + SRD at the end
fprintf(selec_table,'%s\n', list_Raven_C2D4);
fclose('all');



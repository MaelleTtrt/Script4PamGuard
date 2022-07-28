%% This script compares PG detections vs Manual Raven annotations
%Box2Timebin compares an annotation/detection vector to a timebin vector
%If an annotation/detection is present within the considered timebin,
%Then the timebin is considered relevant, i.e. timebin(i) = 1

clear;clc
main_path = cd;
time_bin = str2double(inputdlg("time bin ? (s)"));

% Import Aplose annotations
[Ap_data, Ap_datapath] = uigetfile('*.csv','Select Aplose annotations');
Ap_Annotation = importAploseSelectionTable(strcat(Ap_datapath,Ap_data));
Ap_Annotation(1,:)=[];

msg='Select The annotion type to analyse';
opts=[unique(Ap_Annotation.annotation )];
selection_type_data=menu(msg,opts);
type_selected = opts(selection_type_data);
counter = find(Ap_Annotation.annotation ~= type_selected);
Ap_Annotation(counter,:)=[];

splitDates = split(Ap_Annotation.filename,"_");
Annot_Dates = splitDates(:,3) + splitDates(:,4);
Annot_Dates_formated = datetime(Annot_Dates, 'InputFormat', 'ddMMyyHHmmss', 'Format', 'yyyy MM dd - HH mm ss');

datenum_Ap_begin = datenum(Annot_Dates_formated)*24*3600;
datenum_Ap_end = (datenum_annot_begin*3600*24) + time_bin;
datenum_Ap = [datenum_Ap_begin, datenum_Ap_end];



% Import PG annotations for Aplose
[PG_data, PG_datapath] = uigetfile('*.csv','Select PG detections');
PG_Annotation = importPG_csvSelectionTable(strcat(PG_datapath,PG_data));
PG_Annotation(1,:)=[];
PG_Annotation_begin = char(string(table2cell(PG_Annotation(:,1))));
PG_Annotation_end = char(string(table2cell(PG_Annotation(:,2))));
PG_Annotation_begin2 = "";
PG_Annotation_end2 = "";
for i =1:length(PG_Annotation_begin)
    PG_Annotation_begin2(i,1) = string(strrep(PG_Annotation_begin(i,1:end-6),'T',' '));
    PG_Annotation_end2(i,1) = string(strrep(PG_Annotation_end(i,1:end-6),'T',' '));
end
datenum_PG_begin = datenum(PG_Annotation_begin2)*24*3600;
datenum_PG_end = datenum(PG_Annotation_end2)*24*3600;
datenum_PG = [datenum_PG_begin, datenum_PG_end];


%%
tic
output = NaN(length(datenum_Ap),1);
k=1;
interval_PG = NaN;
overlap_intervals=[];

for i = 1:length(datenum_Ap)
    counter_exceed=[];
    interval_Ap = fixed.Interval(datenum_Ap(i,1), datenum_Ap(i,2) );

    for j = k:length(datenum_PG) %on parcours le vecteur PG de k à length(PG) et on regarde s'il y a intersection avec le vecteur Ap
        interval_PG = fixed.Interval(datenum_PG(j,1), datenum_PG(j,2) );
        overlap_intervals(j) = overlaps(interval_Ap, interval_PG);
        %Si la fin d'une annotation raven(k) depasse la fin de la timebin(i) et se termine une timebin(i+N),
        %l'indice k doit recommencer à cette valeur pour la timebin suivante (cf l66)
        if interval_PG.RightEnd > interval_Ap.RightEnd
            counter_exceed = [counter_exceed;j]; 
        end
    end
    
    if find( overlap_intervals(k:length(datenum_PG)) == 1, 1 ) > 1
        output(i,1) = 1; %output_R(j) = 1 si intersection sinon 0
    elseif sum( overlap_intervals(k:length(datenum_PG))) == 0
        output(i,1) = 0; %output_R(j) = 1 si intersection sinon 0
    end
   
    if isempty(counter_exceed)
        k=find(overlap_intervals==1,1,'last')+1;
    elseif isempty(counter_exceed) == 0
        k = min(counter_exceed);
    end
    
    %Si pas d'overlap (i.e. output_R ne contient pas de 1), k est
    %réinitialisé à 1
    if isempty(k) == 1
        k = 1;
    end

end

toc







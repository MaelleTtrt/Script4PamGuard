%% This script compares PG detections vs Manual Raven annotations
%Box2Timebin compares an annotation/detection vector to a timebin vector
%If an annotation/detection is present within the considered timebin,
%Then the timebin is considered relevant, i.e. timebin(i) = 1

clear;clc
main_path = cd;
time_bin = str2double(inputdlg("time bin ? (s)"));

% % Import formatted PG detections
% [PG_data, PG_datapath] = uigetfile('*.txt','Select PG detections');
% PG_Annotation = sortrows(importRavenSelectionTable(strcat(PG_datapath,PG_data)),1);
% PG_output = Box2Timebin(PG_Annotation,time_bin);
% 
% % Import Raven annotations
% [R_data, R_datapath] = uigetfile('*.txt','Select Raven annotations');
% R_Annotation = sortrows(importRavenSelectionTable(strcat(R_datapath,R_data)),1);
% R_output = Box2Timebin(R_Annotation,time_bin);

% Import Aplose annotations
[R_data, R_datapath] = uigetfile('*.txt','Select Raven annotations');
R_Annotation = sortrows(importRavenSelectionTable(strcat(R_datapath,R_data)),1);
R_output = Box2Timebin(R_Annotation,time_bin);

%%
comparison = "";
for i = 1:length(PG_output)
    if PG_output(i) == 1
        if R_output(i) == 1
            comparison(i,1) = "VP";
        elseif R_output(i) == 0
            comparison(i,1) = "FP";
        else comparison(i,1) = "erreur999";
        end
    elseif PG_output(i) == 0
        if R_output(i) == 1
            comparison(i,1) = "FN";
        elseif R_output(i) == 0
            comparison(i,1) = "VN";
        else comparison(i,1) = "erreur998";
        end
    else comparison(i,1) = "erreur997";
    end
end

Precision = length(find(comparison == "VP")) / (length(find(comparison == "VP")) + length(find(comparison == "FP")));
Recall = length(find(comparison == "VP")) / (length(find(comparison == "VP")) + length(find(comparison == "FN")));

Result = [Precision, Recall]
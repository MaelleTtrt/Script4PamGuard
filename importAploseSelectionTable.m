function [output1] = importAploseSelectionTable(filename)

dataLines = [1, Inf];

% Set up the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 10);

% Specify range and delimiter
opts.DataLines = dataLines;
opts.Delimiter = ",";

% Specify column names and types
opts.VariableNames = ["dataset", "filename", "start_time", "end_time", "start_frequency", "end_frequency", "annotation", "annotator", "start_datetime", "end_datetime"];
opts.VariableTypes = ["string", "string", "double", "double", "double", "double", "string", "string", "string", "string"];
opts.SelectedVariableNames = ["start_time", "end_time", "start_frequency", "end_frequency", "start_datetime", "end_datetime","annotation"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
opts = setvaropts(opts, ["annotation", "start_datetime", "end_datetime"], "WhitespaceRule", "preserve");
opts = setvaropts(opts, ["start_time", "end_time", "start_frequency", "end_frequency","annotation",  "start_datetime", "end_datetime"], "EmptyFieldRule", "auto");

% Import the data
output1 = readtable(filename, opts);
output1(1,:)=[];

output_temp1 = char(output1.start_datetime);
output_temp2 = char(output1.end_datetime);


for i =1:height(output1)
    output1.start_datetime(i,1) = string(strrep(output_temp1(i,1:end-6),'T',' '));
    output1.end_datetime(i,1) = string(strrep(output_temp2(i,1:end-6),'T',' '));
end
output1.start_datetime = datetime(output1.start_datetime);
output1.end_datetime = datetime(output1.end_datetime);

%deletion of  box annotations (useless for now)
idx = find(output1.start_time ~= 0);
output1(idx,:)=[];
idx = find(output1.start_frequency ~= 0);
output1(idx,:)=[];
idx = find(output1.end_frequency ~= 72000);
output1(idx,:)=[];



end
function [output1, output2] = importAploseSelectionTable(filename, dataLines)
%IMPORTFILE Import data from a text file
%  GLIDERSPAMS24KHZANNOTATIONCAMPAIGN010421COPIE = IMPORTFILE(FILENAME)
%  reads data from text file FILENAME for the default selection.
%  Returns the data as a table.
%
%  GLIDERSPAMS24KHZANNOTATIONCAMPAIGN010421COPIE = IMPORTFILE(FILE,
%  DATALINES) reads data for the specified row interval(s) of text file
%  FILENAME. Specify DATALINES as a positive scalar integer or a N-by-2
%  array of positive scalar integers for dis-contiguous row intervals.
%
%  Example:
%  GliderSPAms24kHzannotationcampaign010421Copie = importfile("D:\Glider_SPams\Glider_SPAms 24kHz annotation campaign_010421 - Copie.csv", [1, Inf]);
%
%  See also READTABLE.
%
% Auto-generated by MATLAB on 28-Jul-2022 16:00:17

%% Input handling

% If dataLines is not specified, define defaults
if nargin < 2
    dataLines = [1, Inf];
end

%% Set up the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 8);

% Specify range and delimiter
opts.DataLines = dataLines;
opts.Delimiter = ",";

% Specify column names and types
opts.VariableNames = ["Var1", "filename", "Var3", "Var4", "Var5", "Var6", "annotation", "Var8"];
opts.SelectedVariableNames = ["filename", "annotation"];
opts.VariableTypes = ["string", "string", "string", "string", "string", "string", "string", "string"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
opts = setvaropts(opts, ["Var1", "filename", "Var3", "Var4", "Var5", "Var6", "annotation", "Var8"], "WhitespaceRule", "preserve");
opts = setvaropts(opts, ["Var1", "filename", "Var3", "Var4", "Var5", "Var6", "annotation", "Var8"], "EmptyFieldRule", "auto");

% Import the data
output1 = readtable(filename, opts);

end
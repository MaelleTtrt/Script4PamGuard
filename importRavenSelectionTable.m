function SelectionTable = importRavenSelectionTable(filename, dataLines)
%IMPORTFILE Import data from a text file
%  APOCADOIROISED1SELECTIONDAUPHIN20220801000000PAMGUARD2RAVENSELE =
%  IMPORTFILE(FILENAME) reads data from text file FILENAME for the
%  default selection.  Returns the numeric data.
%
%  APOCADOIROISED1SELECTIONDAUPHIN20220801000000PAMGUARD2RAVENSELE =
%  IMPORTFILE(FILE, DATALINES) reads data for the specified row
%  interval(s) of text file FILENAME. Specify DATALINES as a positive
%  scalar integer or a N-by-2 array of positive scalar integers for
%  dis-contiguous row intervals.
%
%  Example:
%  APOCADOIROISED1selectiondauphin20220801000000PamGuard2RavenSele = importfile("L:\acoustock\Bioacoustique\DATASETS\Biblio_sons_dauphins\APOCADO - IROISE D1 - selection dauphin - 20220801000000 - PamGuard2Raven Selection Table.txt", [1, Inf]);
%
%  See also READTABLE.
%
% Auto-generated by MATLAB on 21-Jul-2022 10:50:56

%% Input handling

% If dataLines is not specified, define defaults
if nargin < 2
    dataLines = [1, Inf];
end

%% Set up the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 7);

% Specify range and delimiter
opts.DataLines = dataLines;
opts.Delimiter = "\t";

% Specify column names and types
opts.VariableNames = ["Var1", "Var2", "Var3", "BeginTimes", "EndTimes", "Var6", "Var7"];
opts.SelectedVariableNames = ["BeginTimes", "EndTimes"];
opts.VariableTypes = ["string", "string", "string", "double", "double", "string", "string"];

% Specify file level properties
opts.ImportErrorRule = "omitrow";
opts.MissingRule = "omitrow";
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";


% Specify variable properties
opts = setvaropts(opts, ["Var1", "Var2", "Var3", "Var6", "Var7"], "WhitespaceRule", "preserve");
opts = setvaropts(opts, ["Var1", "Var2", "Var3", "Var6", "Var7"], "EmptyFieldRule", "auto");

% Import the data
SelectionTable = readtable(filename, opts);

%% Convert to output type
SelectionTable = table2array(SelectionTable);
end
function [time,data_extracted, labels] = extract_columns_v2(filename, sheet, file_sheet, col_interest, verbosity)
%this function is used to extract the specific columns fromt he csv file of
%each Xsens file type

%input:
%filename: name of the file from which we want to extract the data. path is not required - string
%sheet: in case of data derived from one unique file, this provides the name of the sheet from which to extract the data - string
%file_sheet: variable "f" or "s" indicating if the data needs to be retrieved from multiple files or from different sheets of one unique file, respectively
%col_interest: names of the columns we want to extract from the Xsens file- string vector
%verbosity: flag variable 0\1 indicating if we want to receive messages in case of failure

%output:
%time: tme column, it should be common among all the Xsens files - vector
%of doubles
%data_extracted: matrix containign the values of the columns asked for - matrx of
%doubles
% labels: names of the variables extracted - string vector

if file_sheet=="f"
    raw_data=readtable(filename);
    time=raw_data.time;
elseif file_sheet=="s"
    raw_data=readtable(filename, 'Sheet',sheet);
    time=raw_data.Frame;
end

if isempty(raw_data)
    if verbosity==1
        fprintf("\n File " + filename + " not found");
    end
else
    
    col_names=string(raw_data.Properties.VariableNames);
    index_cols=[];
    for i=1:length(col_interest)
        index_cols=[index_cols;find(col_names==col_interest(i))];
    end
    data_extracted=table2array(raw_data(:,index_cols));
    
    %I attach also the other columns, to have a complete picture
    all_columns=1:size(raw_data, 2);
    if col_names(2)=="time" && col_names(3)=="ms"
        all_columns(1:3)=[];
    elseif col_names(1)=="Frames"
        all_columns(1)=[];
    end
    remaining_columns=setdiff(all_columns, index_cols);
    data_extracted=[data_extracted, table2array(raw_data(:,remaining_columns))];
    
    %save in the labels variable the names of the variables
    labels=[col_interest, col_names(remaining_columns)];
end
end


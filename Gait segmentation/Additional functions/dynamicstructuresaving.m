% Function to save the data in a structure with a dynamic pipeline
function [flag] = dynamicstructuresaving(subjectstring,sessionID,struct2save,filename,testlabel);
if exist(filename)
    % If the data already exists, load and check it
    data        = load(filename);
    saveflag    = 0;
    if ~isfield(data.(subjectstring),'TestLabel')
        % Write the test identifier
        saveflag = 1;
        eval([subjectstring,'.TestLabel = ', testlabel])
    end            
    if ~isfield(data.(subjectstring),(sessionID))
        % Include the data of the session
        saveflag = 1;
        data.(subjectstring).(sessionID) = struct2save;
    else
        % If the dataset is already present, ask if over-write the new data
        userinput = questdlg('Data already saved, over-write?','User input','Yes','No','No');
        if strcmp(userinput,'Yes')
            saveflag = 1;
            data.(subjectstring).(sessionID) = struct2save;
        end
    end
    if saveflag
        eval([subjectstring '= data.(subjectstring)'])
        save(filename,subjectstring)	% Data saving
    end
    clear data
else
    eval([subjectstring,'.',sessionID,' = struct2save'])	% Create a struct with the identifier of the subject (dynamic assigment)
    eval([subjectstring,'.TestLabel = ','"',testlabel,'"'])	% Tag with the test ID
    save(filename,subjectstring)                          	% Data saving
end
eval(['clear ' subjectstring])
flag = 1;
return
end
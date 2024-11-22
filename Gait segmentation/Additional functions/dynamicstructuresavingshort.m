% Function to save the data in a structure with a dynamic pipeline
function [flag] = dynamicstructuresavingshort(subjectstring,sessionID,struct2save,filename,testlabel);
% if exist(filename)
%     % If the data already exists, load and check it
%     data        = load(filename);
%     saveflag    = 1;
%     if ~isfield(data.(subjectstring),'TestLabel')
%         % Write the test identifier
%         saveflag = 0;
%         eval([subjectstring,'.TestLabel = ', testlabel])
%     end            
%     if saveflag
%         eval([subjectstring '= data.(subjectstring)'])
%         save(filename,subjectstring)	% Data saving
%     end
%     clear data
% else
    eval([subjectstring,' = struct2save'])	% Create a struct with the identifier of the subject (dynamic assigment)
    eval([subjectstring,'.TestLabel = ','"',testlabel,'"'])	% Tag with the test ID
    save(filename,subjectstring)                          	% Data saving
% end
eval(['clear ' subjectstring])
flag = 1;
return
end
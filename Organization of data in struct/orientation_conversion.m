function [filename_new] = orientation_conversion(filename,orientation_type)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
quaternions=readtable(filename);
axes=orientation_type;

if isempty(quaternions)
    if verbosity==1
        fprintf("\n File " + filename + " not found");
    end
else
    quat_names=string(quaternions.Properties.VariableNames);
    time=quaternions.time;
    time=array2table(time);
    time.Properties.VariableNames="time";
    quaternions=table2array(quaternions);
       
    if quat_names(2)=="time" && quat_names(3)=="ms"
        quaternions(:,1:3)=[];
        quat_names(1:3)=[];
    end
    
    new_quat=[];
    new_quat_names=[];
    
    for i=1:4:size(quaternions,2)
        new_quat=[new_quat, quat2eul(quaternions(:,i:i+3), orientation_type)];
        new_quat_names=[new_quat_names; replace(quat_names(i), "_q0", axes(1)); replace(quat_names(i), "_q0", axes(2)); replace(quat_names(i), "_q0", axes(3))];
    end
    
    new_quat_tab=array2table(new_quat);
    new_quat_tab.Properties.VariableNames=new_quat_names;
    new_quat_tab=[time, new_quat_tab];
    
    writetable(new_quat_tab, "orientation_converted.csv");
    filename_new="orientation_converted.csv";
end


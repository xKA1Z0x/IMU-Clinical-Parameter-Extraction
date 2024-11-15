function Exportparameters = Cadence(data, bodyside, Exportparameters)
       %calling the body side in a loop
   for k = 1:numel(bodyside)
       s = data.subdata_out.Segmented.(bodyside{k});
       %loop through each stride for the current body side
       for i = 1:size(s.ACC_seg, 1)
           %calculate cadence for each stride and assign to the table
           Exportparameters{i, k+0} = (60^2)/length(s.ACC_seg{i,1});
       end
   end
   
   %calculating cadence assymetry
   for i = 1:height(Exportparameters)
       if ~isnan(Exportparameters{i, 1}) && ~isnan(Exportparameters{i, 2})
          Exportparameters{i, 3} = (Exportparameters{i, 1}-Exportparameters{i,2}) / (0.5 * (Exportparameters{i, 1}+Exportparameters{i,2})) * 100;
       else
          Exportparameters{i, 3} = NaN; 
       end
   end
end
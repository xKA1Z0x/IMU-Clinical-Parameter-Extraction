function Pel = pelvis_correct(Pel_ro)

% Correct discontinuous trajectory when the angle goes over +-180 degrees.
% Input: 1-axis discoutinuous signal (rad)
% Output: Corrected continuous signal

Pel_ro = Pel_ro*180/pi;
delta_pel = 0;
for k = 1:1:length(Pel_ro)
    if k ==1
        sign = Pel_ro(k);
    else
        sign = Pel_ro(k) - Pel_ro(k-1);
    end
    
    if sign < -200
        delta_pel = delta_pel + 360;
    elseif sign > 200
        delta_pel = delta_pel - 360;
    else
        delta_pel = delta_pel;
    end
    Pel_correct(k) = Pel_ro(k) + delta_pel;       
end 

Pel = Pel_correct*pi/180;
%%
time = CVA040.SSV1.Extracted.time(1:1591);
speed = CVA040.SSV1.Extracted.AV(:,19:21);
acc = CVA040.SSV1.Extracted.ACC_S(:,19:21);
figure
plot(time,acc)
xlabel('Time (sec)')
ylabel('Acceleration (mm/sec^2)')
%%Design High Pass Filter
fs = 8000; % Sampling Rate
fc = 0.1/30;  % Cut off Frequency
order = 6; % 6th Order Filter
%%Filter  Acceleration Signals
[b1 a1] = butter(order,fc,'high');
accf=filtfilt(b1,a1,acc);
figure (2)
plot(time,accf,'r'); hold on
plot(time,acc)
xlabel('Time (sec)')
ylabel('Acceleration (mm/sec^2)')
%%First Integration (Acceleration - Veloicty)
velocity=cumtrapz(time,accf);
figure (3)
plot(time,velocity)
xlabel('Time (sec)')
ylabel('Velocity (mm/sec)')
%%Filter  Veloicty Signals
[b2 a2] = butter(order,fc,'high');
velf = filtfilt(b2,a2,velocity);
%%Second Integration   (Velocity - Displacement)
Displacement=cumtrapz(time, velf);
figure(4)
plot(time,Displacement)
xlabel('Time (sec)')
ylabel('Displacement (mm)')
figure(5)
plot(vecnorm(velocity'))
function frame = set_frame(data, dlength, freq)

t = 0:dlength/length(data):dlength-dlength/length(data);
t=t';
t0 = 0:1/freq:dlength;

opts = fitoptions('Method', 'smoothingspline', 'SmoothingParam', 1.0);
spline = fit(t,data,'smoothingspline',opts);
frame = feval(spline,t0);
function freq_features = FFeatures(x, fs)

% Get time series data and output frequency domain general features 
% x_DPMag = Dominant power magnitude
% x_DFreq = dominant frequency
% x_PSD_mean = mean of power spectial density 
% x_PSD_std = SD of power spectial density 
% x_PSD_skew = skewness of power spectial density 
% x_PSD_kurtosis = kurtosis of power spectial density 

[P,f] = FFT_data(x, fs, 0);
[max_P, freq] = max(P);

x_DPMag = max_P;
x_DFreq = f(freq);
x_PSD_mean = mean(P);
x_PSD_std = std(P);
x_PSD_skew = skewness(P);
x_PSD_kurtosis = kurtosis(P);

freq_features = [x_DPMag, x_DFreq, x_PSD_mean, x_PSD_std, x_PSD_skew, x_PSD_kurtosis];


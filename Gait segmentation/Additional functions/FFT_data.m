function [P, f, L, n, Y] = FFT_data(X, Fs, fig)

% Fast Fourier transform of time-series 
% Input: X - time-series data
%        Fs: Sampling frequency in Hz
%        fig: figure or not
%        Output: power of spectrum
%             f: frequency

Ts = 1/Fs;
t = [1:1:length(X)]*Ts;

L = length(X);
n = 2^nextpow2(L);
Y = fft(X,n);

f = Fs*(0:(n/2))/n;
P = 2*(abs(Y/n));
P = P(1:n/2+1).^2;

if fig == 1
    figure
    subplot(2,1,1)
    plot(t, X,'k-')
    xlabel('Time [sec]')
    ylabel('Amp [A.U.]')
    xlim([t(1) t(end)])
    subplot(2,1,2)
    plot(f,P,'k-')
    xlabel('Frequency [Hz]')
    ylabel('|Power(f)|')
    xlim([f(1) f(end)]) 
else
end


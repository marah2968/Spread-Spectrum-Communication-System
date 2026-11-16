clear; close all;
clc;
%%parameters
Fs = 10000;
fc = 100;
fp = 7;
bit_t = 0.1;
N=4;
%%message generation with BPSK
% m = randi([0 1], 1, N);
% m=2*m-1;
m=[-1 1];
message = repmat(m,fp,1);
message = reshape(message,1,[]);
%%PN generation and multiply with message
pncode =[1 0 1 1 1 0 0];
pncode=2*pncode-1;
pn_code= repmat(pncode,1,length(m));
DSSS = message.*pn_code;


%%Draw original message, PN code , encoded sequence on time domain
pn_size = length(pn_code);
tm = 0:bit_t:(length(m))*bit_t;
tpn = linspace(0,length(m)*bit_t-0.0123,pn_size);
figure
subplot(311)
stairs(tpn,message,'linewidth',2)
title('Message bit sequence')
axis([0 (length(m)*bit_t) -1 1]);
xlabel('Time');
ylabel('Amplitude');
subplot(312)
stairs(tpn,pn_code,'linewidth',2)
title('Pseudo-random code');
axis([0 (length(m)*bit_t) -1 1]);
xlabel('Time');
ylabel('Amplitude');
subplot(313)
stairs(tpn,DSSS,'linewidth',2)
title('Signal after spreading signal');
axis([0 (length(m)*bit_t) -1 1]);
xlabel('Time');
ylabel('Amplitude');

%%Draw original message, PN code , encoded sequence on frequency domain
f = linspace(-Fs/2,Fs/2,10e5);
figure
subplot(311)
plot(f,abs(fftshift(fft(message,10e5))),'linewidth',2);
title('Message spectrum')
xlabel('frequency');
ylabel('spectrum');
subplot(312)
plot(f,abs(fftshift(fft(pn_code,10e5))),'linewidth',2);
title('Pseudo-random code spectrum');
xlabel('frequency');
ylabel('spectrum');
subplot(313)
plot(f,abs(fftshift(fft(DSSS,10e5))),'linewidth',2);
title('Signal after spreading spectrum');
xlabel('frequency');
ylabel('spectrum');
 
%%autocorrelation and power density
[r,lag] = xcorr(pncode,'biased');
figure;
stem (lag,r);
title('autocorrelation of PN');


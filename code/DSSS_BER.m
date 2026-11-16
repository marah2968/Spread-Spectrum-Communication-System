clear; close all; clc;
fp = 31;
Number_of_bits_per_block=1000;
Max_number_of_block=1e7;
Max_number_error=200;
SNRmin=-4;
SNRstep=0.5;
SNRmax=10;
SNR=SNRmin:SNRstep:SNRmax;
num_errors = zeros(length(SNR),1);
num_sent_blocks = zeros(length(SNR),1);
BER = zeros(length(SNR),1);
%% PN generation and multiply with message
% pncode =[1 0 1 1 1 0 0];
% pncode=2*pncode-1;
pncode=pn';
%%
for op=1:length(SNR)
    numErrs = 0;
    numBits = 0;
    numErrsNoCorr = 0;
    numBitsNoCorr = 0;
    numErrsCorr = 0;
    numBitsCorr = 0;
    while numErrs < 200 && numBits < 1e7
        m = randi([0 1], 1, Number_of_bits_per_block);
        m1 = 2*m-1;
        DSSS  = kron(m1,pncode);
        received_signals =zeros(1,Number_of_bits_per_block);
        noiseq=randn(Number_of_bits_per_block*fp,1);
        Eb2N_num=10^(SNR(op)/10); % Eb/N in numeral
        Var_n=fp/(2*Eb2N_num); %1/SNR is the noise variance
        signois=sqrt(Var_n); % standard deviation
        awgnois=signois*noiseq; %
        r_noise =awgnois' + DSSS; 
        received=reshape(r_noise,fp,Number_of_bits_per_block).'; clear r_noise awgnois;
        % Despread first
        received_signals=received*pncode';
        % Decision based on the sign of the samples
        dec1=sign(received_signals);
        dec2 = 0.5*dec1+0.5;
        nErrors = biterr(dec2',m);
        numErrs = numErrs + nErrors;
        numBits = numBits + Number_of_bits_per_block;
        
    end
    BER(op) = numErrs/numBits;
end
%%
%BER=num_errors./(num_sent_blocks.*Number_of_bits_per_block);
bertheory=berawgn(SNR,'psk',2,'nondiff');
figure;
semilogy(SNR,smooth(BER),'r-+','LineWidth',2);
hold on ;grid on;
semilogy(SNR,bertheory,'b-o','LineWidth',2);
legend("BER","BERtheory");
xlabel('E_b/N (dB)');
ylabel('Bit error rate');
title(['DSSS with spreading factor = ',num2str(fp)]);
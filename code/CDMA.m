clear; close all; clc;
fp =2;
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
BER2 = zeros(length(SNR),1);
% BER3 = zeros(length(SNR),1);
% BER4 = zeros(length(SNR),1);
% PN generation and multiply with message
% pn = [1 1 1 -1
% -1 1 -1 1
% -1 -1 1 1
% 1 1 -1 -1
% -1 -1 -1 -1
% 1 1 1 1
% 1 1 -1 -1
% -1 -1 -1 1
% -1 1 -1 -1
% 1 -1 -1 1
% -1 -1 1 1
% 1 1 -1 1
% 1 -1 -1 -1
% -1 1 1 1
% 1 -1 1 1
% -1 1 1 -1
% -1 -1 1 -1
% -1 1 1 -1
% 1 1 1 -1
% 1 -1 1 1
% 1 -1 1 -1
% 1 1 -1 -1
% 1 1 1 1
% 1 1 -1 -1
% -1 -1 -1 -1
% 1 1 -1 1
% 1 -1 -1 -1
% -1 1 -1 1
% 1 1 -1 -1
% 1 1 1 1
% 1 1 1 1];
pncode1= [-1 1];
pncode2 = [1 1];
pncode3= [1 -1];
pncode4= [-1 -1];
% pncode1= pn1';
% pncode2 = pn2';
%%
for op=1:length(SNR)
    numErrs = 0;
    numBits = 0;
    numErrs2 = 0;
    numBits2 = 0;
     numErrs3 = 0;
    numBits3 = 0;
      numErrs4 = 0;
    numBits4 = 0;
    while numErrs < 200 && numBits < 1e7
        m = randi([0 1], 1, Number_of_bits_per_block);
        m1 = 2*m-1;
        m22 = randi([0 1], 1, Number_of_bits_per_block);
        m2 = 2*m22-1;
         m33 = randi([0 1], 1, Number_of_bits_per_block);
        m3 = 2*m33-1;
         m44 = randi([0 1], 1, Number_of_bits_per_block);
        m4 = 2*m44-1;
        DSSS1  = kron(m1,pncode1);
        DSSS2  = kron(m2,pncode2);
        DSSS3  = kron(m3,pncode3);
       DSSS4  = kron(m4,pncode4);
        received_signals1 = zeros(1,Number_of_bits_per_block);
        received_signals2 = zeros(1,Number_of_bits_per_block);
        received_signals3 = zeros(1,Number_of_bits_per_block);
        received_signals4 = zeros(1,Number_of_bits_per_block);
        noiseq=randn(Number_of_bits_per_block*fp,1);
        Eb2N_num=10^(SNR(op)/10); % Eb/N in numeral
        Var_n=fp/(2*Eb2N_num); %1/SNR is the noise variance
        signois=sqrt(Var_n); % standard deviation
        awgnois=signois*noiseq; %
        r_noise =awgnois' + DSSS1+DSSS2; 
        received=reshape(r_noise,fp,Number_of_bits_per_block).'; clear r_noise awgnois;
        % Despread first
        received_signals1=received*pncode1';
        received_signals2=received*pncode2';
        received_signals3=received*pncode3';
        received_signals4=received*pncode4';
        
        % Decision based on the sign of the samples
        dec1=sign(received_signals1);
        dec11 = 0.5*dec1+0.5;
        dec2=sign(received_signals2);
        dec22 = 0.5*dec2+0.5;
        dec3=sign(received_signals3);
        dec33 = 0.5*dec3+0.5;
        dec4=sign(received_signals4);
        dec44 = 0.5*dec4+0.5;
        nErrors = biterr(dec11',m);
        numErrs = numErrs + nErrors;
        numBits = numBits + Number_of_bits_per_block;
        nErrors2 = biterr(dec22',m22);
        numErrs2 = numErrs2 + nErrors2;
        numBits2 = numBits2 + Number_of_bits_per_block;
        nErrors3 = biterr(dec33',m33);
        numErrs3 = numErrs3 + nErrors3;
        numBits3 = numBits3 + Number_of_bits_per_block;
        nErrors4 = biterr(dec44',m44);
        numErrs4 = numErrs4 + nErrors4;
        numBits4 = numBits4 + Number_of_bits_per_block;
       
    end
    BER(op) = numErrs/numBits;
    BER2(op) = numErrs2/numBits2;
     BER3(op) = numErrs3/numBits3;
    BER4(op) = numErrs4/numBits4;

end
%%
bertheory=berawgn(SNR,'psk',2,'nondiff');
figure;
semilogy(SNR,smooth(BER),'r-+','LineWidth',2);
hold on ;grid on;
semilogy(SNR,smooth(BER2),'g-*','LineWidth',2);
hold on ;
semilogy(SNR,bertheory,'b-o','LineWidth',2);
% hold on ;
% semilogy(SNR,smooth(BER3),'LineWidth',2);
 hold on ;
semilogy(SNR,smooth(BER4),'LineWidth',2);
legend("BER for user1","BER for user2","single user","BER for user3","BER for user4");
xlabel('E_b/N (dB)');
ylabel('Bit error rate');
title(['DSSS with spreading factor = ',num2str(fp)]);
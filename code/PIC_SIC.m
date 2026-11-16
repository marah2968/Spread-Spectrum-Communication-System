clear; close all; clc;
%% parameters
Fs = 1000;
fc = 100;
fp = 8;
bit_t = 0.1;
N=1000000;
SNRmin=-4;
SNRstep=0.2;
SNRmax=8;
SNR=SNRmin:SNRstep:SNRmax;
BER1 = zeros(length(SNR),1);
BER11 = zeros(length(SNR),1);
BER2 = zeros(length(SNR),1);
BER22 = zeros(length(SNR),1);
pncode1= [1 1 1 1 -1 -1 -1 -1];
pn_code1= repmat(pncode1,1,N);
pncode2 = [1 1 1 1 -1 -1 1 1];
pn_code2= repmat(pncode2,1,N);
%% message generation with BPSK
for op=1:length(SNR)
    m1 = randi([0 1], 1, N);
    for bit = 1:N
        if(m1(bit)==0)
        m1(bit) = -1;
        end
    end
    message1 = repmat(m1,fp,1);
    message1 = reshape(message1,1,[]);
    m2 = randi([0 1], 1, N);
    for bit = 1:N
        if(m2(bit)==0)
        m2(bit) = -1;
        end
    end
    message2 = repmat(m2,fp,1);
    message2 = reshape(message2,1,[]);
    DSSS1 = message1.*pn_code1;
    DSSS2 = message2.*pn_code2;
    received_signal1 = zeros(1,N);
    received_signal2 = zeros(1,N);
    received_signal11 = zeros(1,N);
    received_signal22 = zeros(1,N);
    received =awgn(DSSS1+DSSS2,SNR(op));
    %% PIC
    received1 = (1/sqrt(2))*received.*pn_code1;
    received2 = (1/sqrt(2))*received.*pn_code2;
    %% SIC
    received11 = received.*pn_code1;
    tempreceived = received - received11;
    received22 = tempreceived.*pn_code2;

    for k=1:N
        receivedm=received1(fp*(k-1)+1:fp*k);
        receivedm1=received11(fp*(k-1)+1:fp*k);
        received_signal1(k)=sum(receivedm);
        received_signal11(k)=sum(receivedm1);
    end
    for k=1:N
         if (received_signal1(k)>0)
             received_signal1(k)=1;
         else 
             received_signal1(k)=-1;
         end   
    end
    for k=1:N
         if (received_signal11(k)>0)
             received_signal11(k)=1;
         else 
             received_signal11(k)=-1;
         end   
    end
    num_errors1=nnz(received_signal1-m1);
    num_errors11=nnz(received_signal11-m1);
    BER1(op,1)=num_errors1/N;
    BER11(op,1)=num_errors11/N;
    for k=1:N
        receivedm=received2(fp*(k-1)+1:fp*k);
        received_signal2(k)=sum(receivedm);
        receivedm2=received22(fp*(k-1)+1:fp*k);
        received_signal22(k)=sum(receivedm2);
    end
    for k=1:N
         if (received_signal2(k)>0)
             received_signal2(k)=1;
         else 
             received_signal2(k)=-1;
         end   
    end
    for k=1:N
         if (received_signal22(k)>0)
             received_signal22(k)=1;
         else 
             received_signal22(k)=-1;
         end   
    end
    num_errors2=nnz(received_signal2-m2);
    num_errors22=nnz(received_signal22-m2);
    BER2(op,1)=num_errors2/N;
    BER22(op,1)=num_errors22/N;
end
figure;
semilogy(SNR,smooth(BER1));
hold on;grid on
semilogy(SNR,smooth(BER2));
hold on;
semilogy(SNR,smooth(BER11));
hold on;
semilogy(SNR,smooth(BER22));
legend("BER for user 1 PIC ","BER for user 2 PIC ","BER for user 1 SIC ","BER for user 2 SIC ");
xlabel('E_b/N (dB)');
ylabel('Bit error rate');
title(['DSSS with spreading factor = ',num2str(fp)]);
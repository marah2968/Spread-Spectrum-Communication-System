%%
%  save ('yout.mat');
% scatterplot(hiast.signals.values);
fp =16;
code = [-1 1 -1 1 1 1 -1 1 1 -1 -1 -1 1 1 1 1];
m = real(marah.signals.values)';
Len = length(m);
pcode=[];
for i = 1: fp
    pcode(i,:) = circshift(code,i);
end
c = repmat(pcode(6,:)',250,1);
y1 = m.*c';
z1 = arrayfun(@(i) mean(y1(i:min(i+8, end))), 1:8:length(y1));
zdemo = pskdemod(z1,2);
pre =    [0 0 0 0 1 1 1 1 0 0 0 0 1 1 1 1];
preinv = [1 1 1 1 0 0 0 0 1 1 1 1 0 0 0 0];
nn = 0; nv = 0;
for km =1:length(zdemo)-15
    vv = zdemo(km:km+15);
    if vv == pre
        nn =nn+1;
        fprintf('nn',km);
        km
    end
    if vv == preinv
        nv = nv+1;
        fprintf("nv",km);
        km
    end
end
%%

%%
ps =49;
dec2=zdemo(ps:ps+71);
b = reshape(dec2, 8, []).';      % reshape vector into matrix; 8 bits per row
b = num2str(b);                     % convert to char array
b = bin2dec(b);                     % convert to decimal
fprintf(char(b)); 
nErrors = biterr(dec2,message);
 BER = nErrors/72;
 display (BER) ;
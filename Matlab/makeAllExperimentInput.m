clc
clear all


K=32;

treat=mod([1:K]+3,4);
for k=1:4:K-3;
    s=randperm(3);
    shuffled=treat(k:k+2);
    shuffled=shuffled(s);
    treat(k:k+2)=shuffled;
end

makeEAv2Xinput(0, 5, 1);


fid=fopen('../Data/input0.dat');

for k=1:K
    fseek(fid,0,'bof');
    fid2=fopen(['../Data/input',num2str(k),'.dat'],'w');
    while 1
        tline = fgetl(fid);
        if ~ischar(tline)
            break
        end
        writeme=regexprep(tline,'(^\d+\t)(5)',['$1',num2str(treat(k))]);
        fprintf(fid2,[writeme,'\n']);
    end
    fclose(fid2);
end
fclose(fid);


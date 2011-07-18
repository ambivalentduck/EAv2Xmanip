clc
clear all

K=10;
treat=zeros(K,1);

for k=1:2:K-1
    if rand>.5
        treat(k:k+1)=[0 1];
    else
        treat(k:k+1)=[1 0];
    end
end

fid=fopen('../Data/input0.dat');

for k=1:K
    fseek(fid,0,'bof');
    fid2=fopen(['../Data/input',num2str(k+300),'.dat'],'w');
    linenum=0;
    while 1
        linenum=linenum+1;
        tline = fgetl(fid);
        if ~ischar(tline)
            break
        end
        writeme=regexprep(tline,'(^\d+\t)(5)',['$1',num2str(treat(k))]);
        if (linenum>474)&&(linenum<859)
            fprintf(fid2,[writeme,'\t.1\n']);
        else
            fprintf(fid2,[writeme,'\t0\n']);
        end
    end
    fclose(fid2);
end
fclose(fid);
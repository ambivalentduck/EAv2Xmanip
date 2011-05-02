clc 
clear all

name='3';
output=cell(1,1);

load(['../Data/',name,'.mat']);

output{1}=maxperpendicular(subject);

lo=length(output);

figure(1);
clf
hold on

%initalize
aftereffects=zeros(lo,1);
learningStarttoFinish=zeros(lo,1);
learning3=zeros(lo,1);

f=find([subject.trial(subject.block(2).trials).stim]~=0);
exes2=subject.block(2).trials(f);
f=find([subject.trial(subject.block(2).trials).stim]==0);
dots2=subject.block(2).trials(f);

for o=1:lo
    sub=[subject.block(1).trials(end-9:end) subject.block(5).trials(1:10)];
    aftereffects(o)=regressNotZero(sub,output{o}(sub));

    subset=subject.block(3).trials;
    learning3(o)=regressNotZero(subset,output{o}(subset));

    sub=[exes2, subject.block(4).trials(end-length(exes2)+1:end)];
    learningStarttoFinish(o)=regressNotZero(sub,output{o}(sub));
end


colors='kgcmy';

tol=.01;
centers=zeros(length(subject.block),1);
for b=1:length(subject.block)
    centers(b)=(subject.block(b).trials(end)+subject.block(b).trials(1))/2;
end

for k=1:lo
    for b=1:length(subject.block)
        subset=subject.block(b).trials(6:end-5);
        if b~=2
            dots=1:length(subset);
            exes=[];
        else
            exes=find([subject.trial(subset).stim]~=0);
            dots=find([subject.trial(subset).stim]==0);
        end
        output_=output{k}(subset);
        plot(subset(dots),output_(dots)+(k-1),'b.')
        plot(subset(exes),output_(exes)+(k-1),'bx')
        for kk=1:5
            symbol='.';
            plot(subject.block(b).trials(kk),output{k}(subject.block(b).trials(kk))+(k-1),[symbol,colors(kk)])
            plot(subject.block(b).trials(end-(kk-1)),output{k}(subject.block(b).trials(end-(kk-1)))+(k-1),[symbol,colors(6-kk)])
        end

        if learningStarttoFinish(k)&&(b==4)
            plot(centers(b),.05,'r*')
        end
        if learning3(k)&&(b==3)
            plot(centers(b),.05,'r*')
        end
        if aftereffects(k)&&(b==5)
            plot(centers(b),.05,'r*')
        end
    end
end

legends=cell(length(subject.block),1);
for k=1:length(subject.block)
    if strcmp(subject.block(k).treatName,'')
        plus='';
        if strcmp(subject.block(k).stimName,'')
            arrow='';
        else
            arrow=': ';
        end
    else
        arrow=': ';
        plus='+';
    end
    legends{k}=[subject.block(k).typeName,arrow,subject.block(k).stimName,plus,subject.block(k).treatName];
end
legends{end-1}=[legends{end-1},' ',legends{end}];
legends{end}=' ';


xtick=zeros(length(subject.block),1);

y=ylim;

for k=1:length(subject.block)
    if k>1
        plot([subject.block(k).trials(1)-.5 subject.block(k).trials(1)-.5],[y(1) y(2)],'r');
    end
    xtick(k)=mean([subject.block(k).trials(1) subject.block(k).trials(end)]);
end
L=subject.block(end).trials(end);


set(gca,'xlim',[1 L]);
set(gca,'xtick',xtick);
set(gca,'xticklabel',legends)
title(name)

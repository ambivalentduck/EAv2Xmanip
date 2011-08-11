clc
clear all
close all
tic

range=[1,2,5,7,10,11,13,15,19,21,22,26,27,29,30,301:320];

for k=range
    if(~exist(['../Data/',num2str(k),'.mat']))
        try
            addSubject(num2str(k))
            toc
        end
    end
end

matexists=zeros(400,1);

for k=range
    if(exist(['../Data/',num2str(k),'.mat']))
        matexists(k)=1;
    end
end

matexists=find(matexists);
l=length(matexists);

tauvalues=cell(l,1);
group=cell(l,1);

split=zeros(l,1);
eagroup=split;
delaygroup=split;


output={};
c=0;
toc
names={'Delay','Delay + EA','','EA'};
delay={'Delay','Delay + EA'};
ea={'Delay + EA','EA'};

numbers=zeros(size(matexists));
for k=matexists'
    k
    load(['../Data/',num2str(k),'.mat']);
    if sum(strcmp(subject.block(3).treatName,names))==0
        continue
    end
    c=c+1;
    
    if sum(strcmp(subject.block(3).treatName,delay))>0
        delaygroup(c)=1;
    end

    if sum(strcmp(subject.block(3).treatName,ea))>0
        eagroup(c)=1;
    end
    
    group{c}=subject.block(3).treatName;
    if isempty(group{c})
        group{c}='Null';
    end
    
    [tauvalues{c},split(c)]=getNewTau(subject);

    toc
end

slowtau=zeros(size(tauvalues));
fasttau=slowtau;

for k=1:length(tauvalues)
    fasttau(k)=min(tauvalues{k});
    slowtau(k)=max(tauvalues{k});
end

pslow=anovan(slowtau,{eagroup,delaygroup})
pfast=anovan(fasttau,{eagroup,delaygroup})
psplit=anovan(split,{eagroup,delaygroup})
annotatedplot(400,slowtau,group,@kruskalwallis,'Slow Tau','noplot')
annotatedplot(401,fasttau,group,@anova1,'Fast Tau') %,'noplot')
annotatedplot(402,split,group,@anova1,'Split') %,'noplot')

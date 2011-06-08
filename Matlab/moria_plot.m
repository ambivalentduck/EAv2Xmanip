clc
clear all
close all
tic
for k=1:40
    if(~exist(['../Data/',num2str(k),'.mat']))
        try
            addSubject(num2str(k))
            toc
        end
    end
end

matexists=zeros(40,1);

for k=1:40
    if(exist(['../Data/',num2str(k),'.mat']))
        if sum(k==[24])==0
            matexists(k)=1;
        end
    end
end

matexists=find(matexists);
l=length(matexists);

group=cell(length(matexists),1);
output={};
c=0;
toc
numbers=zeros(size(matexists));
for k=matexists'
    k
    c=c+1;
    load(['../Data/',num2str(k),'.mat']);
    numbers(c)=k;
    try
        output{k}.rawvals=subject.maxperpendicular;
    catch
        subject.maxperpendicular=feval(@maxperpendicular,subject);
        save(['../Data/',num2str(k),'.mat'],'subject')
        output{k}.rawvals=subject.maxperpendicular;
    end
    %output{k}.rawvals=subject.times./log(subject.maxperpendicular);
    group{c}=subject.block(3).treatName;
    if isempty(group{c})
        group{c}='Null';
    end
end

vals=zeros(c,3);

for cat=1:3
    learn3vals=zeros(l,1);
    echangevals=zeros(l,1);
    vchangevals=zeros(l,1);
    fevalues=zeros(l,1);
    trainingvariability=zeros(l,1);
    persistvalues=zeros(l,1);
    tauvalues=zeros(l,1);

    echangegroup=cell(l,1);
    c=0;
    for k=matexists'
        c=c+1;

        for b=1:length(subject.block)
            cats=[subject.trial(subject.block(b).trials).targetcat];
            subject.block(b).ctrials=subject.block(b).trials(cats==cat);
        end

        f=find([subject.trial(subject.block(2).ctrials).stim]~=0);
        exes2=subject.block(2).trials(f);

        trainingvariability(c)=std(output{k}.rawvals(subject.block(4).ctrials(floor(end/2):end)));

        echangevals(c)=mean(output{k}.rawvals(subject.block(4).ctrials))-mean(output{k}.rawvals(exes2));
        vchangevals(c)=std(output{k}.rawvals(subject.block(4).ctrials))/std(output{k}.rawvals(exes2));
        echangegroup{c}=group{c};

        fevalues(c)=mean(output{k}.rawvals(subject.block(4).ctrials(floor(end/2):end)));


        persistvalues(c)=mean(output{k}.rawvals(subject.block(4).ctrials(1:ceil(end/3))))-mean(output{k}.rawvals(subject.block(4).ctrials(floor(2*end/3):end)));

        vals(c,cat)=fevalues(c);

        toc
    end
end

[a,b,c]=unique(group);
data=cell(5,3);
for k=1:length(a)
    f=find(c==k);
    for kk=1:3
        data{k,kk}=vals(f,kk);
    end
end

anovavals=[vals(:,1); vals(:,2); vals(:,3)];
cat=[ones(size(vals(:,1)))*1;ones(size(vals(:,1)))*2;ones(size(vals(:,1)))*3];
groups=[group;group;group];
[p,table,stats]=anovan(anovavals,{groups,cat})


ave=zeros(5,3);
s=ave;
for k=1:5
    for kk=1:3
        ave(k,kk)=mean(data{k,kk});
        s(k,kk)=1.96*std(data{k,kk})/sqrt(length(data{k,kk}));
    end
end

figure(314159)
clf
hold on
color='rgb';
for k=1:3
    errorbar([1:5]+.1*(k-1),ave(:,k),s(:,k),[color(k),'.'])
end
set(gca,'xtick',1:5);
set(gca,'xticklabel',a);




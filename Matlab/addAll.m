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
        matexists(k)=1;
    end
end

matexists=find(matexists);
l=length(matexists);
aftereffects=matexists;
learning3=matexists;
learningStarttoFinish=matexists;

aftereffectsvals=zeros(10*l,1); %Paired Anova
learn3vals=zeros(l,1); 
learnSFvals=zeros(24*l,1); %Paired Anova

group=cell(length(matexists),1);
aftereffectsgroup=cell(1,10*l);
learnSFgroup=cell(1,24*l);


output={};
c=0;
toc
for k=matexists'
    k
    c=c+1;
    load(['../Data/',num2str(k),'.mat']);
    try
        output{k}.rawvals=subject.maxperpendicular;
    catch
        subject.maxperpendicular=feval(@maxperpendicular,subject);
        save(['../Data/',num2str(k),'.mat'],'subject')
        output{k}.rawvals=subject.maxperpendicular;
    end
        
    group{c}=subject.block(3).treatName;
    if isempty(group{c})
        group{c}='Null';
    end
    
    f=find([subject.trial(subject.block(2).trials).stim]~=0);
    exes2=subject.block(2).trials(f);
    f=find([subject.trial(subject.block(2).trials).stim]==0);
    dots2=subject.block(2).trials(f);

    sub=[subject.block(1).trials(end-9:end) subject.block(5).trials(1:10)];
    aftereffects(c)=regressNotZero(sub,output{k}.rawvals(sub));
    aftereffectsvals((10*(c-1)+1):(10*c))=output{k}.rawvals(sub(1:10))-output{k}.rawvals(sub(11:20));
    for cc=(10*(c-1)+1):(10*c)
        aftereffectsgroup{cc}=group{c};
    end
    
    subset=subject.block(3).trials;
    learning3(c)=regressNotZero(subset,output{k}.rawvals(subset));
    learn3vals((10*(c-1)+1):(10*c))=output{k}.rawvals(sub(1:10))-output{k}.rawvals(sub(11:20));

    sub=[exes2, subject.block(4).trials(end-length(exes2)+1:end)];
    le=length(exes2);
    learningStarttoFinish(c)=regressNotZero(sub,output{k}.rawvals(sub));
    learnSFvals((le*(c-1)+1):(le*c))=output{k}.rawvals(sub(1:le))-output{k}.rawvals(sub(le+1:end));
    for cc=(le*(c-1)+1):(le*c)
        learnSFgroup{cc}=group{c};
    end
    toc
end

[p,table,stats]=anova1(abs(aftereffectsvals),aftereffectsgroup)
c=multcompare(stats,'alpha',.05)

[p,table,stats]=anova1(learnSFvals,learnSFgroup)
[c,m,h]=multcompare(stats,'alpha',.05)
figure(h)
clf
hold on
for k=1:4
    plot([-m(k,2) m(k,2)]+m(k,1),[5-k 5-k],'b-',m(k,1),5-k,'bo')

toc


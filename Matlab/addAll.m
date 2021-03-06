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

aftereffectsvals=zeros(10*l,1); %Paired Anova
learn3vals=zeros(l,1);
%smallfeVals
echangevals=zeros(l,1);
vchangevals=zeros(l,1);
fevalues=zeros(l,1);
trainingvariability=zeros(l,1);
persistvalues=zeros(l,1);
tauvalues=zeros(l,1);

group=cell(length(matexists),1);
aftereffectsgroup=cell(1,10*l);
echangegroup=cell(l,1);


output={};
c=0;
toc
names={'Delay','Delay + EA','','EA'};


numbers=zeros(size(matexists));
for k=matexists'
    load(['../Data/',num2str(k),'.mat']);
    if sum(strcmp(subject.block(3).treatName,names))==0
        continue
    end
    c=c+1;
    numbers(c)=k;
        try
            output{k}.rawvals=subject.maxperpendicular;
        catch
            subject.maxperpendicular=feval(@maxperpendicular,subject);
            save(['../Data/',num2str(k),'.mat'],'subject')
            output{k}.rawvals=subject.maxperpendicular;
        end
    
    
        try
            output{k}.rawvals=subject.times;
        catch
            subject.times=feval(@reachtimes,subject);
            save(['../Data/',num2str(k),'.mat'],'subject')
            output{k}.rawvals=subject.times;
        end

    output{k}.rawvals=subject.times./log(subject.maxperpendicular);

    try
        output{k}.learnrate=subject.tau;
    catch
        [subject.expfitvals,subject.tau]=expFit(subject);
        save(['../Data/',num2str(k),'.mat'],'subject')
        output{k}.learnrate=subject.tau;
    end

    %     try
    %         output{k}.rawvals=subject.speed;
    %     catch
    %         subject.speed=avespeed(subject);
    %         save(['../Data/',num2str(k),'.mat'],'subject')
    %         output{k}.rawvals=subject.speed;
    %     end

    %     try
    %         output{k}.rawvals=subject.initialdirection;
    %     catch
    %         subject.initialdirection=initialdirection(subject);
    %         save(['../Data/',num2str(k),'.mat'],'subject')
    %         output{k}.rawvals=subject.initialdirection;
    %     end


    group{c}=subject.block(3).treatName;
    if isempty(group{c})
        group{c}='Null';
    end
    
    f=find([subject.trial(subject.block(2).trials).stim]~=0);
    exes2=subject.block(2).trials(f);

    sub=[subject.block(1).trials(end-9:end) subject.block(5).trials(1:10)]; %this is wrong, look at later
    aftereffects(c)=regressNotZero(sub,output{k}.rawvals(sub));
    aftereffectsvals((10*(c-1)+1):(10*c))=output{k}.rawvals(sub(1:10))-output{k}.rawvals(sub(11:20));
    for cc=(10*(c-1)+1):(10*c)
        aftereffectsgroup{cc}=group{c};
    end

    trainingvariability(c)=std(output{k}.rawvals(subject.block(4).trials(end/2-1:2:end-1)));

    echangevals(c)=mean(output{k}.rawvals(subject.block(4).trials(7:2:end-1)))-mean(output{k}.rawvals(exes2));
    vchangevals(c)=std(output{k}.rawvals(subject.block(4).trials(7:2:end-1)))/std(output{k}.rawvals(exes2));
    echangegroup{c}=group{c};

    sub=subject.block(4).trials(1:2:end-1);
    fevalues(c)=mean(output{k}.rawvals(sub(13:24)));

    persistvalues(c)=mean(output{k}.rawvals(sub(1:8)))-mean(output{k}.rawvals(sub(17:24)));

    tauvalues(c)=output{k}.learnrate;
    taugroup=echangegroup;

    toc
end



annotatedplot(1,-aftereffectsvals(1:c),aftereffectsgroup(1:c),@anova1,'After-Effects')

annotatedplot(2,-echangevals(1:c),echangegroup(1:c),@anova1,'Error Change in Eval 1 - 2')

annotatedplot(3,fevalues(1:c),echangegroup(1:c),@anova1,'Error Midway through Second Eval')

annotatedplot(4,persistvalues(1:c),echangegroup(1:c),@anova1,'Final Eror - Persistence')

annotatedplot(6,trainingvariability(1:c),echangegroup(1:c),@kruskalwallis,'Variability 2nd half of training')

annotatedplot(7,-vchangevals(1:c),echangegroup(1:c),@anova1,'Change in Variability Eval 1 - 2')

tauvalues=tauvalues(1:c);
fi=find(tauvalues<175);
annotatedplot(5,tauvalues(fi),taugroup(fi),@anova1,'Tau','noplot')
%annotatedplot(5,tauvalues,taugroup,@kruskalwallis,'Tau','noplot','this is dumb')
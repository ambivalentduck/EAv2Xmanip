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

aftereffectsvals=zeros(10*l,1); %Paired Anova
learn3vals=zeros(l,1); 
%smallfeVals
echangevals=zeros(l,1);
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
%     
%     try
%         output{k}.rawvals=subject.times;
%     catch
%         subject.times=feval(@reachtimes,subject);
%         save(['../Data/',num2str(k),'.mat'],'subject')
%         output{k}.rawvals=subject.times;
%     end
    
    %output{k}.rawvals=subject.times./log(subject.maxperpendicular);

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
    
    echangevals(c)=mean(output{k}.rawvals(subject.block(4).trials(1:2:end-1)))-mean(output{k}.rawvals(exes2));
    echangegroup{c}=group{c};
    
    sub=subject.block(4).trials(1:2:end-1);
    fevalues(c)=mean(output{k}.rawvals(sub(13:24)));
    
    persistvalues(c)=mean(output{k}.rawvals(sub(1:8)))-mean(output{k}.rawvals(sub(17:24)));

    tauvalues(c)=output{k}.learnrate;
    taugroup=echangegroup;
    
    toc
end

annotatedplot(1,-aftereffectsvals,aftereffectsgroup,@anova1,'After-Effects')

annotatedplot(2,-echangevals,echangegroup,@anova1,'Error Change in Eval 1 - 2')

annotatedplot(3,fevalues,echangegroup,@anova1,'Error Midway through Second Eval')

annotatedplot(4,persistvalues,echangegroup,@anova1,'Final Eror - Persistence')

annotatedplot(6,trainingvariability,echangegroup,@anova1,'Variability 2nd half of training')

fi=find(tauvalues<175);
annotatedplot(5,tauvalues(fi),taugroup(fi),@anova1,'Tau','noplot')
%annotatedplot(5,tauvalues,taugroup,@kruskalwallis,'Tau','noplot','this is dumb')
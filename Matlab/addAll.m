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

aftereffectsvals=zeros(10*l,1); %Paired Anova
learn3vals=zeros(l,1); 
%smallfeVals
echangevals=zeros(l,1);
fevalues=zeros(l,1);
persistvalues=zeros(l,1);
tauvalues=zeros(l,1);

group=cell(length(matexists),1);
aftereffectsgroup=cell(1,10*l);
echangegroup=cell(l,1);



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
    
    try
        output{k}.rawvals=subject.times;
    catch
        subject.times=feval(@reachtimes,subject);
        save(['../Data/',num2str(k),'.mat'],'subject')
        output{k}.rawvals=subject.times;
    end
    
    try
        error
        output{k}.learnrate=subject.tau;
    catch
        [subject.expfitvals,subject.tau]=expFit(subject);
        save(['../Data/',num2str(k),'.mat'],'subject')
        output{k}.learnrate=subject.tau;
    end
        
    group{c}=subject.block(3).treatName;
    if isempty(group{c})
        group{c}='Null';
    end

    
    f=find([subject.trial(subject.block(2).trials).stim]~=0);
    exes2=subject.block(2).trials(f);
   
    sub=[subject.block(1).trials(end-9:end) subject.block(5).trials(1:10)];
    aftereffects(c)=regressNotZero(sub,output{k}.rawvals(sub));
    aftereffectsvals((10*(c-1)+1):(10*c))=output{k}.rawvals(sub(1:10))-output{k}.rawvals(sub(11:20));
    for cc=(10*(c-1)+1):(10*c)
        aftereffectsgroup{cc}=group{c};
    end
    
    echangevals(c)=mean(output{k}.rawvals(subject.block(4).trials(2:2:end)))-mean(output{k}.rawvals(exes2));
    echangegroup{c}=group{c};
    
    sub=subject.block(4).trials(2:2:end);
    fevalues(c)=mean(output{k}.rawvals(sub(5:8)));
    
    persistvalues(c)=mean(output{k}.rawvals(sub(1:6)))-mean(output{k}.rawvals(sub(7:12)));

    tauvalues(c)=output{k}.learnrate;
    taugroup=echangegroup;

%     for nm=1:4
%         tauvalues(c+nm*l)=output{k}.learnrate;
%         taugroup=[taugroup; echangegroup];
%     end
    
    toc
end

figure(1)
[p,table,stats]=anova1(abs(aftereffectsvals),aftereffectsgroup,'off')
c=multcompare(stats,'alpha',.05)
title('After-Effects')

figure(2)
[p,table,stats]=anova1(abs(echangevals),echangegroup,'off')
c=multcompare(stats,'alpha',.05)
title('Error Change in Eval 1 - 2')

figure(3)
[p,table,stats]=anova1(fevalues,echangegroup,'off')
c=multcompare(stats,'alpha',.05)
title('Error Midway through Second Eval')

figure(4)
[p,table,stats]=anova1(persistvalues,echangegroup,'off')
c=multcompare(stats,'alpha',.05)
title('Final Eror - Persistence')

figure(5)
[p,table,stats]=kruskalwallis(tauvalues,taugroup,'off')
%[p,table,stats]=anova1(tauvalues,echangegroup,'off')
c=multcompare(stats,'alpha',.05)
title('Learning Rate')

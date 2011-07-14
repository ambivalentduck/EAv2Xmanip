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

for k=[1:40 106]
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
            output{k}.learnrate=subject.tau;
        catch
            [subject.expfitvals,subject.tau]=expFit(subject);
            save(['../Data/',num2str(k),'.mat'],'subject')
            output{k}.learnrate=subject.tau;
    end
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
        
        tauvalues(c)=output{k}.learnrate;
        
        toc
    end

%     annotatedplot(1+(cat-1)*4,-echangevals,echangegroup,@anova1,'Error Change in Eval 1 - 2')
% 
%     annotatedplot(2+(cat-1)*4,fevalues,echangegroup,@anova1,'Error Midway through Second Eval')
% 
%     annotatedplot(3+(cat-1)*4,persistvalues,echangegroup,@anova1,'Final Eror - Persistence')
% 
%     annotatedplot(4+(cat-1)*4,trainingvariability,echangegroup,@kruskalwallis,'Variability 2nd half of training')

    f1=find(strcmp(echangegroup,'Null'));
    f2=find(strcmp(echangegroup,'1995 Graphics'));
    annotatedplot(4000+(cat-1)*4,tauvalues([f1;f2]),echangegroup([f1;f2]),@anova1,'Learning Time Constant')

end
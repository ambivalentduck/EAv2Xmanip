clc
clear all
close all

spaceconst=70;

once=0;

matexists=zeros(40,1);

for k=[1:40 102]
    if(exist(['../Data/',num2str(k),'.mat']))
        if sum(k==[24])==0
            matexists(k)=1;
        end
    end
end

matexists=find(matexists);

c=0;
group={};
s={};
tic
for k=matexists'
    load(['../Data/',num2str(k),'.mat']);
    c=c+1;
    group{c}=subject.block(3).treatName;
    if isempty(group{c})
        group{c}='Null';
    end

    if ~once
        targetcats=[subject.trial(subject.block(4).trials).targetcat];
        one=subject.block(4).trials(find(targetcats==1));
        two=subject.block(4).trials(find(targetcats==2));
        three=subject.block(4).trials(find(targetcats==3));
        
        for kk=1:8
            names{kk}=num2str(kk);
            set{kk}=[one(kk) two(kk) three(kk)];
        end
    end

    for g=1:length(set)
        cats=[subject.trial(set{g}).targetcat];
        for cat=1:3
            data(c,cat,g)=subject.maxperpendicular(set{g}(find(cats==cat)));
        end
    end
    k
    toc
end

[treatlabels,trash,groupnums]=unique(group);
o=ones(size(data(:,1,g)));
catvec=[o; o*2; o*3];
groupnumsvec=[groupnums';groupnums';groupnums'];

for g=1:length(set)
    datavec=[[data(:,1,g)]; [data(:,2,g)]; [data(:,3,g)]];
    [p,table,stats]=anovan(datavec,{groupnumsvec, catvec},'display','off');
    table{2,end}
end



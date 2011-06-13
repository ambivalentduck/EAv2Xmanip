clc
clear all
close all

spaceconst=70;

once=0;

matexists=zeros(40,1);

for k=1:40
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
        figure(100)
        clf
        hold on

        names{1}='Baseline';
        set{1}=subject.block(1).trials(end/2-2:2:end-1);

        names{2}='Initial Exposure';
        f=find([subject.trial(subject.block(2).trials).stim]~=0);
        set{2}=subject.block(2).trials(f);

        names{3}='After Training';
        set{3}=subject.block(4).trials(end/2-3:2:end-1);

        aftereffects=subject.block(5).trials(1);
        cc=1;
        targetcats=subject.trial(subject.block(5).trials(1)).targetcat;
        while (length(aftereffects)<3)&&cc<20
            cc=cc+2;
            if sum(targetcats==subject.trial(subject.block(5).trials(cc)).targetcat)<1
                aftereffects(end+1)=subject.block(5).trials(cc);
                targetcats(end+1)=subject.trial(subject.block(5).trials(cc)).targetcat;
            end
        end
        names{4}='Aftereffects';
        set{4}=aftereffects;
        once=1;
    end

    for g=1:4
        cats=[subject.trial(set{g}).targetcat];
        clear concat;
        for cat=1:3
            f=find(cats==cat);
            completiontime=zeros(length(f),1);
            for kk=1:length(f)
                dat=subject.trial(set{g}(f(kk)));
                target=dat.target;
                x=dat.drawn;
                t=dat.time';
                o=dat.origin;

                x=[x(:,1)-o(1), x(:,2)-o(2)];

                d=sqrt(x(:,1).^2 + x(:,2).^2);
                cc=1;
                while d(cc)<(.4436/50+.4436/25)
                    cc=cc+1;
                end
                t=t-t(cc);
                ft=find(t>=0);
                concat.direction(cat).n(kk).t=t(ft);
                completiontime(kk)=concat.direction(cat).n(kk).t(end);

                concat.direction(cat).n(kk).x=subject.trial(set{g}(f(kk))).drawn(ft,1)';
                concat.direction(cat).n(kk).y=-subject.trial(set{g}(f(kk))).drawn(ft,2)';
            end
            tlist=[concat.direction(cat).n.t];
            tdesired=linspace(0,min(completiontime),100);
            s.block(g).cat(cat).val(c).t=tdesired;
            s.block(g).cat(cat).val(c).x=weightedAve(tlist,[concat.direction(cat).n.x],tdesired,spaceconst)';
            s.block(g).cat(cat).val(c).y=weightedAve(tlist,[concat.direction(cat).n.y],tdesired,spaceconst)';
        end
    end
    k
    toc
end

[treatlabels,trash,groupnums]=unique(group);
colors=[1, 0, 0;
    0,1,0;
    0,0,1;
    0,0,.5;
    1,.5,.5;
    0,1,1;
    1,1,0;
    1,0,1];


for k=1:5
    f=find(groupnums==k);
    for g=1:4
        subplot(5,4,g+(k-1)*4)
        if k==1
            title(names{g})
        end
        if g==1
            ylabel(treatlabels{k})
        end
        hold on
        for kk=1:length(f)
            for kkk=1:3
                plot(s.block(g).cat(kkk).val(f(kk)).x,s.block(g).cat(kkk).val(f(kk)).y,'Color',colors(kk,:))
            end
        end
        axis equal
    end
end

figure(101)
clf
for k=1:5
    f=find(groupnums==k);
    for g=1:4
        subplot(5,4,g+(k-1)*4)
        if k==1
            title(names{g})
        end
        if g==1
            ylabel(treatlabels{k})
        end
        hold on
        for cat=1:3
            tdesired=linspace(0,.65,100);
            tlist=[s.block(g).cat(cat).val(f).t];
            x=weightedAve(tlist,[s.block(g).cat(cat).val(f).x],tdesired,spaceconst);
            y=weightedAve(tlist,[s.block(g).cat(cat).val(f).y],tdesired,spaceconst);
            plot(x,y,'k')
        end
        axis equal
    end
end



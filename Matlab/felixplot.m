function felixplot(subject)

spaceconst=70;

figure(98)
clf
title('Stuff')

names{1}='Baseline';
set{1}=subject.block(1).trials(end/2-2:2:end-1);

names{2}='Initial Exposure';
f=find([subject.trial(subject.block(2).trials).stim]~=0);
set{2}=subject.block(2).trials(f);

names{3}='After Training';
set{3}=subject.block(4).trials(end/2-3:2:end-1);

aftereffects=subject.block(5).trials(1);
c=1;
targetcats=subject.trial(subject.block(5).trials(1)).targetcat;
while (length(aftereffects)<3)&&c<20
    c=c+2;
    if sum(targetcats==subject.trial(subject.block(5).trials(c)).targetcat)<1
        aftereffects(end+1)=subject.block(5).trials(c);
        targetcats(end+1)=subject.trial(subject.block(5).trials(c)).targetcat;
    end
end
names{4}='Aftereffects';
set{4}=aftereffects;

for g=1:4
    subplot(2,2,g)
    title(names{g})
    hold on
    cats=[subject.trial(set{g}).targetcat];
    clear concat;
    for k=1:3
        f=find(cats==k);
        completiontime=zeros(length(f),1);
        for kk=1:length(f)
            dat=subject.trial(set{g}(f(kk)));
            target=dat.target;
            x=dat.drawn;
            t=dat.time';
            o=dat.origin;

            x=[x(:,1)-o(1), x(:,2)-o(2)];

            d=sqrt(x(:,1).^2 + x(:,2).^2);
            c=1;
            while d(c)<(.4436/50+.4436/25)
                c=c+1;
            end
            t=t-t(c);
            ft=find(t>=0);
            concat.direction(k).n(kk).t=t(ft);
            completiontime(kk)=concat.direction(k).n(kk).t(end);
            
            concat.direction(k).n(kk).x=subject.trial(set{g}(f(kk))).drawn(ft,1)';
            concat.direction(k).n(kk).y=-subject.trial(set{g}(f(kk))).drawn(ft,2)';
        end
        tlist=[concat.direction(k).n.t];
        tdesired=linspace(0,min(completiontime),100);
        %tdesired=linspace(0,min(completiontime)+std(completiontime),100);
        %weightedAve(t,x or y,desired ts, arbitrary %scale)
        xw=weightedAve(tlist,[concat.direction(k).n.x],tdesired,spaceconst);
        yw=weightedAve(tlist,[concat.direction(k).n.y],tdesired,spaceconst);
        plot(xw,yw);
    end
    axis equal
end
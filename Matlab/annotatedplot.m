function annotatedplot(fignum,values, group, fcn, ptitle, varargin)
% function(data,group,test)

figure(fignum)
clf
[p,table,stats]=fcn(values,group,'off');
[c,m,h]=multcompare(stats,'alpha',.05);

title(ptitle)

qtable=[0.970
    0.829
    0.710
    0.625
    0.568
    0.526
    0.493
    0.466]; %smallest val is for n=3, largest for n=10


figure(h)
hold on
labels=get(gca,'yticklabel');
ticks=get(gca,'ytick');
fails=[];

for k=1:length(ticks)
    f=find(strcmp(group,labels{k}));
    vals=values(f);
    plot(vals,ticks(k)*ones(size(vals)),'x')

    try
        [svals,ind]=sort(vals);
        range=svals(end)-svals(1);
        gapmin=svals(2)-svals(1);
        gapmax=svals(end)-svals(end-1);
        n=length(svals);
        if gapmax>gapmin
            gap=gapmax;
            qout=n;
        else
            gap=gapmin;
            qout=1;
        end
        Q=gap/range;

        if (n<10)&&(n>2)
            if Q>qtable(n-2)
                if nargin < 7title(ptitle)
                    plot(svals(qout),ticks(k),'rx')
                end
                failpoint=f(ind(qout))
                fails(end+1)=f(ind(qout));
            end
        end
    end
end


if ~isempty(fails)
    figure(fignum+200)
    clf
    hold on
    comp=zeros(size(values));
    l=[1:length(values)]';
    for k=1:length(fails)
        comp=comp+(l~=fails(k));
    end
    f=find(comp==k);
    [p,table,stats]=fcn(values(f),group(f),'off');
    [c,m,h]=multcompare(stats,'alpha',.05);
    hold on
    for k=1:length(ticks)
        f2=find(strcmp(group(f),labels{k}));
        vals=values(f);
        vals=vals(f2);
        plot(vals,ticks(k)*ones(size(vals)),'x')
    end
    title(ptitle)
end


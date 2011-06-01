function annotatedplot(values, group, fcn, varargin)
% function(data,group,test)

[p,table,stats]=fcn(values,group,'off');
[c,m,h]=multcompare(stats,'alpha',.05);

if ~isempty(varargin{1})
    title(varargin{1})
end

qtable=[0.970
    0.829
    0.710
    0.625
    0.568
    0.526
    0.493
    0.466]; %smallest val is for n=3, largest for n=10

%if isempty(varargin{2})
    figure(h)
    hold on
    labels=get(gca,'yticklabel');
    ticks=get(gca,'ytick');
    for k=1:length(ticks)
        f=find(strcmp(group,labels{k}));
        vals=values(f);
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
        plot(vals,ticks(k)*ones(size(vals)),'x')
        if n<10
            if Q>qtable(n-2)
                plot(svals(qout),ticks(k),'rx')
                failpoint=f(ind(qout))
            end
        end
    end
%end
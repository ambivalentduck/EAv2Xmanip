function plotlaunches(fig,lower,subject,colors,centers)

figure(fig)

lengths=zeros(length(subject.block),1);
for b=1:length(subject.block)
    lengths(b)=length(subject.block(b).trials);
end
ave=mean(lengths);
[val,i]=min(abs(lengths-ave));
xscale=1/length(subject.block(i).trials);


triangle_offset=.35;

for b=1:length(subject.block)
    trials=[subject.block(b).trials(1:2:9) subject.block(b).trials(end-9:2:end-1)];
    for trial=1:length(trials)
        if trial<(length(trials)/2+1)
            upper=1;
        else
            upper=0;
        end
        
        dat=subject.trial((trials(trial)));
        target=dat.target;
        x=dat.drawn;
        t=dat.time;
        o=dat.origin;
        target=target-o;
        yscale=2/((2+sqrt(2))*norm(target));

        theta=-atan2(target(2),target(1))+pi/2;
        x=[x(:,1)-o(1), x(:,2)-o(2)];
        
        %find "outside target"
        d=sqrt(x(:,1).^2 + x(:,2).^2);
        c=1;
        while d(c)<(.4436/50+.4436/25)
            c=c+1;
        end
        
        %snag position ~150 ms later, maybe 100, 150, and 200
        [m,i]=min(abs(t-(t(c)+.100)));
        
        plot(x(:,1)*yscale/xscale+centers(b),x(:,2)*yscale+lower+upper+triangle_offset,colors(mod(trial-1,5)+1));
        plot(x(i,1)*yscale/xscale+centers(b),x(i,2)*yscale+lower+upper+triangle_offset,'rx') %100 ms
        plot(target(1)*yscale/xscale+centers(b),target(2)*yscale+lower+upper+triangle_offset,'kx')
    end
end
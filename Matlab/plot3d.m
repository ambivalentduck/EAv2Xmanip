function plot3d(subject)

figure(99)
clf
hold on

color='rgb';

for k=subject.block(3).trials(1:2:end-1)
    dat=subject.trial(k);
    target=dat.target;
    x=dat.drawn;
    t=dat.time;
    o=dat.origin;
    target=target-o;

    x=[x(:,1)-o(1), x(:,2)-o(2)];

    %find "outside target"
    d=sqrt(x(:,1).^2 + x(:,2).^2);
    c=1;
    while d(c)<(.4436/50+.4436/25)
        c=c+1;
    end

    %snag position ~150 ms later, maybe 100, 150, and 200
    [m,i]=min(abs(t-(t(c)+.100)));

    kk=k/1000;
    plot3(x(:,1),-x(:,2),kk*ones(size(x(:,2))),color(dat.targetcat));
    plot3(x(i,1),-x(i,2),kk,'rx') %100 ms
    plot3(target(1),-target(2),kk,'cx')
end

axis equal
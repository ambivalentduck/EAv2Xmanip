function out=initialdirection(varargin)

if strcmp(varargin{1},'ylabel')
    out='Initial Direction';
    return
end

subject=varargin{1};

out=zeros(length(subject.trial),1);

for k=1:length(subject.trial)
    x=subject.trial(k).drawn;
    o=subject.trial(k).origin;
    x=[x(:,1)-o(1) x(:,2)-o(2)];
    %find "outside target"
    d=sqrt(x(:,1).^2 + x(:,2).^2);
    c=1;
    while d(c)<(.4436/50+.4436/25)
        c=c+1;
    end
    %snag position ~150 ms later, maybe 100, 150, and 200
    t=subject.trial(k).time;
    [m,i]=min(abs(t-(t(c)+.100)));
    target=subject.trial(k).target;
    target=target-o;
    out(k)=atan2(x(i,2),x(i,1))-atan2(target(2),target(1));
end






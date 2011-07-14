function out=reachtimes(varargin)

if strcmp(varargin{1},'ylabel')
    out='Reach Time';
    return
end

subject=varargin{1};

out=zeros(length(subject.trial),1);

for k=1:length(subject.trial)
    dat=subject.trial(k);
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
    out(k)=t(end);
end
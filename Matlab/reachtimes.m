function out=reachtimes(varargin)

if strcmp(varargin{1},'ylabel')
    out='Reach Time';
    return
end

subject=varargin{1};

out=zeros(length(subject.trial),1);

for k=1:length(subject.trial)
    speed=sqrt(subject.trial(k).vel(:,1).^2+subject.trial(k).vel(:,2).^2);
    f=find(speed>.05);
    out(k)=subject.trial(k).time(end)-subject.trial(k).time(f(1));
end
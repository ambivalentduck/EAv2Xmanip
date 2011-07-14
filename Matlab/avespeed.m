function out=avespeed(varargin)

if strcmp(varargin{1},'ylabel')
    out='Average Speed';
    return
end

subject=varargin{1};

out=zeros(length(subject.trial),1);

for k=1:length(subject.trial)
    speed=sqrt(subject.trial(k).vel(:,1).^2+subject.trial(k).vel(:,2).^2);
    out(k)=mean(speed);
end
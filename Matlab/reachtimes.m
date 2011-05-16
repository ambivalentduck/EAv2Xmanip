function out=reachtimes(varargin)

if strcmp(varargin{1},'ylabel')
    out='Reach Time';
    return
end

subject=varargin{1};

out=zeros(length(subject.trial),1);

for k=1:length(subject.trial)
    out(k)=subject.trial(k).time(end)-subject.trial(k).time(1);
end
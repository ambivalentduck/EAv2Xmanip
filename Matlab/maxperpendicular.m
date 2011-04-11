function out=maxperpendicular(varargin)

if strcmp(varargin{1},'ylabel')
    out='Max Perpendicular Distance';
    return
end

subject=varargin{1};

out=zeros(length(subject.trial),1);

for k=1:length(subject.trial)
    x=subject.trial(k).drawn;
    o=x(1,:);
    x=[x(:,1)-o(1), x(:,2)-o(2)];
   
    try
        M=subject.trial(k).target-o;
    catch
        M=subject.trial(k).target'-o;
    end
    dists=zeros(length(subject.trial(k).time),1);
    for kk=1:length(subject.trial(k).time)
        dists(kk)=norm(x(kk,:)-(dot(x(kk,:),M)/dot(M,M))*M);
    end
    out(k)=max(dists);
end
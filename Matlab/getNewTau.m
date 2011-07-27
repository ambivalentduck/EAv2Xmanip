function tau=getNewTau(sub,plot)

if isa(sub,'double')
    try
        load(['../Data/',num2str(sub),'.mat']);
    catch
        addSubject(num2str(sub));
        load(['../Data/',num2str(sub),'.mat']);
    end
else
    subject=sub;    
end

try
    data=subject.fittsconstant(subject.block(3).trials); %#ok<NODEF>
    %data=subject.maxperpendicular(subject.block(3).trials); %#ok<NODEF>
catch %#ok<CTCH>
    subject.fittsconstant=feval(@fittsconstant,subject);
    %subject.maxperpendicular=feval(@maxperpendicular,subject);
    save(['../Data/',num2str(sub),'.mat'],'subject')
    %data=subject.maxperpendicular(subject.block(3).trials);
    data=subject.fittsconstant(subject.block(3).trials); %#ok<NODEF>
end

[v,i]=min(data);

datat=[(1:length(data))',log(data-min(data))];

datat=datat((1:length(data))~=i,:);

if nargin>1
    p=linplotEM(datat);
else
    p=linsepEM(datat);
end

temp=[p{end}.p{:}];
tau=-1./[temp.m];
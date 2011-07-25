function params=EM(data, groups, calcparams, calcprob)

%assume data is structured with rows as "members" and columns as measures

if nargin<3
    %     calcparams=@gaussparams;
    %     calcprob=@gaussprob;
    calcparams=@linfit;
    calcprob=@linprob;
end

L=size(data,1);
shuffle=mod([1:L]-1,groups)+1;
shuffle=shuffle(randperm(L))';

for k=1:groups
    params(k)=calcparams(data(shuffle==k,:));
end

oldshuffle=shuffle;
first=true;
rm=[];
ITER=0;

while ((sum(shuffle~=oldshuffle)>0)||first)&&(ITER<1000)
    ITER=ITER+1;
    first=false;
    oldshuffle=shuffle;
    c=calcprob(data,params);
    [trash,shuffle]=max(c,[],2);
    for k=1:groups
        f=find(shuffle==k);
        if ~isempty(f)
            params(k)=calcparams(data(f,:));
        else
            rm(end+1)=k;
        end
    end
    if ~isempty(rm)
        oldparams=params;
        clear params;
        K=0;
        for k=1:groups;
            if sum(k==rm)==0
                K=K+1;
                params(K)=oldparams(k);
            end
        end
        groups=groups-length(rm);
        rm=[];
    end
end

function params=linfit(data)
x=[data(:,1) ones(size(data,1),1)]\data(:,2);
params.m=x(1);
params.b=x(2);
resid=data(:,2)-data(:,1)*x(1)+x(2);
params.res_mu=mean(resid);
params.res_std=std(resid);

function prob=linprob(data,params)
L=size(data,1);
P=length(params);

prob=zeros(L,P);
for g=1:P
%     x0=[0 params(g).b];
%     x1=[1 params(g).m+params(g).b];
%     M=x0-x1;
%     m2=norm(M)^2;
%     prob(:,g)=ones(L,1)*M
    resid=data(:,2)-data(:,1)*params(g).m+params(g).b; %only along y
    prob(:,g)=resid.^2;
    %prob(:,g)=exp(-(resid-params(g).res_mu).^2./(2*params(g).res_std.^2))./(2*pi*params(g).res_std.^2);
end

function params=gaussparams(data)
params.mean=mean(data);
params.std=std(data);

function prob=gaussprob(data,params)
L=size(data,1);
P=length(params);

prob=zeros(L,P);
for g=1:P
    prob(:,g)=exp(-(data-params(g).mean).^2./(2*params(g).std.^2))./(2*pi*params(g).std.^2);
end
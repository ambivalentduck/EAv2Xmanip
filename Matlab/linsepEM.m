function params=linsepEM(data)

%assume data is structured with rows as "members" and columns as measures

L=size(data,1);

split=15; %floor(L/2);
params{1}.p{1}=linfit(data(1:split,:));
params{1}.p{2}=linfit(data(split+1:end,:));

ITER=0;
oldsplit=inf;

while (split~=oldsplit)&&(ITER<1000)
    ITER=ITER+1;
    oldsplit=split;
    split=linprob(data,params{ITER}.p);
    params{ITER+1}.split=split;
    params{ITER+1}.p{1}=linfit(data(1:split,:));
    params{ITER+1}.p{2}=linfit(data(split+1:end,:));
    if split==0
        params{ITER+1}.p={params{ITER+1}.p{2}};
    elseif split==L
        params{ITER+1}.p={params{ITER+1}.p{1}};
    else
        continue;
    end
    split
    break;
end
disp([num2str(ITER),' iterations to converge.'])

function params=linfit(data)
x=[data(:,1) ones(size(data,1),1)]\data(:,2);
params.m=x(1);
params.b=x(2);
resid=data(:,2)-data(:,1)*x(1)+x(2);
params.res_mu=mean(resid);
params.res_std=std(resid);

function split=linprob(data,params)
L=size(data,1);
P=length(params);

data=[data,zeros(L,1)];

prob=zeros(L,P);
for g=1:P
    x0=[0 params{g}.b 0];
    x1=[1 params{g}.m+params{g}.b 0];
    M=x1-x0;
    m2=norm(M)^2;
    calc=cross(ones(L,1)*M,ones(L,1)*x0-data)/m2;
    prob(:,g)=calc(:,3);
end

cost=zeros(L+1,1);
Prob=prob.^2;
for k=0:L
    cost(k+1)=sum(Prob(1:k,1))+sum(Prob(k+1:end,2));
end
[trash,split]=min(cost);
split=split-1; %account for zero v one-based indexing



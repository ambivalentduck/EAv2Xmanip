function params=linplotEM(data)

close all

params=linsepEM(data);

mId=min(data(:,1));
mAd=max(data(:,1));
md=[mId,mAd];

colors='rg';

figure(1)
clf
hold on

for K=1:length(params{1}.p)
    plot(md,md*params{1}.p{K}.m+params{1}.p{K}.b,'r')
end

for K=1:length(params{end}.p)
    plot(md,md*params{end}.p{K}.m+params{end}.p{K}.b,'g')
end

plot(data(:,1),data(:,2),'.')



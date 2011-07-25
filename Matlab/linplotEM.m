function params=linplotEM(data,groups)

close all
figure(1)
clf
hold on

params=EM(data,groups);

mId=min(data(:,1));
mAd=max(data(:,1));
md=[mId,mAd];

labels={};

for k=1:length(params)
    plot(md,md*params(k).m+params(k).b,'r')
    labels{k}=[num2str(params(k).m),'x+',num2str(params(k).b)];
end

legend(labels)

plot(data(:,1),data(:,2),'.')



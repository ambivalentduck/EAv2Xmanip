function params=linplotEM(data)

close all

params=linsepEM(data);

mId=min(data(:,1));
mAd=max(data(:,1));
md=[mId,mAd];

colors='rgbcmyk';

figure(1)
clf
hold on
for k=1:length(params)
    for K=1:length(params{k}.p)
        plot(md,md*params{k}.p{K}.m+params{k}.p{K}.b,colors(k))
    end
end


plot(data(:,1),data(:,2),'.')



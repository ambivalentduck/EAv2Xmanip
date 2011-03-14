clc
clear all
tic;

N=10000;

data={};
data2={};
matrix=zeros(100,1);
times=zeros(N,1);

for k=1:N
    data(k).dat=rand(1000,1);
    data(k).t=toc;
end

for k=1:N
    data2(k).dat=rand;
    data2(k).t=toc;
end

for k=1:N
    matrix(:,k)=rand(100,1);
    times(k)=toc;
end

t=[data.t];
t2=[data2.t];

plot(1:N-1,diff(t),'b',1:N-1,diff(t2),'k',1:N-1,diff(times),'r')
xlabel('Array Length')
ylabel('Time to Allocate a New Member')
legend('Structure array. Member: rand(1000,1)','Structure array. Member: rand(1,1)','Matrix. Member: rand(100,1)')

    
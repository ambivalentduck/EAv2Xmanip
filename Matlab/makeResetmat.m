function makeResetmat(name)

input=load(['../Data/input',name,'.dat']);
output=load(['../Data/output',name,'.dat']);
size(output)
f=find(input(:,2)~=0);

for k=1:length(f)
    fo=find(output(:,1)==f(k));
    trials{k}.pos=output(fo,[3 4]);
    trials{k}.force=output(fo,[9 10]);
    trials{k}.mag=input(f(k),2);
    trials{k}.delay=input(f(k),5);
end


save(['../Data/',name,'.mat'],'trials')
function out=movingmin(in,n)

cn2=ceil(n/2);
lin=length(in);

out=zeros(size(in));

for k=1:lin
    out(k)=min(in(max(1,k-cn2):min(lin,k+cn2)));
end
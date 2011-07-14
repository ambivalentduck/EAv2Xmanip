function out=movave(in,n)

out=in;

l=length(out);
for k=1:l
    out(k)=mean(in(max(1,k-floor(n/2)):min(l,k-ceil(n/2))));
end
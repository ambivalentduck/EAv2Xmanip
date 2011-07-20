function out=denoise_poisson(in)

if ischar(in)
    out=['Denoised ',in];
    return;
end

u=in;
f=movingmin(in,5);

%Choose B = 1
B=1;
%Naively choose alpha = .5;
a=.5;
m=norm(in)/100;

laststep=inf;
k=1;
while 1
    k=k+1;
    gradu=gradient(u);
    div=gradient(u./abs(u));
    Epu=-div+B./u.*(u-f);
    u=u-a*Epu;
    n=norm(a*Epu);
    if laststep-n<n/1000
        break
    end
    laststep=n;
end
k
out=u;
function v=deriv(x1)
[m,n]=size(x1);
x1d=diff(x1);

j_inds=1:2:(m-2)*2;
i_inds=1:m-2;
iis=1:m-2;
jjs=2:2:2*m-4;
i2_inds=1:2:2*m-1;
ii_inds=1:(2*m-1)/2+1;


for k=1:n
    x2d(j_inds,1)=x1d(i_inds,k);
    x2d(jjs,1)=.5*(x1d(iis,k)+x1d(iis+1,k));
    x2d(jjs(end)+1)=x1d(end,k);
    x2da=2*x2d(1)-x2d(2);
    x2db=2*x2d(end)-x2d(end-1);
    x11d=[x2da; x2d; x2db];
    v(ii_inds,k)=x11d(i2_inds);
end

%makes resulting vector same length as original one. only way its different
%than diff
%Must be in the form of a column vector
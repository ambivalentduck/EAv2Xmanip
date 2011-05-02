function [e, g]=fitexp(x)
global yhat n

y=x(1)*exp(-x(2)*n)+x(3);
e=0.5*sum((y-yhat).^2);
g(1)=sum((y-yhat).*exp(-x(2)*n));
g(2)=sum(-(y-yhat).*x(1).*n.*exp(-x(2)*n));
g(3)=sum(y-yhat);

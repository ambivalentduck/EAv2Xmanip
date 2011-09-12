function makerandomwalkinput

global reachdist
reachdist=.45;

fhandle=fopen('../Data/input608.dat','wt');

pos=[0,0];
x=zeros(430,2);

for k=1:28
    pos=genpos(pos);
    x(k,:)=pos;
    fprintf(fhandle, '%i\t%i\t%i\t%6.6f\t%6.6f\n',k,0,0,pos(1),pos(2)-.4);
end

pos=gotozero(pos);
x(29,:)=pos;
fprintf(fhandle, '%i\t%i\t%i\t%6.6f\t%6.6f\n',29,0,0,pos(1),pos(2)-.4);

x(30,:)=[0 0];
fprintf(fhandle, '%i\t%i\t%i\t%6.6f\t%6.6f\n',30,0,0,0,0);

norm(pos)

for k=31:430
    pos=genpos(pos);
    x(k,:)=pos;
    fprintf(fhandle, '%i\t%i\t%i\t%6.6f\t%6.6f\n',k,mod(k,2),4,pos(1),pos(2)-.4);
end

figure(1)
clf
hold on
plot(x(:,1),x(:,2),'b')
plot(x(28:30,1),x(28:30,2),'r')
axis equal

for k=1:430
    if norm(x(k,:))>1
        k
    end
end



function out=gotozero(in)
global reachdist
D=norm(in);
gamma=acos(1-D^2/(2*reachdist^2));
phi=atan2(in(2),in(1));
theta=phi-gamma-pi/2;
out=in+[cos(theta),sin(theta)]*reachdist;

function out=genpos(in)
global reachdist
k=0;
first=1;
out=[inf,inf];
while ((norm(out)>.5)&&(k<1000))||first==1
    first=0;
    theta=rand*360;
    out=in+[cos(theta),sin(theta)]*reachdist;
end
if(k>=1000)
    out=out/norm(out);
end
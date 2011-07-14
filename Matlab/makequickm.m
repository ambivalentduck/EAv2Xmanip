function makequickm()

Treat=0;
Stim=1;
number=667;

if Treat==3
    Treat=2;
    X2dist=1;
else
    X2dist=0;
end

fhandle=fopen(['../Data/input',num2str(number),'.dat'],'wt');

%In center out reaching, you really only define half of the targets.  The
%goal is a shuffle of 2 lengths with 3 directions.  So, block lengths
%should be even multiples of 12.

directions=[pi/6 5*pi/6 3*pi/2]; % Y shape to avoid motor
%Only need to compute trig/multiply once
cd=cos(directions);
sd=sin(directions);
cd2=cd/2;
sd2=sd/2;

xtable=[cd2',cd'];
ytable=[sd2',sd'];
%use via xtable(direction, distance), directions 1-3 and distance (.5 or 1)
%as (1 or 2)

offset=0;
dist=1;

[dir,s]=shuffleStuff(15, 0);
for k=1:30
    if mod(k,2)
        fprintf(fhandle, '%i\t%i\t%i\t%6.6f\t%6.6f\t%6.6f\n',k,0,0,0,0,.05);
    else
        fprintf(fhandle, '%i\t%i\t%i\t%6.6f\t%6.6f\t%6.6f\n',k,0,0,xtable(dir(k/2),dist),ytable(dir(k/2),dist),.05);
    end
end
[dir,s]=shuffleStuff(30, 0);
for k=31:90
    if mod(k,2)
        fprintf(fhandle, '%i\t%i\t%i\t%6.6f\t%6.6f\t%6.6f\n',k,0,3,0,0,.05);
    else
        fprintf(fhandle, '%i\t%i\t%i\t%6.6f\t%6.6f\t%6.6f\n',k,0,3,xtable(dir(k/2-15),dist),ytable(dir(k/2-15),dist),.05);
    end
end
for k=91:150
    if mod(k,2)
        fprintf(fhandle, '%i\t%i\t%i\t%6.6f\t%6.6f\t%6.6f\n',k,0,3,0,0,0);
    else
        fprintf(fhandle, '%i\t%i\t%i\t%6.6f\t%6.6f\t%6.6f\n',k,0,3,xtable(dir(k/2-45),dist),ytable(dir(k/2-45),dist),0);
    end
end

fclose(fhandle);


function [dir,s]=shuffleStuff(n, sporadic)
n3=mod(n,3);
if n3 ~= 0
    error('N is the wrong size.  Should be divisible by 3.')
end

if (n~=8*8*3) && sporadic
    error('N must be 8*8*3 when sporadic')
end

r1=randperm(n);

direction=ceil(3*(1:n)/n); %A list of 1s, 2s, and 3s, sorted: 111222333 etc
%distance=mod((1:n)-1,2)+1; Not presently in use, but would go 12121212 etc
if sporadic
    s=zeros(size(direction));
    first=find(direction==1);
    second=find(direction==2);
    third=find(direction==3);
    s([first(1:8) second(1:8) third(1:8)])=ones(24,1);
else
    s=zeros(size(direction));
end

flag=1;
while flag
    flag=0;
    for k=1:length(r1)
        if s(r1(k))==1
            if sum(s(r1(k:min(k+3,n))))>1 %Don't permit to catch trials within 4 trials of one another
                temp=r1(k);
                rnd=floor(rand*n)+1;
                r1(k)=r1(rnd);
                r1(rnd)=temp;
                flag=1;
                break;
            end
        end
    end
end

dir=direction(r1);
%dist=distance(r1);
s=s(r1);
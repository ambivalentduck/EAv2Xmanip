function y=smartlabel(rr,cc,rlabel, clabel, rowtext, coltext, override, override2)

if nargin<7; override=0; end
if nargin<8; override2=0; end

%set(gcf, 'Pos', [80     10   800   600])
wfract=.85/clabel;
hfract=.9/rlabel;

width=wfract-.02;
height=hfract-.02;

if override
    hfract=.9/rlabel;
    height=hfract-.075;

end

xpos=(cc-1)*wfract+.1;
ypos=(-rr+rlabel)*hfract+.075;

RECT=[xpos ypos width height];

hh=get(gcf,'Children');
size(hh);
ztest=sign(prod(size(hh)));

if ztest==1
    for nq=1:length(hh);
        hhpos=get(hh(nq),'Position');
        %[hhpos; RECT]
        axisnow(nq)=(sum(hhpos==RECT)==4);
    end

    qq=find(axisnow==1);
    if isempty(qq);     y=axes('position', RECT);
    else
        oldhandle=hh(qq);
        y=oldhandle;
        axes(oldhandle);
    end
end




if ztest==0;
    y=axes('position', RECT);
end
%box on;

if rr==rlabel; ccc=xlabel(rowtext,'fonts',12);

end
if cc==1; ddd=ylabel(coltext,'fonts',12 ); end

if ((override==0)&(override2==0))
    if rr~=rlabel; set(y, 'Xticklabel', ''); end
    
    if cc~=1;   set(gca, 'Yticklabel', ''); end
end

if ((override2==1))
    
    if cc~=1;   set(gca, 'Yticklabel', ''); end
end


if override;
    xxs=get(y,'Xtick');
    yys=get(y,'Ytick');

     set(y, 'Xticklabel', xxs);
    % set(y, 'Yticklabel', yys);
    xlabel(rowtext,'fonts',12);
    % ylabel(coltext);
end


function out=fittsconstant(varargin)

if strcmp(varargin{1},'ylabel')
    out='Fitt''s Constant';
    return
end

subject=varargin{1};

out=-reachtimes(subject)./log(maxperpendicular(subject));
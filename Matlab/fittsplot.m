function fittsplot(varargin)
%load systematically
name=varargin{1};

output=cell(1,1);

load(['../Data/',name,'.mat']);

for k=2:length(varargin)
    if isa(varargin{k},'function_handle') %If argument 2,3,4...etc is a functional handle, run it on the data and store it
        output{k-1}=feval(varargin{k},subject)
         maxperp=feval(varargin(2))
         %rt=feval(varargin(3})
       
        dat=output;
        %c = num2cell(dat)
    else
        break;
    end
    
   
end
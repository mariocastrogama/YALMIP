function varargout = xor(varargin)
%XOR (overloaded)
%   
%    z = xor(x,y)
%
% It is assumed that x and y are binary variables (either explicitely
% declared using BINVAR, or constrained using BINARY.)
%
% See also SDPVAR/OR, SDPVAR/AND, SDPVAR/NOT, BINVAR, BINARY

switch class(varargin{1})
    case 'char'
        
        z = varargin{2};        
        xy = [];        
        for i = 3:nargin            
            xy = [xy varargin{i}];
        end
        [M,m] = derivebounds(z);

        % If user has constrained the XOR operator to true, we can add that
        % constraint very easily
        if m>0
            varargout{1} = (sum(xy) == 1);
        else
            T1 = -ones(n);
            T1 = T1 + 2*diag(ones(n,1));
            t = combnk(1:n,2);
            T2 = zeros(size(t,1),n);
            for i = 1:size(t,1)
                T2(i,t(i,1)) = 1;
                T2(i,t(i,2)) = -1;
            end
            varargout{1} = (2 - T2*reshape(xy,n,1) >= z) + (z >= T1*reshape(xy,n,1)) +(binary(z));
        end
        
        varargout{2} = struct('convexity','none','monotonicity','none','definiteness','none','model','integer');
        varargout{3} = xy;

    case 'sdpvar'
        if nargin == 1
            if length(varargin{1})==1
                varargout{1} = varargin{1}
            else
                x = varargin{1};
                % bug in matlab...
                %temp = or(x(1),x(2));
                temp = xor(extsubsref(x,1),extsubsref(x,2));
                for i = 3:length(x)
                    temp = xor(temp,extsubsref(x,i));
                end
                 varargout{1} = temp;
            end           
        else
            varargout{1} = yalmip('define','xor',varargin{:});
        end
    otherwise
end
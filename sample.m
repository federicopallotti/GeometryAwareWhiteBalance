 
%function to sample
function sampled = sample(min_val, max_val, step,n_step, param)
%create a 3d grid
x = min_val:step:max_val; %divide into discrete steps
y = min_val:step:max_val;
z = min_val:step:max_val;

[X,Y,Z] = meshgrid(x,y,z);

chromatic = (X~=Y)~=Z;  %mask to filter out achromatic colors

%filter out achromatic values
X = X.*chromatic;
Y = Y.*chromatic; 
Z = Z.*chromatic;

%%rgb values to plot
mask = [X(:) > Y(:) &  X(:) > Z(:),Y(:) > X(:) &  Y(:) > Z(:), Z(:) > Y(:) &  Z(:) > X(:)];

mask(sum(mask,2)==0,:) =1;

R = X(:).';
G = Y(:).';
B = Z(:).';
S = 50;
if param ==1
    figure
    h = scatter3(R,G,B,S,mask,'*');
    axis equal
    box on

end

% compute rg chromaticities components
x = X./(X+Y+Z) ;
y = Y./(X+Y+Z) ;
z= 1-x-y;
%compute the log chromtaticites components
l_r =  log((x./z));

l_g = log((y./z ));

x_l = l_r(:);

y_l = l_g(:);

%visualization of log chromaticity values

coords = [x_l y_l];
bool = ones(length(coords),1);

% bool(coords(:,1)==coords(:,2),:) =0;
bool(coords(:,1)==0 | coords(:,2)==0,:) =0;

% coords= coords(coords(:,1)~=coords(:,2),:);
coords = coords(coords(:,1)~=0 & coords(:,2)~=0,:);
bool=logical(bool);

mask = mask(bool,:);

if param==1
    figure
    scatter(coords(:,1),coords(:,2),S,mask,'*');
end

%boundaries for the space to sample from
x_l = x_l(~isnan(x_l));
y_l = y_l(~isnan(y_l));

x_max = max(x_l);
x_min = min(x_l);

y_max = max(y_l);
y_min = min(y_l);

x_range = abs(x_max - x_min);
y_range = abs(y_max - y_min);

x_step = x_range/(n_step-1);
y_step = y_range/(n_step-1);

sx = x_min:x_step:x_max;
sy= y_min:y_step:y_max;

[sX,sY] = meshgrid(sx,sy);

sampled = [sX(:),sY(:)];
size(sampled);

end
%reading input image
im_name ='frame_colored.jpg';
In = imread(im_name);
In_size = size(In);

%reading depth image
im_depth = 'real_depth.png';
In_depth = imread(im_depth);

%preprocessing gamma correction
In = rgb2lin(In,'OutputType','double');
figure,imshow(In)

%resize input image to depth image dimension (smaller dimension)
r_size = size(In_depth);
J = imresize(In, r_size,'bicubic');%RGB resized
size(J)
% imtool(J) %used to pick colors of the light sources
% figure,imshow(J)

%input light sources

%cold light L1
L1 = [0.5500,0.6400,0.6800];
L1 = reshape(L1, [1 1 3]);

%warm light L2
L2 = [0.6400, 0.2900, 0.1200]; %actual bulb color
L2 = reshape(L2, [1 1 3]);

%sample 32x32 values in log chrom space
log_sampled = sample(0.1, 1, 0.1, 32, 0);

%convert sampled to rgb
rg_sampled = from_log_val(log_sampled);
RGB_sampled = RGB(rg_sampled,0.5);

%filter colors not in the feasible space
mask = RGB_sampled(:,1) <= 1 & RGB_sampled(:,2) <= 1 & RGB_sampled(:,3) <= 1;
RGB_sampled = RGB_sampled(mask,:);

%normal map from depth map
N = getNormals(In_depth);
%get rid of possible nan vals and substitute with average neighbouring vals
while sum(isnan(N),'all')>0
    [row, col] = find(isnan(N));
    n_row = row+1;
    n_col = col+1;
    N(row,col) = (N(row,n_col) + N(n_row,col))/2;
%     sum(isnan(N),'all')    
end

%process the normals to make them smoother
DoS = 100*diff(getrangefromclass(N)).^2.; %degree of smoothing for bilateral filter
N = imbilatfilt(N,DoS,1);
figure,imshow(N)

%resizing images 
C = chrom(J);

%threshold for the voting scheme
thres = 0.02;

%UNCOMMENT HERE TO USE THE CODE WITH NEW INPUTS

%compute k1 and k2 in RGB space
[k1,k2] = RGB_compute_param(J,RGB_sampled, L1, L2);

%computing votes for each material color (rg space)
[vs] = fast_RGB_voting(J,RGB_sampled,thres,L1, L2, k1, k2);

%computing the first set of assigned material colors
[first_image,new_set, k_mat, n_k1, n_k2] = real_first_set(J,vs,RGB_sampled,k1,k2);
figure('Name','first image','NumberTitle','off'), imshow(first_image);

%alpha matrix
k_mat = double(k_mat);
alpha_mat = k_mat(:,:,1)./(k_mat(:,:,1)+k_mat(:,:,2));
% figure,imshow(alpha_mat)

%mask to get the non null values of the matrix
alpha_mask = first_image > 0;
alpha_mask = sum(alpha_mask,3);

figure,imshow(alpha_mask)
title('apha mask')


%compute second set of RELIABLE material color
rel_out_image = second_set(J,first_image, new_set, thres, L1, L2, n_k1,n_k2);
figure('Name','reliable image','NumberTitle','off'), imshow(rel_out_image);

reliable_mask = rel_out_image>0;
reliable_mask = sum(reliable_mask,3);
mask = and(reliable_mask,alpha_mask);

%create input scribble-like images
scribble_im = scrib(C,alpha_mat,mask);
scribble_im_RGB = scrib(J,alpha_mat,mask);
scribble_norm = scrib(N,alpha_mat,mask);
 

%matting paramters
epsilon = 1.0000e-6; 
lambda = 0.1;

alpha_RGB = runMatting(J,scribble_im_RGB,N,scribble_norm,epsilon,lambda,1,J);
figure,imshow(alpha_RGB)
title('RGB alpha')

w = 0.3; %weight of the colors wrt the normals
my_alpha = runMatting(J,scribble_im_RGB,N,scribble_norm,epsilon,lambda,w,J);

figure,imshow(my_alpha)
title('my alpha')

alpha_RGB = imresize(alpha_RGB, [1920 1440],'bicubic');%RGB resized
figure,imshow(alpha_RGB)
title('upsampled RGB alpha')
RGB_result = balance(In,L1,L2,alpha_RGB);

my_alpha = imresize(my_alpha, [1920 1440] ,'bicubic');%RGB resized
figure,imshow(my_alpha)
title('upsampled my alpha')
my_result =  balance(In,L1,L2,my_alpha);

%output the two results
output_result(my_result)
output_result(RGB_result)

%function to apply white balance
function balanced = balance(I,L1,L2,alpha)
a = alpha;
b = 1-alpha;
size(L1(1))
Wr = 1./(a* L1(1) + b*L2(1));
size(Wr)
Wg = 1./(a* L1(2) + b*L2(2));
Wb = 1./(a* L1(3) + b*L2(3));
W = cat(3,Wr,Wg,Wb);
size(W)
balanced = I.* W;
end

%function to overlay scribbles to input image
function scribble = scrib(I,alpha_mat,alpha_mask)
scribble = I;
s_1 = scribble(:,:,1);
s_2 = scribble(:,:,2);
s_3 = scribble(:,:,3);

s_1(alpha_mask) = alpha_mat(alpha_mask);
s_2(alpha_mask) = alpha_mat(alpha_mask);
s_3(alpha_mask) = alpha_mat(alpha_mask);

scribble = cat(3,s_1,s_2,s_3);


end

function scribble = scrib_2D(I,alpha_mat,alpha_mask)
scribble = I;
s_1 = scribble(:,:,1);
s_2 = scribble(:,:,2);
s_1(alpha_mask) = alpha_mat(alpha_mask);
s_2(alpha_mask) = alpha_mat(alpha_mask);

scribble = cat(3,s_1,s_2);


end

%CONVERSION FUNCTIONS
%convert from rg to log rg
 function res = to_log(I)
 sz = size(I);
 res = zeros(sz(1),sz(2),2);
 X =  log(I(:,:,1)./I(:,:,3));
 Y = log(I(:,:,2)./I(:,:,3));

 res(:,:,1) = X;
 res(:,:,2) = Y;
 end
 
 %convert from rg to log rg val
 function res = to_log_val(I)
 sz = size(I);
 res = zeros(sz(1),2);
 X =  log(I(:,1)./I(:,3));
 Y = log(I(:,2)./I(:,3));

 res(:,1) = X;
 res(:,2) = Y;
 end
 
 
 %convert from log rg to rg
 function res = from_log(I)
 sz = size(I);
 res = zeros(sz(1),sz(2),3);
 e_X =  exp(I(:,:,1));
 e_Y= exp(I(:,:,2));
 A = e_X./(1+e_X);
 B = e_Y./(1+e_Y);
 %computing the chrom components
 x = (A - A.*B)./(1 - A.*B);
 y = B - B.*x;
 z = 1-x-y;
 res(:,:,1) = x;
 res(:,:,2) = y;
 res(:,:,3) = z;               
 end
 
  %convert from log rg to rg
 function res = from_log_val(I)
 sz = size(I);
 res = zeros(sz(1),3);
 e_X =  exp(I(:,1));
 e_Y= exp(I(:,2));
 A = e_X./(1+e_X);
 B = e_Y./(1+e_Y);
 %computing the chrom components
 x = (A - A.*B)./(1 - A.*B);
 y = B - B.*x;
 z = 1-x-y;
 res(:,1) = x;
 res(:,2) = y;
 res(:,3) = z;               
 end

%convert from RGB to rg images
function res = chrom(I)
res = zeros(size(I));
X = I(:,:,1);
Y = I(:,:,2);
Z = I(:,:,3);
x = X./(X+Y+Z);
y = Y./(X+Y+Z);

res(:,:,1) = x;
res(:,:,2) = y;
res(:,:,3) = 1-x-y;

end


%convert from RGB to rg values
function res = chrom_val(I)
res = zeros(size(I));
X = I(:,1);
Y = I(:,2);
Z = I(:,3);
x = X./(X+Y+Z);
y = Y./(X+Y+Z);

res(:,1) = x;
res(:,2) = y;
res(:,3) = 1-x-y;

end

%convert from rg to RGB (fixed intensity i)
function res = RGB(I,i)
r = I(:,1);
g = I(:,2);
b = I(:,3);

% x = i./(r.*0.21 + g.*0.72 + b.*0.07);
x = i./(r.*0.33333 + g.*0.33333 + b.*0.33333);
R = r.*x;
G= g.*x;
B= b.*x;
res(:,1) = R;
res(:,2) = G;
res(:,3) = B;
end

%convert from rg image to RGB image (fixed intensity i)
function res = RGB_im(I,i)
res = zeros(size(I));
r = I(:,:,1);
g = I(:,:,2);
b = I(:,:,3);

x = i./(r.*0.21 + g.*0.72 + b.*0.07);
R = r.*x;
G= g.*x;
B= b.*x;

res(:,:,1) = R;
res(:,:,2) = G;
res(:,:,3) = B;
end

function alpha = runMatting(I,mI,N,mN,epsilon,lambda,w1,originalI)
if (~exist('thr_alpha','var'))
  thr_alpha=[];
end
if (~exist('epsilon','var'))
  epsilon=[];
end
if (~exist('win_size','var'))
  win_size=[];
end

if (~exist('levels_num','var'))
  levels_num=1;
end  
if (~exist('active_levels_num','var'))
  active_levels_num=1;
end  

%common consts map
consts_map=sum(abs(I-mI),3)>0.001;%should be unique for both

% different consts vals
if (size(I,3)==3)
  consts_vals_I=rgb2gray(mI).*consts_map;
  consts_vals_N=rgb2gray(mN).*consts_map;
 
end
if (size(I,3)==1)
  consts_vals_I = mI.*consts_map;
  consts_vals_N = mN.*consts_map;
end

% figure, imshow(consts_vals_I)
% figure, imshow(consts_vals_N)
%stupid, they re the same

[h,w,c]=size(I);
img_size=w*h;
D = spdiags(consts_map(:),0,img_size,img_size);


[A_I] = getLaplacian1(I,consts_map,epsilon,win_size);
% size(consts_map)

[A_N] = getLaplacian1(N,consts_map,epsilon,win_size);


           
 w2 = 1-w1;
 num = (w1*A_I + w2*A_N) + lambda*D;
 den = lambda*(w1* consts_map(:).*consts_vals_I(:) + w2 *consts_map(:).*consts_vals_N(:));
% den = lambda*(consts_map(:).*consts_vals_I(:));
x=num\den;
 
alpha=max(min(reshape(x,h,w),1),0); %clamp btwn 0 and 1 and reshape to input image size             
              
% figure, imshow(alpha);
% title ('final alpha');
% drawnow;
% [F,B]=solveFB(originalI,alpha);
% figure, imshow([F.*repmat(alpha,[1,1,3]),B.*repmat(1-alpha,[1,1,3])])
end
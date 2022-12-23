function N = getNormals(I)

%Pixel size computation
FOV = 39.6;
% FOV = 27;
S = size(I);
res_i = S(1); % num of row (y dir)
res_j = S(2); %num of col (x dir)

f = 1;  %focal length / z-component
hs = f*tan(FOV/2); %half size of the image plane
s = hs*2;
p_s = s/res_j; %pixel size

%initialize 3D distance vec matrix
O = zeros(res_i,res_j,3);

for i = 1:res_i   % for number of rows of the image
    for j = 1:res_j    % for number of columns of the image
        %direction vector
        d = zeros(3,1);
        d(1) = (res_j -j)*p_s; % x component        
        d(2) = (res_i - i )*p_s; % y component
        d(3) = f; % z component
        
        %compute normalized direction vector
        n = d/norm(d);
        
        %compute output value from depthmap (where to place the normal
        O(i,j,1) = n(1)* I(i,j); % x component
        O(i,j,2) = n(2)* I(i,j); % y component
        O(i,j,3) = n(3)* I(i,j); % z component
    end
end

%compute normals from cross prod
N = zeros(res_i, res_j,3);

for i = 2:res_i   % for number of rows of the image
    for j = 2:res_j    % for number of columns of the image
        if i < res_i && j < res_j
            d1 = -O(i-1,j,:) + O(i+1,j,:);
            d2 = -O(i,j-1,:) + O(i,j+1,:);
            
             
         
            
            d = cross(d1(:),d2(:));
            %flip z component
            d(3) = -d(3);
            d = d*0.5 + 0.5; %scale and translate to not lose info
            
            
            N(i,j,:) = d/norm(d);
        end
    end
end

%visualize normals
% quiver3(O(:,:,1),O(:,:,2),O(:,:,3), N(:,:,1),N(:,:,2),N(:,:,3));
% axis equal



end
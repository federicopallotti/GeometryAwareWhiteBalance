function votes = fast_RGB_voting(input,sampled,threshold,l1,l2, k1, k2)

%vectorizing the input values

%input image matrix
Jr =  repmat(input,1,1,1,length(sampled));
sj = size(input);
%sampled colors matrix
Jt = reshape(sampled.',[1,1,3,length(sampled)]);
Js = repelem(Jt,sj(1),sj(2),1,1);

%assign terms to solve equations
Ir = Jr(:,:,1,:);
Ig = Jr(:,:,2,:);
Ib = Jr(:,:,3,:);

l1x = l1(:,:,1);
l1y = l1(:,:,2);
l1z = l1(:,:,3);

l2x = l2(:,:,1);
l2y = l2(:,:,2);
l2z = l2(:,:,3);

s_x = Js(:,:,1,:);
s_y = Js(:,:,2,:);
s_z = Js(:,:,3,:);

sk = size(k1);
k1 = reshape(k1,[sk(1),sk(2),1,sk(3)]);
k2 = reshape(k2,[sk(1),sk(2),1,sk(3)]);

%compute the term to threshold

term_x = Ir - k1 .* s_x * l1x - k2 .* s_x * l2x;
term_y = Ig - k1 .* s_y * l1y - k2 .* s_y * l2y;
term_z = Ib - k1 .* s_z * l1z - k2 .* s_z * l2z;

term = term_x.^2 + term_y.^2 + term_z.^2;

%assigning votes for each material color
bool_mat = sqrt(term) < threshold;
l_s = length(sampled);
bool_mat = reshape(bool_mat,[sj(1) sj(2) l_s]);
votes= bool_mat;

end
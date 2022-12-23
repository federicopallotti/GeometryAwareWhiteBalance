%function to obatain a subset of the full material color set
function [new_k1,new_k2,output,set] = voting(input,sampled,threshold,l_c,l_w, k1, k2)

Jr =  repmat(input,1,1,1,length(sampled));%input
sj = size(input);
Jt = reshape(sampled.',[1,1,2,length(sampled)]);
Js = repelem(Jt,sj(1),sj(2),1,1);

%assign terms to solve equations
Ix = Jr(:,:,1,:);
Iy = Jr(:,:,2,:);

Lwx = l_w(:,:,1);
Lwy = l_w(:,:,2);

Lcx = l_c(:,:,1);
Lcy = l_c(:,:,2);

Rx = Js(:,:,1,:);
Ry = Js(:,:,2,:);


% % clamp to positive values
sk = size(k1);
k1 = reshape(k1,[sk(1),sk(2),1,sk(3)]);
k2 = reshape(k2,[sk(1),sk(2),1,sk(3)]);

dv_x = Ix - (k1.*Rx)*Lcx -(k2.*Rx)*Lwx;
dv_y = Iy - (k1.*Ry)*Lcy -(k2.*Ry)*Lwy;

diff_val = dv_x.^2 + dv_y.^2;

bool_mat = sqrt(diff_val) < threshold;
l_s = length(sampled);

bool_mat = reshape(bool_mat,[sj(1) sj(2) l_s]);
chrom_stats = sum(bool_mat,[1,2]);
c_s = reshape(chrom_stats,[1,length(chrom_stats)]);

%assiging values
output = zeros(size(input));
in_sz = size(input);
tot_pixels = in_sz(1)*in_sz(2);
votes = c_s;    %copy of votes
output_set_mask = zeros(size(sampled));
 while sum(votes) > 0.04 * tot_pixels
     
%     z=z+1
    [~,idx] = max(votes);
%     votes(idx) = 0;
    mask= bool_mat(:,:,idx);
    n_mask = ~mask;
    bool_mat = bool_mat.*n_mask;
    bool_mat = logical(bool_mat);
    
    %NEW PART: not consider old pixel votes 
    %reset bool_mat
     bool_mat(:,:,idx) = 0;
    %recompute the stats
     chrom_stats_t = sum(bool_mat,[1,2]);
     votes = reshape(chrom_stats_t,[1,length(chrom_stats_t)]);
    
    o_1 = output(:,:,1);
    o_2 = output(:,:,2);
    s_i = sampled(idx,:);
    output_set_mask(idx,:) = 1;
    
    o_1(mask) = s_i(1);
    o_2(mask) = s_i(2);
    
    %resetting 
    o_1(~mask) = 0;
    o_2(~mask) = 0;
    
    t_out = cat(3,o_1,o_2);
    output = output + t_out;
   
 end
 
 full_set = output_set_mask.*sampled;
 osm = output_set_mask(:,1);
 osm = logical(osm);
 new_k1 = k1(:,:,osm);
 new_k2 = k2(:,:,osm);
 set = full_set(osm,:);
 
end


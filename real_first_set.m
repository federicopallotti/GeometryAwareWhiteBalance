function [out_img , new_set, k_output, new_k1,new_k2] = real_first_set(input,votes,materials,k1,k2)

si = size(input);
tot_pixels = si(1)*si(2);

bool_mat = votes;
s = sum(votes,[1,2]); %obtain 1D vector as long as # of m colors
ss = size(s);
s = reshape(s,[ss(1) ss(3)]);
% mask = s > 0;%filtering material colors with zero votes
% mask = s >tot_pixels*0.0001;%filtering material colors with zero votes


%filtering material non relevant colors
% bool_mat = bool_mat(:,:,mask);
% materials = materials(mask,:);
% chrom_stats = s(mask);
chrom_stats = s;


output = zeros(si);
k_output = zeros(si(1),si(2),2); %matrix to store the ks
output_set_mask = zeros(size(materials));
% tot_pixels

S = tot_pixels;
while S > 0.1 * tot_pixels
%      S
    [~,idx] = max(chrom_stats);
    %test plotting
%     chrom_stats
%     idx
%     materials(idx,:)
    
    
    %select pixels that voted for that material color
    mask = bool_mat(:,:,idx);
    S = sum(sum(sum(mask)));
    
    %get the k1 k2 of those pixels, given that material color
    mask_k1 = mask.* k1(:,:,idx);
    mask_k2 = mask.* k2(:,:,idx);
    
    k_output(:,:,1) = k_output(:,:,1)+mask_k1;
    k_output(:,:,2) = k_output(:,:,2)+mask_k2;
    
%     sum(sum(sum(mask)))
%     size(mask)
    mask = logical(mask);
%     sum(sum(sum(sum(mask))))
    n_mask = ~mask;
    %resetting all channels in those voted pixel positions
    bool_mat = bool_mat.*n_mask;
    bool_mat = logical(bool_mat);
    bool_mat(:,:,idx) = 0;
    %update stats
    s = sum(bool_mat,[1,2]);
    ss = size(s);
    chrom_stats  = reshape(s,[ss(1) ss(3)]);
    
    o_1 = output(:,:,1);
    o_2 = output(:,:,2);
    o_3 = output(:,:,3);
    
    s_i = materials(idx,:);
    output_set_mask(idx,:) = 1;
    
    o_1(mask) = s_i(1);
    o_2(mask) = s_i(2);
    o_3(mask) = s_i(3);
    
    %resetting 
    o_1(~mask) = 0;
    o_2(~mask) = 0;
    o_3(~mask) = 0;
    
    %update of the stats removing votes from pixels already taken into
    %account
    
    t_out = cat(3,o_1,o_2,o_3);
    output = output + t_out;
    figure,imshow(output)
%   figure('Name','temp output image','NumberTitle','off'),imshow(output)
   
end

full_set = output_set_mask.*materials;
osm = output_set_mask(:,1);
osm = logical(osm);
new_set = full_set(osm,:);
new_k1 = k1(:,:,osm);
new_k2 = k2(:,:,osm);
out_img = output;

end
function [out_img] = second_set(input,f_image, new_materials, threshold, l1,l2, K1,K2)
s = size(new_materials);
l = s(1);
sz = size(input);
votes = zeros(sz(1),sz(2),l);

for m = 1:l
    s = new_materials(m,:);
%     if std(s) < 0.02
%         t = 0.5*threshold;
%     else if std(s) > 0.1
%         t =  1.25* threshold;
%         else
%         t = threshold;
%         end
%        
%     end
   
    
    for r = 1:sz(1)
        for c = 1:sz(2)
             
             Ir = input(r,c,1);
             Ig = input(r,c,2);
             Ib = input(r,c,3);
             
             k1 = K1(r,c,m);
             k2 = K2(r,c,m);
             
             l1x = l1(:,:,1);
             l1y = l1(:,:,2);
             l1z = l1(:,:,3);
             
             l2x = l2(:,:,1);
             l2y = l2(:,:,2);
             l2z = l2(:,:,3);
             
             s_x = s(1);
             s_y = s(2);
             s_z = s(3);
             
             term_x = Ir - k1*s_x * l1x - k2 * s_x * l2x;
             term_y = Ig - k1*s_y * l1y - k2 * s_y * l2y;
             term_z = Ib - k1*s_z * l1z - k2 * s_z * l2z;
             
             term = term_x^2 + term_y^2 + term_z^2;
             
             if sqrt(term) < threshold
                 
                 votes(r,c,m) = 1;
             end
        end
    end
    
end
    
    mask = sum(votes,3);
    m = max(max(max(mask)));
    vote_map = mask/m;
%     imtool(vote_map)
    conf_map = 1-vote_map;
%     imtool(conf_map)
    
    mask(mask > 1) = 0;


    lm = logical(mask);
    lm =  ~lm;

    o_1 = f_image(:,:,1);
    o_2 = f_image(:,:,2);
    o_3 = f_image(:,:,3);
    
    o_1(lm) = 0;
    o_2(lm) = 0;
    o_3(lm) = 0;
    
    out_img = cat(3,o_1,o_2,o_3);
 



end

 %function to compute k1 and k2 in RGB space
 
 function [k1,k2] = RGB_compute_param(input, material,l1, l2)
 s = size(input);
 l = length(material);
 k1 = zeros(s(1), s(2), l);
 k2 = zeros(s(1), s(2), l);
 for m = 1:l
     R0_x = material(m,1);
     R0_y = material(m,2);
     R0_z = material(m,3);
             
     for r = 1:s(1)
         for c = 1:s(2)
             
             
             Ix = input(r,c,1);
             Iy = input(r,c,2);
             Iz = input(r,c,3);
             
             A = [R0_x*l1(1) R0_x*l2(1);
                  R0_y*l1(2) R0_y*l2(2);
                  R0_z*l1(3) R0_z*l2(3);];
              
             b = [Ix;
                 Iy;
                 Iz;];
             
             ks =lsqnonneg(A,b);
             
             k1(r,c,m) = ks(1);
             k2(r,c,m) = ks(2);
                    
         end

     end
 end
 end


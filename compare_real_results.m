function  compare_real_results(final_result, G)

final_result = imadjust(final_result,[],[],1/2.2);
figure,imshow(final_result)
title('final result')

figure,imhist(final_result)
title('output histogram')

figure,imhist(G)
title('gt histogram')

   
end
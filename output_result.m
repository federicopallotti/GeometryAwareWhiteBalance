function  output_result(final_result)

final_result = imadjust(final_result,[],[],1/2.2);
figure,imshow(final_result)
title('final result')
   
end
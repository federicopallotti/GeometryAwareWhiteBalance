# GeometryAwareWhiteBalance

This code provides the implementation of the method of Eugene and colleagues, "Light Mixture Estimation for Spatially Varying White Balance."
The code presents an additional part where the method exploits the scene's Geometry (using depth maps) to estimate the Light Mixture better.
The code provided by Levin and colleagues in their paper "A Closed-Form Solution to Natural Image Matting" was used to implement the final mixture optimization.

To run the code you just need the input RGB image and Depth image.
A workspace is provided to avoid the running time.

![checker_bright](https://user-images.githubusercontent.com/77103965/209367143-166caff2-8017-4251-bc17-ff0f20833697.jpg)
![normal_map](https://user-images.githubusercontent.com/77103965/209366811-8e5f03d9-9ec5-46e4-b5f5-6e5a0b0925cc.jpg)
![my_result](https://user-images.githubusercontent.com/77103965/209366802-399d407f-75c9-42ed-85bc-f101a65518fc.jpg)

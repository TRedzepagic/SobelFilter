#!/bin/bash

echo "Compiling SobelFilter"
g++ -c SobelFilter.cpp -l OpenCL -I ./common/OpenCL/include -I ./common/FreeImage/include -o SobelFilter.a

echo "Compiling EdgeDetector"
g++ RunSobel.cpp SobelFilter.a ./common/FreeImage/lib/linux/x86_64/libfreeimage.a -l OpenCL -I ./common/OpenCL/include -o sobel

./sobel ./images/lena.bmp prewitt
./sobel ./images/lena.bmp sobel
./sobel ./images/lena.bmp scharr
./sobel ./images/lena.bmp roberts

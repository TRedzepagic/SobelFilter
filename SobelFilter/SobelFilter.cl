const sampler_t Sampler = CLK_NORMALIZED_COORDS_FALSE |
							CLK_ADDRESS_CLAMP |
							CLK_FILTER_NEAREST;

// Runs the Edge Detector Filter on an image, this expects the image to be read in
// using unsigned integers to represent the RGB channels and should be between
// 0 and 255. This means the format CL_UNSIGNED_INT8 should be used when creating
// the image2d_t source and output
__kernel void SobelFilter(
	__read_only image2d_t sourceImage, 
	__write_only image2d_t outputImage,
	int width,
	int height,
	int mode
	)
{ 
	// This is the currently focused pixel and is the output pixel
	// location
	int2 ImageCoordinate = (int2)(get_global_id(0), get_global_id(1));

	// Make sure we are within the image bounds
	if (ImageCoordinate.x < width && ImageCoordinate.y < height)
	{ 		
		int x = ImageCoordinate.x;
		int y = ImageCoordinate.y;

		// Read the 8 pixels around the currently focused pixel
		uint4 Pixel00 = read_imageui(sourceImage, Sampler, (int2)(x - 1, y - 1));
		uint4 Pixel01 = read_imageui(sourceImage, Sampler, (int2)(x, y - 1));
		uint4 Pixel02 = read_imageui(sourceImage, Sampler, (int2)(x + 1, y - 1));

		uint4 Pixel10 = read_imageui(sourceImage, Sampler, (int2)(x - 1, y));
		// Only for Roberts, we need the exact pixel (x,y)
		uint4 Pixel11 = read_imageui(sourceImage, Sampler, (int2)(x, y));
		uint4 Pixel12 = read_imageui(sourceImage, Sampler, (int2)(x + 1, y));

		uint4 Pixel20 = read_imageui(sourceImage, Sampler, (int2)(x - 1, y + 1));
		uint4 Pixel21 = read_imageui(sourceImage, Sampler, (int2)(x, y + 1));
		uint4 Pixel22 = read_imageui(sourceImage, Sampler, (int2)(x + 1, y + 1));

		// This is equivalent to looping through the 9 pixels
		// under this convolution and applying the appropriate
		// filter, here we've already applied the filter coefficients
		// since they are static

		// 0 -> Sobel
		// 1 -> Prewitt
		// 2 -> Scharr
		// 3 -> Roberts' Cross
		uint4 Gx, Gy;
		if (mode == 0){
			// Sobel
			Gx = Pixel00 + 2 * Pixel10 + Pixel20 -
				Pixel02 - 2 * Pixel12 - Pixel22;

		 	Gy = Pixel00 + 2 * Pixel01 + Pixel02-
				Pixel20 - 2 * Pixel21 - Pixel22;
		} else if(mode == 1){
			// Prewitt
			Gx = Pixel00 + Pixel10 + Pixel20 -
				Pixel02 - Pixel12 - Pixel22;

			Gy = Pixel00 + Pixel01 + Pixel02 -
				Pixel20 - Pixel21 - Pixel22;
		} else if(mode == 2){
			// Scharr
			Gx = 3*Pixel00 + 10 * Pixel10 + 3*Pixel20 -
				3*Pixel02 - 10 * Pixel12 - 3*Pixel22;

			Gy = 3*Pixel00 + 10 * Pixel01 + 3*Pixel02 -
				3*Pixel20 - 10 * Pixel21 - 3*Pixel22;
		} else if(mode == 3) {
			// Roberts
			Gx = Pixel11 - Pixel22;
			Gy = Pixel12 - Pixel21;
		}


		// Holds the output RGB values
		uint4 OutColor = (uint4)(0, 0, 0, 1);

		// Compute the gradient magnitude
		OutColor.x = sqrt((float)(Gx.x * Gx.x + Gy.x * Gy.x)); // R
		OutColor.y = sqrt((float)(Gx.y * Gx.y + Gy.y * Gy.y)); // G
		OutColor.z = sqrt((float)(Gx.z * Gx.z + Gy.z * Gy.z)); // B

		// Adjust all of the RGB values to not be more than 255
		if (OutColor.x > 255)
		{
			OutColor.x = 255;
		}

		if (OutColor.y > 255)
		{
			OutColor.y = 255;
		}

		if (OutColor.z > 255)
		{
			OutColor.z = 255;
		}
		
		// Convert to grayscale using luminosity method
		uint Gray = (OutColor.x * 0.2126) + (OutColor.y * 0.7152) + (OutColor.z * 0.0722);

		// Write the RGB value to the output image
		write_imageui(outputImage, ImageCoordinate, (uint4)(Gray, Gray, Gray, 0));
		}
	}



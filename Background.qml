import QtQuick 2.2
import QtGraphicalEffects 1.0

FocusScope {
    id: sceneBackground_base

    property int screenWidth: Screen.width
    property int screenHeight: Screen.height

    Image {
        id: sceneImageBackground_base
        anchors.fill: parent
        fillMode: Image.PreserveAspectFit
        source: config.background || config.Background
        smooth: true

        layer.enabled: true
        layer.effect: ShaderEffect {
            width: sceneImageBackground_base.width
            height: sceneImageBackground_base.height

            fragmentShader: "
				uniform lowp sampler2D source;
				varying highp vec2 qt_TexCoord0;

                void main() {
					vec4 sourceColor = texture2D(source, qt_TexCoord0);
					vec3 inputColor = sourceColor.rgb;
					// #define N 32                   // Number of iterations per fragment (higher N = more samples)
					// #define PALETTE_SIZE 16        // Number of colours in the palette
					// #define ERROR_FACTOR 0.8       // Quantisation error coefficient (0 = no dithering)

					// #define INFINITY 3.4e38        // 'Infinity'

					// // Helper macro to convert an RGB hex code to a vec3
					// #define RGB8(h) (vec3(h >> 16 & 0xFF, h >> 8 & 0xFF, h & 0xFF) / 255.0) 

					// 	/*
					// 	Thomas Knoll's Pattern Dithering algorithm[1]. For every iteration, we find the closest palette 
					// 	colour to the 'goal' colour, which is first set to the current fragment colour. When the closest
					// 	colour is found, we record it as the candidate for this iteration and calculate the quantisation
					// 	error (the difference between it and our fragment colour). The sum of the quantisation error
					// 	and the current fragment is then used as the goal colour for the next iteration. Every time 
					// 	we find a new candidate, we accumulate the total quantisation error. At the end, the frequency
					// 	of each candidate represents the proportion of its contribution to the input colour. An error
					// 	coefficient controls the intensity of the dither.
						
					// 	The original algorithm maintains an array of candidates of size N, where N is the number of
					// 	iterations. The colour of the final pixel is selected by randomly (or psuedo-randomly) indexing
					// 	into the array of candidates - in this case, we use a texture, although any noise function will 
					// 	also do. An intermediate step involves sorting the candidate array by luminance before we select 
					// 	the final colour. This is done to ensure that candidate colours are in a consistent relative position 
					// 	in the array, and it also ensures that colours with similar luminance values appear further apart 
					// 	in the final image, minimising the appearance of 'clumps'.
						
					// 	Included is an optimised version of the algorithm which forgoes the candidate array in favour of an 
					// 	array representing the frequency of each palette colour by index. Selecting from the frequency array 
					// 	is done by obtaining a random value from 0 to N-1 and summing the cumulative frequency until the sum 
					// 	is greater than the value. Instead of sorting the entire array of candidates each time, we simply
					// 	pre-sort the palette. For large values of N, the performance difference is quite noticeable.
						
					// 	[1] https://patents.google.com/patent/US6606166B1/en
					// 	*/

					// // Using the PICO-8 palette. Optimised version uses a pre-sorted palette.

					// const vec3 palette[PALETTE_SIZE] = vec3[](
					// 	RGB8(0x000000), RGB8(0x1D2B53), RGB8(0x7E2553), RGB8(0x008751),
					// 	RGB8(0xAB5236), RGB8(0x5F574F), RGB8(0xC2C3C7), RGB8(0xFFF1E8),
					// 	RGB8(0xFF004D), RGB8(0xFFA300), RGB8(0xFFEC27), RGB8(0x00E436),
					// 	RGB8(0x29ADFF), RGB8(0x83769C), RGB8(0xFF77A8), RGB8(0xFFCCAA));


					// // Convert a gamma-encoded sRGB value to linear RGB
					// // https://chilliant.blogspot.com/2012/08/srgb-approximations-for-hlsl.html
					// vec3 sRGBtoLinear(vec3 colour)
					// {
					// 	return colour * (colour * (colour * 0.305306011 + 0.682171111) + 0.012522878);
					// }

					// // Get the luminance value of a given colour
					// float getLuminance(vec3 colour)
					// {
					// 	return colour.r * 0.299 + colour.g * 0.587 + colour.b * 0.114;
					// }

					// // Find the closest palette colour to the input colour via brute force
					// int getClosestColour(vec3 inputColour)
					// {
					// 	float closestDistance = INFINITY;
					// 	int closestColour = 0;
						
					// 	for (int i = 0; i < PALETTE_SIZE; i++)
					// 	{
					// 		vec3 difference = inputColour - sRGBtoLinear(palette[i]);
					// 		float distance = dot(difference, difference);
							
					// 		if (distance < closestDistance)
					// 		{
					// 			closestDistance = distance;
					// 			closestColour = i;
					// 		}
					// 	}
						
					// 	return closestColour;
					// }

					// // Sample the value in the threshold matrix for the current pixel
					// float sampleThreshold(vec2 coord)
					// {
					// 	// Sample the centre of the texel
					// 	ivec2 pixel = ivec2(coord / PIXEL_SIZE) % ivec2(iChannelResolution[1]);
					// 	vec2 uv = vec2(pixel) / iChannelResolution[1].xy;
					// 	vec2 offset = 0.5 / iChannelResolution[1].xy;
					// 	return texture(iChannel1, uv + offset).x * float(N - 1);
					// }

					// void mainImage( out vec4 fragColor, in vec2 fragCoord )
					// {
					// 	// Get the colour for this fragment
					// 	vec2 pixelSizeNormalised = PIXEL_SIZE * (1.0 / iResolution.xy);
					// 	vec2 uv = pixelSizeNormalised * floor(fragCoord / iResolution.xy / pixelSizeNormalised);
					// 	vec3 colour = texture(iChannel0, uv).rgb;

					// 	// Screen wipe effect
					// 	if (fragCoord.x < iMouse.x) 
					// 	{
					// 		fragColor = vec4(colour, 1.0);
					// 		return;
					// 	}
					
					// 	// ====================================== //
					// 	// Actual dithering algorithm starts here //
					// 	// ====================================== //

					// 	// Fill the candidate array
					// 	int candidates[N];
					// 	vec3 quantError = vec3(0, 0, 0);
					// 	vec3 colourLinear = sRGBtoLinear(colour);

					// 	for (int i = 0; i < N; i++)
					// 	{
					// 		vec3 goalColour = colourLinear + quantError * ERROR_FACTOR;
					// 		int closestColour = getClosestColour(goalColour);
							
					// 		candidates[i] = closestColour;
					// 		quantError += colourLinear - sRGBtoLinear(palette[closestColour]);
					// 	}


					// 	// Sort the candidate array by luminance (bubble sort)
					// 	for (int i = N - 1; i > 0; i--) 
					// 	{
					// 	for (int j = 0; j < i; j++) 
					// 	{
					// 		if (getLuminance(palette[candidates[j]]) > getLuminance(palette[candidates[j+1]])) 
					// 		{ 
					// 			// Swap the candidates
					// 			int t = candidates[j]; 
					// 			candidates[j] = candidates[j+1]; 
					// 			candidates[j+1] = t; 
					// 		}
					// 	}
					// 	}
						

					// 	// Select from the candidate array, using the value in the threshold matrix
					// 	int index = int(sampleThreshold(fragCoord));
					// 	fragColor = vec4(palette[candidates[index]], 1.0);
						

					// } 
				
					gl_FragColor = vec4(source);
				}
            "

            property variant source: ShaderEffectSource {
                sourceItem: sceneImageBackground_base
                hideSource: true
            }
        }
    }
}

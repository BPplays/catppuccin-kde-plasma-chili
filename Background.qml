import QtQuick 2.2
import QtGraphicalEffects 1.0

FocusScope {
    id: sceneBackground_base

    property int screenWidth: Screen.width
    property int screenHeight: Screen.height

    // onWidthChanged: {
    //     // Update any necessary properties or trigger functions when the width changes
    //     sceneImageBackground_ShaderEffect.iResolution = Qt.vector2d(width, sceneImageBackground_base.height);
    // }

    // onHeightChanged: {
    //     // Update any necessary properties or trigger functions when the height changes
    //     sceneImageBackground_ShaderEffect.iResolution = Qt.vector2d(sceneImageBackground_base.width, height);
    // }
    // onScreenChanged: {
    //     screenHeight = Screen.height;
    //     screenWidth = Screen.width;
    // }



    Image {
        id: bayer8x8
        source: "components/artwork/matrix_2x2.png"
        smooth: false
		// width: 32; height: 32
        visible: false
        opacity: 0

    }

	// Component.onCompleted: {
	// // Render the shader effect to the offscreen item once
	// // shaderCacheItem.width = sceneImageBackground_base.width
	// // shaderCacheItem.height = sceneImageBackground_base.height
	// sceneImageBackground_ShaderEffect.done = 1
    // }

    Image {
        id: sceneImageBackground_base
        anchors.fill: parent
        // fillMode: Image.PreserveAspectFit
		fillMode: Image.PreserveAspectFill
        source: config.background || config.Background
        smooth: true

		visible: false

        // layer.enabled: true
        // layer.effect: 
    }

	ShaderEffect {
		id: sceneImageBackground_ShaderEffect
		width: sceneImageBackground_base.width
		height: sceneImageBackground_base.height
			Component.onCompleted: {
			// Render the shader effect to the offscreen item once
			// shaderCacheItem.width = sceneImageBackground_base.width
			// shaderCacheItem.height = sceneImageBackground_base.height
			setProperty("done", 1);
			}

		property variant iChannel1: ShaderEffectSource {
			// Specify the source for iChannel1 if needed
			sourceItem: bayer8x8
			hideSource: true
			live: false
		}

		property var iMouse: Qt.vector2d(0, 0) // Default value, adjust as needed
		property var iResolution: Qt.vector2d(width, height)
		property variant iChannelResolution: Qt.size(width, height)

		property variant done: 0
		// test fds

		// property var done: 0

		//#version 330 core


		fragmentShader: "
				#version 330
				#define N 32                   // Number of iterations per fragment (higher N = more samples)
				#define RGB8(h) (vec3(h >> 16 & 0xFF, h >> 8 & 0xFF, h & 0xFF) / 255.0) 
				#define PALETTE_SIZE 4        // Number of colours in the palette
				#define ERROR_FACTOR 0.5       // Quantisation error coefficient (0 = no dithering)
				#define PIXEL_SIZE 1.0         // Size of pixels in the shader output
				#define ENABLE_SORT            // Choose whether to enable the sorting procedures
				// #define OPTIMISED_KNOLL        // Run an optimised version of the algorithm
				#define ENABLE 1


				#define INFINITY 3.4e38        // 'Infinity'


				#define RGB8(h) (vec3(h >> 16 & 0xFF, h >> 8 & 0xFF, h & 0xFF) / 255.0) 



				
				// uniform lowp sampler2D source;
				uniform highp sampler2D iChannel0;
				uniform highp sampler2D iChannel1;
				varying highp vec2 qt_TexCoord0;
				varying highp vec2 qt_TexCoord1;
				uniform highp vec2 iResolution;

				uniform highp vec2 iChannelResolution;

				// varying highp float done;



				uniform highp vec2 iMouse;
				// uniform sampler2D iChannel0;

				// vec3 palette[PALETTE_SIZE];

			#if ENABLE == 1

				const highp vec3 palette[PALETTE_SIZE] = highp vec3[](
					RGB8(0x1e1e2e), RGB8(0x313244), RGB8(0x45475a), RGB8(0xf5c2e7)
				);

				// colorPalette[0] = vec3(0.9607843137254902, 0.7607843137254902, 0.9058823529411765);    // f5c2e7
				// colorPalette[1] = vec3(0.19215686274509805, 0.19607843137254902, 0.26666666666666666);   // 313244
				// colorPalette[2] = vec3(0.11764705882352941, 0.11764705882352941, 0.1803921568627451);    // 1e1e2e
				// colorPalette[3] = vec3(0.27058823529411763, 0.2784313725490196, 0.35294117647058826);    // 45475a


				vec3 sRGBtoLinear(vec3 colour)
				{
					return colour * (colour * (colour * 0.305306011 + 0.682171111) + 0.012522878);
					// return colour;
				}

				// Get the luminance value of a given colour
				float getLuminance(vec3 colour) {
					return colour.r * 0.299 + colour.g * 0.587 + colour.b * 0.114;
				}

				int getClosestColour(vec3 inputColour) {
					float closestDistance = INFINITY;
					int closestColour = 0;
					// vec3 paletteColor;

					for (int i = 0; i < PALETTE_SIZE; i++) {
						// Assuming palette colors are predefined
						// vec3 paletteColor = palette[1];
						// if (i == 0) paletteColor = vec3(0.0); // Example color
						// else if (i == 1) paletteColor = vec3(1.0); // Example color
						// Define other palette colors similarly

						// Calculate the difference manually
						vec3 difference = inputColour - sRGBtoLinear(palette[i]);
						float distance = dot(difference, difference);

						if (distance < closestDistance) {
							closestDistance = distance;
							closestColour = i;
						}
					}

					return closestColour;
				}

				float sampleThreshold(vec2 coord) {
					// Sample the centre of the texel
					ivec2 pixel = ivec2(coord / PIXEL_SIZE) % ivec2(textureSize(iChannel1, 0).xy);
					vec2 uv = vec2(pixel) / vec2(textureSize(iChannel1, 0).xy);
					vec2 offset = 0.5 / vec2(textureSize(iChannel1, 0).xy);
					return texture2D(iChannel1, uv + offset).x * (N - 1);

					// // Sample the center of the texel
					// ivec2 pixel = ivec2(coord / PIXEL_SIZE) % ivec2(iChannelResolution);
					// vec2 uv = vec2(pixel) / iChannelResolution;
					// vec2 offset = 0.5 / iChannelResolution;
					// return texture2D(iChannel1, uv + offset).x * float(N - 1.0);
				}

				// float getClosestColour(vec3 inputColour)
				// {
				// 	float closestDistance = INFINITY;
				// 	float closestColour = 0;
					
				// 	for (float i = 0; i < PALETTE_SIZE; i++)
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


				void main() {


					// palette[0] = RGB8(0x1e1e2e);
					// palette[1] = RGB8(0x313244);
					// palette[2] = RGB8(0x45475a);
					// palette[3] = RGB8(0xf5c2e7);




					// // Get the color for this fragment
					// vec2 pixelSizeNormalised = PIXEL_SIZE * ivec2(textureSize(source, 0).xy);
					// vec2 uv = pixelSizeNormalised * floor(gl_FragCoord.xy / ivec2(textureSize(source, 0).xy) / pixelSizeNormalised);
					// // vec3 colour = texture2D(source, qt_TexCoord0).rgb;
					// vec3 colour = texture2D(source, uv).rgb;

					// highp vec2 pixelSizeNormalised = 1.0 / iResolution.xy;
					// highp vec2 uv = pixelSizeNormalised * floor(gl_FragCoord.xy / iResolution.xy / pixelSizeNormalised);
					// highp vec3 colour = texture2D(source, uv).rgb;
					highp vec3 colour = texture2D(iChannel0, qt_TexCoord0).rgb;

					// // Screen wipe effect
					// if (gl_FragCoord.x < iMouse.x) {
					// 	gl_FragColor = vec4(colour, 1.0);
					// 	return;
					// }

					// ====================================== //
					// Actual dithering algorithm starts here //
					// ====================================== //

					// Fill the candidate array
					int candidates[N];
					vec3 quantError = vec3(0.0);
					vec3 colourLinear = sRGBtoLinear(colour);

					for (int i = 0; i < N; i++) {
						vec3 goalColour = colourLinear + quantError * ERROR_FACTOR;
						int closestColour = getClosestColour(goalColour);

						candidates[i] = closestColour;
						quantError += colourLinear - sRGBtoLinear(palette[closestColour]);
					}

				#if defined(ENABLE_SORT)
					// Sort the candidate array by luminance (bubble sort)
					for (int i = N - 1; i > 0; i--) {
						for (int j = 0; j < i; j++) {
							if (getLuminance(palette[candidates[j]]) > getLuminance(palette[candidates[j+1]])) {
								// Swap the candidates
								int t = candidates[j];
								candidates[j] = candidates[j + 1];
								candidates[j + 1] = t;
							}
						}
					}
				#endif // ENABLE_SORT

					// Select from the candidate array, using the value in the threshold matrix
					int index = int(sampleThreshold(gl_FragCoord.xy));
					gl_FragColor = vec4(palette[candidates[index]], 1.0);

					// console.log(done);
				












					// palette[0] = RGB8(0x1e1e2e);
					// palette[1] = RGB8(0x313244);
					// palette[2] = RGB8(0x45475a);
					// palette[3] = RGB8(0xf5c2e7);

					// palette[0] = vec3(0.9607843137254902, 0.7607843137254902, 0.9058823529411765);    // f5c2e7
					// palette[1] = vec3(0.19215686274509805, 0.19607843137254902, 0.26666666666666666);   // 313244
					// palette[2] = vec3(0.11764705882352941, 0.11764705882352941, 0.1803921568627451);    // 1e1e2e
					// palette[3] = vec3(0.27058823529411763, 0.2784313725490196, 0.35294117647058826);    // 45475a


					
					// vec4 sourceColor = texture2D(source, qt_TexCoord0);

					// #if defined ENABLE
					// 	gl_FragColor = vec4(1.0 - sourceColor.rgb, sourceColor.a);
					// #else
					// 	gl_FragColor = vec4(sourceColor);
					// #endif
					// gl_FragColor = vec4(sourceColor);
					// gl_FragColor = vec4(candidateList[index], sourceColor.a);
				}
						

				
			#else
				void main() {
					vec4 sourceColor = texture2D(iChannel0, qt_TexCoord0);
					gl_FragColor = vec4(sourceColor);
				}
			#endif
			"


		property variant iChannel0: ShaderEffectSource {
			sourceItem: sceneImageBackground_base
			hideSource: true
			live: false
		}
	}

    ShaderEffectSource {
        id: cacheItem
        anchors.fill: parent
        visible: yes
        smooth: true
        sourceItem: sceneImageBackground_ShaderEffect
        live: true
        hideSource: visible
    }
}

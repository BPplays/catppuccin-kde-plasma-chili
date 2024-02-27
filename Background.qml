import QtQuick 2.2
import QtGraphicalEffects 1.0

FocusScope {
    id: sceneBackground_base

    property int screenWidth: Screen.width
    property int screenHeight: Screen.height

    Image {
        id: sceneImageBackground_base
        anchors.fill: parent
        // fillMode: Image.PreserveAspectFit
		fillMode: Image.PreserveAspectFill
        source: config.background || config.Background
        smooth: true

        layer.enabled: true
        layer.effect: ShaderEffect {
            width: sceneImageBackground_base.width
            height: sceneImageBackground_base.height

			fragmentShader: "
					#version 330 core
					#define N 32                   // Number of iterations per fragment (higher N = more samples)
					#define RGB8(h) (vec3(h >> 16 & 0xFF, h >> 8 & 0xFF, h & 0xFF) / 255.0) 
					#define PALETTE_SIZE 4        // Number of colours in the palette
					#define ERROR_FACTOR 0.8       // Quantisation error coefficient (0 = no dithering)
					#define PIXEL_SIZE 1.0         // Size of pixels in the shader output
					#define ENABLE_SORT            // Choose whether to enable the sorting procedures
					// #define OPTIMISED_KNOLL        // Run an optimised version of the algorithm
					#define ENABLE


					#define INFINITY 3.4e38        // 'Infinity'



					
					uniform lowp sampler2D source;
					varying highp vec2 qt_TexCoord0;

					vec3 palette[PALETTE_SIZE];

					// colorPalette[0] = vec3(0.9607843137254902, 0.7607843137254902, 0.9058823529411765);    // f5c2e7
					// colorPalette[1] = vec3(0.19215686274509805, 0.19607843137254902, 0.26666666666666666);   // 313244
					// colorPalette[2] = vec3(0.11764705882352941, 0.11764705882352941, 0.1803921568627451);    // 1e1e2e
					// colorPalette[3] = vec3(0.27058823529411763, 0.2784313725490196, 0.35294117647058826);    // 45475a


					vec3 sRGBtoLinear(vec3 colour)
					{
						return colour * (colour * (colour * 0.305306011 + 0.682171111) + 0.012522878);
					}

					// Get the luminance value of a given colour
					float getLuminance(vec3 colour)
					{
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
						ivec2 pixel = ivec2(coord / PIXEL_SIZE) % ivec2(textureSize(iChannel1, 0));
						vec2 uv = vec2(pixel) / vec2(textureSize(iChannel1, 0));
						// vec2 offset = 0.5 / vec2(textureSize(iChannel1, 0));
						return texture2D(iChannel1, uv + offset).x * (N - 1.0);
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

						palette[0] = vec3(0.9607843137254902, 0.7607843137254902, 0.9058823529411765);    // f5c2e7
						palette[1] = vec3(0.19215686274509805, 0.19607843137254902, 0.26666666666666666);   // 313244
						palette[2] = vec3(0.11764705882352941, 0.11764705882352941, 0.1803921568627451);    // 1e1e2e
						palette[3] = vec3(0.27058823529411763, 0.2784313725490196, 0.35294117647058826);    // 45475a


						
						vec4 sourceColor = texture2D(source, qt_TexCoord0);

						#if defined ENABLE
							gl_FragColor = vec4(1.0 - sourceColor.rgb, sourceColor.a);
						#else
							gl_FragColor = vec4(sourceColor);
						#endif
						// gl_FragColor = vec4(sourceColor);
						// gl_FragColor = vec4(candidateList[index], sourceColor.a);
					}
				"

            property variant source: ShaderEffectSource {
                sourceItem: sceneImageBackground_base
                hideSource: true
            }
        }
    }
}

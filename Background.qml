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
					#define N 32                   // Number of iterations per fragment (higher N = more samples)
					#define PALETTE_SIZE 4        // Number of colours in the palette
					#define ERROR_FACTOR 0.8       // Quantisation error coefficient (0 = no dithering)
					#define PIXEL_SIZE 2.0         // Size of pixels in the shader output
					#define ENABLE_SORT            // Choose whether to enable the sorting procedures
					#define OPTIMISED_KNOLL        // Run an optimised version of the algorithm
					#define ENABLE
					uniform lowp sampler2D source;
					varying highp vec2 qt_TexCoord0;

					vec3 palette[PALETTE_SIZE];

					// colorPalette[0] = vec3(0.9607843137254902, 0.7607843137254902, 0.9058823529411765);    // f5c2e7
					// colorPalette[1] = vec3(0.19215686274509805, 0.19607843137254902, 0.26666666666666666);   // 313244
					// colorPalette[2] = vec3(0.11764705882352941, 0.11764705882352941, 0.1803921568627451);    // 1e1e2e
					// colorPalette[3] = vec3(0.27058823529411763, 0.2784313725490196, 0.35294117647058826);    // 45475a




					void main() {

						palette[0] = RGB8(0x1e1e2e);
						palette[1] = RGB8(0x313244);
						// palette[2] = RGB8(0x45475a);
						// palette[3] = RGB8(0xf5c2e7);



						
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

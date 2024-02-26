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
					#define PALETTE_SIZE 16        // Number of colours in the palette
					#define ERROR_FACTOR 0.8       // Quantisation error coefficient (0 = no dithering)
					#define PIXEL_SIZE 2.0         // Size of pixels in the shader output
					#define ENABLE_SORT            // Choose whether to enable the sorting procedures
					#define OPTIMISED_KNOLL        // Run an optimised version of the algorithm
					#define ENABLE
					uniform lowp sampler2D source;
					varying highp vec2 qt_TexCoord0;



					void main() {
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

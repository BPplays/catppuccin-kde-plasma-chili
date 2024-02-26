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
					#define N 32
					uniform lowp sampler2D source;
					varying highp vec2 qt_TexCoord0;



					void main() {
						vec4 sourceColor = texture2D(source, qt_TexCoord0);

						gl_FragColor = vec4(sourceColor.rg, N/999, sourceColor.a);
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

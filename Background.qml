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

                void main() {

				}
            "

            property variant source: ShaderEffectSource {
                sourceItem: sceneImageBackground_base
                hideSource: true
            }
        }
    }
}

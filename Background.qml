import QtQuick 2.2
import QtGraphicalEffects 1.0

FocusScope {
    id: sceneBackground_base

    property int screenWidth: Screen.width
    property int screenHeight: Screen.height

    // Declare a uniform property for color palette
    property color colorPalette[4]: [
        "#f5c2e7",
        "#313244",
        "#1e1e2e",
        "#45475a"
    ]

    Image {
        id: sceneImageBackground_base
        anchors.fill: parent
        // fillMode: Image.Pad
        fillMode: Image.PreserveAspectFit
        source: config.background || config.Background
        smooth: true

        // property real scaleRatio: Math.max(1, Math.round(screenWidth / sceneImageBackground_base.width))
        // transform: Scale {
        //     origin.x: sceneImageBackground_base.width / 2
        //     origin.y: sceneImageBackground_base.height / 2
        //     xScale: scaleRatio
        //     yScale: scaleRatio
        // }

        layer.enabled: true
        layer.effect: ShaderEffect {
            width: sceneImageBackground_base.width
            height: sceneImageBackground_base.height

            fragmentShader: "
                varying highp vec2 qt_TexCoord0;
                uniform lowp sampler2D source;

                // Color palette
                uniform lowp vec3 colorPalette[4];

                void main() {
                    vec4 srcColor = texture2D(source, qt_TexCoord0);
                    // vec3 originalColor = srcColor.rgb;


                    gl_FragColor = vec4(srcColor);
                }
            "

            property variant source: ShaderEffectSource {
                sourceItem: sceneImageBackground_base
                hideSource: true
            }
            // Set the colorPalette uniform
            onColorPaletteChanged: {
                shaderEffect.colorPalette = colorPalette.map(function(color) { return Qt.rgba(color.r, color.g, color.b, 1.0); });
            }
        }
    }
}

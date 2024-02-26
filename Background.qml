import QtQuick 2.2
import QtGraphicalEffects 1.0

FocusScope {
    id: sceneBackground_base

    property int screenWidth: Screen.width
    property int screenHeight: Screen.height

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
                const vec3 colorPalette[4] = vec3[4](
                    vec3(0.9607843137254902, 0.7607843137254902, 0.9058823529411765),    // f5c2e7
                    vec3(0.19215686274509805, 0.19607843137254902, 0.26666666666666666),   // 313244
                    vec3(0.11764705882352941, 0.11764705882352941, 0.1803921568627451),    // 1e1e2e
                    vec3(0.27058823529411763, 0.2784313725490196, 0.35294117647058826)    // 45475a
                );

                // Ordered dithering matrix
                const mat4 ditherMatrix = mat4(
                     0.0, 0.5, 0.125, 0.625,
                    0.75, 0.25, 0.875, 0.375,
                    0.1875, 0.6875, 0.0625, 0.5625,
                    0.9375, 0.4375, 1.0, 0.5
                );

                void main() {
                    vec4 srcColor = texture2D(source, qt_TexCoord0);
                    vec3 originalColor = srcColor.rgb;

                    // Apply ordered dithering
                    int x = int(mod(qt_TexCoord0.x * 4.0, 4.0));
                    int y = int(mod(qt_TexCoord0.y * 4.0, 4.0));
                    float ditherValue = ditherMatrix[x + 4 * y];
                    vec3 ditheredColor = originalColor + colorPalette[int(ditherValue * 4.0)] - 0.5;

                    gl_FragColor = vec4(ditheredColor, srcColor.a);
                }
            "

            property variant source: ShaderEffectSource {
                sourceItem: sceneImageBackground_base
                hideSource: true
            }
        }
    }
}

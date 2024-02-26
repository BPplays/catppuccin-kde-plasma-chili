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

                const vec3 colorPalette[4] = vec3[4](
                    vec3(0.9607843137254902, 0.7607843137254902, 0.9058823529411765),    // f5c2e7
                    vec3(0.19215686274509805, 0.19607843137254902, 0.26666666666666666),   // 313244
                    vec3(0.11764705882352941, 0.11764705882352941, 0.1803921568627451),    // 1e1e2e
                    vec3(0.27058823529411763, 0.2784313725490196, 0.35294117647058826)    // 45475a
                );

                void main() {
                    vec4 srcColor = texture2D(source, qt_TexCoord0);

                    // Quantize the color to the nearest color in the palette
                    vec3 quantizedColor = colorPalette[int(srcColor.r * 3.999)];

                    // Apply ordered dithering
                    ivec2 texCoord = ivec2(gl_FragCoord.xy);
                    int x = texCoord.x % 2;
                    int y = texCoord.y % 2;
                    vec3 ditheredColor = quantizedColor + vec3(x, y, 0) * 0.5; // Adjust dithering strength as needed

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

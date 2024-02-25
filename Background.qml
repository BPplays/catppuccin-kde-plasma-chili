import QtQuick 2.2
import QtGraphicalEffects 1.0

FocusScope {
    id: sceneBackground_base

    property int screenWidth: Screen.width
    property int screenHeight: Screen.height

    Image {
        id: sceneImageBackground_base
        anchors.fill: parent
        fillMode: Image.Pad
        source: config.background || config.Background
        smooth: true

        // Calculate the nearest integer scaling factor
        property real scaleRatio: Math.max(1, Math.round(screenWidth / sceneImageBackground_base.width))
        transform: Scale {
            origin.x: sceneImageBackground_base.width / 2
            origin.y: sceneImageBackground_base.height / 2
            xScale: scaleRatio
            yScale: scaleRatio
        }

        ShaderEffectItem {
            width: sceneImageBackground_base.width
            height: sceneImageBackground_base.height
            anchors.fill: parent
            sourceItem: sceneImageBackground_base

            fragmentShader: "
                uniform lowp float qt_Opacity;
                varying highp vec2 qt_TexCoord0;
                uniform sampler2D source;

                // Color palette
                vec3 colorPalette[4] = vec3[4](
                    vec3(0.9607843137254902, 0.7607843137254902, 0.9058823529411765),    // f5c2e7
                    vec3(0.19215686274509805, 0.19607843137254902, 0.26666666666666666),   // 313244
                    vec3(0.11764705882352941, 0.11764705882352941, 0.1803921568627451),    // 1e1e2e
                    vec3(0.27058823529411763, 0.2784313725490196, 0.35294117647058826)    // 45475a
                );

                void main() {
                    vec4 srcColor = texture2D(source, qt_TexCoord0);
                    vec3 originalColor = srcColor.rgb;

                    // Apply ordered dithering
                    ivec2 texCoord = ivec2(gl_FragCoord.xy);
                    int x = texCoord.x % 4;
                    int y = texCoord.y % 4;
                    vec3 ditheredColor = originalColor + colorPalette[x + 4 * y] - 0.5;

                    gl_FragColor = vec4(ditheredColor, srcColor.a) * qt_Opacity;
                }
            "
        }
    }
}

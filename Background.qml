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

        // Apply shader effect for color quantization with ordered dithering
        layer.enabled: true
        layer.effect: ShaderEffect {
            width: sceneImageBackground_base.width
            height: sceneImageBackground_base.height

            fragmentShader: "
                uniform sampler2D source;
                uniform lowp float qt_Opacity;
                varying highp vec2 qt_TexCoord0;

                // Custom color palette
                const vec3 colorPalette[4] = vec3[4](
                    vec3(0.9607843137254902, 0.7607843137254902, 0.9058823529411765),    // f5c2e7
                    vec3(0.19215686274509805, 0.19607843137254902, 0.26666666666666666),    // 313244
                    vec3(0.11764705882352941, 0.11764705882352941, 0.1803921568627451),    // 1e1e2e
                    vec3(0.27058823529411763, 0.2784313725490196, 0.35294117647058826)    // 45475a
                );

                // Ordered dithering matrix
                const mat3 ditherMatrix = mat3(
                    vec3(0.5137, 0.7255, 0.4824),
                    vec3(0.2000, 0.4824, 0.2000),
                    vec3(0.6000, 0.7255, 0.5137)
                );

                void main() {
                    // Get the original color
                    vec4 originalColor = texture2D(source, qt_TexCoord0);

                    // Convert to grayscale using the luminosity method
                    float grayscale = dot(originalColor.rgb, vec3(0.299, 0.587, 0.114));

                    // Quantize the color based on the custom palette
                    vec3 quantizedColor = colorPalette[int(grayscale * 3.99)];

                    // Apply ordered dithering
                    vec3 ditheredColor = quantizedColor + (ditherMatrix[gl_FragCoord.xy % 3] - 0.5) / 255.0;

                    // Output the final color
                    gl_FragColor = vec4(ditheredColor, originalColor.a) * qt_Opacity;
                }
            "

            property var customPalette: [
                vec3(0.9607843137254902, 0.7607843137254902, 0.9058823529411765),    // f5c2e7
                vec3(0.19215686274509805, 0.19607843137254902, 0.26666666666666666),    // 313244
                vec3(0.11764705882352941, 0.11764705882352941, 0.1803921568627451),    // 1e1e2e
                vec3(0.27058823529411763, 0.2784313725490196, 0.35294117647058826),    // 45475a
                // Add more colors as needed
            ]

            property var textureSource: sceneImageBackground_base

            onEnabledChanged: {
                if (enabled) {
                    setUniformValue("qt_CustomPalette", customPalette);
                }
            }
        }
    }
}

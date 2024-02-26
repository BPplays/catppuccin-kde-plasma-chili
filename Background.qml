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
    vec3 colorPalette[4];

    // Function to calculate distance between two colors
    float colorDistance(vec3 c1, vec3 c2) {
        vec3 diff = c1 - c2;
        return dot(diff, diff);
    }

    void main() {
        vec4 srcColor = texture2D(source, qt_TexCoord0);

        // Define the color palette
        colorPalette[0] = vec3(0.9607843137254902, 0.7607843137254902, 0.9058823529411765);    // f5c2e7
        colorPalette[1] = vec3(0.19215686274509805, 0.19607843137254902, 0.26666666666666666);   // 313244
        colorPalette[2] = vec3(0.11764705882352941, 0.11764705882352941, 0.1803921568627451);    // 1e1e2e
        colorPalette[3] = vec3(0.27058823529411763, 0.2784313725490196, 0.35294117647058826);    // 45475a

        // Get the original color
        vec3 originalColor = srcColor.rgb;

        // Find the closest color in the palette
        float minDist = colorDistance(originalColor, colorPalette[0]);
        int closestColorIndex = 0;
        for (int i = 1; i < 4; ++i) {
            float dist = colorDistance(originalColor, colorPalette[i]);
            if (dist < minDist) {
                minDist = dist;
                closestColorIndex = i;
            }
        }

        // Apply ordered dithering with reduced strength
        int x = int(mod(gl_FragCoord.x / 2.0, 2.0));
        int y = int(mod(gl_FragCoord.y / 2.0, 2.0));
        float ditherValue = float(x + 2 * y) / 1.0;  // Adjust the denominator for milder dithering
        vec3 ditheredColor = mix(originalColor, colorPalette[closestColorIndex], ditherValue);

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

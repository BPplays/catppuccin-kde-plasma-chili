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
    vec3 colorPalette[256];

    // 8x8 threshold map for pattern dithering
    const int thresholdMap[8][8] = {
        0, 48, 12, 60, 3, 51, 15, 63,
        32, 16, 44, 28, 35, 19, 47, 31,
        8, 56, 4, 52, 11, 59, 7, 55,
        40, 24, 36, 20, 43, 27, 39, 23,
        2, 50, 14, 62, 1, 49, 13, 61,
        34, 18, 46, 30, 33, 17, 45, 29,
        10, 58, 6, 54, 9, 57, 5, 53,
        42, 26, 38, 22, 41, 25, 37, 21
    };

    // Function to calculate distance between two colors
    float colorDistance(vec3 c1, vec3 c2) {
        vec3 diff = c1 - c2;
        return dot(diff, diff);
    }

    // Function to find the closest color in the palette
    int closestColorIndex(vec3 originalColor) {
        float minDist = colorDistance(originalColor, colorPalette[0]);
        int closestIndex = 0;
        for (int i = 1; i < 4; ++i) {
            float dist = colorDistance(originalColor, colorPalette[i]);
            if (dist < minDist) {
                minDist = dist;
                closestIndex = i;
            }
        }
        return closestIndex;
    }

    void main() {
        vec4 srcColor = texture2D(source, qt_TexCoord0);

        colorPalette[0] = vec3(0.9607843137254902, 0.7607843137254902, 0.9058823529411765);    // f5c2e7
        colorPalette[1] = vec3(0.19215686274509805, 0.19607843137254902, 0.26666666666666666);   // 313244
        colorPalette[2] = vec3(0.11764705882352941, 0.11764705882352941, 0.1803921568627451);    // 1e1e2e
        colorPalette[3] = vec3(0.27058823529411763, 0.2784313725490196, 0.35294117647058826);    // 45475a
        //colorPalette[4] = vec3(0.8470588235294118, 0.7019607843137254, 0.8313725490196079);    // ! remove later D8B3D4

        vec3 originalColor = srcColor.rgb;

        // Pattern dithering
        int x = int(gl_FragCoord.x) % 8;
        int y = int(gl_FragCoord.y) % 8;
        float threshold = float(thresholdMap[x][y]) / 63.0;

        // Apply dithering threshold
        originalColor += threshold * (originalColor - colorPalette[closestColorIndex(originalColor)]);

        // Find the closest color in the palette
        int closestIndex = closestColorIndex(originalColor);

        gl_FragColor = vec4(colorPalette[closestIndex], srcColor.a);
    }
"


            property variant source: ShaderEffectSource {
                sourceItem: sceneImageBackground_base
                hideSource: true
            }
        }
    }
}

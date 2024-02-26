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

    // 8x8 threshold map (note: the patented pattern dithering algorithm uses 4x4)
    const mat4 thresholdMatrix = mat4(
        vec4(0.0, 0.48, 0.12, 0.60),
        vec4(0.03, 0.51, 0.15, 0.63),
        vec4(0.32, 0.16, 0.44, 0.28),
        vec4(0.35, 0.19, 0.47, 0.31)
    );

    // Color palette
    vec3 colorPalette[16];

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

        // Set the color palette
        colorPalette[0] = vec3(0.9607843137254902, 0.7607843137254902, 0.9058823529411765);
        colorPalette[1] = vec3(0.19215686274509805, 0.19607843137254902, 0.26666666666666666);
        colorPalette[2] = vec3(0.11764705882352941, 0.11764705882352941, 0.1803921568627451);
        colorPalette[3] = vec3(0.27058823529411763, 0.2784313725490196, 0.35294117647058826);

        // Get the original color
        vec3 originalColor = srcColor.rgb;

        // Initialize error
        float error = 0.0;

        // Candidate list
        int candidateList[16];

        // Populate candidate list
        for (int i = 0; i < 16; ++i) {
            float attempt = originalColor + error * thresholdMatrix[i % 4][i / 4];
            candidateList[i] = closestColorIndex(attempt);
            error = originalColor - colorPalette[candidateList[i]];
        }

        // Sort candidate list by luminance
        for (int i = 0; i < 15; ++i) {
            for (int j = 0; j < 15 - i; ++j) {
                if (colorDistance(colorPalette[candidateList[j]], colorPalette[candidateList[j + 1]]) >
                    colorDistance(colorPalette[candidateList[j + 1]], colorPalette[candidateList[j]])) {
                    int temp = candidateList[j];
                    candidateList[j] = candidateList[j + 1];
                    candidateList[j + 1] = temp;
                }
            }
        }

        // Get the index from threshold matrix
        int index = int(mod(gl_FragCoord.x, 4.0)) + int(mod(gl_FragCoord.y, 4.0)) * 4;

        // Draw pixel using CandidateList[Index]
        gl_FragColor = vec4(colorPalette[candidateList[index]], srcColor.a);
    }
"




            property variant source: ShaderEffectSource {
                sourceItem: sceneImageBackground_base
                hideSource: true
            }
        }
    }
}

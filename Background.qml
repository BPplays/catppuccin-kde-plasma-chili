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

    // Function to find the two closest colors in the palette
    void closestColors(vec3 originalColor, out int closestIndex, out int secondClosestIndex) {
        float minDist = colorDistance(originalColor, colorPalette[0]);
        closestIndex = 0;
        secondClosestIndex = 1;
        float secondMinDist = colorDistance(originalColor, colorPalette[1]);
        if (secondMinDist < minDist) {
            minDist = secondMinDist;
            closestIndex = 1;
            secondMinDist = colorDistance(originalColor, colorPalette[0]);
            secondClosestIndex = 0;
        }
        for (int i = 2; i < 4; ++i) {
            float dist = colorDistance(originalColor, colorPalette[i]);
            if (dist < minDist) {
                secondClosestIndex = closestIndex;
                secondMinDist = minDist;
                minDist = dist;
                closestIndex = i;
            } else if (dist < secondMinDist) {
                secondClosestIndex = i;
                secondMinDist = dist;
            }
        }
    }

    // Bayer matrix for ordered dithering
    const mat3 bayerMatrix = mat3(
        vec3(0.0, 0.5, 0.125),
        vec3(0.75, 0.375, 0.625),
        vec3(0.1875, 0.9375, 0.0625)
    );

    void main() {
        vec4 srcColor = texture2D(source, qt_TexCoord0);

        colorPalette[0] = vec3(0.9607843137254902, 0.7607843137254902, 0.9058823529411765);    // f5c2e7
        colorPalette[1] = vec3(0.19215686274509805, 0.19607843137254902, 0.26666666666666666);   // 313244
        colorPalette[2] = vec3(0.11764705882352941, 0.11764705882352941, 0.1803921568627451);    // 1e1e2e
        colorPalette[3] = vec3(0.27058823529411763, 0.2784313725490196, 0.35294117647058826);    // 45475a

        vec3 originalColor = srcColor.rgb;

        // Find the two closest colors in the palette
        int closestIndex;
        int secondClosestIndex;
        closestColors(originalColor, closestIndex, secondClosestIndex);

        // Apply ordered dithering using Bayer matrix
        ivec2 pixelCoord = ivec2(gl_FragCoord.xy);
        int x = int(mod(float(pixelCoord.x), 3.0));
        int y = int(mod(float(pixelCoord.y), 3.0));
        float ditherValue = bayerMatrix[x][y];

        // Adjust dither intensity based on pixel position
        ditherValue = clamp(ditherValue + 0.25 * (float(pixelCoord.x) / float(gl_FragCoord.x) + float(pixelCoord.y) / float(gl_FragCoord.y)), 0.0, 1.0);

        // Blend between the two closest colors
        vec3 blendedColor = mix(colorPalette[closestIndex], colorPalette[secondClosestIndex], ditherValue);

        gl_FragColor = vec4(blendedColor, srcColor.a);
    }
"

            property variant source: ShaderEffectSource {
                sourceItem: sceneImageBackground_base
                hideSource: true
            }
        }
    }
}

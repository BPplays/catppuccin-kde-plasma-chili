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

        colorPalette[0] = vec3(0.9607843137254902, 0.7607843137254902, 0.9058823529411765);    // f5c2e7
        colorPalette[1] = vec3(0.19215686274509805, 0.19607843137254902, 0.26666666666666666);   // 313244
        colorPalette[2] = vec3(0.11764705882352941, 0.11764705882352941, 0.1803921568627451);    // 1e1e2e
        colorPalette[3] = vec3(0.27058823529411763, 0.2784313725490196, 0.35294117647058826);    // 45475a

        vec3 originalColor = srcColor.rgb;

        // Find the two closest colors in the palette
        float minDist1 = colorDistance(originalColor, colorPalette[0]);
        float minDist2 = colorDistance(originalColor, colorPalette[1]);
        int closestColorIndex1 = 0;
        int closestColorIndex2 = 1;

        for (int i = 1; i < 4; ++i) {
            float dist = colorDistance(originalColor, colorPalette[i]);
            if (dist < minDist1) {
                minDist2 = minDist1;
                closestColorIndex2 = closestColorIndex1;

                minDist1 = dist;
                closestColorIndex1 = i;
            } else if (dist < minDist2) {
                minDist2 = dist;
                closestColorIndex2 = i;
            }
        }

        // Calculate the dithering weight
        float ditherValue = fract(dot(fract(qt_TexCoord0 * 4.0), vec2(2.0, 2.0)));

        // Interpolate between the two closest colors based on the dithering value
        vec3 ditheredColor = mix(colorPalette[closestColorIndex1], colorPalette[closestColorIndex2], ditherValue);

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

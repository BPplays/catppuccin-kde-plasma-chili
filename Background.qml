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
        uniform lowp sampler2D source;
        varying highp vec2 qt_TexCoord0;

        vec3 colorPalette[4];
        
        // 8x8 threshold map (note: the patented pattern dithering algorithm uses 4x4)
        const mat4 thresholdMap = mat4(
            0.0, 48.0, 12.0, 60.0,
            3.0, 51.0, 15.0, 63.0,
            32.0, 16.0, 44.0, 28.0,
            35.0, 19.0, 47.0, 31.0
        );

        void main() {
            vec4 sourceColor = texture2D(source, qt_TexCoord0);
            vec3 inputColor = sourceColor.rgb;

            colorPalette[0] = vec3(0.9607843137254902, 0.7607843137254902, 0.9058823529411765);    // f5c2e7
            colorPalette[1] = vec3(0.19215686274509805, 0.19607843137254902, 0.26666666666666666);   // 313244
            colorPalette[2] = vec3(0.11764705882352941, 0.11764705882352941, 0.1803921568627451);    // 1e1e2e
            colorPalette[3] = vec3(0.27058823529411763, 0.2784313725490196, 0.35294117647058826);    // 45475a

            float error = 0.0;
            vec3 candidateList[16];

            for (int i = 0; i < 16; ++i) {
                float attemptR = inputColor.r + error.r * threshold;
                float attemptG = inputColor.g + error.g * threshold;
                float attemptB = inputColor.b + error.b * threshold;

                vec3 candidate = colorPalette[int(thresholdMap[i])];
                
                float errorR = attemptR - candidate.r;
                float errorG = attemptG - candidate.g;
                float errorB = attemptB - candidate.b;

                candidateList[i] = candidate;

                error = vec3(errorR, errorG, errorB);
            }

            // Sort candidateList by luminance (you may need to implement a luminance function)
            // ...

            int index = int(thresholdMap[int(mod(gl_FragCoord.x, 4.0))][int(mod(gl_FragCoord.y, 4.0))]);
            gl_FragColor = vec4(sourceColor);
            // gl_FragColor = vec4(candidateList[index], sourceColor.a);
        }
    "





            property variant source: ShaderEffectSource {
                sourceItem: sceneImageBackground_base
                hideSource: true
            }
        }
    }
}

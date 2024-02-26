import QtQuick 2.2
import QtGraphicalEffects 1.0

FocusScope {
    id: sceneBackground_base

    property int screenWidth: Screen.width
    property int screenHeight: Screen.height

    Image {
        id: sceneImageBackground_base
        anchors.fill: parent
        fillMode: Image.PreserveAspectFit
        source: config.background || config.Background
        smooth: true

        layer.enabled: true
        layer.effect: ShaderEffect {
            width: sceneImageBackground_base.width
            height: sceneImageBackground_base.height

            fragmentShader: "
                uniform lowp sampler2D source;
                varying highp vec2 qt_TexCoord0;

                vec3 colorPalette[4];
                const vec3 palette[4] = vec3[](
                    RGB8(0x1e1e2e), RGB8(0x313244), RGB8(0x45475a), RGB8(0xf5c2e7));

                mat4 thresholdMap = mat4(
                    vec4(00.0/16.0, 12.0/16.0, 03.0/16.0, 15.0/16.0),
                    vec4(08.0/16.0, 04.0/16.0, 11.0/16.0, 07.0/16.0),
                    vec4(02.0/16.0, 14.0/16.0, 01.0/16.0, 13.0/16.0),
                    vec4(10.0/16.0, 06.0/16.0, 09.0/16.0, 05.0/16.0));

                void main() {
                    vec4 sourceColor = texture2D(source, qt_TexCoord0);
                    vec3 inputColor = sourceColor.rgb;

                    colorPalette[0] = vec3(0.9607843137254902, 0.7607843137254902, 0.9058823529411765);
                    colorPalette[1] = vec3(0.19215686274509805, 0.19607843137254902, 0.26666666666666666);
                    colorPalette[2] = vec3(0.11764705882352941, 0.11764705882352941, 0.1803921568627451);
                    colorPalette[3] = vec3(0.27058823529411763, 0.2784313725490196, 0.35294117647058826);

                    float error = 0.0;
                    vec3 candidateList[16];

                    for (int i = 0; i < 16; ++i) {
                        float attempt = inputColor + error * thresholdMap;
                        vec3 candidate = colorPalette[int(thresholdMap[i])];
                        candidateList[i] = candidate;
                        error = inputColor - candidate;
                    }

                    int index = int(thresholdMap[int(mod(gl_FragCoord.x, 4.0))][int(mod(gl_FragCoord.y, 4.0))]);
                    gl_FragColor = vec4(candidateList[index], sourceColor.a);
                }
            "

            property variant source: ShaderEffectSource {
                sourceItem: sceneImageBackground_base
                hideSource: true
            }
        }
    }
}

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
        // const mat4 thresholdMap = mat4(
        //     0.0, 48.0, 12.0, 60.0,
        //     3.0, 51.0, 15.0, 63.0,
        //     32.0, 16.0, 44.0, 28.0,
        //     35.0, 19.0, 47.0, 31.0
        // );

        const palette_size = 4;

        const vec3 palette[palette_size] = vec3[](
            RGB8(0x1e1e2e), RGB8(0x313244), RGB8(0x45475a), RGB8(0xf5c2e7));

        // vec3 sRGBtoLinear(vec3 colour) {
        //     return colour * (colour * (colour * 0.305306011 + 0.682171111) + 0.012522878);
        // }

        float getLuminance(vec3 colour) {
            return colour.r * 0.299 + colour.g * 0.587 + colour.b * 0.114;
        }

        int getClosestColour(vec3 inputColour) {
            float closestDistance = INFINITY;
            int closestColour = 0;
            
            for (int i = 0; i < palette_size; i++) {
                vec3 difference = inputColour - sRGBtoLinear(palette[i]);
                float distance = dot(difference, difference);
                
                if (distance < closestDistance)
                {
                    closestDistance = distance;
                    closestColour = i;
                }
            }
            
            return closestColour;
        }

        float sampleThreshold(vec2 coord) {
            // Sample the centre of the texel
            ivec2 pixel = ivec2(coord / PIXEL_SIZE) % ivec2(iChannelResolution[1]);
            vec2 uv = vec2(pixel) / iChannelResolution[1].xy;
            vec2 offset = 0.5 / iChannelResolution[1].xy;
            return texture(iChannel1, uv + offset).x * float(N - 1);
        }

        mat4 thresholdMap = mat4(
            vec4(00.0/16.0, 12.0/16.0, 03.0/16.0, 15.0/16.0),
            vec4(08.0/16.0, 04.0/16.0, 11.0/16.0, 07.0/16.0),
            vec4(02.0/16.0, 14.0/16.0, 01.0/16.0, 13.0/16.0),
            vec4(10.0/16.0, 06.0/16.0, 09.0/16.0, 05.0/16.0));

        void main() {
            vec4 sourceColor = texture2D(source, qt_TexCoord0);
            vec3 inputColor = sourceColor.rgb;

            colorPalette[0] = vec3(0.9607843137254902, 0.7607843137254902, 0.9058823529411765);    // f5c2e7
            colorPalette[1] = vec3(0.19215686274509805, 0.19607843137254902, 0.26666666666666666);   // 313244
            colorPalette[2] = vec3(0.11764705882352941, 0.11764705882352941, 0.1803921568627451);    // 1e1e2e
            colorPalette[3] = vec3(0.27058823529411763, 0.2784313725490196, 0.35294117647058826);    // 45475a

            float error = 0.0;
            vec3 candidateList[16];

            // for (int i = 0; i < 16; ++i) {
            //     float attempt = inputColor + error * threshold;
            //     vec3 candidate = colorPalette[int(thresholdMap[i])];
            //     candidateList[i] = candidate;
            //     error = inputColor - candidate;
            // }

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

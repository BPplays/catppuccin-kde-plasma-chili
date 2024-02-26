import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15
import QtQuick.ShaderEffects 1.12

Window {
    visible: true
    width: 800
    height: 600

    Rectangle {
        width: 800
        height: 600

        ShaderEffect {
            width: 800
            height: 600

            fragmentShader: "
                varying highp vec2 qt_TexCoord0;
                uniform sampler2D source;

                const int N = 32;
                const int PALETTE_SIZE = 16;
                const float ERROR_FACTOR = 0.8;
                const float PIXEL_SIZE = 2.0;
                
                const vec3 palette[PALETTE_SIZE] = vec3[](
                    vec3(0.0, 0.0, 0.0), vec3(0.117647, 0.168627, 0.325490), vec3(0.494118, 0.145098, 0.325490), vec3(1.0, 0.0, 0.301961),
                    vec3(0.372549, 0.223529, 0.305882), vec3(0.670588, 0.258824, 0.211765), vec3(0.0, 0.529412, 0.317647), vec3(0.513725, 0.462745, 0.694118),
                    vec3(1.0, 0.466667, 0.658824), vec3(1.0, 0.643137, 0.0), vec3(0.160784, 0.678431, 1.0), vec3(0.760784, 0.764706, 0.780392),
                    vec3(0.0, 0.894118, 0.211765), vec3(1.0, 0.8, 0.666667), vec3(1.0, 0.92549, 0.152941), vec3(1.0, 0.945098, 0.909804)
                );

                vec3 sRGBtoLinear(vec3 colour) {
                    return colour * (colour * (colour * 0.305306011 + 0.682171111) + 0.012522878);
                }

                float getLuminance(vec3 colour) {
                    return dot(colour, vec3(0.299, 0.587, 0.114));
                }

                int getClosestColour(vec3 inputColour) {
                    float closestDistance = 3.4e38;
                    int closestColour = 0;

                    for (int i = 0; i < PALETTE_SIZE; i++) {
                        vec3 difference = inputColour - sRGBtoLinear(palette[i]);
                        float distance = dot(difference, difference);

                        if (distance < closestDistance) {
                            closestDistance = distance;
                            closestColour = i;
                        }
                    }

                    return closestColour;
                }

                float sampleThreshold(vec2 coord) {
                    vec2 uv = coord / PIXEL_SIZE / iResolution.xy;
                    return texture(source, uv).r * float(N - 1);
                }

                void main() {
                    vec2 fragCoord = gl_FragCoord.xy;

                    // Get the colour for this fragment
                    vec2 pixelSizeNormalised = PIXEL_SIZE * (1.0 / iResolution.xy);
                    vec2 uv = pixelSizeNormalised * floor(fragCoord / iResolution.xy / pixelSizeNormalised);
                    vec3 colour = texture(source, uv).rgb;

                    // Screen wipe effect
                    if (fragCoord.x < iMouse.x) {
                        gl_FragColor = vec4(colour, 1.0);
                        return;
                    }

                    // Actual dithering algorithm starts here
                    int candidates[N];
                    vec3 quantError = vec3(0, 0, 0);
                    vec3 colourLinear = sRGBtoLinear(colour);

                    for (int i = 0; i < N; i++) {
                        vec3 goalColour = colourLinear + quantError * ERROR_FACTOR;
                        int closestColour = getClosestColour(goalColour);

                        candidates[i] = closestColour;
                        quantError += colourLinear - sRGBtoLinear(palette[closestColour]);
                    }

                    // Select from the candidate array, using the value in the threshold matrix
                    int index = int(sampleThreshold(fragCoord));
                    gl_FragColor = vec4(palette[candidates[index]], 1.0);
                }
            "

            property alias source: item.source
        }

        Image {
            id: item
            source: "your_image.jpg"
            anchors.fill: parent
        }
    }
}

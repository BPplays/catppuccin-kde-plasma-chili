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
                varying highp vec2 qt_TexCoord0;
                uniform sampler2D source;
                uniform sampler2D threshold;

                const float INFINITY = 3.4e38;

                vec3 sRGBtoLinear(vec3 colour) {
                    return colour * (colour * (colour * 0.305306011 + 0.682171111) + 0.012522878);
                }

                float getLuminance(vec3 colour) {
                    return dot(colour, vec3(0.299, 0.587, 0.114));
                }

                int getClosestColour(vec3 inputColour) {
                    float closestDistance = INFINITY;
                    int closestColour = 0;

                    for (int i = 0; i < PALETTE_SIZE; i++) {
                        vec3 difference = inputColour - sRGBtoLinear(texture2D(source, qt_TexCoord0).rgb);
                        float distance = dot(difference, difference);

                        if (distance < closestDistance) {
                            closestDistance = distance;
                            closestColour = i;
                        }
                    }

                    return closestColour;
                }

                float sampleThreshold(vec2 coord) {
                    vec2 uv = coord / PIXEL_SIZE / textureSize(threshold, 0);
                    return texture2D(threshold, uv).r * float(N - 1);
                }

                void main() {
                    vec2 fragCoord = gl_FragCoord.xy;

                    // Get the colour for this fragment
                    vec2 pixelSizeNormalised = PIXEL_SIZE * (1.0 / iResolution.xy);
                    vec2 uv = pixelSizeNormalised * floor(fragCoord / iResolution.xy / pixelSizeNormalised);
                    vec3 colour = texture2D(source, uv).rgb;

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
                        quantError += colourLinear - sRGBtoLinear(texture2D(source, uv).rgb);
                    }

                    #if ENABLE_SORT
                    // Sort the candidate array by luminance (bubble sort)
                    for (int i = N - 1; i > 0; i--) {
                        for (int j = 0; j < i; j++) {
                            if (getLuminance(texture2D(source, uv).rgb) > getLuminance(texture2D(source, uv).rgb)) {
                                // Swap the candidates
                                int t = candidates[j];
                                candidates[j] = candidates[j + 1];
                                candidates[j + 1] = t;
                            }
                        }
                    }
                    #endif

                    // Select from the candidate array, using the value in the threshold matrix
                    int index = int(sampleThreshold(fragCoord));
                    gl_FragColor = vec4(palette[candidates[index]], 1.0);
                }
            "

            property variant source: ShaderEffectSource {
                sourceItem: sceneImageBackground_base
                hideSource: true
            }
        }
    }
}

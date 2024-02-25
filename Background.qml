import QtQuick 2.2
import QtGraphicalEffects 1.0

FocusScope {
    id: sceneBackground_base

    property int screenWidth: Screen.width
    property int screenHeight: Screen.height

    // Define the custom color palette
    property var customPalette: [
        "f5c2e7",
        "313244",
        "1e1e2e",
        "45475a"
    ]

    ShaderEffect {
        id: colorPosterizationShader
        anchors.fill: sceneImageBackground_base
        fragmentShader: "
            #version 330

            uniform sampler2D source;
            uniform float screenWidth;
            uniform float screenHeight;
            uniform float paletteSize;

            uniform vec3 customPalette[4] = [ec3(0.9607843137254902, 0.7607843137254902, 0.9058823529411765),    // f5c2e7
                vec3(0.19215686274509805, 0.19607843137254902, 0.26666666666666666),    // 313244
                vec3(0.11764705882352941, 0.11764705882352941, 0.1803921568627451),    // 1e1e2e
                vec3(0.27058823529411763, 0.2784313725490196, 0.35294117647058826)    // 45475a; // Assuming a palette size of 4
            ]

            void main() {
                vec2 texCoord = gl_TexCoord[0].xy;
                vec4 color = texture2D(source, texCoord);

                // Convert to grayscale
                float gray = dot(color.rgb, vec3(0.299, 0.587, 0.114));

                // Map grayscale to index in the palette
                float index = floor(gray * (paletteSize - 1.0) + 0.5);

                // Apply ordered dithering
                vec2 ditherOffset = vec2(mod(texCoord.x, 8.0) / 8.0 - 0.5, mod(texCoord.y, 8.0) / 8.0 - 0.5);
                float ditherValue = (1.0 / 64.0) * float(int(texCoord.x) % 8 * 8 + int(texCoord.y) % 8);
                index += ditherValue;

                // Clamp index
                index = clamp(index, 0.0, paletteSize - 1.0);

                // Get color from the palette
                vec3 newColor = customPalette[int(index)];

                // Output final color
                gl_FragColor = vec4(newColor, color.a);
            }
        "
        property real paletteSize: customPalette.length

        ShaderEffectSource {
            id: sourceItem
            sourceItem: sceneImageBackground_base
            hideSource: true
        }

        onShaderChanged: {
            colorPosterizationShader.setUniformValue("screenWidth", sceneBackground_base.screenWidth)
            colorPosterizationShader.setUniformValue("screenHeight", sceneBackground_base.screenHeight)
            colorPosterizationShader.setUniformValue("paletteSize", colorPosterizationShader.paletteSize)
            colorPosterizationShader.setUniformValue("customPalette", colorPosterizationShader.paletteSize, colorPosterizationShader.customPalette)
        }
    }

    Image {
        id: sceneImageBackground_base
        anchors.fill: parent
        fillMode: Image.Pad
        source: config.background || config.Background
        smooth: true
    }
}

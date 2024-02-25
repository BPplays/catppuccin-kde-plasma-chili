import QtQuick 2.2
import QtGraphicalEffects 1.0

ShaderEffect {
    id: posterizationShader

    property variant source: ShaderEffectSource {
        sourceItem: sceneImageBackground_base
        hideSource: true
    }

    property int screenWidth: Screen.width
    property int screenHeight: Screen.height

    property vec3 colorPalette[4]: [
        vec3(0.9607843137254902, 0.7607843137254902, 0.9058823529411765),    // f5c2e7
        vec3(0.19215686274509805, 0.19607843137254902, 0.26666666666666666),  // 313244
        vec3(0.11764705882352941, 0.11764705882352941, 0.1803921568627451),   // 1e1e2e
        vec3(0.27058823529411763, 0.2784313725490196, 0.35294117647058826)   // 45475a
    ]

    vertexShader: "
        attribute highp vec4 qt_Vertex;
        attribute highp vec2 qt_MultiTexCoord0;
        varying highp vec2 coord;
        void main() {
            gl_Position = qt_Vertex;
            coord = qt_MultiTexCoord0;
        }
    "

    fragmentShader: "
        uniform highp float qt_Opacity;
        uniform highp vec3 colorPalette[4];
        varying highp vec2 coord;
        void main() {
            highp vec4 tex = texture2D(source, coord);
            highp float lum = dot(tex.rgb, vec3(0.299, 0.587, 0.114));
            highp int index = int(lum * 3.999);
            highp vec3 color = colorPalette[index];
            gl_FragColor = vec4(color, tex.a * qt_Opacity);
        }
    "
}

FocusScope {
    id: sceneBackground_base

    property int screenWidth: Screen.width
    property int screenHeight: Screen.height

    Image {
        id: sceneImageBackground_base
        anchors.fill: parent
        fillMode: Image.Pad
        source: config.background || config.Background
        smooth: true

        // Calculate the nearest integer scaling factor
        property real scaleRatio: Math.max(1, Math.round(screenWidth / sceneImageBackground_base.width))
        // scale: scaleRatio
        transform: Scale {
            origin.x: sceneImageBackground_base.width / 2
            origin.y: sceneImageBackground_base.height / 2
            xScale: scaleRatio
            yScale: scaleRatio
        }
    }

    ShaderEffect {
        width: sceneBackground_base.width
        height: sceneBackground_base.height
        filters: [posterizationShader]
    }
}
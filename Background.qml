/*
 *   Copyright 2016 Boudhayan Gupta <bgupta@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.2
import QtGraphicalEffects 1.0

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

        // Apply shader effect for color quantization with ordered dithering
        layer.enabled: true
        layer.effect: ShaderEffect {
            width: sceneImageBackground_base.width
            height: sceneImageBackground_base.height

            fragmentShader: "
                varying highp vec2 qt_TexCoord0;
                uniform lowp sampler2D source;
                uniform lowp float qt_Opacity;
                uniform lowp vec3 qt_CustomPalette[16];
                
                void main() {
                    lowp vec4 color = texture2D(source, qt_TexCoord0);
                    
                    // Convert to grayscale
                    lowp float gray = dot(color.rgb, vec3(0.299, 0.587, 0.114));
                    
                    // Quantize using ordered dithering
                    lowp float nearestIndex = floor(gray * 15.0 + 0.5);
                    lowp vec3 quantizedColor = qt_CustomPalette[int(nearestIndex)];
                    
                    gl_FragColor = vec4(quantizedColor, color.a) * qt_Opacity;
                }"

            property var customPalette: [
                // Define your custom color palette here
                // Each color should be in the format: vec3(red, green, blue)
                vec3(0.9607843137254902, 0.7607843137254902, 0.9058823529411765),    // f5c2e7
                vec3(0.19215686274509805, 0.19607843137254902, 0.26666666666666666),    // 313244
                vec3(0.11764705882352941, 0.11764705882352941, 0.1803921568627451),    // 1e1e2e
                vec3(0.27058823529411763, 0.2784313725490196, 0.35294117647058826),    // 45475a
                // Add more colors as needed
            ]

            property var textureSource: sceneImageBackground_base

            onEnabledChanged: {
                if (enabled) {
                    setUniformValue("qt_CustomPalette", customPalette);
                }
            }
        }
    }
}


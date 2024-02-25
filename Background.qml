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
    property var customPalette: [
        Qt.rgba(1.0, 0.0, 0.0, 1.0),  // Red
        Qt.rgba(0.0, 1.0, 0.0, 1.0),  // Green
        Qt.rgba(0.0, 0.0, 1.0, 1.0)   // Blue
        // Add more colors as needed
    ]

    ShaderEffect {
        anchors.fill: parent
        fragmentShader: "
            #version 150
            varying highp vec2 qt_TexCoord0;
            uniform sampler2D source;
            uniform highp float qt_Opacity;
            uniform lowp vec4 qtColorPalette[256]; // Define your custom color palette here

            void main() {
                highp vec4 color = texture2D(source, qt_TexCoord0);
                highp float gray = dot(color.rgb, vec3(0.299, 0.587, 0.114));
                highp float threshold = mod(gray, 1.0);

                // Ordered dithering
                highp float ditherValue = 0.0; // Adjust this value for dithering strength
                highp vec4 ditheredColor = color;
                if (threshold > ditherValue) {
                    ditheredColor = qtColorPalette[int(gray * 255.0)];
                }

                gl_FragColor = ditheredColor * qt_Opacity;
            }
        "

        property variant source: ShaderEffectSource {
            sourceItem: Image {
                id: sceneImageBackground_base
                anchors.fill: parent
                fillMode: Image.Pad
                source: config.background || config.Background
                smooth: true
                // Other properties...

                // Calculate the nearest integer scaling factor
                property real scaleRatio: Math.max(1, Math.round(screenWidth / sceneImageBackground_base.width))
                transform: Scale {
                    origin.x: sceneImageBackground_base.width / 2
                    origin.y: sceneImageBackground_base.height / 2
                    xScale: scaleRatio
                    yScale: scaleRatio
                }
            }
        }
    }

    // Other elements...
}


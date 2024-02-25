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



import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15

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
        transform: Scale {
            origin.x: sceneImageBackground_base.width / 2
            origin.y: sceneImageBackground_base.height / 2
            xScale: scaleRatio
            yScale: scaleRatio
        }
    }

    ShaderEffectItem {
        id: ditherEffect
        anchors.fill: sceneImageBackground_base
        source: sceneImageBackground_base
        fragmentShader: "
            varying highp vec2 qt_TexCoord0;
            uniform sampler2D source;
            uniform lowp float qt_Opacity;
            
            // Custom color palette
            const lowp vec3 palette[4] = vec3[4](
                vec3(0.27058823529411763, 0.2784313725490196, 0.35294117647058826),   // Color 1
                vec3(1.0, 0.0, 0.0),   // Color 2
                vec3(0.0, 1.0, 0.0),   // Color 3
                vec3(0.0, 0.0, 1.0)    // Color 4
            );

            void main() {
                lowp vec4 color = texture2D(source, qt_TexCoord0);
                mediump float luminance = dot(color.rgb, vec3(0.299, 0.587, 0.114));

                // Ordered dithering
                lowp int x = int(gl_FragCoord.x) % 4;
                lowp int y = int(gl_FragCoord.y) % 4;
                lowp float threshold = (x * 4.0 + y) / 16.0;

                if (luminance > threshold) {
                    gl_FragColor = vec4(palette[1], color.a);
                } else {
                    gl_FragColor = vec4(palette[2], color.a);
                }
            }"
    }
}


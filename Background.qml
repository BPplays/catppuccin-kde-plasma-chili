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
    id: sceneBackground

    // Image {
    //     id: sceneImageBackground
    //     anchors.fill: parent
    //     fillMode: Image.PreserveAspectCrop
    //     source: config.background || config.Background
    //     smooth: true
    //     // mipmap: true
    // }

        width: 800
    height: 600

    ShaderEffectSource {
        id: source
        sourceItem: Image {
            id: sceneImageBackground_2
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            source: config.background || config.Background
        }

        width: Math.floor(parent.width)
        height: Math.floor(parent.height)

        fragmentShader: "
            varying highp vec2 qt_TexCoord0;
            uniform sampler2D source;

            void main() {
                highp vec2 texCoord = qt_TexCoord0;
                // Perform custom scaling to the nearest integer
                texCoord *= vec2(textureSize(source, 0)) / vec2(parent.width, parent.height);

                // Apply bilinear interpolation
                gl_FragColor = texture2D(source, texCoord);
            }
        "
    }

    Rectangle {
        width: parent.width
        height: parent.height

        Image {
            id: sceneImageBackground
            anchors.fill: parent
            source: source
        }
    }

    RecursiveBlur {
        anchors.fill: sceneImageBackground
        source: sceneImageBackground
        radius: config.Blur == "true" ? config.RecursiveBlurRadius : 0
        loops: config.Blur == "true" ? config.RecursiveBlurLoops : 0
    }
}

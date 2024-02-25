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
        fillMode: Image.PreserveAspectFit
        source: config.background || config.Background
        smooth: false
        // mipmap: true
        // antialiasing: true // Enable antialiasing for smoother scaling

        // Calculate the nearest integer scaling factor
        property real scaleRatio: Math.max(1, Math.round(screenWidth / sceneImageBackground_base.width))
        transform: Scale {
            origin.x: sceneImageBackground_base.width / 2
            origin.y: sceneImageBackground_base.height / 2
            xScale: scaleRatio
            yScale: scaleRatio
        }
    }

    Image {
        id: sceneImageBackground
        anchors.fill: parent
        fillMode: Image.PreserveAspectFit
        source: sceneImageBackground_base
        smooth: true
        // mipmap: true
        // antialiasing: true // Enable antialiasing for smoother scaling

        // Calculate the nearest integer scaling factor
        // property real scaleRatio: Math.max(1, Math.round(screenWidth / sceneImageBackground.width))
        // transform: Scale {
        //     origin.x: sceneImageBackground.width / 2
        //     origin.y: sceneImageBackground.height / 2
        //     xScale: scaleRatio
        //     yScale: scaleRatio
        // }
    }

    // RecursiveBlur {
    //     anchors.fill: sceneImageBackground
    //     source: sceneImageBackground
    //     radius: config.Blur == "true" ? config.RecursiveBlurRadius : 0
    //     loops: config.Blur == "true" ? config.RecursiveBlurLoops : 0
    // }
}


/*
 *   Copyright 2016 David Edmundson <davidedmundson@kde.org>
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

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

import QtQuick.Controls 1.3 as QQC

import QtGraphicalEffects 1.12

item {
    id: root

    property int sessionFontSize
    property string color: "#11111b"
    
    SessionButton {
        id: sessionButton
        sessionFontSize: root.sessionFontSize
    }

    ColorOverlay {
        id: icon_overlay
        anchors.fill: sessionButton
        source: sessionButton
        smooth: true
        cached: true

        // // Extract RGB components from hex color
        // property real redComponent: (cattpuccin_green >> 16) & 0xFF
        // property real greenComponent: (cattpuccin_green >> 8) & 0xFF
        // property real blueComponent: cattpuccin_green & 0xFF

        // color: Qt.rgba(redComponent / 255, greenComponent / 255, blueComponent / 255, 0) // Initial alpha is 0
        // visible: opacity > 0
        // opacity: 0
        color: root.color
        // visible: opacity > 0
        visible: true
        // opacity: 1
        // active: mouseArea.containsMouse || root.activeFocus

    }
}
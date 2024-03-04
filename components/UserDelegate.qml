/*
 *   Copyright 2014 David Edmundson <davidedmundson@kde.org>
 *   Copyright 2014 Aleix Pol Gonzalez <aleixpol@blue-systems.com>
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

import QtQuick 2.4
import QtGraphicalEffects 1.0

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

Item {
    id: wrapper

    // Define color variables
    property string cattpuccin_rosewater: "#f5e0dc"
    property string cattpuccin_flamingo: "#f2cdcd"
    property string cattpuccin_pink: "#f5c2e7"
    property string cattpuccin_mauve: "#cba6f7"
    property string cattpuccin_red: "#f38ba8"
    property string cattpuccin_maroon: "#eba0ac"
    property string cattpuccin_peach: "#fab387"
    property string cattpuccin_yellow: "#f9e2af"
    property string cattpuccin_green: "#a6e3a1"
    property string cattpuccin_teal: "#94e2d5"
    property string cattpuccin_sky: "#89dceb"
    property string cattpuccin_sapphire: "#74c7ec"
    property string cattpuccin_blue: "#89b4fa"
    property string cattpuccin_lavender: "#b4befe"
    property string cattpuccin_text: "#cdd6f4"
    property string cattpuccin_subtext1: "#bac2de"
    property string cattpuccin_subtext1_halfop: "#bac2de7F"
    property string cattpuccin_subtext0: "#a6adc8"
    property string cattpuccin_overlay2: "#9399b2"
    property string cattpuccin_overlay1: "#7f849c"
    property string cattpuccin_overlay0: "#6c7086"
    property string cattpuccin_surface2: "#585b70"
    property string cattpuccin_surface1: "#45475a"
    property string cattpuccin_surface0: "#313244"
    property string cattpuccin_base: "#1e1e2e"
    property string cattpuccin_mantle: "#181825"
    property string cattpuccin_crust: "#11111b"

    property bool isCurrent: true

    readonly property var m: model
    property string name
    property string userName
    property string avatarPath
    property string iconSource
    property bool constrainText: true
    signal clicked()

    property real faceSize: config.AvatarPixelSize ? config.AvatarPixelSize : Math.min(width, height - usernameDelegate.height - units.smallSpacing)

    opacity: isCurrent ? 1.0 : 0.3

    Behavior on opacity {
        OpacityAnimator {
            duration: units.longDuration
        }
    }

    Item {
        id: imageSource
        width: faceSize
        height: faceSize
        anchors {
            bottom: usernameDelegate.top
            horizontalCenter: parent.horizontalCenter
        }
        anchors.bottomMargin: usernameDelegate.height * 0.5

        Rectangle {
            id: outline
            anchors.fill: parent
            anchors.margins: -(config.AvatarOutlineWidth) || -2
            color: "transparent"
            border.width: config.AvatarOutlineWidth || 2
            border.color: config.AvatarOutlineColor || "white"
            radius: 1000
            visible: config.AvatarOutline == "true" ? true : false
        }
        //Image takes priority, taking a full path to a file, if that doesn't exist we show an icon
        Image {
            id: face
            source: wrapper.avatarPath
            sourceSize: Qt.size(faceSize, faceSize)
            smooth: true
            fillMode: Image.PreserveAspectCrop
            anchors.fill: parent
            visible: false
        }
        Image {
            id: mask
            source: config.UsePngInsteadOfMask == "true" ? "" : "artwork/mask.svgz"
            sourceSize: Qt.size(faceSize, faceSize)
            smooth: true
        }
        OpacityMask {
            anchors.fill: face
            source: face
            maskSource: mask
            cached: true
        }

        PlasmaCore.IconItem {
            id: faceIcon
            source: iconSource
            visible: (face.status == Image.Error || face.status == Image.Null)
            anchors.fill: parent
            anchors.margins: units.gridUnit * 0.5 // because mockup says so...
            colorGroup: PlasmaCore.ColorScope.colorGroup
        }
    }

    PlasmaComponents.Label {
        id: usernameDelegate
        font.family: config.Font || "Noto Sans"
        font.pointSize: config.FontPointSize ? config.FontPointSize * 1.2 : root.height / 80 * 1.2
        renderType: Text.QtRendering
        font.capitalization: Font.Capitalize
        anchors {
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
        }
        height: implicitHeight // work around stupid bug in Plasma Components that sets the height
        // width: constrainText ? parent.width : implicitWidth
        text: wrapper.name
        color: cattpuccin_text
        // elide: Text.ElideRight
        horizontalAlignment: Text.AlignHCenter
        //make an indication that this has active focus, this only happens when reached with keyboard navigation
        font.underline: wrapper.activeFocus
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onClicked: wrapper.clicked();
    }

    Accessible.name: name
    Accessible.role: Accessible.Button
    function accessiblePressAction() { wrapper.clicked() }
}

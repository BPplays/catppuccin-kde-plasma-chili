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

import QtGraphicalEffects 1.12

Item {
    id: root
    property alias text: label.text
    property alias iconSource: icon.source
    property alias containsMouse: mouseArea.containsMouse
    // property alias color: item_color
    property alias font: label.font
    signal clicked


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

    property string item_color: color

    


    property bool disable_opacity_hover: true
    property bool disable_color_hover: false



    activeFocusOnTab: true
    opacity: ( containsMouse || activeFocus || disable_opacity_hover ) ? 1 : 0.6
    property int iconSize

    implicitWidth: Math.max(icon.implicitWidth + units.largeSpacing * 3, label.contentWidth)
    implicitHeight: Math.max(icon.implicitHeight + units.largeSpacing * 2, label.contentHeight)

    PlasmaCore.IconItem {
        id: icon
        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
        }

        width: config.PowerIconSize ? config.PowerIconSize : iconSize
        height: config.PowerIconSize ? config.PowerIconSize : iconSize

        colorGroup: PlasmaCore.ColorScope.colorGroup
        active: mouseArea.containsMouse || root.activeFocus
    }

    ColorOverlay {
        id: icon_overlay
        anchors.fill: icon_overlay
        source: icon_overlay
        smooth: true
        cached: true

        // // Extract RGB components from hex color
        // property real redComponent: (cattpuccin_green >> 16) & 0xFF
        // property real greenComponent: (cattpuccin_green >> 8) & 0xFF
        // property real blueComponent: cattpuccin_green & 0xFF

        // color: Qt.rgba(redComponent / 255, greenComponent / 255, blueComponent / 255, 0) // Initial alpha is 0
        // visible: opacity > 0
        // opacity: 0
        color: item_color
        visible: opacity > 0
        // opacity: 1

    }

    PlasmaComponents.Label {
        id: label
        font.family: config.Font || "Noto Sans"
        font.pointSize: config.FontPointSize || root.generalFontSize
        renderType: Text.QtRendering
        color: cattpuccin_surface2
        anchors {
            top: icon.bottom
            topMargin: units.smallSpacing
            left: parent.left
            right: parent.right
        }
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignTop
        wrapMode: Text.WordWrap
        font.underline: root.activeFocus
    }

    MouseArea {
        id: mouseArea
        hoverEnabled: true
        onClicked: root.clicked()
        anchors.fill: root
    }

    Keys.onEnterPressed: clicked()
    Keys.onReturnPressed: clicked()
    Keys.onSpacePressed: clicked()

    Accessible.onPressAction: clicked()
    Accessible.role: Accessible.Button
    Accessible.name: label.text
}

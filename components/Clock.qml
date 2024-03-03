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

import QtQuick 2.0
import QtQuick.Layouts 1.1

import org.kde.plasma.core 2.0
import org.kde.plasma.components 2.0

RowLayout {
    id: clockroot

    property alias color: clockroot.item_color


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


    property string item_color: "#11111b"



    property int clockSize
    
    KeyboardButton {}
    Battery {}
    Label {
        font.family: config.Font || "Noto Sans"
        font.pointSize: clockSize
        text: Qt.formatDateTime(timeSource.data["Local"]["DateTime"], "yyyy/MM/dd,") // MMMM shows month right
        color: item_color
        // color: cattpuccin_base
        renderType: Text.QtRendering
    }
    Label {
        font.family: config.Font || "Noto Sans"
        font.pointSize: clockSize
        text: Qt.formatTime(timeSource.data["Local"]["DateTime"])
        color: item_color
        renderType: Text.QtRendering
    }
    DataSource {
        id: timeSource
        engine: "time"
        connectedSources: ["Local"]
        interval: 1000
    }
}

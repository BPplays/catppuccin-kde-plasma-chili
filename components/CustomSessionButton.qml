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

import QtQuick 2.15
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents

import QtQuick.Controls 2.15 as QQC
import QtQuick.Templates 2.15 as T
import QtGraphicalEffects 1.12

// import "compsrc"

PlasmaComponents.ToolButton {
    id: root
    property int currentIndex: -1
    property int sessionFontSize

    visible: menu.items.length > 1
    font.family: config.Font || "Noto Sans"
    font.pointSize: sessionFontSize

    text: instantiator.itemAt(currentIndex).text || ""

    Component.onCompleted: {
        currentIndex = sessionModel.lastIndex
    }

    Menu {
        id: menu
        Repeater {
            model: sessionModel
            delegate: QQC.MenuItem {
                text: model.name
                onClicked: {
                    root.currentIndex = model.index
                }
            }
        }
        associatedMenu: menu
    }
}

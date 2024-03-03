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

import QtQuick 2.12

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

// import QtQuick.Controls 2.12 as QQC
import QtQuick.Controls 2.12

PlasmaComponents.ToolButton {
    id: root
    property int currentIndex: -1
    property int sessionFontSize

    visible: menu.items.length > 1
    font.family: config.Font || "Noto Sans"
    font.pointSize: sessionFontSize

    text: instantiator.objectAt(currentIndex).text || ""

    Component.onCompleted: {
        currentIndex = sessionModel.lastIndex
    }

    menu: Menu {
        id: menu
        MenuSeparator {
            contentItem: Rectangle {
                implicitWidth: 200
                implicitHeight: 1
                color: "#21be2b"
            }
        }

        topPadding: 2
        bottomPadding: 2

        delegate: MenuItem {
            id: menuItem
            implicitWidth: 200
            implicitHeight: 40

            arrow: Canvas {
                x: parent.width - width
                implicitWidth: 40
                implicitHeight: 40
                visible: menuItem.subMenu
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.fillStyle = menuItem.highlighted ? "#ffffff" : "#21be2b"
                    ctx.moveTo(15, 15)
                    ctx.lineTo(width - 15, height / 2)
                    ctx.lineTo(15, height - 15)
                    ctx.closePath()
                    ctx.fill()
                }
            }

            indicator: Item {
                implicitWidth: 40
                implicitHeight: 40
                Rectangle {
                    width: 26
                    height: 26
                    anchors.centerIn: parent
                    visible: menuItem.checkable
                    border.color: "#21be2b"
                    radius: 3
                    Rectangle {
                        width: 14
                        height: 14
                        anchors.centerIn: parent
                        visible: menuItem.checked
                        color: "#21be2b"
                        radius: 2
                    }
                }
            }

            contentItem: Text {
                leftPadding: menuItem.indicator.width
                rightPadding: menuItem.arrow.width
                text: menuItem.text
                font: menuItem.font
                opacity: enabled ? 1.0 : 0.3
                color: menuItem.highlighted ? "#ffffff" : "#21be2b"
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }

            background: Rectangle {
                implicitWidth: 200
                implicitHeight: 40
                opacity: enabled ? 1 : 0.3
                color: menuItem.highlighted ? "#21be2b" : "transparent"
            }
        }

        background: Rectangle {
            implicitWidth: 200
            implicitHeight: 40
            color: "#ffffff"
            border.color: "#21be2b"
            radius: 2
        }






        Instantiator {
            id: instantiator
            model: sessionModel
            onObjectAdded: menu.insertItem(index, object)
            onObjectRemoved: menu.removeItem( object )
            delegate: QQC.MenuItem {
                text: model.name
                onTriggered: {
                    root.currentIndex = model.index
                }
            }
        }
    }
}

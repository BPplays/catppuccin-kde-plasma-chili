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

PlasmaCore.Dialog {
    id: menuDialog
    modal: true
    visible: false
    width: 200
    height: 150

    PlasmaComponents.ListView {
        model: sessionModel
        delegate: QQC.Item {
            width: menuDialog.width
            height: 50

            QQC.Text {
                anchors.centerIn: parent
                text: model.name
                font.pointSize: 16
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    menuDialog.close()
                    root.currentIndex = model.index
                }
            }
        }
    }
}

PlasmaComponents.Button {
    id: themableButton
    text: "Select Session"
    onClicked: menuDialog.open()
}

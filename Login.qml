import "components"

import QtQuick 2.0
import QtQuick.Layouts 1.2
import QtQuick.Controls.Styles 1.4

import QtGraphicalEffects 1.12

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

SessionManagementScreen {

    property bool showUsernamePrompt: !showUserList
    property int usernameFontSize
    property string usernameFontColor
    property string lastUserName
    property bool passwordFieldOutlined: config.PasswordFieldOutlined == "true"
    property bool hidePasswordRevealIcon: config.HidePasswordRevealIcon == "false"


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


    //the y position that should be ensured visible when the on screen keyboard is visible
    property int visibleBoundary: mapFromItem(loginButton, 0, 0).y
    onHeightChanged: visibleBoundary = mapFromItem(loginButton, 0, 0).y + loginButton.height + units.smallSpacing

    signal loginRequest(string username, string password)

    onShowUsernamePromptChanged: {
        if (!showUsernamePrompt) {
            lastUserName = ""
        }
    }

    /*
    * Login has been requested with the following username and password
    * If username field is visible, it will be taken from that, otherwise from the "name" property of the currentIndex
    */
    function startLogin() {
        var username = showUsernamePrompt ? userNameInput.text : userList.selectedUser
        var password = passwordBox.text

        //this is partly because it looks nicer
        //but more importantly it works round a Qt bug that can trigger if the app is closed with a TextField focussed
        //DAVE REPORT THE FRICKING THING AND PUT A LINK
        loginButton.forceActiveFocus();
        loginRequest(username, password);
    }

    PlasmaComponents.TextField {
        id: userNameInput
        Layout.fillWidth: true
        Layout.minimumHeight: 21
        implicitHeight: root.height / 28
        font.family: config.Font || "Noto Sans"
        font.pointSize: usernameFontSize
        // opacity: 0.5
        opacity: 1
        text: lastUserName
        visible: showUsernamePrompt
        focus: showUsernamePrompt && !lastUserName //if there's a username prompt it gets focus first, otherwise password does
        placeholderText: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Username")

        style: TextFieldStyle {
            textColor: cattpuccin_text
            placeholderTextColor: cattpuccin_text
            background: Rectangle {
                radius: 3
                border.color: cattpuccin_base
                border.width: 0
                color: passwordFieldOutlined ? "transparent" : cattpuccin_base
            }
        }
    }

    PlasmaComponents.TextField {
        id: passwordBox
        
        Layout.fillWidth: true
        Layout.minimumHeight: 21
        implicitHeight: usernameFontSize * 2.85
        font.pointSize: usernameFontSize * 0.8
        // opacity: passwordFieldOutlined ? 0.75 : 0.5
        opacity: 1
        font.family: config.Font || "Noto Sans"
        placeholderText: config.PasswordFieldPlaceholderText == "Password" ? i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Password") : config.PasswordFieldPlaceholderText
        // placeholderText: cattpuccin_green.g
        focus: !showUsernamePrompt || lastUserName
        echoMode: TextInput.Password
        revealPasswordButtonShown: hidePasswordRevealIcon
        onAccepted: startLogin()

        style: TextFieldStyle {
            textColor: passwordFieldOutlined ? "white" : cattpuccin_text
            placeholderTextColor: passwordFieldOutlined ? "white" : cattpuccin_text
            passwordCharacter: config.PasswordFieldCharacter == "" ? "●" : config.PasswordFieldCharacter
            background: Rectangle {
                opacity: 1
                radius: 3
                border.color: cattpuccin_base
                border.width: 0
                color: passwordFieldOutlined ? "transparent" : cattpuccin_base
            }
        }

        Keys.onEscapePressed: {
            mainStack.currentItem.forceActiveFocus();
        }

        //if empty and left or right is pressed change selection in user switch
        //this cannot be in keys.onLeftPressed as then it doesn't reach the password box
        Keys.onPressed: {
            if (event.key == Qt.Key_Left && !text) {
                userList.decrementCurrentIndex();
                event.accepted = true
            }
            if (event.key == Qt.Key_Right && !text) {
                userList.incrementCurrentIndex();
                event.accepted = true
            }
        }

        Keys.onReleased: {
            if (loginButton.opacity == 0 && length > 0) {
                showLoginButton.start()
            }
            if (loginButton.opacity > 0 && length == 0) {
                hideLoginButton.start()
            }
        }

        Connections {
            target: sddm
            onLoginFailed: {
                passwordBox.selectAll()
                passwordBox.forceActiveFocus()
            }
        }
    }

    Image {
        id: loginButton
        source: "components/artwork/login.svgz"
        smooth: true
        sourceSize: Qt.size(passwordBox.height, passwordBox.height)
        anchors {
            left: passwordBox.right
            verticalCenter: passwordBox.verticalCenter
        }
        anchors.leftMargin: 8
        visible: opacity > 0
        opacity: 0
        // MouseArea {
        //     anchors.fill: parent
        //     onClicked: startLogin();
        // }
        // PropertyAnimation {
        //     id: showLoginButton
        //     target: loginButton
        //     properties: "opacity"
        //     to: 0.75
        //     duration: 100
        // }
        // PropertyAnimation {
        //     id: hideLoginButton
        //     target: loginButton
        //     properties: "opacity"
        //     to: 0
        //     duration: 80
        // }

    }
    // Apply a color overlay to change the image color
    ColorOverlay {
        id: loginButton_overlay
        anchors.fill: loginButton
        source: loginButton

        // Extract RGB components from hex color
        property real redComponent: (cattpuccin_green >> 16) & 0xFF
        property real greenComponent: (cattpuccin_green >> 8) & 0xFF
        property real blueComponent: cattpuccin_green & 0xFF

        color: Qt.rgba(redComponent / 255, greenComponent / 255, blueComponent / 255, 0) // Initial alpha is 0
        visible: true

        SequentialAnimation {
            PropertyAnimation {
                target: loginButton_overlay
                properties: "color"
                to: Qt.rgba(redComponent / 255, greenComponent / 255, blueComponent / 255, 0.75)
                duration: 100
            }

            PropertyAnimation {
                target: loginButton_overlay
                properties: "color"
                to: Qt.rgba(redComponent / 255, greenComponent / 255, blueComponent / 255, 0)
                duration: 80
            }
        }
    }

}

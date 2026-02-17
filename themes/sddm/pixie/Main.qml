/**
 * Pixie SDDM
 * A minimal SDDM theme inspired by Pixel UI and Material Design 3.
 * Author: xCaptaiN09
 * GitHub: https://github.com/xCaptaiN09/pixie-sddm
 */
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15
import "components"

Rectangle {
    id: container
    width: 1920
    height: 1080
    color: config.backgroundColor
    focus: !loginState.visible

    // User & Session Logic (Root Level)
    property int userIndex: 0
    property int sessionIndex: 0
    property bool isLoggingIn: false

    Component.onCompleted: {
        if (typeof userModel !== "undefined" && userModel.lastIndex >= 0) userIndex = userModel.lastIndex;
        if (typeof sessionModel !== "undefined" && sessionModel.lastIndex >= 0) sessionIndex = sessionModel.lastIndex;
    }

    function cleanName(name) {
        if (!name) return "";
        var s = name.toString();
        if (s.endsWith("/")) s = s.substring(0, s.length - 1);
        if (s.indexOf("/") !== -1) s = s.substring(s.lastIndexOf("/") + 1);
        if (s.indexOf(".desktop") !== -1) s = s.substring(0, s.indexOf(".desktop"));
        s = s.replace(/[-_]/g, ' ');
        return s.charAt(0).toUpperCase() + s.slice(1);
    }

    function doLogin() {
        if (!loginState.visible || isLoggingIn) return;
        
        var user = "";
        if (typeof userModel !== "undefined" && userModel.count > 0) {
            var idx = container.userIndex;
            if (idx < 0 || idx >= userModel.count) idx = 0;
            
            var edit = userModel.data(userModel.index(idx, 0), Qt.EditRole);
            var nameRole = userModel.data(userModel.index(idx, 0), Qt.UserRole + 1);
            var display = userModel.data(userModel.index(idx, 0), Qt.DisplayRole);
            
            user = edit ? edit.toString() : (nameRole ? nameRole.toString() : (display ? display.toString() : ""));
        }
        
        if (!user || user === "" || user === "User") {
            user = sddm.lastUser;
        }
        
        if (!user && typeof userModel !== "undefined" && userModel.count > 0) {
            var firstEdit = userModel.data(userModel.index(0, 0), Qt.EditRole);
            user = firstEdit ? firstEdit.toString() : "";
        }
        
        if (!user) return;

        container.isLoggingIn = true;
        var pass = passwordField.text;
        var sess = container.sessionIndex;
        
        if (typeof sessionModel !== "undefined") {
            if (sess < 0 || sess >= sessionModel.count) sess = 0;
        } else {
            sess = 0;
        }

        console.log("Pixie SDDM: Attempting login for user [" + user + "] session index [" + sess + "]");
        sddm.login(user.trim(), pass, sess);
        loginTimeout.start();
    }

    Timer {
        id: loginTimeout
        interval: 5000
        onTriggered: container.isLoggingIn = false
    }

    Connections {
        target: sddm
        onLoginFailed: {
            container.isLoggingIn = false
            loginTimeout.stop()
            loginState.isError = true
            shakeAnimation.start()
            passwordField.text = ""
            passwordField.forceActiveFocus()
        }
        onLoginSucceeded: {
            loginTimeout.stop()
        }
    }

    FontLoader { id: fontRegular; source: "assets/fonts/FlexRounded-R.ttf" }
    FontLoader { id: fontMedium; source: "assets/fonts/FlexRounded-M.ttf" }
    FontLoader { id: fontBold; source: "assets/fonts/FlexRounded-B.ttf" }

    Image {
        id: backgroundImage
        source: config.background
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        layer.enabled: true
    }

    FastBlur {
        id: backgroundBlur
        anchors.fill: parent
        source: backgroundImage
        radius: 64
        opacity: loginState.visible ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 400; easing.type: Easing.InOutQuad } }
    }

    Rectangle {
        anchors.fill: parent
        color: "black"
        opacity: loginState.visible ? 0.6 : 0.4
        Behavior on opacity { NumberAnimation { duration: 400 } }
    }

    PowerBar {
        anchors {
            top: parent.top
            right: parent.right
            topMargin: 30
            rightMargin: 40
        }
        textColor: "#D4E4BC"
        z: 100
    }

    Shortcut {
        sequence: "Escape"
        enabled: loginState.visible
        onActivated: {
            loginState.visible = false;
            loginState.isError = false;
            passwordField.text = "";
            container.focus = true;
        }
    }

    Shortcut {
        sequences: ["Return", "Enter"]
        enabled: loginState.visible
        onActivated: container.doLogin()
    }

    Text {
        id: dateText
        text: Qt.formatDateTime(new Date(), "dddd, MMMM d")
        color: "#D4E4BC"
        font.pixelSize: 22
        font.family: config.fontFamily
        anchors {
            top: parent.top
            left: parent.left
            topMargin: 50
            leftMargin: 60
        }
    }

    Item {
        id: lockState
        anchors.fill: parent
        visible: !loginState.visible
        opacity: visible ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 400 } }

        Clock {
            id: mainClock
            anchors.centerIn: parent
            hoursColor: "#AED68A"
            minutesColor: "#D4E4BC"
            fontFamily: config.fontFamily
        }
        
        Text {
            text: "Press any key to unlock"
            color: config.textColor
            font.pixelSize: 16
            anchors {
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
                bottomMargin: 100
            }
            opacity: 0.5
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                loginState.visible = true;
                passwordField.forceActiveFocus();
            }
        }
    }

    Item {
        id: loginState
        anchors.fill: parent
        visible: false
        opacity: visible ? 1 : 0
        z: 10
        Behavior on opacity { NumberAnimation { duration: 400 } }

        onVisibleChanged: {
            if (visible) passwordField.forceActiveFocus();
        }

        property bool isError: false
        SequentialAnimation {
            id: shakeAnimation
            loops: 2
            PropertyAnimation { target: loginCard; property: "x"; from: (container.width - loginCard.width)/2; to: (container.width - loginCard.width)/2 - 10; duration: 50; easing.type: Easing.InOutQuad }
            PropertyAnimation { target: loginCard; property: "x"; from: (container.width - loginCard.width)/2 - 10; to: (container.width - loginCard.width)/2 + 10; duration: 50; easing.type: Easing.InOutQuad }
            PropertyAnimation { target: loginCard; property: "x"; from: (container.width - loginCard.width)/2 + 10; to: (container.width - loginCard.width)/2; duration: 50; easing.type: Easing.InOutQuad }
            onStopped: isError = false
        }

        Rectangle {
            id: loginCard
            width: 380
            height: 480
            x: (parent.width - width) / 2
            y: (parent.height - height) / 2
            color: loginState.isError ? "#442222" : "#1A1C18"
            opacity: 0.7
            radius: 32
            
            Behavior on color { ColorAnimation { duration: 200 } }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 40
                spacing: 15

                Item {
                    Layout.preferredWidth: 120
                    Layout.preferredHeight: 120
                    Layout.alignment: Qt.AlignHCenter
                    
                    Rectangle {
                        id: avatarFallback
                        anchors.fill: parent
                        color: "#2D2F27"
                        radius: width / 2
                        visible: avatar.status !== Image.Ready
                        
                        Text {
                            anchors.centerIn: parent
                            text: {
                                var n = "";
                                if (typeof userModel !== "undefined" && userModel.count > 0) {
                                    var d = userModel.data(userModel.index(container.userIndex, 0), Qt.DisplayRole);
                                    var nr = userModel.data(userModel.index(container.userIndex, 0), Qt.UserRole + 1);
                                    n = d ? d.toString() : (nr ? nr.toString() : "U");
                                } else {
                                    n = sddm.lastUser ? sddm.lastUser : "U";
                                }
                                return n.charAt(0).toUpperCase();
                            }
                            color: config.accentColor
                            font.pixelSize: 48
                            font.family: fontBold.name
                            font.weight: Font.Bold
                        }
                    }

                    Image {
                        id: avatar
                        anchors.fill: parent
                        fillMode: Image.PreserveAspectCrop
                        smooth: true
                        visible: false // Hidden because OpacityMask handles the display
                        
                        property string userIcon: {
                            if (typeof userModel !== "undefined" && userModel.count > 0) {
                                var icon = userModel.data(userModel.index(container.userIndex, 0), Qt.UserRole + 3);
                                return (icon && icon !== "") ? icon : "assets/avatar.jpg";
                            }
                            return "assets/avatar.jpg";
                        }
                        
                        source: userIcon
                        
                        onStatusChanged: {
                            if (status === Image.Error && source != "assets/avatar.jpg") {
                                source = "assets/avatar.jpg";
                            }
                        }
                    }

                    Rectangle {
                        id: avatarMask
                        anchors.fill: parent
                        radius: width / 2
                        visible: false
                    }

                    OpacityMask {
                        anchors.fill: parent
                        source: avatar
                        maskSource: avatarMask
                        visible: avatar.status === Image.Ready
                    }
                }

                Item {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: userNameLabel.width + 40
                    Layout.preferredHeight: userNameLabel.height + 20
                    Layout.topMargin: 10
                    
                    Rectangle {
                        anchors.fill: parent
                        color: "white"
                        opacity: userClickArea.pressed ? 0.2 : 0
                        radius: 12
                        Behavior on opacity { NumberAnimation { duration: 100 } }
                    }

                    Text {
                        id: userNameLabel
                        anchors.centerIn: parent
                        text: {
                            if (typeof userModel !== "undefined" && userModel.count > 0) {
                                var idx = container.userIndex;
                                var modelIdx = userModel.index(idx, 0);
                                var display = userModel.data(modelIdx, Qt.DisplayRole);
                                var edit = userModel.data(modelIdx, Qt.EditRole);
                                var nr = userModel.data(modelIdx, Qt.UserRole + 1);
                                var realName = userModel.data(modelIdx, Qt.UserRole + 2);
                                var finalName = display ? display.toString() : (realName ? realName.toString() : (nr ? nr.toString() : (edit ? edit.toString() : "User")));
                                return cleanName(finalName) + (userModel.count > 1 ? " ▾" : "");
                            }
                            return cleanName(sddm.lastUser ? sddm.lastUser : "User");
                        }
                        color: "white"
                        font.pixelSize: 24
                        font.weight: Font.Bold
                        font.family: config.fontFamily
                    }

                    MouseArea {
                        id: userClickArea
                        anchors.fill: parent
                        onClicked: userPopup.open()
                    }
                    
                    scale: userClickArea.pressed ? 0.95 : 1.0
                    Behavior on scale { NumberAnimation { duration: 100 } }
                }

                Rectangle {
                    id: sessionPill
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 180
                    Layout.preferredHeight: 36
                    color: (sessionClickArea.pressed || sessionPopup.opened) ? "#3D3F37" : "#2D2F27"
                    radius: 18
                    border.width: 1
                    border.color: (sessionClickArea.pressed || sessionPopup.opened) ? config.accentColor : "#3D3F37"
                    
                    scale: sessionClickArea.pressed ? 0.95 : 1.0
                    Behavior on scale { NumberAnimation { duration: 100 } }

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 8
                        Text { 
                            text: "󰟀" 
                            color: config.accentColor
                            font.pixelSize: 16
                        }
                        Text {
                            text: {
                                if (typeof sessionModel !== "undefined" && sessionModel.count > 0) {
                                    var idx = container.sessionIndex;
                                    var modelIdx = sessionModel.index(idx, 0);
                                    var n = sessionModel.data(modelIdx, Qt.UserRole + 4);
                                    var f = sessionModel.data(modelIdx, Qt.UserRole + 2);
                                    var d = sessionModel.data(modelIdx, Qt.DisplayRole);
                                    var finalName = n ? n.toString() : (f ? f.toString() : (d ? d.toString() : "Session " + (idx + 1)));
                                    return cleanName(finalName) + (sessionModel.count > 1 ? " ▾" : "");
                                }
                                return "Hyprland";
                            }
                            color: "white"
                            font.pixelSize: 13
                            font.weight: Font.Medium
                        }
                    }

                    MouseArea {
                        id: sessionClickArea
                        anchors.fill: parent
                        onClicked: sessionPopup.open()
                    }
                }

                Item { Layout.fillHeight: true }

                TextField {
                    id: passwordField
                    echoMode: TextInput.Password
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: 18
                    color: "white"
                    focus: loginState.visible
                    enabled: !container.isLoggingIn
                    
                    background: Rectangle {
                        color: "#2D2F27"
                        radius: 16
                        border.width: parent.activeFocus ? 2 : 0
                        border.color: config.accentColor
                        opacity: parent.enabled ? 1.0 : 0.5
                    }
                    
                    Text {
                        text: "Enter Password"
                        color: "gray"
                        font.pixelSize: 16
                        visible: !parent.text
                        anchors.centerIn: parent
                        opacity: 0.5
                    }

                    onAccepted: container.doLogin()
                }

                Text {
                    id: numLockIndicator
                    text: "Num Lock is on"
                    color: "#D4E4BC"
                    font.pixelSize: 14
                    font.family: config.fontFamily
                    font.weight: Font.Medium
                    Layout.alignment: Qt.AlignHCenter
                    visible: {
                        if (typeof keyboard !== "undefined" && typeof keyboard.numLock !== "undefined") return keyboard.numLock;
                        return false;
                    }
                    opacity: visible ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 200 } }
                }

                Item { Layout.fillHeight: true }

                RoundButton {
                    id: loginButton
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 64
                    Layout.preferredHeight: 64
                    focusPolicy: Qt.NoFocus
                    enabled: !container.isLoggingIn
                    
                    contentItem: Text {
                        text: container.isLoggingIn ? "⋯" : "→"
                        color: "white"
                        font.pixelSize: 32
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        color: container.isLoggingIn ? "#3D3F37" : (loginButton.pressed ? Qt.darker(config.accentColor, 1.1) : config.accentColor)
                        radius: 32
                        opacity: container.isLoggingIn ? 0.5 : 1.0
                    }

                    onClicked: {
                        container.doLogin();
                    }
                }
            }
        }
    }

    Keys.onPressed: function(event) {
        if (!loginState.visible) {
            loginState.visible = true;
            passwordField.forceActiveFocus();
            event.accepted = true;
        }
    }

    Popup {
        id: userPopup
        width: 260
        height: (typeof userModel !== "undefined") ? Math.min(300, userModel.count * 50 + 20) : 100
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2 - 50
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside 
        onOpened: userList.forceActiveFocus()
        background: Rectangle {
            color: "#1A1C18"
            radius: 24
            opacity: 0.95
            border.color: "#3D3F37"
            border.width: 1
        }
        enter: Transition { NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 200 } }
        exit: Transition { NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 200 } }
        ListView {
            id: userList
            anchors.fill: parent
            anchors.margins: 10
            model: (typeof userModel !== "undefined") ? userModel : null
            spacing: 5
            clip: true
            focus: true
            currentIndex: container.userIndex
            highlightFollowsCurrentItem: true
            delegate: ItemDelegate {
                width: parent.width
                height: 40
                property bool isCurrent: index === userList.currentIndex
                background: Rectangle {
                    color: isCurrent ? "#3D3F37" : (hovered ? "#2D2F27" : "transparent")
                    radius: 12
                    Rectangle {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: 8
                        width: 4
                        height: isCurrent ? 16 : 0
                        color: config.accentColor
                        radius: 2
                        Behavior on height { NumberAnimation { duration: 150 } }
                    }
                }
                contentItem: RowLayout {
                    anchors.fill: parent
                    spacing: 0
                    Item { Layout.preferredWidth: 20 }
                    Rectangle {
                        Layout.preferredWidth: 28
                        Layout.preferredHeight: 28
                        Layout.alignment: Qt.AlignVCenter
                        color: isCurrent ? config.accentColor : "#3D3F37"
                        radius: 14
                        Text {
                            anchors.centerIn: parent
                            text: {
                                var mIdx = userModel.index(index, 0);
                                var d = userModel.data(mIdx, Qt.DisplayRole);
                                var n_r = userModel.data(mIdx, Qt.UserRole + 1);
                                var finalVal = d ? d.toString() : (n_r ? n_r.toString() : "U");
                                return finalVal.charAt(0).toUpperCase();
                            }
                            color: isCurrent ? "#1A1C18" : "white"
                            font.pixelSize: 12
                            font.family: fontBold.name
                            font.weight: Font.Bold
                        }
                    }
                    Item { Layout.preferredWidth: 12 }
                    Text {
                        Layout.fillWidth: true
                        text: {
                            var mIdx = userModel.index(index, 0);
                            var d = userModel.data(mIdx, Qt.DisplayRole);
                            var n_r = userModel.data(mIdx, Qt.UserRole + 1);
                            var r = userModel.data(mIdx, Qt.UserRole + 2);
                            var e = userModel.data(mIdx, Qt.EditRole);
                            return cleanName(d ? d : (r ? r : (n_r ? n_r : e)));
                        }
                        color: isCurrent ? "white" : (hovered ? "#DDDDDD" : "#AAAAAA")
                        font.pixelSize: 15
                        font.family: config.fontFamily
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        rightPadding: 60
                        elide: Text.ElideRight
                    }
                }
                onClicked: {
                    container.userIndex = index;
                    userPopup.close();
                }
            }
            Keys.onDownPressed: incrementCurrentIndex()
            Keys.onUpPressed: decrementCurrentIndex()
            Keys.onReturnPressed: { container.userIndex = currentIndex; userPopup.close(); }
            Keys.onEnterPressed: { container.userIndex = currentIndex; userPopup.close(); }
        }
    }

    Popup {
        id: sessionPopup
        width: 260
        height: (typeof sessionModel !== "undefined") ? Math.min(250, sessionModel.count * 50 + 20) : 100
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2 + 80
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        onOpened: sessionList.forceActiveFocus()
        background: Rectangle {
            color: "#1A1C18"
            radius: 24
            opacity: 0.95
            border.color: "#3D3F37"
            border.width: 1
        }
        enter: Transition { NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 200 } }
        exit: Transition { NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 200 } }
        ListView {
            id: sessionList
            anchors.fill: parent
            anchors.margins: 10
            model: (typeof sessionModel !== "undefined") ? sessionModel : null
            spacing: 5
            clip: true
            focus: true
            currentIndex: container.sessionIndex
            highlightFollowsCurrentItem: true
            delegate: ItemDelegate {
                width: parent.width
                height: 40
                property bool isCurrent: index === sessionList.currentIndex
                background: Rectangle {
                    color: isCurrent ? "#3D3F37" : (hovered ? "#2D2F27" : "transparent")
                    radius: 12
                    Rectangle {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: 8
                        width: 4
                        height: isCurrent ? 16 : 0
                        color: config.accentColor
                        radius: 2
                        Behavior on height { NumberAnimation { duration: 150 } }
                    }
                }
                contentItem: RowLayout {
                    anchors.fill: parent
                    spacing: 0
                    Item { Layout.preferredWidth: 20 }
                    Text { 
                        Layout.preferredWidth: 40
                        text: "󰟀"
                        color: isCurrent ? config.accentColor : "gray"
                        font.pixelSize: 16
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    Text {
                        Layout.fillWidth: true
                        text: {
                            var n_val = sessionModel.data(sessionModel.index(index, 0), Qt.UserRole + 4);
                            var f_val = sessionModel.data(sessionModel.index(index, 0), Qt.UserRole + 2);
                            return cleanName(n_val ? n_val : f_val);
                        }
                        color: isCurrent ? "white" : "#AAAAAA"
                        font.pixelSize: 14
                        font.family: config.fontFamily
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        rightPadding: 60
                        elide: Text.ElideRight
                    }
                }
                onClicked: {
                    container.sessionIndex = index;
                    sessionPopup.close();
                }
            }
            Keys.onDownPressed: incrementCurrentIndex()
            Keys.onUpPressed: decrementCurrentIndex()
            Keys.onReturnPressed: { container.sessionIndex = currentIndex; sessionPopup.close(); }
            Keys.onEnterPressed: { container.sessionIndex = currentIndex; sessionPopup.close(); }
        }
    }
}

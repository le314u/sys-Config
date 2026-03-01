/**
 * Pixie SDDM - Clock Component
 * Author: xCaptaiN09
 */
import QtQuick 2.15

Item {
    id: clock
    property color hoursColor: "white"
    property color minutesColor: "white"
    property string fontFamily: "Google Sans Flex Freeze"

    // Helper to get individual digits for perfect alignment
    property string timeStr: Qt.formatTime(new Date(), "HHmm")

    Row {
        anchors.centerIn: parent
        spacing: 0 // Adjust this for horizontal gap between HH and mm columns

        // First Column: Tens digit of Hour over Tens digit of Minute
        Column {
            spacing: -45 // Overlap to match Pixel look
            Text {
                text: clock.timeStr.charAt(0)
                color: clock.hoursColor
                font.pixelSize: 200
                font.family: clock.fontFamily
                font.weight: Font.Medium
                width: 130 // Ensures digit 1 and digit 3 are centered in same space
                horizontalAlignment: Text.AlignHCenter
                antialiasing: true
            }
            Text {
                text: clock.timeStr.charAt(2)
                color: clock.minutesColor
                font.pixelSize: 200
                font.family: clock.fontFamily
                font.weight: Font.Medium
                width: 130
                horizontalAlignment: Text.AlignHCenter
                antialiasing: true
            }
        }

        // Second Column: Ones digit of Hour over Ones digit of Minute
        Column {
            spacing: -45
            Text {
                text: clock.timeStr.charAt(1)
                color: clock.hoursColor
                font.pixelSize: 200
                font.family: clock.fontFamily
                font.weight: Font.Medium
                width: 130
                horizontalAlignment: Text.AlignHCenter
                antialiasing: true
            }
            Text {
                text: clock.timeStr.charAt(3)
                color: clock.minutesColor
                font.pixelSize: 200
                font.family: clock.fontFamily
                font.weight: Font.Medium
                width: 130
                horizontalAlignment: Text.AlignHCenter
                antialiasing: true
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            clock.timeStr = Qt.formatTime(new Date(), "HHmm")
        }
    }
}

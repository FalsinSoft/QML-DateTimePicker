import QtQuick
import QtQuick.Window
import QtQuick.Controls.Material
import "qrc:/../Sources"

Window {
    id: app
    visible: true
    width: 800
    height: 600
    title: "QML-DateTimePicker"

    property date date: new Date()

    Column {
        anchors.centerIn: parent
        spacing: 20

        Row {
            spacing: 20

            Button {
                text: qsTr("Time")
                onClicked: timePicker.open()
                font.pointSize: 25
                Material.background: "blue"
                Material.foreground: "white"
            }
            Text {
                text: ("0" + app.date.getHours()).slice(-2) + ":" + ("0" + app.date.getMinutes()).slice(-2)
                anchors.verticalCenter: parent.verticalCenter
                font.pointSize: 28
            }
        }
        Row {
            spacing: 20

            Button {
                text: qsTr("Date")
                onClicked: datePicker.open()
                font.pointSize: 25
                Material.background: "blue"
                Material.foreground: "white"
            }
            Text {
                text: ("0" + app.date.getDate()).slice(-2)   + "-" + ("0" + app.date.getMonth()).slice(-2) + "-" + app.date.getFullYear()
                anchors.verticalCenter: parent.verticalCenter
                font.pointSize: 28
            }
        }
    }

    TimePicker {
        id: timePicker
        hour: app.date.getHours()
        minute: app.date.getMinutes()
        onAccepted: {
            app.date.setHours(hour);
            app.date.setMinutes(minute);
        }
    }
    DatePicker {
        id: datePicker
        //minSelectableYear: 2023
        //minSelectableMonth: 0
        //minSelectableDay: 1
        //maxSelectableYear: 2024
        //maxSelectableMonth: 11
        //maxSelectableDay: 31
        year: app.date.getFullYear()
        month: app.date.getMonth()
        day: app.date.getDate()
        onAccepted: {
            app.date.setFullYear(year, month, day);
        }
    }
}

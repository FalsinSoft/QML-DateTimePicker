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
                onClicked: {
                    datePicker.minSelectableYear = date.getFullYear() - 2;
                    datePicker.minSelectableMonth = 5;
                    datePicker.minSelectableDay = 10;
                    datePicker.maxSelectableYear = date.getFullYear() + 2;
                    datePicker.maxSelectableMonth = 5;
                    datePicker.maxSelectableDay = 10;
                    datePicker.pickMode = datePicker.pickDayMonthYear;
                    datePicker.open();
                }
                font.pointSize: 25
                Material.background: "blue"
                Material.foreground: "white"
            }
            Text {
                text: ("0" + app.date.getDate()).slice(-2)   + "-" + ("0" + (app.date.getMonth() + 1)).slice(-2) + "-" + app.date.getFullYear()
                anchors.verticalCenter: parent.verticalCenter
                font.pointSize: 28
            }
        }
        Row {
            spacing: 20

            Button {
                text: qsTr("Month and year")
                onClicked: {
                    var date = new Date();
                    datePicker.minSelectableYear = date.getFullYear() - 5;
                    datePicker.minSelectableMonth = 5;
                    datePicker.maxSelectableYear = date.getFullYear() + 5;
                    datePicker.maxSelectableMonth = 5;
                    datePicker.pickMode = datePicker.pickMonthYear;
                    datePicker.open();
                }
                font.pointSize: 25
                Material.background: "blue"
                Material.foreground: "white"
            }
            Text {
                text: ("0" + (app.date.getMonth() + 1)).slice(-2) + "-" + app.date.getFullYear()
                anchors.verticalCenter: parent.verticalCenter
                font.pointSize: 28
            }
        }
        Row {
            spacing: 20

            Button {
                text: qsTr("Year")
                onClicked: {
                    var date = new Date();
                    datePicker.minSelectableYear = date.getFullYear() - 10;
                    datePicker.maxSelectableYear = date.getFullYear() + 10;
                    datePicker.pickMode = datePicker.pickYear;
                    datePicker.open();
                }
                font.pointSize: 25
                Material.background: "blue"
                Material.foreground: "white"
            }
            Text {
                text: app.date.getFullYear()
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
        year: app.date.getFullYear()
        month: app.date.getMonth()
        day: app.date.getDate()
        onAccepted: {
            app.date.setFullYear(year, month, day);
        }
    }
}

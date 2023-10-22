import QtQuick
import QtQuick.Controls.Material

Dialog {
    id: timePicker
    width: Math.min(300, parent.width * 0.9)
    height: timeColumn.height + 20 + footer.height
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    standardButtons: Dialog.Ok | Dialog.Cancel
    Material.roundedScale: Material.MediumScale
    Material.background: backgroundColor
    focus: visible
    modal: true
    padding: 0

    property color backgroundColor: "white"
    property color circleColor: "#E5E4E2"
    property color handleColor: "#CCCCFF"
    property color timeNumberColor: "black"
    property color timeSelectedColor: "#CCCCFF"
    property color timeUnselectedColor: "#E5E4E2"
    property int timeFontPointSize: 24
    property int timeHandleSize: 40

    property int hour: 0
    property int minute: 0

    onAboutToShow: {
        if(hour < 0 || hour > 23) hour = 0;
        if(minute < 0 || minute > 59) minute = 0;
        timeInput.currentInput = timeInput.hourInput;
        timeCircle.setHandlePositionByValue(hour, false);
    }

    Column {
        id: timeColumn
        width: parent.width
        spacing: 10

        Item {
            width: parent.width
            height: timeInput.implicitHeight * 1.5

            Row {
                id: timeInput
                anchors.centerIn: parent
                spacing: 5

                readonly property int hourInput: 0
                readonly property int minuteInput: 1

                property int currentInput: hourInput

                onCurrentInputChanged: {
                    if(currentInput == hourInput)
                        timeCircle.setHandlePositionByValue(parseInt(hourLabel.text), false);
                    else
                        timeCircle.setHandlePositionByValue(parseInt(minuteLabel.text), false);
                }

                Timer {
                    id: switchToMinuteTimer
                    interval: 250
                    onTriggered: timeInput.currentInput = timeInput.minuteInput
                }

                Rectangle {
                    width: hourLabel.width * 2
                    height: hourLabel.height * 1.2
                    radius: 5
                    color: (timeInput.currentInput == timeInput.hourInput) ? timePicker.timeSelectedColor : timePicker.timeUnselectedColor

                    Text {
                        id: hourLabel
                        text: timePicker.hour.toString().padStart(2, "0")
                        anchors.centerIn: parent
                        font.pointSize: timePicker.timeFontPointSize
                        color: timePicker.timeNumberColor
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: timeInput.currentInput = timeInput.hourInput
                    }
                }
                Text {
                    text: ":"
                    color: timePicker.timeNumberColor
                    font.pointSize: timePicker.timeFontPointSize
                    font.bold: true
                }
                Rectangle {
                    width: minuteLabel.width * 2
                    height: minuteLabel.height * 1.2
                    radius: 5
                    color: (timeInput.currentInput == timeInput.minuteInput) ? timePicker.timeSelectedColor : timePicker.timeUnselectedColor

                    Text {
                        id: minuteLabel
                        text: timePicker.minute.toString().padStart(2, "0")
                        anchors.centerIn: parent
                        font.pointSize: timePicker.timeFontPointSize
                        color: timePicker.timeNumberColor
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: timeInput.currentInput = timeInput.minuteInput
                    }
                }
            }
        }
        Item {
            width: parent.width
            height: timeCircle.height

            Rectangle {
                id: timeCircle
                width: parent.width - 20
                height: width
                anchors.centerIn: parent
                color: timePicker.circleColor
                radius: width / 2
                antialiasing: true

                readonly property var centerPos: Qt.point(width / 2, height / 2)
                property int handleOffset: 0
                property int handleAngle: 0

                function isInsideTimeCircle(xPos, yPos, rightSide, leftSide)
                {
                    var distance = (xPos - centerPos.x) * (xPos - centerPos.x) + (yPos - centerPos.y) * (yPos - centerPos.y);
                    return (distance <= (rightSide * rightSide) && distance > (leftSide * leftSide)) ? true : false;
                }

                function setHandlePositionByValue(value, roundPrecision)
                {
                    if(timeInput.currentInput == timeInput.hourInput)
                    {
                        if(value >= 12)
                        {
                            timeCircle.handleOffset = timePicker.timeHandleSize;
                            value -= 12; 
                        }
                        timeCircle.handleAngle = Math.floor((360 * value) / 12);
                    }
                    else
                    {
                        timeCircle.handleOffset = 0;
                        if(roundPrecision) value = (Math.round(value / 5) * 5);
                        timeCircle.handleAngle = Math.floor((360 * value) / 60);
                    }
                }

                function updateHandlePosition(newPos, roundPrecision)
                {
                    timeCircle.handleAngle = Math.atan2(newPos.y - timeCircle.centerPos.y, newPos.x - timeCircle.centerPos.x) * 180 / Math.PI + 90;
                    if(timeCircle.handleAngle < 0) timeCircle.handleAngle += 360;
                    
                    if(timeInput.currentInput == timeInput.hourInput)
                    {
                        timePicker.hour = Math.round((timeCircle.handleAngle * 12) / 360);
                        if(timePicker.hour > 11) timePicker.hour = 0;
                        if(timeCircle.handleOffset > 0) timePicker.hour += 12;
                        if(roundPrecision == true) setHandlePositionByValue(timePicker.hour, true);
                    }
                    else
                    {
                        timePicker.minute = Math.round((timeCircle.handleAngle * 60) / 360);
                        if(timePicker.minute > 59) timePicker.minute = 0;
                        if(roundPrecision == true) setHandlePositionByValue(timePicker.minute, true);
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        var rightSide = (width / 2);
                        var leftSide = (rightSide - timePicker.timeHandleSize);

                        if(timeCircle.isInsideTimeCircle(mouseX, mouseY, rightSide, leftSide))
                        {
                            timeCircle.handleOffset = 0;
                            timeCircle.updateHandlePosition(Qt.point(mouseX, mouseY), true);
                            if(timeInput.currentInput == timeInput.hourInput) switchToMinuteTimer.start();
                        }
                        else if(timeInput.currentInput == timeInput.hourInput
                             && timeCircle.isInsideTimeCircle(mouseX, mouseY, rightSide - timePicker.timeHandleSize, leftSide - timePicker.timeHandleSize))
                        {
                            timeCircle.handleOffset = timePicker.timeHandleSize;
                            timeCircle.updateHandlePosition(Qt.point(mouseX, mouseY), true);
                            switchToMinuteTimer.start();
                        }
                    }
                }

                Item {
                    id: handleItem
                    x: (timeCircle.width / 2) - (width / 2)
                    y: (timeCircle.height / 2) - (height / 2)
                    width: timePicker.timeHandleSize
                    height: timePicker.timeHandleSize
                    antialiasing: true
                    transform: [
                        Translate {
                            y: -(timeCircle.width / 2) + (timePicker.timeHandleSize / 2) + timeCircle.handleOffset
                        },
                        Rotation {
                            angle: timeCircle.handleAngle
                            origin.x: handleItem.width / 2
                            origin.y: handleItem.height / 2
                        }
                    ]

                    MouseArea {
                        id: trackMouse
                        anchors.fill: parent
                        onPositionChanged: timeCircle.updateHandlePosition(mapToItem(timeCircle, trackMouse.mouseX, trackMouse.mouseY), false)
                        onReleased: if(timeInput.currentInput == timeInput.hourInput) switchToMinuteTimer.start()
                    }

                    Rectangle {
                        x: (parent.width / 2) - (width / 2)
                        width: 2
                        height: (timeCircle.height / 2) - timeCircle.handleOffset
                        color: timePicker.handleColor
                        radius: width / 2
                        antialiasing: true
                    }
                    Rectangle {
                        anchors.fill: parent
                        color: timePicker.handleColor
                        radius: width / 2
                        antialiasing: true
                    }
                }
                Rectangle {
                    width: 10
                    height: width
                    anchors.centerIn: parent
                    color: timePicker.handleColor
                    radius: width / 2
                    antialiasing: true
                }

                Loader {
                    active: timeInput.currentInput == timeInput.hourInput
                    sourceComponent: timeLabelsComponent
                    anchors.fill: parent
                    readonly property var timeModel: ["00", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11"]
                    readonly property int circleOffset: 0
                }
                Loader {
                    active: timeInput.currentInput == timeInput.hourInput
                    sourceComponent: timeLabelsComponent
                    anchors.fill: parent
                    readonly property var timeModel: ["12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23"]
                    readonly property int circleOffset: timePicker.timeHandleSize
                }
                Loader {
                    active: timeInput.currentInput == timeInput.minuteInput
                    sourceComponent: timeLabelsComponent
                    anchors.fill: parent
                    readonly property var timeModel: ["00", "05", "10", "15", "20", "25", "30", "35", "40", "45", "50", "55"]
                    readonly property int circleOffset: 0
                }

                Component {
                    id: timeLabelsComponent

                    Repeater {
                        id: numbersRepeater
                        model: timeModel

                        readonly property point originPos: Qt.point(width / 2, height / 2)
                        readonly property real radiusCircle: (width / 2) - circleOffset - (timePicker.timeHandleSize / 2)

                        Text {
                            id: timeLabel                    
                            text: modelData
                            color: timePicker.timeNumberColor
                            font.pointSize: timePicker.timeFontPointSize - 10

                            x: numbersRepeater.originPos.x + numbersRepeater.radiusCircle * Math.cos((index + 9) * 2 * Math.PI / timeModel.length) - (width / 2)
                            y: numbersRepeater.originPos.y + numbersRepeater.radiusCircle * Math.sin((index + 9) * 2 * Math.PI / timeModel.length) - (height / 2)
                        }
                    }
                }
            }
        }
    }
}
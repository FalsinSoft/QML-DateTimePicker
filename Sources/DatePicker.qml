import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Material

Dialog {
    id: datePicker
    width: Math.min(400, parent.width * 0.9)
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    Material.roundedScale: Material.MediumScale
    Material.background: backgroundColor
    focus: visible
    modal: true
    padding: 0

    property color backgroundColor: "white"
    property color topBarBackgroundColor: "blue"
    property color topBarTextColor: "white"
    property color calendarNumberColor: "black"
    property color calendarUnselectableNumberColor: "gray"
    property int topBarFontPointSize: 18
    property int maxSelectableYear: -1
    property int maxSelectableMonth: -1
    property int maxSelectableDay: -1

    property int year: 1970
    property int month: 0
    property int day: 1

    onAboutToShow: {
        if(year < 1970) year = 1970;
        if(month < 0 || month > 11) month = 0;
        if(day < 1 || day > 31) day = 1;
        calendarGrid.year = year;
        calendarGrid.month = month;
        topBar.update();
    }

    Timer {
        id: acceptDayTimer
        interval: 250
        onTriggered: datePicker.accept()
    }
    
    header: Item {
        id: topBar
        implicitHeight: titleRow.height

        function update()
        {
            var monthName;

            switch(calendarGrid.month)
            {
                case 0:
                    monthName = qsTr("January");
                    break;
                case 1:
                    monthName = qsTr("February");
                    break;
                case 2:
                    monthName = qsTr("March");
                    break;
                case 3:
                    monthName = qsTr("April");
                    break;
                case 4:
                    monthName = qsTr("May");
                    break;
                case 5:
                    monthName = qsTr("June");
                    break;
                case 6:
                    monthName = qsTr("July");
                    break;
                case 7:
                    monthName = qsTr("August");
                    break;
                case 8:
                    monthName = qsTr("September");
                    break;
                case 9:
                    monthName = qsTr("October");
                    break;
                case 10:
                    monthName = qsTr("November");
                    break;
                case 11:
                    monthName = qsTr("December");
                    break;
            }
            calendarDateTitle.text = monthName;

            if(datePicker.maxSelectableYear > 0
            && datePicker.maxSelectableMonth >= 0 && datePicker.maxSelectableMonth <= 11)
            {
                var maxDate = new Date(datePicker.maxSelectableYear, datePicker.maxSelectableMonth);
                var currentDate = new Date(calendarGrid.year, calendarGrid.month);

                nextMonthButton.enabled = (current.getTime() >= max.getTime()) ? false : true;
            }
        }

        Rectangle {
            anchors.fill: parent    
            color: datePicker.topBarBackgroundColor
            radius: Material.MediumScale
        }
        Rectangle {
            width: parent.width
            height: Material.MediumScale
            color: datePicker.topBarBackgroundColor
            anchors.bottom: parent.bottom
        }

        RowLayout {
            id: titleRow
            width: parent.width
            anchors.verticalCenter: parent.verticalCenter
            spacing: 5

            readonly property string leftArrowIcon: "data:image/svg+xml;utf8,"
                              + "<svg xmlns='http://www.w3.org/2000/svg' width='24' height='24' viewBox='0 0 24 24'>"
                              + "<polygon points='15.293 3.293 6.586 12 15.293 20.707 16.707 19.293 9.414 12 16.707 4.707 15.293 3.293'/>"
                              + "</svg>"
            readonly property string rightArrowIcon: "data:image/svg+xml;utf8,"
                              + "<svg xmlns='http://www.w3.org/2000/svg' width='24' height='24' viewBox='0 0 24 24'>"
                              + "<polygon points='7.293 4.707 14.586 12 7.293 19.293 8.707 20.707 17.414 12 8.707 3.293 7.293 4.707'/>"
                              + "</svg>"

            ToolButton {
                id: previousMonthButton
                Layout.alignment: Qt.AlignVCenter
                icon.source: parent.leftArrowIcon
                icon.width: icon.height
                icon.height: height * 0.7
                icon.color: datePicker.topBarTextColor
                onClicked: calendarGrid.moveMonth(-1)
            }
            Text {
                id: calendarDateTitle
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                color: datePicker.topBarTextColor
                horizontalAlignment: Text.AlignHCenter
                font.pointSize: datePicker.topBarFontPointSize
            }
            ComboBox {
                id: yearsList
                implicitWidth: yearLabel.width + indicator.width + 20
                Layout.fillHeight: true
                model: ListModel { id: yearsModel }
                currentIndex: calendarGrid.year - startYear

                readonly property int startYear: 1970
                readonly property int endYear: new Date().getFullYear() + 100

                Component.onCompleted: {
                    for(var i = startYear; i < endYear; i++) yearsModel.append({ "text": i })
                }

                onCurrentIndexChanged: calendarGrid.year = (startYear + currentIndex)

                contentItem: Item {
                    width: yearsList.width - yearsList.indicator.width - 20
                    height: yearsList.height

                    Text {
                        id: yearLabel
                        anchors.verticalCenter: parent.verticalCenter
                        text: yearsList.displayText
                        elide: Text.ElideRight
                        font.pointSize: datePicker.topBarFontPointSize
                        color: datePicker.topBarTextColor
                    }
                }

                background: Rectangle {
                    color: yearsList.down ? Qt.darker(datePicker.topBarBackgroundColor, 1.2) : datePicker.topBarBackgroundColor
                    radius: 5
                }

                indicator: Canvas {
                    id: canvasIndicator
                    x: yearsList.width - width - 10
                    y: (yearsList.availableHeight - height) / 2
                    width: 18
                    height: 13

                    onPaint: {
                        var context = getContext("2d");
                        context.reset();
                        context.moveTo(0, 0);
                        context.lineTo(width, 0);
                        context.lineTo(width / 2, height);
                        context.closePath();
                        context.fillStyle = datePicker.topBarTextColor;
                        context.fill();
                    }
                }
                
                popup: Popup {
                    width: yearsList.width
                    implicitHeight: contentItem.implicitHeight
                    padding: 0

                    contentItem: ListView {
                        implicitHeight: contentHeight
                        model: yearsList.popup.visible ? yearsList.delegateModel : null
                        clip: true
                        currentIndex: yearsList.highlightedIndex

                        ScrollIndicator.vertical: ScrollIndicator { }
                    }

                    background: Rectangle {
                        color: datePicker.backgroundColor
                        radius: 5
                        clip: true
                    }
                }
            }
            ToolButton {
                id: nextMonthButton
                Layout.alignment: Qt.AlignVCenter
                icon.source: parent.rightArrowIcon
                icon.width: icon.height
                icon.height:  height * 0.7
                icon.color: datePicker.topBarTextColor
                onClicked: calendarGrid.moveMonth(1)
            }
        }
    }
    
    Item {
        id: calendarFrame
        width: datePicker.width
        implicitHeight: calendarColumn.height + 20

        Column {
            id: calendarColumn
            width: parent.width - 20
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 5
            
            DayOfWeekRow {
                id: calendarDayOfWeek
                width: parent.width

                function dayOfWeekShortName(day)
                {
                    var name;
            
                    switch(day)
                    {
                        case 0:
                            name = qsTr("Sun");
                            break;
                        case 1:
                            name = qsTr("Mon");
                            break;
                        case 2:
                            name = qsTr("Tue");
                            break;
                        case 3:
                            name = qsTr("Wed");
                            break;
                        case 4:
                            name = qsTr("Thu");
                            break;
                        case 5:
                            name = qsTr("Fri");
                            break;
                        case 6:
                            name = qsTr("Sat");
                            break;
                    }

                    return name;
                }

                delegate: Text {
                    text: calendarDayOfWeek.dayOfWeekShortName(model.day)
                    font: calendarDayOfWeek.font
                    color: datePicker.calendarNumberColor
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
            MonthGrid {
                id: calendarGrid
                width: parent.width

                function moveMonth(value)
                {
                    var newDate = new Date(calendarGrid.year, calendarGrid.month);
                    newDate.setMonth(newDate.getMonth() + value);
                    calendarGrid.year = newDate.getFullYear();
                    calendarGrid.month = newDate.getMonth();
                    topBar.update();
                }

                function isDateSelectable(year, month, day)
                {
                    if(datePicker.maxSelectableYear > 0
                    && datePicker.maxSelectableMonth >= 0 && datePicker.maxSelectableMonth <= 11
                    && datePicker.maxSelectableDay >= 1 && datePicker.maxSelectableDay <= 31)
                    {
                        var maxDate = new Date(datePicker.maxSelectableYear, datePicker.maxSelectableMonth, datePicker.maxSelectableDay);
                        var cellDate = new Date(year, month, day);

                        return (cellDate.getTime() > maxDate.getTime()) ? false : true;
                    }

                    return true;
                }

                delegate: Item {
                    id: dayCell
                    width: calendarColumn.width / 7
                    height: dayNumberLabel.height + 20

                    function dayNumberColor(year, month, day)
                    {
                        var numberColor = datePicker.calendarUnselectableNumberColor;

                        todayColor.visible = false;
                        if(calendarGrid.isDateSelectable(year, month, day))
                        {
                            if(month == calendarGrid.month)
                            {
                                if(year == datePicker.year
                                && month == datePicker.month
                                && day == datePicker.day)
                                {
                                    todayColor.visible = true;
                                    numberColor = datePicker.topBarTextColor;
                                }
                                else
                                {
                                    numberColor = datePicker.calendarNumberColor;
                                }
                            }
                        }
                                                
                        return numberColor;
                    }

                    Rectangle {
                        id: todayColor
                        visible: false
                        width: height
                        height: dayNumberLabel.height * 2
                        anchors.centerIn: parent
                        color: datePicker.topBarBackgroundColor
                        radius: width / 2
                    }
                    Text {
                        id: dayNumberLabel
                        text: model.day
                        font.pointSize: datePicker.topBarFontPointSize - 5
                        anchors.centerIn: parent
                        color: dayCell.dayNumberColor(model.year, model.month, model.day)
			        }
                }

                onClicked: {
                    var year = date.getFullYear();
                    var month = date.getMonth();
                    var day = date.getDate();

                    if(calendarGrid.isDateSelectable(year, month, day) == true && month == calendarGrid.month)
                    {
                        datePicker.year = year;
                        datePicker.month = month;
                        datePicker.day = day;
                        acceptDayTimer.start();
                    }
                }
            }
        }
    }
}
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
            Item {
                id: monthsList
                Layout.fillWidth: true
                Layout.fillHeight: true

                property var listControl: headerListComponent.createObject(monthsList, {
                                model: monthsModel,
                                currentIndex: calendarGrid.month
                                });

                Component.onCompleted: {
                    monthsModel.append({ "text": qsTr("January") });
                    monthsModel.append({ "text": qsTr("February") });
                    monthsModel.append({ "text": qsTr("March") });
                    monthsModel.append({ "text": qsTr("April") });
                    monthsModel.append({ "text": qsTr("May") });
                    monthsModel.append({ "text": qsTr("June") });
                    monthsModel.append({ "text": qsTr("July") });
                    monthsModel.append({ "text": qsTr("August") });
                    monthsModel.append({ "text": qsTr("September") });
                    monthsModel.append({ "text": qsTr("October") });
                    monthsModel.append({ "text": qsTr("November") });
                    monthsModel.append({ "text": qsTr("December") });
                }

                Connections {
                    target: monthsList.listControl
                    function onItemSelected(index)
                    {
                        calendarGrid.month = index;
                    }
                }

                ListModel { id: monthsModel }
            }
            Item {
                id: yearsList
                implicitWidth: listControl.implicitWidth
                Layout.fillHeight: true

                property var listControl: headerListComponent.createObject(yearsList, {
                                model: yearsModel,
                                currentIndex: calendarGrid.year - 1970
                                });

                Component.onCompleted: {
                    var endYear = (new Date().getFullYear() + 100);
                    for(var i = 1970; i <= endYear; i++) yearsModel.append({ "text": i });
                }

                Connections {
                    target: yearsList.listControl
                    function onItemSelected(index)
                    {
                        calendarGrid.year = (1970 + index);
                    }
                }

                ListModel { id: yearsModel }
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

        Component {
            id: headerListComponent

            ComboBox {
                id: headerListControl
                width: parent.width
                implicitWidth: headerListLabel.width + indicator.width + 20
                height: parent.height
                
                signal itemSelected(int index)
                
                onCurrentIndexChanged: itemSelected(currentIndex)

                contentItem: Item {
                    width: headerListControl.width - headerListControl.indicator.width - 20
                    height: headerListControl.height

                    Text {
                        id: headerListLabel
                        anchors.verticalCenter: parent.verticalCenter
                        text: headerListControl.displayText
                        elide: Text.ElideRight
                        font.pointSize: datePicker.topBarFontPointSize
                        color: datePicker.topBarTextColor
                    }
                }

                background: Rectangle {
                    color: headerListControl.down ? Qt.darker(datePicker.topBarBackgroundColor, 1.2) : datePicker.topBarBackgroundColor
                    radius: 5
                }

                indicator: Canvas {
                    x: headerListControl.width - width - 10
                    y: (headerListControl.availableHeight - height) / 2
                    width: 15
                    height: 10

                    onPaint: {
                        var ctx = getContext("2d");
                        ctx.reset();
                        ctx.moveTo(0, 0);
                        ctx.lineTo(width, 0);
                        ctx.lineTo(width / 2, height);
                        ctx.closePath();
                        ctx.fillStyle = datePicker.topBarTextColor;
                        ctx.fill();
                    }
                }                
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
                    if(datePicker.maxSelectableYear >= 1970
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
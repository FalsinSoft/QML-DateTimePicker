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

    readonly property int pickDayMonthYear: 0
    readonly property int pickMonthYear: 1
    readonly property int pickYear: 2

    property color backgroundColor: "white"
    property color topBarBackgroundColor: "blue"
    property color topBarTextColor: "white"
    property color calendarNumberColor: "black"
    property color calendarUnselectableNumberColor: "gray"
    property int topBarFontPointSize: 18
    property int minSelectableYear: 1970
    property int maxSelectableYear: (new Date().getFullYear() + 50)
    property int minSelectableMonth: 0
    property int maxSelectableMonth: 11
    property int minSelectableDay: 1
    property int maxSelectableDay: 31

    property int pickMode: pickDayMonthYear
    property int year: 1970
    property int month: 0
    property int day: 1

    onAboutToShow: {
        if(minSelectableYear < 1970) minSelectableYear = 1970;
        if(maxSelectableYear < 1970) maxSelectableYear = 1970;
        if(year < 1970) year = 1970;
        if(minSelectableMonth < 0 || minSelectableMonth > 11) minSelectableMonth = 0;
        if(maxSelectableMonth < 0 || maxSelectableMonth > 11) maxSelectableMonth = 0;
        if(month < 0 || month > 11) month = 0;
        if(minSelectableDay < 1 || minSelectableDay > 31) minSelectableDay = 1;
        if(maxSelectableDay < 1 || maxSelectableDay > 31) maxSelectableDay = 1;
        if(day < 1 || day > 31) day = 1;

        topBar.initialize();

        switch(pickMode)
        {
            case pickDayMonthYear:
                dateComponentLoader.sourceComponent = calendarComponent;
                break;
            case pickMonthYear:
                dateComponentLoader.sourceComponent = monthsGridComponent;
                break;
            case pickYear:
                dateComponentLoader.sourceComponent = yearsGridComponent;
                break;
        }
    }
    onClosed: {
        dateComponentLoader.sourceComponent = null;
    }

    Timer {
        id: acceptDateTimer
        interval: 250
        onTriggered: datePicker.accept()
    }

    background: Canvas {
        onPaint: {
            var radius = datePicker.Material.roundedScale;
            var topBarHeight = (topBar.height + 1);
            var ctx = getContext("2d");

            ctx.beginPath();
            ctx.moveTo(radius, 0);
            ctx.lineTo(width - radius, 0);
            ctx.quadraticCurveTo(width, 0, width, radius);
            ctx.lineTo(width, topBarHeight);
            ctx.lineTo(0, topBarHeight);
            ctx.lineTo(0, radius);
            ctx.quadraticCurveTo(0, 0, radius, 0);
            ctx.closePath();
            ctx.fillStyle = datePicker.topBarBackgroundColor;
            ctx.fill();

            ctx.beginPath();
            ctx.moveTo(0, topBarHeight);
            ctx.lineTo(0, height - radius);
            ctx.quadraticCurveTo(0, height, radius, height);
            ctx.lineTo(width - radius, height);
            ctx.quadraticCurveTo(width, height, width, height - radius);
            ctx.lineTo(width, topBarHeight);
            ctx.closePath();
            ctx.fillStyle = datePicker.backgroundColor;
            ctx.fill();
        }
    }
    
    header: Item {
        id: topBar
        implicitHeight: 50

        property int year
        property int month

        function initialize()
        {
            var years = [];

            yearsList.enabled = false;
            for(var i = datePicker.minSelectableYear; i <= datePicker.maxSelectableYear; i++) years.push(i);
            yearsList.model = years;
            yearsList.enabled = true;

            topBar.year = datePicker.year;
            topBar.month = datePicker.month;
        }

        readonly property string leftArrowIcon: "data:image/svg+xml;utf8,"
                            + "<svg xmlns='http://www.w3.org/2000/svg' width='24' height='24' viewBox='0 0 24 24'>"
                            + "<polygon points='15.293 3.293 6.586 12 15.293 20.707 16.707 19.293 9.414 12 16.707 4.707 15.293 3.293'/>"
                            + "</svg>"
        readonly property string rightArrowIcon: "data:image/svg+xml;utf8,"
                            + "<svg xmlns='http://www.w3.org/2000/svg' width='24' height='24' viewBox='0 0 24 24'>"
                            + "<polygon points='7.293 4.707 14.586 12 7.293 19.293 8.707 20.707 17.414 12 8.707 3.293 7.293 4.707'/>"
                            + "</svg>"

        readonly property int ceterAreaWidth: width - previousDateButton.width - nextDateButton.width

        ToolButton {
            id: previousDateButton
            width: height
            height: parent.height
            anchors.left: parent.left
            icon.source: parent.leftArrowIcon
            icon.width: icon.height
            icon.height: height * 0.7
            icon.color: enabled ? datePicker.topBarTextColor : datePicker.topBarBackgroundColor
            onClicked: {
                if(dateComponentLoader.status == Loader.Ready)
                {
                    dateComponentLoader.item.previous();
                }
            }
        }
        ComboBox {
            id: monthsList
            visible: datePicker.pickMode == datePicker.pickDayMonthYear
            currentIndex: topBar.month
            width: parent.ceterAreaWidth * 0.6
            height: parent.height
            anchors.left: previousDateButton.right
            font.pointSize: datePicker.topBarFontPointSize - 3
            Material.foreground: datePicker.topBarTextColor

            model: [
                qsTr("January"),
                qsTr("February"),
                qsTr("March"),
                qsTr("April"),
                qsTr("May"),
                qsTr("June"),
                qsTr("July"),
                qsTr("August"),
                qsTr("September"),
                qsTr("October"),
                qsTr("November"),
                qsTr("December")
            ]

            background: Rectangle { color: monthsList.down ? Qt.darker(datePicker.topBarBackgroundColor, 1.2) : datePicker.topBarBackgroundColor }

            onActivated: (index)=> {
                topBar.month = index;
                dateComponentLoader.item.update();
            }
        }
        ComboBox {
            id: yearsList
            visible: datePicker.pickMode == datePicker.pickDayMonthYear || datePicker.pickMode == datePicker.pickMonthYear
            currentIndex: enabled ? indexOfValue(topBar.year) : -1
            width: parent.ceterAreaWidth * 0.4
            height: parent.height
            anchors.right: nextDateButton.left
            font.pointSize: datePicker.topBarFontPointSize - 3
            Material.foreground: datePicker.topBarTextColor

            background: Rectangle { color: yearsList.down ? Qt.darker(datePicker.topBarBackgroundColor, 1.2) : datePicker.topBarBackgroundColor }

            onActivated: (index)=> {
                topBar.year = yearsList.currentValue;
                dateComponentLoader.item.update();
            }
        }
        ToolButton {
            id: nextDateButton
            width: height
            height: parent.height
            anchors.right: parent.right
            icon.source: parent.rightArrowIcon
            icon.width: icon.height
            icon.height: height * 0.7
            icon.color: enabled ? datePicker.topBarTextColor : datePicker.topBarBackgroundColor
            onClicked: {
                if(dateComponentLoader.status == Loader.Ready)
                {
                    dateComponentLoader.item.next();
                }
            }
        }
    }

    Loader {
        id: dateComponentLoader
        width: parent.width
    }

    Component {
        id: calendarComponent

        Item {
            implicitHeight: calendarColumn.height + 20

            function next()
            {
                var newDate = new Date(topBar.year, topBar.month, 1);
                newDate.setMonth(newDate.getMonth() + 1);
                topBar.year = newDate.getFullYear();
                topBar.month = newDate.getMonth();
                update();
            }

            function previous()
            {
                var newDate = new Date(topBar.year, topBar.month, 1);
                newDate.setMonth(newDate.getMonth() - 1);
                topBar.year = newDate.getFullYear();
                topBar.month = newDate.getMonth();
                previousDateButton.enabled = false;
                update();
            }

            function update()
            {
                var minDateTime = new Date(datePicker.minSelectableYear, datePicker.minSelectableMonth, 1).getTime();
                var maxDateTime = new Date(datePicker.maxSelectableYear, datePicker.maxSelectableMonth, 1).getTime();
                var currentDateTime = new Date(topBar.year, topBar.month, 1).getTime();
                previousDateButton.enabled = (currentDateTime <= minDateTime) ? false : true;
                nextDateButton.enabled = (currentDateTime >= maxDateTime) ? false : true;
            }

            Component.onCompleted: update()

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
                    month: topBar.month
                    year: topBar.year

                    readonly property var minDateTime: new Date(datePicker.minSelectableYear, datePicker.minSelectableMonth, datePicker.minSelectableDay).getTime();
                    readonly property var maxDateTime: new Date(datePicker.maxSelectableYear, datePicker.maxSelectableMonth, datePicker.maxSelectableDay).getTime();

                    function isDateSelectable(year, month, day)
                    {
                        var cellDateTime = new Date(year, month, day).getTime();
                        if(cellDateTime < calendarGrid.minDateTime || cellDateTime > calendarGrid.maxDateTime) return false;
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

                    onClicked: (date)=> {
                        var year = date.getFullYear();
                        var month = date.getMonth();
                        var day = date.getDate();

                        if(calendarGrid.isDateSelectable(year, month, day) == true && month == calendarGrid.month)
                        {
                            datePicker.year = year;
                            datePicker.month = month;
                            datePicker.day = day;
                            acceptDateTimer.start();
                        }
                    }
                }
            }
        }
    }

    Component {
        id: monthsGridComponent

        Item {
            implicitHeight: monthsGrid.height + 10

            function next()
            {
                topBar.year += 1;
                update();
            }

            function previous()
            {
                topBar.year -= 1;
                update();
            }

            function update()
            {
                previousDateButton.enabled = (topBar.year > datePicker.minSelectableYear) ? true : false;
                nextDateButton.enabled = (topBar.year < datePicker.maxSelectableYear) ? true : false;
            }

            Component.onCompleted: update()

            GridLayout {
                id: monthsGrid
                width: parent.width - 20
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                flow: GridLayout.TopToBottom
                rows: 4
                columns: 3
                rowSpacing: 5
                columnSpacing: 5

                readonly property var minDateTime: new Date(datePicker.minSelectableYear, datePicker.minSelectableMonth, 1).getTime();
                readonly property var maxDateTime: new Date(datePicker.maxSelectableYear, datePicker.maxSelectableMonth, 1).getTime();

                function isMonthSelectable(year, month)
                {
                    var cellDateTime = new Date(year, month, 1).getTime();
                    if(cellDateTime < monthsGrid.minDateTime || cellDateTime > monthsGrid.maxDateTime) return false;
                    return true;
                }

                Repeater {
                    model: [qsTr("January"),
                            qsTr("February"),
                            qsTr("March"),
                            qsTr("April"),
                            qsTr("May"),
                            qsTr("June"),
                            qsTr("July"),
                            qsTr("August"),
                            qsTr("September"),
                            qsTr("October"),
                            qsTr("November"),
                            qsTr("December")]

                    Button {
                        Layout.fillWidth: true
                        enabled: monthsGrid.isMonthSelectable(topBar.year, index)
                        text: modelData
                        autoExclusive: true
                        flat: true
                        checkable: true
                        font.pointSize: datePicker.topBarFontPointSize - 3
                        Material.roundedScale: Material.MediumScale
                        Material.accent: checked ? datePicker.topBarTextColor : monthsGrid.Material.accent
                        Material.background: checked ? datePicker.topBarBackgroundColor : monthsGrid.Material.background
                        checked: topBar.year == datePicker.year && index == datePicker.month
                        onClicked: {
                            datePicker.year = topBar.year;
                            datePicker.month = index;
                            acceptDateTimer.start();
                        }
                    }
                }
            }
        }
    }

    Component {
        id: yearsGridComponent

        Item {
            implicitHeight: yearsGrid.height + 10

            function next()
            {
                topBar.year += (yearsGrid.rows * yearsGrid.columns);
                yearsRepeater.calculateYears(topBar.year);
                update();
            }

            function previous()
            {
                topBar.year -= (yearsGrid.rows * yearsGrid.columns);
                yearsRepeater.calculateYears(topBar.year);
                update();
            }

            function update()
            {
                previousDateButton.enabled = (yearsRepeaterModel.get(0).year > datePicker.minSelectableYear) ? true : false;
                nextDateButton.enabled = (yearsRepeaterModel.get(yearsRepeaterModel.count - 1).year < datePicker.maxSelectableYear) ? true : false;
            }

            Component.onCompleted: {
                yearsRepeater.calculateYears(datePicker.year);
                update();
            }

            GridLayout {
                id: yearsGrid
                width: parent.width - 20
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                flow: GridLayout.TopToBottom
                rows: 4
                columns: 4
                rowSpacing: 5
                columnSpacing: 5

                readonly property var minDateTime: new Date(datePicker.minSelectableYear, 0, 1).getTime();
                readonly property var maxDateTime: new Date(datePicker.maxSelectableYear, 0, 1).getTime();

                function isYearSelectable(year)
                {
                    var cellDateTime = new Date(year, 0, 1).getTime();
                    if(cellDateTime < yearsGrid.minDateTime || cellDateTime > yearsGrid.maxDateTime) return false;
                    return true;
                }

                Repeater {
                    id: yearsRepeater
                    model: ListModel { id: yearsRepeaterModel }

                    function calculateYears(centralYear)
                    {
                        var visibleYearsNumber = (yearsGrid.rows * yearsGrid.columns);
                        var baseYear = (centralYear - (visibleYearsNumber / 2));

                        yearsRepeaterModel.clear();
                        for(var i = baseYear; i < (baseYear + visibleYearsNumber); i++) yearsRepeaterModel.append({ "year": i });
                    }

                    Button {
                        Layout.fillWidth: true
                        enabled: yearsGrid.isYearSelectable(model.year)
                        text: model.year
                        autoExclusive: true
                        flat: true
                        checkable: true
                        font.pointSize: datePicker.topBarFontPointSize - 3
                        Material.roundedScale: Material.MediumScale
                        Material.accent: checked ? datePicker.topBarTextColor : yearsGrid.Material.accent
                        Material.background: checked ? datePicker.topBarBackgroundColor : yearsGrid.Material.background
                        checked: parseInt(text) == datePicker.year
                        onClicked: {
                            datePicker.year = model.year;
                            acceptDateTimer.start();
                        }
                    }
                }
            }
        }
    }
}
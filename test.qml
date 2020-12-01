import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import QtQuick.Controls.Styles 1.4


Rectangle
{
    anchors.rightMargin: 4
    anchors.bottomMargin: 4
    anchors.leftMargin: 4
    anchors.topMargin: 4
    anchors.fill: parent

    ColumnLayout
    {
        //clip: true
        spacing: 2
        anchors.fill: parent

        Rectangle
        {
            //color:"yellow"
            Layout.fillWidth: true
            Layout.fillHeight: true
            RowLayout {
                anchors.fill: parent
                Rectangle
                {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    ListView {
                        id:idLogListView
                        focus:true
                        //Keys.enabled: true
                        //highlightRangeMode: ListView.ApplyRange
                        anchors.fill: parent
                        highlight: Rectangle { color: "#00CED1" }
                        model: idListModle
                        delegate: Component
                        {
                        RowLayout {
                            id:idlistElemnet
                            height: 20
                            width: parent.width
                            spacing: 20
                            Layout.fillWidth: true

                            Rectangle {height: 16
                                width: 16
                                radius: 5
                                color:getListEleHeadColor(type)
                                Text{ anchors.centerIn: parent}
                            }

                            Text { text: time; font.bold: true}
                            Text { text:type }
                            Text { text:descripe; color:"blue" ; Layout.fillWidth: true}

                            states: State {
                                name: "Current"
                                when: idlistElemnet.ListView.isCurrentItem
                                PropertyChanges { target: idlistElemnet; x: 20 }
                            }
                            transitions: Transition {
                                NumberAnimation { properties: "x"; duration: 200 }
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: idlistElemnet.ListView.view.currentIndex = index
                            }

                        }


                    }

                    Component.onCompleted:
                    {
                        for(var idx=0;idx<100;idx++)
                        {
                            var newType=parseInt((Math.random(Math.random())*100+1)%3);
                            idListModle.append( { "descripe": "系统日志....................","time": "2016-10-2","type":newType});
                        }

                    }


                }

                ListModel {
                    id:idListModle
                    ListElement {
                        descripe: "系统日志....................."
                        time: "2016-11-2"
                        type:1
                    }

                }

            }

            Rectangle
            {
                Layout.fillHeight: true
                // 滚动条

                id: scrollbar
                width: 10;
                height: 380
                color: "#D9D9D9"
                radius: 10
                // 按钮
                Rectangle {
                    id: button
                    x: 0
                    y: idLogListView.visibleArea.yPosition * scrollbar.height
                    width: 10
                    height: idLogListView.visibleArea.heightRatio * scrollbar.height;
                    color: "#979797"
                    radius: 10
                    // 鼠标区域
                    MouseArea {
                        id: mouseArea
                        anchors.fill: button
                        drag.target: button
                        drag.axis: Drag.YAxis
                        drag.minimumY: 0
                        drag.maximumY: scrollbar.height - button.height
                        // 拖动
                        onMouseYChanged: {
                            idLogListView.contentY = button.y / scrollbar.height * idLogListView.contentHeight
                        }
                    }
                }

            }


        }


    }

    Rectangle
    {
        Layout.preferredHeight: 40
        Layout.fillWidth: true
        Layout.minimumHeight:40
    }
}

function getListEleHeadColor(ntype)
{
    switch(ntype)
    {
    case 0:
        return "lightblue"
    case 1:
        return "red";

    case 2:
        return "yellow";
    case 3:
        return "green";
    default:
        return "black";
    }

}

}

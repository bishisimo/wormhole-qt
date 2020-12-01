import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1
import QtQuick.Controls 2.15

Window {
    id: window
    width: 640
    height: 480
    visible: true
    color: "#d6d5b7"
    title: qsTr("Hello World")
    property bool isFirst: true
    onSceneGraphInitialized: {
        redux.get_online_devices(listView)
        redux.set_name(textInput_name)
        redux.set_ip(textInput_net)
    }
    onVisibleChanged: {
        if(isFirst){
            isFirst=false
        }else{
            redux.exit()
        }
    }
    Timer {
        id: timer
        interval: 200; repeat: true
        running: true
        triggeredOnStart: true

        onTriggered: {
            redux.get_message(textEdit_log)
        }
    }

    Column {
        id: column
        x: 0
        y: 0
        width: 640
        height: 480
    }

    Row {
        id: row_left
        x: 0
        y: 0
        width: 241
        height: 480
    }

    Rectangle {
        id: rectangle_left
        x: 0
        y: 0
        width: 292
        height: 480
        color: "#8cc7b5"

        MouseArea {
            id: mouseArea
            x: 242
            y: 103
            width: 40
            height: 32
            onClicked:{
                redux.set_name(textInput_name)
                redux.set_ip(textInput_net)
                redux.get_online_devices(listView)
            }
            AnimatedImage {
                id: animatedImage1
                x: 4
                y: 0
                width: 32
                height: 32
                source: "res/image/refresh2.png"
            }
        }

        MouseArea {
            id: mouseArea1
            x: 242
            y: 52
            width: 42
            height: 31

            AnimatedImage {
                id: animatedImage2
                x: 4
                y: 1
                width: 31
                height: 29
                source: "res/image/ok_green.png"
            }
        }

        MouseArea {
            id: mouseArea2
            x: 242
            y: 8
            width: 40
            height: 32

            AnimatedImage {
                id: animatedImage
                x: 4
                y: 0
                width: 31
                height: 29
                source: "res/image/ok_green.png"
            }
        }

        Rectangle {
            id: rectangle2
            x: 0
            y: 153
            width: 284
            height: 327
            color: "#b9caec"
        }
    }

    Rectangle {
        id: rectangle_state
        x: 0
        y: 0
        width: 235
        height: 45
        color: "#bee7e9"

        Rectangle {
            id: rectangle_name
            x: 51
            y: 8
            width: 176
            height: 29
            color: "#888a85"

            TextInput {
                id: textInput_name
                x: 0
                y: 2
                width: 176
                height: 25
                color: "#3ccc88"
                text: "localhost"
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.NoWrap
                clip: false
                font.kerning: true
                selectionColor: "#aeaefc"
                selectedTextColor: "#011429"
                maximumLength: 10
                selectByMouse: true
                overwriteMode: true
                onAccepted: {
                    if(textInput_name.text===""){
                        redux.set_name(textInput_name)
                    }else{
                        redux.change_name(textInput_name.text)
                    }
                }
            }
        }

        Text {
            id: element
            x: 8
            y: 15
            width: 37
            height: 17
            text: qsTr("Name:")
            font.pixelSize: 12
        }
    }

    Rectangle {
        id: rectangle_net
        x: 0
        y: 46
        width: 235
        height: 43
        color: "#e6ceac"
        Text {
            id: text_net
            x: 0
            y: 8
            width: 45
            height: 27
            text: qsTr("Net:")
            font.pixelSize: 12
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.NoWrap
            renderType: Text.QtRendering
            maximumLineCount: 1

            Rectangle {
                id: rectangle_net_ip
                x: 51
                y: 0
                width: 176
                height: 27
                color: "#888a85"

                TextInput {
                    id: textInput_net
                    x: 0
                    y: 0
                    width: 176
                    height: 27
                    color: "#93df24"
                    text: qsTr("127.0.0.1")
                    font.pixelSize: 12
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    selectionColor: "#aeaefc"
                    selectByMouse: true
                    overwriteMode: true
                    maximumLength: 15
                    validator: RegExpValidator{regExp: /^(\d{1,3}\.){3}\d{1,3}$/}
                    onAccepted: {
                        if(textInput_net.text===""){
                            redux.set_ip(textInput_net)
                        }else{
                            redux.add_net(textInput_net.text)
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        id: rectangle_online
        x: 0
        y: 104
        width: 235
        height: 30
        color: "#beedc7"
        Text {
            id: text_online
            x: 0
            y: 1
            width: 235
            height: 30
            text: "在线设备"
            font.pixelSize: 12
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    Row {
        id: row_right
        x: 315
        y: 0
        width: 325
        height: 480
    }


    Rectangle {
        id: rectangle_drop
        x: 315
        y: 0
        width: 325
        height: 149
        color: "#abaca8"

        DropArea {
            id: dropArea_drop
            x: 0
            y: 0
            width: 325
            height: 149
            Connections {
                target: dropArea_drop
                function onDropped(drop){
                    if (drop.urls.length>0){
                        redux.send(listView.currentIndex ,drop.urls[0].substring(7))
                    }
                }
            }
        }

        MouseArea {
            id: mouseArea_drop
            x: 0
            y: 0
            width: 325
            height: 149
            preventStealing: true
            hoverEnabled: true
            property bool  is_hover:false
            Connections {
                target: mouseArea_drop
                function onHoveredChanged() {
                    mouseArea_drop.is_hover=mouseArea_drop.is_hover?false:true
                    text_drop.font.pixelSize=mouseArea_drop.is_hover?25:18
                    text_drop.font.underline=mouseArea_drop.is_hover?true:false
                    text_drop.color=mouseArea_drop.is_hover?"#A0EEE1":"#000000"
                }
            }
        }

        Text {
            id: text_drop
            objectName: "drop_text"
            x: 24
            y: 21
            width: 282
            height: 106
            color: "#000000"
            text: qsTr("Drop to Here")
            font.pixelSize: 18
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            styleColor: "#e85757"
            maximumLineCount: 1
        }
    }

    ListView {
        id: listView
        objectName: "listView"
        x: 0
        y: 154
        width: 285
        height: 326
        maximumFlickVelocity: 500
        snapMode: ListView.NoSnap
        antialiasing: true
        transformOrigin: Item.Center
        highlightResizeDuration: 1
        highlightMoveDuration: 1
        keyNavigationWraps: false
        contentWidth: 0
        pixelAligned: false
        interactive: true
        highlightRangeMode: ListView.StrictlyEnforceRange
        clip:true
        delegate:Component {
            id:item_device
            //            x: 0
            //            width: 200
            //            height: 40
            Rectangle {
                id: rectangle_device
                x: 0
                y: 0
                width: rectangle_device.ListView.isCurrentItem?285:260
                height: 23
                color: rectangle_device.ListView.isCurrentItem?"#FF6666":"#bee7e9"
                clip: false
                Row {
                    id: row_device
                    x:10
                    Text {
                        text: index
                        anchors.verticalCenter: parent.verticalCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    Text {
                        text: host
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: name
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    spacing: 10
                }
            }
        }
        model: ListModel {
            ListElement {
                name: ""
                host: "192.168.1.1"
            }
        }

    }
    Rectangle {
        id: rectangle_log
        x: 315
        y: 177
        width: 325
        height: 173
        color: "#a09696"
        clip:true
        Keys.onUpPressed: vbar.decrease()
        Keys.onDownPressed: vbar.increase()

        TextEdit {
            id: textEdit_log
            x: 0
            height: contentHeight
            width: rectangle_log.width - vbar.width
            y: -vbar.position * textEdit_log.height
            font.pixelSize: 12
            wrapMode: Text.WrapAnywhere
            selectionColor: "#7f54d1"
            selectByKeyboard: true
            selectByMouse: true
            readOnly: true
            MouseArea{
                  anchors.fill: parent
                  onWheel: {
                      if (wheel.angleDelta.y > 0) {
                          vbar.decrease();
                      }
                      else {
                          vbar.increase();
                      }
                  }
                  onClicked: {
                      textEdit_log.forceActiveFocus();
                  }
            }
        }
    }

    ScrollBar {
        id: vbar
        hoverEnabled: true
        active: hovered || pressed
        orientation: Qt.Vertical
        size: rectangle_log.height / textEdit_log.height
        width: 10
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.bottom: parent.bottom
    }

    Rectangle {
        id: rectangle_message
        x: 316
        y: 369
        width: 324
        height: 95
        color: "#ffffff"

        TextInput {
            id: textInput_message
            x: 0
            y: 0
            width: 324
            height: 95
            font.pixelSize: 12
            wrapMode: Text.Wrap
            selectByMouse: true
            persistentSelection: false
            overwriteMode: false
            cursorVisible: true
            selectionColor: "#7f54d1"
            maximumLength: 135
            onAccepted: {
                redux.send(listView.currentIndex ,textInput_message.text)
            }
        }
    }

}

/*##^##
Designer {
    D{i:0;formeditorZoom:1.659999966621399}
}
##^##*/

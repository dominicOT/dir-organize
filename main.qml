import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import QtMultimedia

ApplicationWindow {
    id: window
    visible: true
    width: 720
    height: 680
    minimumWidth: 620
    minimumHeight: 580
    title: "Leo • Arm A"
    flags: Qt.Window | Qt.FramelessWindowHint  // Optional: more futuristic

    background: Rectangle {
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#0a0f1c" }
            GradientStop { position: 1.0; color: "#02050f" }
        }
    }

    // Sound Effects
    SoundEffect {
        id: scanSound
        source: "qrc:/sounds/scan.wav"  // We'll handle sounds later
    }
    SoundEffect { id: moveSound; source: "qrc:/sounds/move.wav" }
    SoundEffect { id: successSound; source: "qrc:/sounds/success.wav" }
    SoundEffect { id: errorSound; source: "qrc:/sounds/error.wav" }

    FolderDialog {
        id: folderDialog
        title: "Select Target Directory"
        onAccepted: dirBridge.setTargetDirectoryFromUrl(selectedFolder.toString())
    }

    Connections {
        target: dirBridge
        function onValidationError(errorMsg) {
            errorMessage.text = errorMsg
            errorSound.play()
        }
    }

    // Main HUD Container
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 30
        spacing: 25

        // Header
        RowLayout {
            Layout.fillWidth: true
            spacing: 15

            Text {
                text: "◉"
                font.pixelSize: 42
                color: "#00f0ff"
                style: Text.Outline
                styleColor: "#00f0ff"
            }

            ColumnLayout {
                spacing: 4
                Layout.fillWidth: true
                Text {
                    text: "Leo Arm A v1.0"
                    color: "#00f0ff"
                    font.pixelSize: 24
                    font.bold: true
                    font.letterSpacing: 2
                }
                Text {
                    text: "ARC REACTOR PROTOCOL ACTIVE • FILES BEING SORTED"
                    color: "#22ff88"
                    font.pixelSize: 12
                    font.letterSpacing: 1.5
                }
            }

            // Status Indicator
            Rectangle {
                width: 18; height: 18
                radius: 9
                color: dirBridge.isProcessing ? "#22ff88" : "#ff4444"
                border.color: "#ffffff"
                border.width: 2
            }
        }

        Rectangle { Layout.fillWidth: true; height: 1; color: "#00f0ff"; opacity: 0.3 }

        // Folder Selection (Holographic Cards)
        RowLayout {
            Layout.fillWidth: true
            spacing: 20

            // Downloads Card
            HoloCard {
                visible: dirBridge.downloadsExists
                icon: "📥"
                label: "DOWNLOADS"
                path: dirBridge.homeDownloads
                active: dirBridge.targetDirectory === dirBridge.homeDownloads
                onClicked: {
                    dirBridge.targetDirectory = dirBridge.homeDownloads
                    errorMessage.text = ""
                }
            }

            // Documents Card
            HoloCard {
                visible: dirBridge.documentsExists
                icon: "📁"
                label: "DOCUMENTS"
                path: dirBridge.homeDocuments
                active: dirBridge.targetDirectory === dirBridge.homeDocuments
                onClicked: {
                    dirBridge.targetDirectory = dirBridge.homeDocuments
                    errorMessage.text = ""
                }
            }
        }

        // Path Input + Browse
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            TextField {
                id: pathInput
                text: dirBridge.targetDirectory
                placeholderText: "ENTER CUSTOM PATH OR USE QUICK SELECT"
                Layout.fillWidth: true
                onTextChanged: dirBridge.targetDirectory = text
                color: "#a0f0ff"
                font.pixelSize: 14
                background: Rectangle {
                    color: "#0a1428"
                    border.color: pathInput.focus ? "#00f0ff" : "#1e3a5f"
                    border.width: 2
                    radius: 6
                }
            }

            Button {
                text: "BROWSE"
                onClicked: folderDialog.open()
                background: Rectangle {
                    color: "#1e3a5f"
                    border.color: "#00f0ff"
                    radius: 6
                }
                contentItem: Text { text: parent.text; color: "#00f0ff"; font.bold: true }
            }
        }

        // Error
        Rectangle {
            Layout.fillWidth: true
            height: errorMessage.text ? 48 : 0
            color: "#330000"
            border.color: "#ff4444"
            radius: 6
            visible: errorMessage.text !== ""

            Text {
                id: errorMessage
                anchors.centerIn: parent
                color: "#ff6666"
                font.pixelSize: 14
                font.bold: true
            }
        }

        // Visual Progress + File Animation Area
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 220
            color: "#05080f"
            border.color: "#00f0ff"
            border.width: 1
            radius: 10
            clip: true

            // Animated Files Container
            Item {
                id: animationArea
                anchors.fill: parent
                anchors.margins: 15

                Repeater {
                    id: fileRepeater
                    model: 0  // Controlled from Python/JS

                    delegate: Image {
                        id: flyingFile
                        source: "qrc:/icons/file.png"  // We'll add placeholder icons
                        width: 42; height: 42
                        opacity: 0.9

                        PropertyAnimation on x {
                            from: Math.random() * animationArea.width
                            to: animationArea.width * 0.75
                            duration: 1200 + Math.random() * 800
                            running: true
                        }
                        PropertyAnimation on y {
                            from: Math.random() * animationArea.height * 0.6
                            to: animationArea.height * 0.8
                            duration: 1400 + Math.random() * 600
                            running: true
                        }

                        SequentialAnimation on opacity {
                            loops: 1
                            NumberAnimation { to: 0.3; duration: 800 }
                            NumberAnimation { to: 0; duration: 400 }
                        }
                    }
                }
            }

            ColumnLayout {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 20

                Text {
                    text: dirBridge.statusMessage
                    color: "#00ffcc"
                    font.pixelSize: 15
                    font.bold: true
                }

                ProgressBar {
                    value: dirBridge.progress
                    Layout.fillWidth: true
                    background: Rectangle { color: "#112233"; height: 8; radius: 4 }
                    contentItem: Rectangle {
                        width: parent.width * parent.visualPosition
                        height: 8
                        radius: 4
                        gradient: Gradient {
                            GradientStop { position: 0; color: "#00f0ff" }
                            GradientStop { position: 1; color: "#22ff88" }
                        }
                    }
                }
            }
        }

        // Big Organize Button
        Button {
            Layout.fillWidth: true
            height: 62
            enabled: !dirBridge.isProcessing && dirBridge.targetDirectory !== ""

            background: Rectangle {
                radius: 12
                border.color: "#00f0ff"
                border.width: 3
                gradient: Gradient {
                    GradientStop { position: 0.0; color: parent.enabled ? (parent.parent.hovered ? "#00ffff" : "#0088ff") : "#334455" }
                    GradientStop { position: 1.0; color: "#003366" }
                }
            }

            contentItem: Text {
                text: dirBridge.isProcessing ? "● ORGANIZING IN PROGRESS ●" : "INITIALIZE SORT PROTOCOL"
                color: "#ffffff"
                font.pixelSize: 18
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            onClicked: {
                dirBridge.startOrganizing()
                scanSound.play()
            }
        }

        // Log Console (Terminal Style)
        ColumnLayout {
            Layout.fillHeight: true
            Layout.fillWidth: true

            Text { text: "ARC LOG"; color: "#00ffcc"; font.bold: true; font.pixelSize: 14 }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "#01050a"
                border.color: "#00f0ff"
                border.width: 1
                radius: 8

                ScrollView {
                    anchors.fill: parent
                    anchors.margins: 12
                    TextArea {
                        text: dirBridge.logText
                        readOnly: true
                        color: "#88eeff"
                        font.family: "monospace"
                        font.pixelSize: 12
                        background: null
                    }
                }
            }
        }
    }

    // Custom Holographic Card Component
    component HoloCard: Rectangle {
        property string icon
        property string label
        property string path
        property bool active: false
        signal clicked()

        width: 280; height: 92
        radius: 12
        color: active ? "#0f1f38" : "#0a1428"
        border.color: active ? "#00f0ff" : "#1e4a7a"
        border.width: active ? 3 : 2

        RowLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 16

            Text { text: icon; font.pixelSize: 42 }

            ColumnLayout {
                Text { text: label; color: "#ffffff"; font.pixelSize: 17; font.bold: true }
                Text { text: path; color: "#88aaff"; font.pixelSize: 11; elide: Text.ElideMiddle }
            }
        }

        MouseArea { anchors.fill: parent; onClicked: parent.clicked() }
    }
}

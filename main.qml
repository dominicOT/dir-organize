import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

ApplicationWindow {
    id: window
    visible: true
    width: 620
    height: 600
    minimumWidth: 550
    minimumHeight: 550
    title: "Smart Directory Organizer"

    // Modern Dark Background
    background: Rectangle {
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#0f172a" } // Slate 900
            GradientStop { position: 1.0; color: "#090d16" } // Custom Obsidian
        }
    }

    FolderDialog {
        id: folderDialog
        title: "Select Folder to Organize"
        onAccepted: {
            dirBridge.setTargetDirectoryFromUrl(selectedFolder.toString())
            errorMessage.text = "" // Clear any previous error
        }
    }

    Connections {
        target: dirBridge
        function onValidationError(errorMsg) {
            errorMessage.text = errorMsg
        }
        function onLogsCleared() {
            // Logs are cleared via the text binding
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 25
        spacing: 20

        // Header Section
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Text {
                text: "✨"
                font.pixelSize: 32
                Layout.alignment: Qt.AlignVCenter
            }

            ColumnLayout {
                spacing: 2
                Layout.fillWidth: true

                Text {
                    text: "Directory Organizer"
                    color: "#f8fafc"
                    font.pixelSize: 22
                    font.bold: true
                }

                Text {
                    text: "Keep your files sorted by file types automatically"
                    color: "#94a3b8" // Slate 400
                    font.pixelSize: 13
                }
            }
        }

        // Horizontal Separator
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#334155" // Slate 700
        }

        // Section 1: Quick & Custom Folder Selection
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 10

            Text {
                text: "1. Choose Folder to Organize (Documents or Downloads only)"
                color: "#cbd5e1" // Slate 300
                font.pixelSize: 13
                font.bold: true
            }

            // Quick Select Cards
            RowLayout {
                Layout.fillWidth: true
                spacing: 15

                // Downloads Card
                Item {
                    id: downloadsCard
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1
                    height: 80
                    visible: dirBridge.downloadsExists

                    Rectangle {
                        anchors.fill: parent
                        color: dirBridge.targetDirectory === dirBridge.homeDownloads ? "#1e293b" : "#0f172a"
                        border.color: dirBridge.targetDirectory === dirBridge.homeDownloads ? "#6366f1" : "#1e293b"
                        border.width: dirBridge.targetDirectory === dirBridge.homeDownloads ? 2 : 1
                        radius: 10

                        Behavior on color { ColorAnimation { duration: 150 } }
                        Behavior on border.color { ColorAnimation { duration: 150 } }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: {
                                if (dirBridge.targetDirectory !== dirBridge.homeDownloads) {
                                    parent.border.color = "#475569"
                                }
                            }
                            onExited: {
                                if (dirBridge.targetDirectory !== dirBridge.homeDownloads) {
                                    parent.border.color = "#1e293b"
                                }
                            }
                            onClicked: {
                                dirBridge.targetDirectory = dirBridge.homeDownloads
                                errorMessage.text = ""
                            }
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 12

                            Text {
                                text: "📥"
                                font.pixelSize: 28
                                Layout.alignment: Qt.AlignVCenter
                            }

                            ColumnLayout {
                                spacing: 2
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter

                                Text {
                                    text: "Downloads"
                                    color: "#f8fafc"
                                    font.pixelSize: 15
                                    font.bold: true
                                }

                                Text {
                                    text: dirBridge.homeDownloads
                                    color: "#64748b"
                                    font.pixelSize: 11
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                            }
                        }
                    }
                }

                // Documents Card
                Item {
                    id: documentsCard
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1
                    height: 80
                    visible: dirBridge.documentsExists

                    Rectangle {
                        anchors.fill: parent
                        color: dirBridge.targetDirectory === dirBridge.homeDocuments ? "#1e293b" : "#0f172a"
                        border.color: dirBridge.targetDirectory === dirBridge.homeDocuments ? "#6366f1" : "#1e293b"
                        border.width: dirBridge.targetDirectory === dirBridge.homeDocuments ? 2 : 1
                        radius: 10

                        Behavior on color { ColorAnimation { duration: 150 } }
                        Behavior on border.color { ColorAnimation { duration: 150 } }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: {
                                if (dirBridge.targetDirectory !== dirBridge.homeDocuments) {
                                    parent.border.color = "#475569"
                                }
                            }
                            onExited: {
                                if (dirBridge.targetDirectory !== dirBridge.homeDocuments) {
                                    parent.border.color = "#1e293b"
                                }
                            }
                            onClicked: {
                                dirBridge.targetDirectory = dirBridge.homeDocuments
                                errorMessage.text = ""
                            }
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 12

                            Text {
                                text: "📁"
                                font.pixelSize: 28
                                Layout.alignment: Qt.AlignVCenter
                            }

                            ColumnLayout {
                                spacing: 2
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter

                                Text {
                                    text: "Documents"
                                    color: "#f8fafc"
                                    font.pixelSize: 15
                                    font.bold: true
                                }

                                Text {
                                    text: dirBridge.homeDocuments
                                    color: "#64748b"
                                    font.pixelSize: 11
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                            }
                        }
                    }
                }
            }

            // Manual Select Input Row
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                TextField {
                    id: pathInput
                    placeholderText: "Or type/browse a custom directory path..."
                    text: dirBridge.targetDirectory
                    onTextChanged: {
                        if (dirBridge.targetDirectory !== text) {
                            dirBridge.targetDirectory = text
                        }
                    }

                    Layout.fillWidth: true
                    color: "#f8fafc"
                    placeholderTextColor: "#64748b"
                    font.pixelSize: 13
                    selectByMouse: true

                    background: Rectangle {
                        color: "#1e293b"
                        radius: 8
                        border.color: pathInput.focus ? "#6366f1" : "#334155"
                        border.width: pathInput.focus ? 1.5 : 1
                        Behavior on border.color { ColorAnimation { duration: 150 } }
                    }
                }

                Button {
                    id: browseButton
                    text: "Browse..."

                    background: Rectangle {
                        color: browseButton.hovered ? "#334155" : "#1e293b"
                        border.color: "#475569"
                        border.width: 1
                        radius: 8
                    }

                    contentItem: Text {
                        text: browseButton.text
                        color: "#f8fafc"
                        font.pixelSize: 13
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        leftPadding: 15
                        rightPadding: 15
                    }

                    onClicked: folderDialog.open()
                }
            }
        }

        // Error Banner
        Rectangle {
            id: errorBanner
            Layout.fillWidth: true
            height: errorMessage.text !== "" ? 40 : 0
            color: "#1e1416" // Dark reddish background
            opacity: errorMessage.text !== "" ? 1.0 : 0.0
            radius: 8
            border.color: "#ef4444" // Bright red outline
            border.width: errorMessage.text !== "" ? 1 : 0
            clip: true

            Behavior on height { NumberAnimation { duration: 150; easing.type: Easing.InOutQuad } }
            Behavior on opacity { NumberAnimation { duration: 150 } }

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 8

                Text {
                    text: "⚠️"
                    font.pixelSize: 14
                    Layout.alignment: Qt.AlignVCenter
                }

                Text {
                    id: errorMessage
                    text: ""
                    color: "#f87171" // Light red text
                    font.pixelSize: 12
                    font.bold: true
                    wrapMode: Text.Wrap
                    Layout.fillWidth: true
                }
            }
        }

        // Progress Bar Section
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 5
            visible: dirBridge.isProcessing || dirBridge.progress > 0

            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: dirBridge.statusMessage
                    color: "#e2e8f0"
                    font.pixelSize: 12
                    Layout.fillWidth: true
                }
                Text {
                    text: Math.round(dirBridge.progress * 100) + "%"
                    color: "#38bdf8"
                    font.pixelSize: 12
                    font.bold: true
                }
            }

            ProgressBar {
                id: progressBar
                value: dirBridge.progress
                Layout.fillWidth: true

                background: Rectangle {
                    implicitHeight: 6
                    color: "#1e293b"
                    radius: 3
                }

                contentItem: Item {
                    implicitHeight: 6
                    Rectangle {
                        width: progressBar.visualPosition * parent.width
                        height: parent.height
                        radius: 3
                        color: "#6366f1"
                    }
                }
            }
        }

        // Section 2: Action Button
        Button {
            id: organizeButton
            Layout.fillWidth: true
            height: 46
            enabled: !dirBridge.isProcessing && dirBridge.targetDirectory !== ""

            scale: pressed ? 0.98 : 1.0
            Behavior on scale { NumberAnimation { duration: 80 } }

            background: Rectangle {
                radius: 8
                gradient: Gradient {
                    GradientStop {
                        position: 0.0
                        color: !organizeButton.enabled ? "#475569" :
                               (organizeButton.hovered ? "#818cf8" : "#6366f1")
                    }
                    GradientStop {
                        position: 1.0
                        color: !organizeButton.enabled ? "#334155" :
                               (organizeButton.hovered ? "#6366f1" : "#4f46e5")
                    }
                }
                border.color: !organizeButton.enabled ? "#1e293b" : "#4f46e5"
                border.width: 1
            }

            contentItem: RowLayout {
                spacing: 8
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                BusyIndicator {
                    id: busyInd
                    running: dirBridge.isProcessing
                    visible: running
                    implicitWidth: 18
                    implicitHeight: 18
                }

                Text {
                    text: dirBridge.isProcessing ? "Sorting Directories..." : "Organize Folder Now"
                    color: !organizeButton.enabled ? "#94a3b8" : "#ffffff"
                    font.pixelSize: 14
                    font.bold: true
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            onClicked: {
                errorMessage.text = ""
                dirBridge.startOrganizing()
            }
        }

        // Section 3: Activity Log / Output Console
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 6

            Text {
                text: "Activity Log"
                color: "#cbd5e1"
                font.pixelSize: 13
                font.bold: true
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "#020617" // Very dark background for terminal feel
                border.color: "#1e293b"
                border.width: 1
                radius: 8
                clip: true

                ScrollView {
                    id: logScrollView
                    anchors.fill: parent
                    anchors.margins: 10

                    TextArea {
                        id: logTextArea
                        text: dirBridge.logText
                        readOnly: true
                        color: "#38bdf8" // Light blue console text
                        font.family: "monospace"
                        font.pixelSize: 11
                        wrapMode: Text.WrapAnywhere
                        selectByMouse: true
                        background: Item {} // Transparent background

                        onTextChanged: {
                            // Automatically scroll to bottom when new logs are added
                            logTextArea.cursorPosition = logTextArea.text.length
                        }
                    }
                }
            }
        }
    }
}

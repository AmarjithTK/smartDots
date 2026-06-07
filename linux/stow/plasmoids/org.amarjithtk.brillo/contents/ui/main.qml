import QtQuick 2.0
import QtQuick.Layouts 1.4
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.kirigami 2.20 as Kirigami

Item {
    id: root

    // ─── State ────────────────────────────────────────────────
    property int currentBrightness: 50
    property int sliderValue: 50
    property string brightnessMethod: "unknown"
    property bool updatingFromCommand: false

    // ─── Layout hint: compact horizontal panel item ───────────
    Layout.minimumWidth: Kirigami.Units.iconSizes.smallMedium + Kirigami.Units.smallSpacing * 2
    Layout.minimumHeight: Kirigami.Units.iconSizes.smallMedium
    Layout.preferredWidth: Kirigami.Units.iconSizes.smallMedium + Kirigami.Units.smallSpacing * 2

    // ─── DataSource for running shell commands ────────────────
    PlasmaCore.DataSource {
        id: executor
        engine: "executable"
        connectedSources: []

        onNewData: {
            var stdout = data["stdout"] || ""
            var exitCode = data["exitCode"] || -1

            if (source === "brightnessGet") {
                var val = parseInt(stdout.trim())
                if (!isNaN(val) && val >= 0 && val <= 100) {
                    updatingFromCommand = true
                    currentBrightness = val
                    sliderValue = val
                    updatingFromCommand = false
                }
            } else if (source === "brightnessSet") {
                // After set, re-read actual brightness
                executor.connectSource("display-manager brightness get")
            } else if (source === "brightnessSave") {
                // After save, update display
            }

            disconnectSource(source)
        }
    }

    // ─── Timer: debounce slider changes ───────────────────────
    Timer {
        id: debounceTimer
        interval: 150
        repeat: false
        onTriggered: {
            if (!updatingFromCommand) {
                executor.connectSource("display-manager brightness set " + sliderValue)
                // Also save for persistence
                executor.connectSource("display-manager brightness save")
            }
        }
    }

    // ─── Load brightness on startup ───────────────────────────
    Component.onCompleted: {
        executor.connectSource("display-manager brightness get")
    }

    // ─── Compact representation (shown in panel) ──────────────
    PlasmaCore.IconItem {
        id: icon
        anchors.centerIn: parent
        width: Kirigami.Units.iconSizes.smallMedium
        height: width
        source: "brightnesssettings"
        active: mouseArea.containsMouse

        // Show brightness % as overlay text
        PlasmaComponents.Label {
            anchors {
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
            }
            text: currentBrightness + "%"
            fontSizeMode: Text.Fit
            font.pixelSize: 8
            color: PlasmaCore.Theme.textColor
            opacity: 0.8
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                popup.visible = !popup.visible
            }
        }
    }

    // ─── Popup with slider ────────────────────────────────────
    PlasmaComponents.Dialog {
        id: popup
        x: 0
        y: parent.height + Kirigami.Units.smallSpacing

        width: Kirigami.Units.gridUnit * 8
        height: Kirigami.Units.gridUnit * 4

        padding: Kirigami.Units.gridUnit

        mainItem: ColumnLayout {
            spacing: Kirigami.Units.smallSpacing

            PlasmaExtras.Heading {
                level: 5
                text: "Brightness"
                Layout.fillWidth: true
            }

            RowLayout {
                spacing: Kirigami.Units.smallSpacing
                Layout.fillWidth: true

                PlasmaCore.IconItem {
                    source: "brightness-low"
                    width: Kirigami.Units.iconSizes.small
                    height: width
                }

                PlasmaComponents.Slider {
                    id: brightnessSlider
                    Layout.fillWidth: true
                    from: 0
                    to: 100
                    value: sliderValue
                    stepSize: 1

                    onMoved: {
                        sliderValue = value
                        debounceTimer.restart()
                    }
                }

                PlasmaCore.IconItem {
                    source: "brightness-high"
                    width: Kirigami.Units.iconSizes.small
                    height: width
                }
            }

            // Percentage label
            PlasmaComponents.Label {
                text: sliderValue + "%"
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
                font.pixelSize: Kirigami.Units.fontSizeXLarge
                font.weight: Font.Bold
                color: PlasmaCore.Theme.textColor
            }
        }
    }
}

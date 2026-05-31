import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Widgets
import qs.Services.UI

Item {
  id: root

  property var pluginApi: null
  property ShellScreen screen
  property string widgetId: ""
  property string section: ""
  property int sectionWidgetIndex: -1
  property int sectionWidgetsCount: 0

  readonly property string screenName: screen?.name ?? ""
  readonly property string barPosition: Settings.getBarPositionForScreen(screenName)
  readonly property bool isBarVertical: barPosition === "left" || barPosition === "right"
  readonly property real capsuleHeight: Style.getCapsuleHeightForScreen(screenName)
  readonly property real barFontSize: Style.getBarFontSizeForScreen(screenName)

  readonly property real contentWidth: iconWidget.implicitWidth + Style.marginM * 2
  readonly property real contentHeight: capsuleHeight

  implicitWidth: contentWidth
  implicitHeight: contentHeight

  property string keyFilePath: ""
  property string scriptPath: ""

  Rectangle {
    id: visualCapsule
    x: Style.pixelAlignCenter(parent.width, width)
    y: Style.pixelAlignCenter(parent.height, height)
    width: root.contentWidth
    height: root.contentHeight
    color: mouseArea.containsMouse ? Color.mHover : Style.capsuleColor
    radius: Style.radiusL
    border.color: Style.capsuleBorderColor
    border.width: Style.capsuleBorderWidth

    NIcon {
      id: iconWidget
      anchors.centerIn: parent
      icon: "screenshot"
      color: mouseArea.containsMouse ? Color.mPrimary : Color.mOnSurface
      pointSize: barFontSize + 2
    }
  }

  MouseArea {
    id: mouseArea
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor

    onClicked: {
      if (ocrProc.running || keyReader.running) return
      keyReader.running = true
    }
  }

  // ── Read .apikey file ──────────────────────────────────────────
  Process {
    id: keyReader
    command: []
    running: false
    stdout: StdioCollector { id: keyOut }

    onExited: function() {
      var key = keyOut.readAll().trim()
      if (!key) {
        ToastService.showNotice("Set Mistral API key in plugin settings first")
        return
      }
      ocrProc.command = ["sh", root.scriptPath, key]
      ocrProc.running = true
    }
  }

  // ── Run the screenshot+OCR script ───────────────────────────────
  Process {
    id: ocrProc
    running: false
    command: []
    stdout: StdioCollector { id: sout }
    stderr: StdioCollector { id: serr }

    onExited: function(code) {
      var out = sout.readAll().trim()
      var err = serr.readAll().trim()
      if (code === 0 && out.length > 0) {
        ToastService.showNotice("OCR: " + out.length + " chars \u2192 clipboard")
      } else if (code !== 0) {
        if (err.indexOf("cancelled") < 0) {
          ToastService.showNotice("OCR failed: " + err.substring(0, 80))
        }
      }
    }
  }

  Component.onCompleted: {
    var dir = pluginApi?.pluginDir || ""
    if (!dir) {
      dir = String(Qt.resolvedUrl(".")).replace("file://", "")
    }
    root.keyFilePath = dir + "/.apikey"
    root.scriptPath = dir + "/scripts/screenshot-ocr.sh"
    keyReader.command = ["sh", "-c", "cat '" + root.keyFilePath + "' 2>/dev/null || true"]
    Logger.i("ScreenshotOCR", "Ready")
  }
}

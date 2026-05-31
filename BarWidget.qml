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

  readonly property real contentWidth: Math.max(capsuleHeight, iconWidget.implicitWidth + Style.marginM * 2)
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
    acceptedButtons: Qt.LeftButton

    onClicked: function(mouse) {
      if (mouse.button !== Qt.LeftButton) return
      if (ocrProc.running || keyReader.running) return

      Logger.i("ScreenshotOCR", "Bar icon clicked")

      var savedKey = pluginApi?.pluginSettings?.mistralApiKey || ""
      if (savedKey.trim().length > 0) {
        startOcr(savedKey.trim())
        return
      }

      keyReader.running = true
    }
  }

  function startOcr(key) {
    Logger.i("ScreenshotOCR", "Starting OCR script: " + root.scriptPath)
    if (Qt.platform.os === "linux") {
      ocrProc.command = ["niri", "msg", "action", "spawn", "--", "env", "SCREENSHOT_OCR_NOTIFY=1", "bash", root.scriptPath, key]
    } else {
      ocrProc.command = ["bash", root.scriptPath, key]
    }
    ocrProc.running = true
  }

  function collectorText(collector) {
    return String(collector?.text || "").trim()
  }

  // ── Read .apikey file ──────────────────────────────────────────
  Process {
    id: keyReader
    command: []
    running: false
    stdout: StdioCollector { id: keyOut }

    onExited: function() {
      var key = collectorText(keyOut)
      if (!key) {
        ToastService.showNotice("Set Mistral API key in plugin settings first")
        return
      }
      startOcr(key)
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

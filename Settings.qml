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

  property string widgetId: ""
  property string section: ""
  property int sectionWidgetIndex: -1

  property string keyFilePath: ""

  implicitWidth: content.implicitWidth + Style.marginL * 2
  implicitHeight: content.implicitHeight + Style.marginL * 2

  ColumnLayout {
    id: content
    anchors.centerIn: parent
    spacing: Style.marginM
    width: Math.min(parent.width - Style.marginL * 2, 400)

    NText {
      text: "Mistral API Key"
      color: Color.mOnSurface
      pointSize: Style.fontSizeM
      font.weight: Font.Medium
    }

    NTextInput {
      id: apiKeyInput
      Layout.fillWidth: true
      text: ""
      placeholderText: "sk-..."

      onEditingFinished: {
        if (text.length > 0 && root.keyFilePath) {
          writeKeyToFile(text)
        }
      }
    }

    NText {
      text: "Get your key at console.mistral.ai/api-keys"
      color: Color.mOnSurfaceVariant
      pointSize: Style.fontSizeXS
      wrapMode: Text.WordWrap
      Layout.fillWidth: true
    }

    Item { Layout.fillHeight: true }

    NText {
      text: "Dependencies: grim, slurp, wl-copy, curl, jq"
      color: Color.mOnSurfaceVariant
      pointSize: Style.fontSizeXS
    }
  }

  // ── Write key to file ──────────────────────────────────────────
  function writeKeyToFile(key) {
    writeProc.command = ["sh", "-c",
      "printf '%s' '" + key + "' > '" + root.keyFilePath + "' && chmod 600 '" + root.keyFilePath + "'"]
    writeProc.running = true
  }

  Process {
    id: writeProc
    command: []
    running: false

    onExited: function(code) {
      if (code === 0) {
        ToastService.showNotice("API key saved")
      }
    }
  }

  // ── Read existing key on load ───────────────────────────────────
  Process {
    id: readProc
    command: []
    running: false
    stdout: StdioCollector { id: readOut }

    onExited: function() {
      var val = readOut.readAll().trim()
      if (val.length > 0) {
        apiKeyInput.text = val
      }
    }
  }

  Component.onCompleted: {
    var dir = pluginApi?.pluginDir || ""
    if (!dir) {
      dir = String(Qt.resolvedUrl(".")).replace("file://", "")
    }
    root.keyFilePath = dir + "/.apikey"

    // Read existing key
    readProc.command = ["sh", "-c", "cat '" + root.keyFilePath + "' 2>/dev/null || true"]
    readProc.running = true
  }
}

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Widgets

ColumnLayout {
  id: root
  property var pluginApi: null

  spacing: Style.marginL

  ColumnLayout {
    spacing: Style.marginS
    Layout.fillWidth: true

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

      onTextChanged: {
        if (pluginApi && root.keyFilePath) {
          pluginApi.pluginSettings.mistralApiKey = text
          writeKeyToFile(text)
        }
      }
    }

    NText {
      text: "Get a key at console.mistral.ai/api-keys"
      color: Color.mOnSurfaceVariant
      pointSize: Style.fontSizeXS
      wrapMode: Text.WordWrap
      Layout.fillWidth: true
    }
  }

  Item { Layout.fillHeight: true }

  NText {
    text: "Dependencies: grim, slurp, wl-copy, curl, jq"
    color: Color.mOnSurfaceVariant
    pointSize: Style.fontSizeXS
  }

  // ── File path ──────────────────────────────────────────────────
  property string keyFilePath: ""

  // ── Write to .apikey file ──────────────────────────────────────
  function writeKeyToFile(key) {
    if (!root.keyFilePath) return
    writeProc.command = ["sh", "-c",
      "printf '%s' '" + key + "' > '" + root.keyFilePath + "' && chmod 600 '" + root.keyFilePath + "'"]
    writeProc.running = true
  }

  function collectorText(collector) {
    return String(collector.text || "").trim()
  }

  Process {
    id: writeProc
    command: []
    running: false
  }

  // ── Load existing key on startup ────────────────────────────────
  Component.onCompleted: {
    var dir = pluginApi?.pluginDir || ""
    if (!dir) {
      dir = String(Qt.resolvedUrl(".")).replace("file://", "")
    }
    root.keyFilePath = dir + "/.apikey"

    // Try pluginSettings first, fall back to .apikey file
    var savedKey = pluginApi?.pluginSettings?.mistralApiKey || ""
    if (savedKey) {
      apiKeyInput.text = savedKey
    } else {
      readProc.command = ["sh", "-c", "cat '" + root.keyFilePath + "' 2>/dev/null || true"]
      readProc.running = true
    }
  }

  Process {
    id: readProc
    command: []
    running: false
    stdout: StdioCollector { id: readOut }

    onExited: function() {
      var val = collectorText(readOut)
      if (val.length > 0) {
        apiKeyInput.text = val
      }
    }
  }
}

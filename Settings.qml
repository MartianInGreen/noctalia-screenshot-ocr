import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Widgets
import qs.Services.UI

Item {
  id: root
  property var pluginApi: null

  // The widget ID being configured (passed by settings system)
  property string widgetId: ""
  property string section: ""
  property int sectionWidgetIndex: -1

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
      text: pluginApi?.pluginSettings?.mistralApiKey || ""
      placeholderText: "sk-..."
      echoMode: TextInput.Password

      onTextChanged: {
        if (pluginApi) {
          pluginApi.pluginSettings.mistralApiKey = text
          pluginApi.saveSettings()
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
}

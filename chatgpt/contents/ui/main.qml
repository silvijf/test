import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kirigami 2.19 as Kirigami

import QtWebEngine 1.9

Item {
  id: root

  property bool pinned: false
  property int focusTimerInterval: 100

  Plasmoid.icon: plasmoid.configuration.icon

  Plasmoid.fullRepresentation: ColumnLayout {
    anchors.fill: parent

    Layout.minimumWidth: 240
    Layout.minimumHeight: 470
    Layout.preferredWidth: 540
    Layout.preferredHeight: 920

    Timer {
      id: focusTimer
      interval: root.focusTimerInterval
      running: false

      onTriggered: {
        chatGptWebView.forceActiveFocus()
        chatGptWebView.focus = true
        chatGptWebView.runJavaScript("tryToFocusPromptInput()")
      }
    }

    Connections {
      target: plasmoid
      onExpandedChanged: {
        if (plasmoid.expanded && chatGptWebView.loadProgress === 100) {
          focusTimer.start()
        }
      }
    }

    // Pinned binding
    onPinnedChanged: plasmoid.hideOnWindowDeactivate = !root.pinned

    // Header
    RowLayout {
      Layout.fillWidth: true
      spacing: Kirigami.Units.mediumSpacing

      Kirigami.Heading {
        text: i18n("ChatGPT")
        Layout.fillWidth: true
      }

      Kirigami.ToolButton {
        icon.name: "view-refresh"
        onClicked: chatGptWebView.reload()
        ToolTip.text: i18n("Refresh")
      }

      Kirigami.ToolButton {
        checkable: true
        checked: root.pinned
        icon.name: "window-pin"
        ToolTip.text: i18n("Pin window")
        onToggled: root.pinned = checked
      }
    }

    // Web view
    WebEngineView {
      id: chatGptWebView
      Layout.fillWidth: true
      Layout.fillHeight: true

      url: "https://chat.openai.com/chat"
      focus: true
      zoomFactor: plasmoid.configuration.zoomFactor

      profile: WebEngineProfile {
        id: chatGptProfile
        storageName: "chatgpt"
        offTheRecord: false
        httpCacheType: WebEngineProfile.DiskHttpCache
        persistentCookiesPolicy: WebEngineProfile.ForcePersistentCookies

        userScripts: [
          WebEngineScript {
            injectionPoint: WebEngineScript.Deferred
            sourceUrl: "./browser/chatgpt.js"
            worldId: WebEngineScript.MainWorld
          }
        ]
      }

      onLoadingChanged: {
        if (loadRequest.status === WebEngineView.LoadSucceededStatus) {
          chatGptWebView.forceActiveFocus()
          chatGptWebView.runJavaScript("tryToFocusPromptInput()")
        }
      }

      onNavigationRequested: {
        const currentUrl = chatGptWebView.url.toString()
        const requestedUrl = request.url.toString()

        if (!currentUrl.startsWith("https://chat.openai.com/c")) {
          return
        }

        if (requestedUrl.includes("openai.com")) {
          request.action = WebEngineView.AcceptRequest
        } else {
          request.action = WebEngineView.IgnoreRequest
          Qt.openUrlExternally(request.url)
        }
      }

      onJavaScriptConsoleMessage: {
        if (!message.startsWith("Refused")) {
          console.debug(`(JS console): ${message}`)
        }
      }
    }
  }
}

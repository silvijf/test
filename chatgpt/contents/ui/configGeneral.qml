import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.19 as Kirigami

Kirigami.FormLayout {
  id: page
  Layout.fillWidth: true

  property alias cfg_icon: plasmoidIcon.icon.name
  property alias cfg_zoomFactor: zoomFactor.value

  // Behavior section
  Item {
    Kirigami.FormData.label: i18n("Behavior")
    Kirigami.FormData.isSection: true
  }

  RowLayout {
    QQC2.Label {
      text: i18n("Zoom Factor:")
    }

    SpinBox {
      id: zoomFactor
      from: 0.1
      to: 3.0
      stepSize: 0.05
      decimals: 2

      ToolTip {
        text: i18n("Zoom factor used to scale the plasmoid")
      }
    }
  }

  Kirigami.Separator {
    Layout.fillWidth: true
    Kirigami.FormData.isSection: true
  }

  // Appearance section
  Item {
    Kirigami.FormData.label: i18n("Appearance")
    Kirigami.FormData.isSection: true
  }

  RowLayout {
    QQC2.Label { text: i18n("Plasmoid Icon:") }

    Kirigami.Button {
      id: plasmoidIcon
      text: i18n("Select Icon")

      onClicked: {
        plasmoidIconDialog.open()
        plasmoidIconDialog.icon = { "name": plasmoidIcon.icon.name }
      }
    }

    Kirigami.IconDialog {
      id: plasmoidIconDialog
      property var icon
    }
  }
}

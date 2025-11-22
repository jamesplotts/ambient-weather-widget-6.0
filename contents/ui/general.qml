import QtQuick
import QtQuick.Controls as QQC
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.ScrollablePage {

    property alias cfg_apiKey: apiKeyField.text
    property alias cfg_applicationKey: appKeyField.text
    property alias cfg_macAddress: macAddressField.text

    Kirigami.FormLayout {

        QQC.TextField {
            id: apiKeyField
            Kirigami.FormData.label: "API Key:"
            placeholderText: "Enter your Ambient Weather API Key"
            width: 300
        }

        QQC.TextField {
            id: appKeyField
            Kirigami.FormData.label: "Application Key:"
            placeholderText: "Enter your Ambient Weather Application Key"
            width: 300
        }

        QQC.TextField {
            id: macAddressField
            Kirigami.FormData.label: "MAC Address:"
            placeholderText: "XX:XX:XX:XX:XX:XX"
            width: 300
        }

        QQC.Label {
            text: "Note: You can find these keys in your Ambient Weather account settings."
            font.italic: true
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }
    }
}

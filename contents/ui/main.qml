import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore

PlasmoidItem {
    id: root

    // Data properties
    property string temperature: "--"
    property string feelsLike: "--"
    property string humidity: "--"
    property string windSpeed: "--"
    property string windDir: ""
    property string lastUpdated: "Never"
    property bool loading: false
    property string errorMessage: ""

    property string debugInfo: ""

    // Configuration properties
    readonly property string apiKey: Plasmoid.configuration.apiKey
    readonly property string appKey: Plasmoid.configuration.applicationKey
    readonly property string macAddress: Plasmoid.configuration.macAddress

    // Main Timer - 60 seconds interval (Rate Limiting)
    Timer {
        id: refreshTimer
        interval: 60000 // 1 minute
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: fetchData()
    }

    function fetchData() {
        var cleanApiKey = apiKey ? apiKey.trim() : "";
        var cleanAppKey = appKey ? appKey.trim() : "";

        debugInfo = "Fetching... Key: " + (cleanApiKey ? cleanApiKey.substring(0, 4) + "..." : "None");

        if (!cleanApiKey || !cleanAppKey) {
            errorMessage = "Please configure API keys.";
            debugInfo += " | Missing Keys";
            return;
        }

        loading = true;
        errorMessage = ""; // Clear previous errors

        var xhr = new XMLHttpRequest();
        var url = "https://api.ambientweather.net/v1/devices?applicationKey=" + cleanAppKey + "&apiKey=" + cleanApiKey;
        
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                loading = false;
                debugInfo += " | Status: " + xhr.status + " | Len: " + xhr.responseText.length;
                
                if (xhr.status === 200) {
                    try {
                        var response = JSON.parse(xhr.responseText);
                        processData(response);
                    } catch (e) {
                        errorMessage = "Error parsing data";
                        debugInfo += " | Parse Error: " + e.message;
                        console.error("JSON Parse Error:", e);
                    }
                } else {
                    errorMessage = "API Error: " + xhr.status + " " + xhr.statusText;
                    debugInfo += " | API Fail";
                    console.error("API Error:", xhr.responseText);
                }
            }
        }
        
        xhr.open("GET", url);
        xhr.send();
    }

    function processData(devices) {
        if (devices.error) {
             errorMessage = "API Message: " + devices.error;
             debugInfo += " | API Error Msg";
             return;
        }

        if (!Array.isArray(devices) || devices.length === 0) {
            errorMessage = "No devices found on account.";
            debugInfo += " | No Devices";
            return;
        }

        var device = null;
        var cleanMac = macAddress ? macAddress.trim().replace(/:/g, "").toLowerCase() : "";

        if (cleanMac) {
            // Find device by MAC (normalized)
            for (var i = 0; i < devices.length; i++) {
                var devMac = devices[i].macAddress ? devices[i].macAddress.replace(/:/g, "").toLowerCase() : "";
                if (devMac === cleanMac) {
                    device = devices[i];
                    break;
                }
            }
            if (!device) {
                errorMessage = "Device with MAC " + macAddress + " not found.";
                debugInfo += " | MAC Not Found";
                return; 
            }
        } else {
            // Default to first device
            device = devices[0];
        }

        if (device && device.lastData) {
            var data = device.lastData;
            temperature = Math.round(data.tempf) + "°";
            feelsLike = Math.round(data.feelsLike) + "°F";
            humidity = data.humidity + "%";
            windSpeed = Math.round(data.windspeedmph) + " mph";
            windDir = degreesToCardinal(data.winddir);
            
            var date = new Date(data.date);
            lastUpdated = date.toLocaleTimeString(Qt.locale(), Locale.ShortFormat);
            errorMessage = ""; // Clear error on success
            debugInfo += " | Success";
        } else {
            errorMessage = "Device found but no weather data available.";
            debugInfo += " | No Data";
        }
    }

    function degreesToCardinal(degrees) {
        const cardinals = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"];
        var val = Math.floor((degrees / 22.5) + 0.5);
        return cardinals[val % 16];
    }

    preferredRepresentation: Plasmoid.CompactRepresentation

    // Compact Representation (The Widget on the Panel/Desktop)
    compactRepresentation: Item {
        Layout.minimumWidth: tempLabel.implicitWidth + Kirigami.Units.largeSpacing
        Layout.minimumHeight: tempLabel.implicitHeight + Kirigami.Units.largeSpacing

        PlasmaComponents.Label {
            id: tempLabel
            anchors.centerIn: parent
            text: root.temperature
            font.pointSize: 24 // Make it big like the image
            font.bold: true
        }
        
        MouseArea {
            anchors.fill: parent
            onClicked: root.expanded = !root.expanded
        }
    }

    fullRepresentation: Item {
        Layout.preferredWidth: 300
        Layout.preferredHeight: 200
        width: 300
        height: 200
        
        Rectangle {
            anchors.fill: parent
            color: Kirigami.Theme.backgroundColor
            opacity: 0.9
            radius: 5
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Kirigami.Units.largeSpacing
                
                RowLayout {
                    Layout.fillWidth: true
                    PlasmaComponents.Label {
                        text: deviceName()
                        font.bold: true
                        font.pointSize: 12
                        Layout.fillWidth: true
                    }
                    PlasmaComponents.Button {
                        icon.name: "view-refresh"
                        text: "Refresh"
                        onClicked: fetchData()
                        Layout.preferredHeight: Kirigami.Units.gridUnit * 1.5
                    }
                }
                
                PlasmaComponents.Label {
                    text: "Temperature: " + root.temperature + "F"
                }
                
                PlasmaComponents.Label {
                    text: "Feels like " + root.feelsLike
                }
                
                PlasmaComponents.Label {
                    text: "Humidity: " + root.humidity
                }
                
                PlasmaComponents.Label {
                    text: "Wind: " + root.windSpeed + " " + root.windDir
                }
                
                RowLayout {
                    Layout.fillWidth: true
                    PlasmaComponents.Label {
                        text: "Updated: " + root.lastUpdated
                        font.pointSize: 8
                        opacity: 0.7
                    }
                    Item { Layout.fillWidth: true }
                    PlasmaComponents.BusyIndicator {
                        running: root.loading
                        visible: root.loading
                        Layout.preferredHeight: Kirigami.Units.gridUnit
                        Layout.preferredWidth: Kirigami.Units.gridUnit
                    }
                }
                
                // Debug Info Label
                PlasmaComponents.Label {
                    text: root.debugInfo
                    font.pointSize: 7
                    opacity: 0.6
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }
                
                Item { Layout.fillHeight: true } // Spacer
                
                PlasmaComponents.Label {
                    visible: root.errorMessage !== ""
                    text: root.errorMessage
                    color: Kirigami.Theme.negativeTextColor
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }
            }
        }
    }
    
    function deviceName() {
        // Could fetch this from API too, but for now hardcode or use generic
        return "Ambient Weather Station";
    }

    Component.onCompleted: {
        // Initial fetch
        fetchData();
    }
    
    Connections {
        target: Plasmoid.configuration
        function onApiKeyChanged() { fetchData(); }
        function onApplicationKeyChanged() { fetchData(); }
        function onMacAddressChanged() { fetchData(); }
    }
}

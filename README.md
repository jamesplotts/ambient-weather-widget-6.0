# Ambient Weather Station Widget 6.0

A KDE Plasma 6 widget that displays real-time weather data from your personal Ambient Weather station.

## Features
- **Compact View**: Displays current temperature on your panel or desktop.
- **Detailed Popup**: Hover or click to see:
  - Temperature & Feels Like
  - Humidity
  - Wind Speed & Direction
  - Last Update Time
- **Real-time Updates**: Fetches data every 60 seconds.
- **Debug Mode**: Built-in debug information to help troubleshoot API connection issues.

## Installation

### From .plasmoid file
1.  Download `com.ambientweather.widget.plasmoid`.
2.  Run the following command:
    ```bash
    kpackagetool6 -i com.ambientweather.widget.plasmoid
    ```
    (If upgrading, use `-u` instead of `-i`).

### From Source
1.  Clone this repository.
2.  Zip the contents (excluding git files):
    ```bash
    zip -r com.ambientweather.widget.plasmoid *
    ```
3.  Install using `kpackagetool6`.

## Configuration
1.  Right-click the widget and select **Configure Ambient Weather Monitor...**.
2.  Enter your **API Key** and **Application Key** from your [Ambient Weather Account](https://ambientweather.net/account).
3.  (Optional) Enter your **MAC Address** if you have multiple devices. If left blank, it defaults to the first device found.
4.  Click **Apply**.

## Troubleshooting
The widget includes a debug line in the popup (e.g., `Status: 200 | Len: 1543 | Success`).
- **Status: 401**: Unauthorized. Check your API and Application keys.
- **Status: 0**: Network error. Check your internet connection.
- **Key: None**: Keys are not saved. Go to configuration and save them again.

## License
This project is licensed under the GPL-2.0 License - see the [LICENSE](LICENSE) file for details.

# 🌿 ESP32 Smart Irrigation System

An automated smart irrigation system built on the ESP32 microcontroller. This project integrates a Flutter mobile application to control watering, monitor sensor data, and display real-time weather information.

## ✨ Features

* **Automated Watering:** The ESP32 reads real-time data from soil moisture and temperature sensors to automatically trigger irrigation.
* **Mobile Control:** A full-stack Flutter application provides remote control to manually start or stop watering.
* **Real-time Monitoring:** View live soil moisture, temperature, and other sensor data directly from the mobile app.
* **Live Weather Updates:** The application displays current weather conditions and forecasts to help optimize irrigation schedules.
* **Efficient Resource Usage:** The system conserves water by only irrigating when necessary, based on environmental conditions.

## 🛠️ Technologies Used

| Technology | Purpose |
| :--- | :--- |
| **Flutter** | Frontend for the mobile application |
| **Dart** | Language for the Flutter application |
| **Python** | Backend processing (e.g., for APIs) |
| **ESP32** | Microcontroller for hardware control |
| **Firebase** | Backend services for data storage and authentication |
| **Sensors** | Soil Moisture Sensor, DHT11 Temperature Sensor |

<p align="left">
  <a href="https://flutter.dev/" target="_blank" rel="noreferrer"><img src="https://raw.githubusercontent.com/danielcranney/readme-generator/main/public/icons/skills/flutter-colored.svg" alt="Flutter" title="Flutter" width="36" height="36" /></a>
  <a href="https://dart.dev/" target="_blank" rel="noreferrer"><img src="https://raw.githubusercontent.com/danielcranney/readme-generator/main/public/icons/skills/dart-colored.svg" alt="Dart" title="Dart" width="36" height="36" /></a>
  <a href="https://www.python.org/" target="_blank" rel="noreferrer"><img src="https://raw.githubusercontent.com/danielcranney/readme-generator/main/public/icons/skills/python-colored.svg" alt="Python" title="Python" width="36" height="36" /></a>
  <a href="https://firebase.google.com/" target="_blank" rel="noreferrer"><img src="https://raw.githubusercontent.com/danielcranney/readme-generator/main/public/icons/skills/firebase-colored.svg" alt="Firebase" title="Firebase" width="36" height="36" /></a>
</p>

## 🚀 Getting Started

### Prerequisites

* **Hardware:**
    * ESP32 Microcontroller
    * Soil Moisture Sensor
    * Temperature Sensor (e.g., DHT11)
    * Water Pump
    * Transistor/Relay Module
    * Breadboard and jumper wires
* **Software:**
    * Arduino IDE or PlatformIO
    * Flutter SDK

### ⚙️ Hardware Setup

1.  **Connect the sensors:** Wire the soil moisture and temperature sensors to the ESP32 according to the provided schematics.
2.  **Connect the pump:** Connect the water pump to the ESP32 via a transistor or relay module to control the power supply.
3.  **Power:** Power the ESP32 and the pump using a suitable power source.

### 💻 Software Setup

#### 1. ESP32 Code

1.  Open the `ESP32_code/ESP32_code.ino` file in your Arduino IDE.
2.  Configure your Wi-Fi credentials and Firebase settings in the code.
3.  Upload the code to your ESP32 board.

#### 2. Flutter Application

1.  Navigate to the `flutter_code` directory.
2.  Install dependencies:
    ```bash
    flutter pub get
    ```
3.  Run the application on a connected device or emulator:
    ```bash
    flutter run
    ```
4.  Follow the on-screen instructions to connect to your ESP32.

## 🤝 Contribution

Contributions are welcome! If you have suggestions or want to improve the project, feel free to open an issue or submit a pull request.


## 👨‍💻 Author

**Aviral Gokhale**
* [GitHub Profile](https://github.com/Aviral-Gokhale)
* [LinkedIn Profile](https://www.linkedin.com/in/aviral-gokhale-b9b531225/)

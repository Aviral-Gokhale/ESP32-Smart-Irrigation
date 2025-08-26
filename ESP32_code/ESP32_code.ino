#include <DHT.h>
#include <WiFi.h>
#include <AsyncTCP.h>
#include <ESPAsyncWebServer.h>
#include <AsyncWebSocket.h>
#include <ArduinoJson.h>

// Pin Definitions
#define SOIL_MOISTURE_PIN 34  // Analog pin for soil moisture sensor
#define RELAY_PIN 26          // Digital pin for relay (Pump control)
#define DHTPIN 4              // Digital pin for DHT sensor
#define DHTTYPE DHT11         // Change to DHT22 if using that sensor

// Moisture Thresholds (Set based on sensor calibration)
#define DRY_VALUE 800       // Value when soil is completely dry
#define WET_VALUE 300       // Value when soil is fully wet
#define MOISTURE_THRESHOLD 30  // Below this percentage → Pump ON

// WiFi Credentials
#define WIFI_SSID "ID"
#define WIFI_PASSWORD "PWD"

// Initialize DHT Sensor
DHT dht(DHTPIN, DHTTYPE);

// Set up WebSocket server on port 80 at path "/ws"
AsyncWebServer server(80);
AsyncWebSocket ws("/ws");

void onWebSocketEvent(AsyncWebSocket *server, AsyncWebSocketClient *client, AwsEventType type,
                        void *arg, uint8_t *data, size_t len) {
  switch (type) {
    case WS_EVT_CONNECT:
      Serial.printf("WebSocket client #%u connected from %s\n", client->id(), client->remoteIP().toString().c_str());
      break;
    case WS_EVT_DISCONNECT:
      Serial.printf("WebSocket client #%u disconnected\n", client->id());
      break;
    case WS_EVT_DATA:
      Serial.printf("WebSocket client #%u received data: %s\n", client->id(), (char *)data);
      break;
    case WS_EVT_PONG:
      Serial.printf("WebSocket client #%u received pong\n", client->id());
      break;
    case WS_EVT_ERROR: {
      uint16_t errorCode = arg ? *(uint16_t *)arg : 0;
      Serial.printf("WebSocket client #%u error: %u, %s\n", client->id(), errorCode, (char *)data);
    } break;
  }
}

void setup() {
  Serial.begin(115200);
  delay(1000); // Allow time for Serial Monitor to start

  // Initialize sensor pins
  pinMode(SOIL_MOISTURE_PIN, INPUT);
  pinMode(RELAY_PIN, OUTPUT);
  digitalWrite(RELAY_PIN, HIGH); // Ensure pump is OFF at start

  dht.begin();

  Serial.println("\nStarting...");

  // Connect to WiFi
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to WiFi");
  int attempts = 0;
  while (WiFi.status() != WL_CONNECTED && attempts < 20) { // Try for 10 seconds
    delay(500);
    Serial.print(".");
    attempts++;
  }

  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("\nWiFi Connected!");
    Serial.print("IP Address: ");
    Serial.println(WiFi.localIP());

    // Initialize WebSocket event handler
    ws.onEvent(onWebSocketEvent);
    server.addHandler(&ws);
    server.begin();
    Serial.println("WebSocket server started");
  } else {
    Serial.println("\nWiFi connection failed!");
    while (1) {
      delay(1000);
      Serial.println("Restarting in 1 second");
      ESP.restart();
    }
  }
}

void loop() {
  // Read raw soil moisture value and convert to percentage
  int moistureValue = analogRead(SOIL_MOISTURE_PIN);
  int moisturePercentage = map(moistureValue, DRY_VALUE, WET_VALUE, 0, 100);
  moisturePercentage = constrain(moisturePercentage, 0, 100);

  // Read soil_temp and humidity from DHT sensor
  float soil_temp = dht.readsoil_temp();
  float humidity = dht.readHumidity();

  Serial.print("Soil Moisture: ");
  Serial.print(moisturePercentage);
  Serial.println("%");

  if (!isnan(soil_temp) && !isnan(humidity)) {
    Serial.print("soil_temp: ");
    Serial.print(soil_temp);
    Serial.print(" °C | Humidity: ");
    Serial.print(humidity);
    Serial.println(" %");
  } else {
    Serial.println("Failed to read from DHT sensor!");
  }

  // Pump control based on moisture percentage
  if (moisturePercentage < MOISTURE_THRESHOLD) {
    Serial.println("Soil is dry. Turning ON pump.");
    digitalWrite(RELAY_PIN, LOW);  // Relay active LOW
  } else {
    Serial.println("Soil has enough moisture. Turning OFF pump.");
    digitalWrite(RELAY_PIN, HIGH);
  }

  // Send sensor data over WebSocket
  sendSensorData(moisturePercentage, soil_temp, humidity);

  ws.cleanupClients();
  delay(5000); // Wait 5 seconds before next reading
}

void sendSensorData(int moisturePercentage, float soil_temp, float humidity) {
  // Prepare JSON document to send over WebSocket
  StaticJsonDocument<256> doc;
  doc["moisture"] = moisturePercentage;
  doc["soil_temp"] = soil_temp;
  doc["humidity"] = humidity;
  doc["pump_state"] = (moisturePercentage < MOISTURE_THRESHOLD) ? "ON" : "OFF";

  String jsonString;
  serializeJson(doc, jsonString);

  ws.textAll(jsonString);
  Serial.print("Sending WebSocket data: ");
  Serial.println(jsonString);
}

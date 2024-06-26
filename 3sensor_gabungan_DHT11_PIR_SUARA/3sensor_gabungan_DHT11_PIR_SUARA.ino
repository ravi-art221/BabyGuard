#include <ESP8266WiFi.h>
#include <WiFiManager.h>
#include <DHT.h>
#include <WebSocketsServer.h>

#define DHTPIN D4
#define DHTTYPE DHT11
#define PIR_PIN D6
#define LED_PIN D13
#define SOUND_SENSOR_PIN D2
#define SOUND_LED_PIN D11

DHT dht(DHTPIN, DHTTYPE);
WebSocketsServer webSocket = WebSocketsServer(81);

bool motionDetected = false;
bool pirLedOn = false;
bool soundLedOn = false;
unsigned long led_on_time = 0;
unsigned long led_off_time = 0;
const unsigned long on_duration = 10000; // Duration LED on (10 seconds)
const unsigned long off_duration = 5000; // Duration LED off (5 seconds)

void handleWebSocketMessage(uint8_t num, WStype_t type, uint8_t * payload, size_t length) {
  // Handle messages from the WebSocket
}

void setup() {
  Serial.begin(9600);
  pinMode(PIR_PIN, INPUT);
  pinMode(LED_PIN, OUTPUT);
  pinMode(SOUND_SENSOR_PIN, INPUT);
  pinMode(SOUND_LED_PIN, OUTPUT);

  dht.begin();

  WiFiManager wifiManager;
  wifiManager.resetSettings();
  wifiManager.autoConnect("AutoConnectAP");

  webSocket.begin();
  webSocket.onEvent(handleWebSocketMessage);
  Serial.println("WebSocket server started");
}

void loop() {
  webSocket.loop();

  // Read PIR sensor state
  int pirState = digitalRead(PIR_PIN);

  if (pirState == HIGH) {
    Serial.println("Motion detected!");
    motionDetected = true;
    pirLedOn = true;
  } else {
    Serial.println("No motion detected");
    motionDetected = false;
    pirLedOn = false;
  }

  digitalWrite(LED_PIN, pirLedOn ? HIGH : LOW);

  // Read sound sensor state
  int soundData = digitalRead(SOUND_SENSOR_PIN);

  if (soundData == 1 && !soundLedOn) {
    digitalWrite(SOUND_LED_PIN, HIGH);
    soundLedOn = true;
    led_on_time = millis();
  }

  if (soundLedOn && millis() - led_on_time < on_duration) {
    Serial.println("Sound detected!"); // Output sound detected when sound is detected
  }

  if (soundLedOn && millis() - led_on_time >= on_duration) {
    digitalWrite(SOUND_LED_PIN, LOW);
    soundLedOn = false;
    led_off_time = millis();
  }

  if (!soundLedOn && millis() - led_off_time >= off_duration) {
    Serial.println("No sound detected"); // Output no sound detected when no sound is detected
  }

  // Reading temperature and humidity
  float humidity = dht.readHumidity();
  float temperature = dht.readTemperature();

  // Check if any reads failed and exit early
  if (!isnan(humidity) && !isnan(temperature)) {
    Serial.print(F("Humidity: "));
    Serial.print(humidity);
    Serial.print(F("%\tTemperature: "));
    Serial.println(temperature);

    String soundStatus = (soundData == 1) ? "Sound Detected" : "No Sound";
    String data = "{\"temperature\": " + String(temperature) + ", \"humidity\": " + String(humidity) + ", \"motion\": " + (motionDetected ? "true" : "false") + ", \"sound\": \"" + soundStatus + "\"}";
    webSocket.broadcastTXT(data);
  } else {
    Serial.println(F("Failed to read from DHT sensor!"));
  }

  delay(1000);
}

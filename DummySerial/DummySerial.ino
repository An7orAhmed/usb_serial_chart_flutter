
void setup() {
  Serial.begin(115200);
  randomSeed(analogRead(34));  // I used ESP32, A0 for arduino boards
}

void loop() {
  float volt = random(0, 500) / 100.0;
  Serial.println(volt);
  delay(500);
}

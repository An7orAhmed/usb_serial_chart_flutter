
int x = 0;

void setup() {
  Serial.begin(115200);
  randomSeed(analogRead(34));  // I used ESP32, A0 for arduino boards
}

void loop() {
  float volt = x / 100.0;
  Serial.println(volt);
  delay(2);
  x++;
  if(x >= 500) x = 0; 
}

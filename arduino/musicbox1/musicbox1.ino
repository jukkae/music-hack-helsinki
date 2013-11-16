int pin = 2;

void setup() {
  Serial.begin(9600);
  while (!Serial);
}
void loop()
{
  Serial.println(analogRead(pin));  // Output measurement
  delay(50);
}











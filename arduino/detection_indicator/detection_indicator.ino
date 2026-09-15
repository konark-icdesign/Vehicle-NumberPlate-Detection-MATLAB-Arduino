/*
  MATLAB vehicle / number-plate detection indicator

  MATLAB sends one byte:
    'V' -> vehicle detected
    'P' -> plate candidate detected
    'N' -> no active detection

  Hardware:
    vehicle LED  -> digital pin 8 through ~220 ohm resistor
    plate LED    -> digital pin 9 through ~220 ohm resistor
    optional buzzer -> digital pin 10
*/

const int vehicleLed = 8;
const int plateLed = 9;
const int buzzerPin = 10;

void setup() {
  pinMode(vehicleLed, OUTPUT);
  pinMode(plateLed, OUTPUT);
  pinMode(buzzerPin, OUTPUT);

  digitalWrite(vehicleLed, LOW);
  digitalWrite(plateLed, LOW);
  digitalWrite(buzzerPin, LOW);

  Serial.begin(9600);
}

void loop() {
  if (Serial.available() <= 0) {
    return;
  }

  const char command = Serial.read();

  switch (command) {
    case 'V':
      digitalWrite(vehicleLed, HIGH);
      digitalWrite(plateLed, LOW);
      digitalWrite(buzzerPin, LOW);
      break;

    case 'P':
      digitalWrite(vehicleLed, HIGH);
      digitalWrite(plateLed, HIGH);
      digitalWrite(buzzerPin, HIGH);
      delay(80);
      digitalWrite(buzzerPin, LOW);
      break;

    case 'N':
    default:
      digitalWrite(vehicleLed, LOW);
      digitalWrite(plateLed, LOW);
      digitalWrite(buzzerPin, LOW);
      break;
  }
}

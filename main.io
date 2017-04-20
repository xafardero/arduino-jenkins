#include <SPI.h>
#include <Ethernet.h>

byte mac[] = {0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED};
IPAddress ip(192, 168, 0, 33);
IPAddress myDns(8, 8, 8, 8);
EthernetClient client;

char server[] = "JENKINS-URL";
unsigned long lastConnectionTime = 0;             // last time you connected to the server, in milliseconds
const unsigned long postingInterval = 10L * 500L; // delay between updates, in milliseconds  the "L" is needed to use long type numbers

int PIN_RED_LED = 4;
int PIN_GREEN_LED = 2;
int PIN_YELLOW_LED = 3;

String readString = String(100);

void setup() {
  Serial.begin(9600);
  while (!Serial) { ; }

  delay(1000);
  
  configurePINs();
  setSignalYellow();
  
  Ethernet.begin(mac, ip, myDns);
  //Serial.print("My IP address: ");
  //Serial.println(Ethernet.localIP());
}

void loop() {
  if (client.available()) {
    char c = client.read();
    Serial.write(c);
    readString.concat(c);
  }

  // if ten seconds have passed since your last connection,
  // then connect again and send data:
  if (millis() - lastConnectionTime > postingInterval) {
     bool isSuccessful = readString.indexOf("SUCCESS") > -1;
      readString.remove(0);
      if (isSuccessful) {
        //Serial.write("GREEN");
         setSignalGreen();
      } else {
         //Serial.write("RED");
         setSignalRed();
      }
    httpRequest();
  }

}

// this method makes a HTTP connection to the server:
void httpRequest() {
  // close any connection before send a new request.
  // This will free the socket on the WiFi shield
  client.stop();

  // if there's a successful connection:
  if (client.connect(server, 8080)) {
    Serial.println("connecting...");
    // send the HTTP GET request:
    client.println("GET /job/{project}/lastBuild/api/json?tree=result HTTP/1.1");
    client.println("Authorization: Basic {Base64 user:token}"); 
    client.println("Host: JENKINS-HOST");

    client.println("Connection: close");
    client.println();

    // note the time that the connection was made:
    lastConnectionTime = millis();
  } else {
    // if you couldn't make a connection:
    Serial.println("connection failed");
  }
}


void configurePINs()
{
   pinMode(PIN_GREEN_LED, OUTPUT);
   pinMode(PIN_RED_LED, OUTPUT);
   pinMode(PIN_YELLOW_LED, OUTPUT);
}

void setSignalYellow()
{
   digitalWrite(PIN_GREEN_LED, LOW);
   digitalWrite(PIN_YELLOW_LED, HIGH);
   digitalWrite(PIN_RED_LED, LOW);
}
void setSignalRed()
{
   digitalWrite(PIN_GREEN_LED, LOW);
   digitalWrite(PIN_YELLOW_LED, LOW);
   digitalWrite(PIN_RED_LED, HIGH);
}
void setSignalGreen()
{
   digitalWrite(PIN_RED_LED, LOW);
   digitalWrite(PIN_YELLOW_LED, LOW);
   digitalWrite(PIN_GREEN_LED, HIGH);
}
void setAllSignalsOff()
{
   digitalWrite(PIN_RED_LED, HIGH);
   digitalWrite(PIN_YELLOW_LED, HIGH);
   digitalWrite(PIN_GREEN_LED, HIGH);   
}

#include <ESP8266WiFi.h>
#include <Firebase_ESP_Client.h>
#include <ArduinoJson.h> 
#include "addons/TokenHelper.h"
#include "addons/RTDBHelper.h"
#include <time.h>

#define API_KEY "AIzaSyAygTXVYk-30pA_9-Kar_CZxlxiCjsrzzc"
#define DATABASE_URL "https://smartenergi-56048-default-rtdb.firebaseio.com/"

FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;
bool authOK = false;
bool signupOK = false;

const char* ntpServer1 = "pool.ntp.org";
const char* ntpServer2 = "time.nist.gov";
const long  gmtOffset_sec = 5.5 * 3600; // Adjust based on your timezone
const int   daylightOffset_sec = 0;      // Adjust based on your timezone's daylight saving time

bool isFirstIteration = true; // Flag to indicate the first iteration

const char *ssid = "SLT_FIBRE 256";
const char *password = "Shan1234";

// Service account credentials
const char *serviceAccountClientEmail = "firebase-adminsdk-5hiwl@smartenergi-56048.iam.gserviceaccount.com";
const char *serviceAccountPrivateKey = "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDB/6FTiBM1ylAz\nc5BKAGPdh5M1WXaOpe/y1Ro4hzXqmf5wvD+cC42Y51S129HIJJktxWNdZN0LxH3t\nmFZY0kySzyGyD+DOYoeRe3tEQIZDkN4Xwz4W2p+55U3ON8srae13WBgmD/16cHgS\ntoooSJ4u1vdwFNYwrJ+gE066Jw6ciwaZrFyC6YU3vBVXr5d2Icd+qvUPYaYN6pyk\nIkhLYTXZjJOxmqcDJlabE/mhHopNUBP8QEEk+Y01BwzpTleqKosu+Xv/95fkuF6a\nA7vvOyNxAdqe3PKbxN1lTACgfXYe28xU/VTcz8eV2/Qyo3ambpt3OCkv81Kp9csn\nQM7jgR17AgMBAAECggEAXrPEFMtqGUmccil5Z+6d0aBjx9jW69bsdh36cVrsAozP\nLUhwQuRO6LQQ4cAfvfTDxBjGI2rgD2UJ1kkV6cEreUVdHRfsNcPaizX83DolcOlQ\nycfZUP3DmFNscn1BFH3e2vIpw7btle4+Z2AtvHGKqrHs042Qa+1w9QtH1M7JLrhC\nJenpDTUCSWRdv7J4boIKsOwhmCCpogCnUH4SRgX05CGausLdJp4u1qG4yedfSC0N\nItt1czyd0EDF9MQk1FWvEbD9imbHxNazjijEYMB9kpvX87absI1hkqotx0INLmsk\noPahB82RQsuAeyJTleAV8e24Img1KAU3ywA0kKh73QKBgQD8iBn9qTSm9V9pwL6h\n+v+nzIcKqbNexpzSVrlbJt7FkwZh4iDHC62T+QPHshH3WZ6RePsRJw59ER+f5PY7\nFgllH7cSZY7YmkyCqJLk3agk3QVRTjEg5gRqtkMrcP0A618mGzAJqRTNKKBOTaN8\nimRc1W7VpyoNm/bFDiI4B6M0nwKBgQDEqboZoBCEiftHP+Ukot7uM1cKGkDHV92O\nsft7iQTtBBnFMKh5eIb865JvKLzDB+Mw4ulzlg2nneZgPNczXj6oBu3SpQdycp97\n7gNuH7fz1788zwlLOqqU9JSulsmQPVzVXzqICnbEBuxEaBaSkVFxWgxdkliAuAVj\nBavDCMftpQKBgQCDr3lWNGkXczbZD8CY+Sld2CLHZaz6jDl02fJ4XPGoN74JRwDu\nquFOG3lkJjCGOr6cf2j1DdfZUheaqqvYLeqiSAKQXlM6EmQ5cix/mjK3XmYKeurV\ni/zbpMWsHpRgaVzJoz3Om9QUE85cZtIM/KHPYyET2sLsK9tn8LHZY+owYwKBgGW5\nUSyuEb0szg/1qeYAZQWbAruUBsvV1CFaSLWGk0ix5U6NM6fZQyGSDGV5EeJjsw13\nYb/K7vczgpVnAv1sE0bAhsV9XVPCnGHzJE0TFQiJIT8n7CvAhbmUpU+FaW81fk5T\n+qehmfsdhZqAqKRZjGHwbRL9fs/d39NvfH/ei+ONAoGBAJiib5YRVF/07FW6BW6B\n4J+rcl4AsDeQjwtIpgoaFxxvwqbHNhW06mflVIDqY2VGXEdREYiPPB0mmbjodt9u\nxpwovH0JoOsI5FZfqo+PtdDKEZyTwgnH4GmHnHvFZ4junFn3RP24ks3U0ap66pTF\ncrQjDmYoOQsrXSimzrot3hf8\n-----END PRIVATE KEY-----\n";

void synchronizeTime(); // Function prototype

void setup() {
  Serial.begin(9600);

  // Connect to Wi-Fi
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(250);
    Serial.print(".");
  }
  Serial.println("\nConnected to Wi-Fi");

  // Initialize Firebase
  config.api_key = API_KEY;
  config.database_url = DATABASE_URL;

  // Sign up with Firebase admin credentials
  if (Firebase.signUp(&config, &auth, serviceAccountClientEmail, serviceAccountPrivateKey)) {
    Serial.println("Firebase admin signup successful");
    signupOK = true;
    config.token_status_callback = tokenStatusCallback;
    Firebase.begin(&config, &auth);
    Firebase.reconnectWiFi(true);
  } else {
    // Authenticate with Firebase user credentials
    auth.user.email = serviceAccountClientEmail;
    auth.user.password = serviceAccountPrivateKey;
    Firebase.begin(&config, &auth);
    unsigned long start = millis();
    while (!Firebase.ready()) {
      if (millis() - start > 100000000) {
        Serial.println("Authentication timeout");
        break;
      }
      delay(500);
    }
    if (Firebase.ready()) {
      Serial.println("Firebase authenticated successfully");
      authOK = true;
    } else {
      Serial.println("Failed to authenticate Firebase");
    }
  }

  // Synchronize time with NTP server
  synchronizeTime();
}

float x = 0;

void loop() {
  // Your loop code here
  // This loop will print the current time every second

  if (authOK || signupOK) {
    // Fetch data from Firebase RTDB
    if (Firebase.RTDB.getFloat(&fbdo, "/ESPmodules/XQCTF/Index")) {
      Serial.println("Data fetched successfully");
      int fetchedValue = fbdo.floatData();
      Serial.println("Fetched value: " + String(fetchedValue));

      // Increment fetched value
      fetchedValue++;

      // Fetch device information from Firestore
      if (Firebase.Firestore.getDocument(&fbdo, "smartenergi-56048", "", "System-Verified-Modules/XQCTF")) {
        Serial.println("Document fetched successfully");

        DynamicJsonDocument doc(1024);
        deserializeJson(doc, fbdo.payload());
        String currentlyConnected = doc["fields"]["CurrentlyConnected"]["stringValue"];
        Serial.print("CurrentlyConnected: ");
        Serial.println(currentlyConnected);

        // Construct path with device information and current timestamp
        String dateTimeString = getCurrentDateTimeString();
        String paddedFetchedValue;
        if (fetchedValue < 10) {
          paddedFetchedValue = "0000000" + String(fetchedValue); // Pad with seven leading zeros
        } else if (fetchedValue < 100) {
          paddedFetchedValue = "000000" + String(fetchedValue); // Pad with six leading zeros
        } else if (fetchedValue < 1000) {
          paddedFetchedValue = "00000" + String(fetchedValue); // Pad with five leading zeros
        } else if (fetchedValue < 10000) {
          paddedFetchedValue = "0000" + String(fetchedValue); // Pad with four leading zeros
        } else if (fetchedValue < 100000) {
          paddedFetchedValue = "000" + String(fetchedValue); // Pad with three leading zeros
        } else if (fetchedValue < 1000000) {
          paddedFetchedValue = "00" + String(fetchedValue); // Pad with two leading zeros
        } else if (fetchedValue < 10000000) {
          paddedFetchedValue = "0" + String(fetchedValue); // Pad with one leading zero
        } else {
          paddedFetchedValue = String(fetchedValue); // No padding needed
        }
        String devicePath = "ESPmodules/XQCTF/Devices/" + currentlyConnected + "/" + paddedFetchedValue + "-" + dateTimeString;

        // Send data to Firebase RTDB
        if (Firebase.RTDB.setFloat(&fbdo, "ESPmodules/XQCTF/CurrentValue", x)) {
          Serial.println("Data sent successfully");
        } else {
          Serial.println("Failed to send data");
          Serial.println(fbdo.errorReason());
        }

        // Send data to specific device path
        if (Firebase.RTDB.setFloat(&fbdo, devicePath.c_str(), x)) {
          Serial.println("Data sent successfully");
        } else {
          Serial.println("Failed to send data");
          Serial.println(fbdo.errorReason());
        }

        // Update the index value in Firebase
        if (Firebase.RTDB.setFloat(&fbdo, "/ESPmodules/XQCTF/Index", fetchedValue)) {
          Serial.println("Index updated successfully");
        } else {
          Serial.println("Failed to update index");
          Serial.println(fbdo.errorReason());
        }
      } else {
        Serial.println("Failed to get document");
        Serial.println(fbdo.errorReason());
      }

      delay(1000);
      x++;
       // Wait 1 second before next iteration
    }
  }
}

// Function to synchronize time with NTP server
void synchronizeTime() {
  configTime(gmtOffset_sec, daylightOffset_sec, ntpServer1, ntpServer2);
  Serial.println("\nWaiting for Internet time");
  time_t now = time(nullptr);
  while (now < 24 * 3600) {
    delay(500);
    Serial.print(".");
    now = time(nullptr);
  }
  Serial.println("\nTime synchronized");
}

// Function to get current date-time string
String getCurrentDateTimeString() {
  time_t now = time(nullptr);
  struct tm* p_tm = localtime(&now);
  String dateTimeString = String((p_tm->tm_mday < 10 ? "0" : "") + String(p_tm->tm_mday)) + "-" + 
                          String((p_tm->tm_mon + 1) < 10 ? "0" : "") + String(p_tm->tm_mon + 1) + "-" + 
                          String(p_tm->tm_year + 1900) + " " +
                          String((p_tm->tm_hour % 12) < 10 ? "0" : "") + String(p_tm->tm_hour % 12) + ":" + // 12-hour format
                          (p_tm->tm_min < 10 ? "0" : "") + String(p_tm->tm_min) + ":" +
                          (p_tm->tm_sec < 10 ? "0" : "") + String(p_tm->tm_sec) + " " +
                          (p_tm->tm_hour < 12 ? "AM" : "PM");
  return dateTimeString;
}

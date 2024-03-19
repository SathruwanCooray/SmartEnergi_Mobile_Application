#include <ESP8266WiFi.h>
#include <Firebase_ESP_Client.h>
#include <ArduinoJson.h> 
#include "addons/TokenHelper.h"
#include "addons/RTDBHelper.h"
#include <time.h>

#define API_KEY "AIzaSyC1KG32Ki-Mqkk2Hs1ZiJGbVX0MFJUvjbY"
#define DATABASE_URL "https://smartenergi-7425c-default-rtdb.firebaseio.com/"

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
const char *serviceAccountClientEmail = "firebase-adminsdk-32tt8@smartenergi-7425c.iam.gserviceaccount.com";
const char *serviceAccountPrivateKey = "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDF+9FhBwp+/bKw\nLWLmzoZn5SDrF1GGGojpPxTsgp2nG3WHndNR5QrrS9Mn1JvUjDTZnOaIHoXb8dCP\nNeipS5pCoYede/fdW1iMwQb7w3wcGpC+TVbDEIACBF/+NMPKUM5HzHq/VpV79sNK\nBn3S5PuCNIse3fR5e/D/CCvqSA1EW3rbWACzTy2xVAN5vT6LpWZYI/fAMOjrJvuG\n77ENopgdEM1t6Sz9wEObIRag/5Y5zJ4yBwUE37Qf26+/JHGOS5pgaDRf7iputYEG\n9cxG8EK/zsnrpP+wj7vQ+XKHVh2J03IblMPp+3Q/JAm4T3uSa6gEOZ+eXd2CHG6j\n1+3Mu9EBAgMBAAECggEAP9DiFhDjcLiM0t3mTbhPOYjxGeYLyJqf+/Lx5yRY9cbT\nlPGp7nFSGjL4LpQI4LOKy4QYCNMx2Ynx7F93ja5JXGXdpUUSyZ6KheAoRJmn1RU5\nB6Y9K6YTZNMNMA7I91shiqIeBLO/flQ1cZRzFTnq2fbeywXHKitprILxSNSNtjTn\nN4kIqEaJnnebiYsrvuCbXEAOl0K+oafLsYRZoBXihvoz3AIldU4QyvSbDgQmYoYF\nxxdbNpgDU8tTQhBWvN/eTA5uBZ3joyDOQ3DNnF2CGMGdqtpqLmqqMOFLlfhTVSQ+\n/sRjy1TzTQoWRUbRt0VYGytna41Fautx6tdBfnpTkwKBgQDrUuP+cJpKdnxx1ETu\nRHja8v5Q7Ost1RozNSBk47LfyPB4WhNB/828rWyykWApewTN87LJKt1DAohbpCtW\nlSiNv4oPitHNwYHwDKeLxjQWhKvkkF4n7RXuSQQbwEcehR6mV3yGv8MAIlsueGDc\n67bT4XmJRksxQH/pNJbCBpK/TwKBgQDXYQpTc57/IHs2eeByCjmixIJztgtTjUSQ\n/oYhKu4VKLPUhT9sUpVmd/FuqdFWKPopp0GuuxLxPCvvsRXaaJpQEDw2uyp3C+c1\nSQPvEEp4XoCASyn86k/Slw7vFl0tA9nVu8CdSxPE1CWaRXN4ZcxaN1JT6D73gruH\nWhflndHWrwKBgQCw8jgrt4Hc4fE7KnDWdLgncrXWJf/FC8tSm+0Kz8hNy2s+JAT9\nCJsr93+XWgbjyfPX5RoXd9q+K2Za+jv4M9o1k8P9YdXWkF3jIbDOQjAiiooyKHgU\nL4rhDRhAwbj4cwKT847YR9MaA7tqWuwC0l88PPvFRA0AMM69jWSa6pRnswKBgCEk\noLco0q3F7M/8P0qtQiNHBCAUQnfwBD4fvLo75flBkzK/8nuT1cO372ItJbaRhbWF\nNHlT9l1C+ivfX1KFyEFLzkhJ0wYQwdqUStOt+Re+yx1y85ok4HWyoyytj1cPAaV/\nR+uskvU2BDdSOqurVqAHZVbeJVpnNr5kYcsG1zSnAoGAJpgeQ6rE0AKOV5SahOT/\nCpIdRQsgGNtRdKLQUvJPs2/Ovz0GxaDexZ2RqyG9V+yPaHsqnuWoOet1lzlhJms8\nZW/bKjazBBQpviR4UKCaCOyAlrOQSlfW1jNqeHMWZY45FfVVekVdLo22taIuNtM5\nbW4hu/M3hPGL9TARztQTxkU=\n-----END PRIVATE KEY-----\n";

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
      if (Firebase.Firestore.getDocument(&fbdo, "smartenergi-7425c", "", "System-Verified-Modules/XQCTF")) {
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

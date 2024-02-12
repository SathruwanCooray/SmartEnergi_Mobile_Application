#include <ESP8266WiFi.h>
#include <Firebase_ESP_Client.h>
#include "addons/TokenHelper.h"
#include "addons/RTDBHelper.h"

#define API_KEY "AIzaSyC1KG32Ki-Mqkk2Hs1ZiJGbVX0MFJUvjbY"
#define DATABASE_URL "https://smartenergi-7425c-default-rtdb.firebaseio.com/"

FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;
bool authOK = false;
bool signupOK = false;

const char *ssid = "SLT_FIBRE 256";
const char *password = "Shan1234";

// Service account credentials
const char *serviceAccountClientEmail = "firebase-adminsdk-32tt8@smartenergi-7425c.iam.gserviceaccount.com";
const char *serviceAccountPrivateKey = "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDF+9FhBwp+/bKw\nLWLmzoZn5SDrF1GGGojpPxTsgp2nG3WHndNR5QrrS9Mn1JvUjDTZnOaIHoXb8dCP\nNeipS5pCoYede/fdW1iMwQb7w3wcGpC+TVbDEIACBF/+NMPKUM5HzHq/VpV79sNK\nBn3S5PuCNIse3fR5e/D/CCvqSA1EW3rbWACzTy2xVAN5vT6LpWZYI/fAMOjrJvuG\n77ENopgdEM1t6Sz9wEObIRag/5Y5zJ4yBwUE37Qf26+/JHGOS5pgaDRf7iputYEG\n9cxG8EK/zsnrpP+wj7vQ+XKHVh2J03IblMPp+3Q/JAm4T3uSa6gEOZ+eXd2CHG6j\n1+3Mu9EBAgMBAAECggEAP9DiFhDjcLiM0t3mTbhPOYjxGeYLyJqf+/Lx5yRY9cbT\nlPGp7nFSGjL4LpQI4LOKy4QYCNMx2Ynx7F93ja5JXGXdpUUSyZ6KheAoRJmn1RU5\nB6Y9K6YTZNMNMA7I91shiqIeBLO/flQ1cZRzFTnq2fbeywXHKitprILxSNSNtjTn\nN4kIqEaJnnebiYsrvuCbXEAOl0K+oafLsYRZoBXihvoz3AIldU4QyvSbDgQmYoYF\nxxdbNpgDU8tTQhBWvN/eTA5uBZ3joyDOQ3DNnF2CGMGdqtpqLmqqMOFLlfhTVSQ+\n/sRjy1TzTQoWRUbRt0VYGytna41Fautx6tdBfnpTkwKBgQDrUuP+cJpKdnxx1ETu\nRHja8v5Q7Ost1RozNSBk47LfyPB4WhNB/828rWyykWApewTN87LJKt1DAohbpCtW\nlSiNv4oPitHNwYHwDKeLxjQWhKvkkF4n7RXuSQQbwEcehR6mV3yGv8MAIlsueGDc\n67bT4XmJRksxQH/pNJbCBpK/TwKBgQDXYQpTc57/IHs2eeByCjmixIJztgtTjUSQ\n/oYhKu4VKLPUhT9sUpVmd/FuqdFWKPopp0GuuxLxPCvvsRXaaJpQEDw2uyp3C+c1\nSQPvEEp4XoCASyn86k/Slw7vFl0tA9nVu8CdSxPE1CWaRXN4ZcxaN1JT6D73gruH\nWhflndHWrwKBgQCw8jgrt4Hc4fE7KnDWdLgncrXWJf/FC8tSm+0Kz8hNy2s+JAT9\nCJsr93+XWgbjyfPX5RoXd9q+K2Za+jv4M9o1k8P9YdXWkF3jIbDOQjAiiooyKHgU\nL4rhDRhAwbj4cwKT847YR9MaA7tqWuwC0l88PPvFRA0AMM69jWSa6pRnswKBgCEk\noLco0q3F7M/8P0qtQiNHBCAUQnfwBD4fvLo75flBkzK/8nuT1cO372ItJbaRhbWF\nNHlT9l1C+ivfX1KFyEFLzkhJ0wYQwdqUStOt+Re+yx1y85ok4HWyoyytj1cPAaV/\nR+uskvU2BDdSOqurVqAHZVbeJVpnNr5kYcsG1zSnAoGAJpgeQ6rE0AKOV5SahOT/\nCpIdRQsgGNtRdKLQUvJPs2/Ovz0GxaDexZ2RqyG9V+yPaHsqnuWoOet1lzlhJms8\nZW/bKjazBBQpviR4UKCaCOyAlrOQSlfW1jNqeHMWZY45FfVVekVdLo22taIuNtM5\nbW4hu/M3hPGL9TARztQTxkU=\n-----END PRIVATE KEY-----\n";

void setup() {
  Serial.begin(9600);

  // Connect to Wi-Fi
  WiFi.begin(ssid, password);

  while (WiFi.status() != WL_CONNECTED) {
    delay(250);
    Serial.print(".");
  }

  Serial.println("");
  Serial.println("Connected to Wi-Fi");

  // Firebase setup
  config.api_key = API_KEY;
  config.database_url = DATABASE_URL;

  // Firebase admin Authentication
  if (Firebase.signUp(&config, &auth, serviceAccountClientEmail, serviceAccountPrivateKey)) {
    Serial.println("Firebase admin signup successful");
    signupOK = true;

    config.token_status_callback = tokenStatusCallback;
    Firebase.begin(&config, &auth);
    Firebase.reconnectWiFi(true);
  } else {
		auth.user.email = serviceAccountClientEmail;
	  auth.user.password = serviceAccountPrivateKey;

	  // Initialize Firebase with config and auth
	  Firebase.begin(&config, &auth);

	  // Wait for Firebase authentication
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
}

float x = 0;

void loop() {
  Serial.println("Loop started");
  if (Firebase.ready() && (signupOK || authOK)) {
    Serial.println("Firebase is ready, attempting to send data...");
    Serial.print("Data to be sent: ");
    Serial.println(x);
    
    if (Firebase.RTDB.setFloat(&fbdo, "ESPmodules/XQCTF/CurrentValue", x)) {
      Serial.println("Data sent successfully");
    } else {
      Serial.println("Failed to send data");
      Serial.println(fbdo.errorReason());
    }
    
    delay(1000);
    x++;
  }
}

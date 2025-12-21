# Flutter Car Locator - Setup Instructions

## Prerequisites

This app has been configured with the necessary permissions and API key placeholders. Follow these steps to complete the setup:

## Google Maps API Key Setup

### 1. Get Google Maps API Key

1. Go to the [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Enable the following APIs:

   - Maps SDK for Android
   - Maps SDK for iOS
   - Places API (if using places features)
   - Geocoding API (if using geocoding features)

4. Go to "Credentials" and create an API Key
5. Restrict the API key (recommended for security):
   - For Android: Add your app's package name `com.example.flutter_car_locator` and SHA-1 fingerprint
   - For iOS: Add your app's bundle identifier

### 2. Configure the API Key

**Android:**

- Open `android/app/src/main/AndroidManifest.xml`
- Replace `YOUR_GOOGLE_MAPS_API_KEY` with your actual API key:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_ACTUAL_API_KEY_HERE"/>
```

**iOS:**

- Open `ios/Runner/AppDelegate.swift`
- Add the following import and configuration:

```swift
import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("YOUR_ACTUAL_API_KEY_HERE")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

## Permissions Configured

The following permissions have been added to your project:

### Android (AndroidManifest.xml)

- `ACCESS_FINE_LOCATION` - For precise location access
- `ACCESS_COARSE_LOCATION` - For approximate location access
- `CAMERA` - For QR scanning and AR features
- `WRITE_EXTERNAL_STORAGE` - For file storage
- `READ_EXTERNAL_STORAGE` - For file access

### iOS (Info.plist)

- `NSLocationWhenInUseUsageDescription` - Location access when app is in use
- `NSLocationAlwaysAndWhenInUseUsageDescription` - Background location access
- `NSCameraUsageDescription` - Camera access for QR and AR features

## Getting Your SHA-1 Fingerprint (Android)

To get your SHA-1 fingerprint for API key restriction:

```bash
# For debug keystore
keytool -list -v -alias androiddebugkey -keystore ~/.android/debug.keystore

# Default password is: android
```

## Testing

1. Replace the API key placeholder with your actual key
2. Run the app: `flutter run`
3. Grant location and camera permissions when prompted
4. The map should now load without crashing

## Common Issues

- **"API key not found"**: Make sure you replaced `YOUR_GOOGLE_MAPS_API_KEY` with your actual key
- **Map loads but is gray**: Check that you've enabled the correct APIs in Google Cloud Console
- **Location not working**: Ensure location permissions are granted and location services are enabled on the device
- **iOS build issues**: Make sure you've added the GoogleMaps import and configuration to AppDelegate.swift

## Next Steps

After completing the setup, your car locator app should work without force closing on both Android and iOS.

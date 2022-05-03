# chat

Chat Plugin

## Getting Started

## Flutter
    Chat.open(BuildContext,email,password,appIcon,domain:domain);
## Android:
Manfifest:

    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.READ_PHONE_STATE" />
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
        tools:ignore="ScopedStorage" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.REQUEST_INSTALL_PACKAGES" />
    <uses-feature android:name="android.hardware.camera" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.WAKE_LOCK" />
    <uses-feature android:name="android.hardware.camera.autofocus" />
    <queries>
        <intent>
            <action android:name="android.intent.action.VIEW" />
            <data android:scheme="https" />
        </intent>
        <intent>
            <action android:name="android.intent.action.DIAL" />
            <data android:scheme="tel" />
        </intent>
        <intent>
            <action android:name="android.intent.action.SENDTO" />
            <data android:scheme="smsto" />
        </intent>
        <intent>
            <action android:name="android.intent.action.SEND" />
            <data android:mimeType="*/*" />
        </intent>
    </queries>
    <application
                 .....
        android:usesCleartextTraffic="true"
        android:requestLegacyExternalStorage="true"
                 ....
   </application>

## iOS:
InfoPlist:

    <key>UISupportsDocumentBrowser</key>
    <true/>
    <key>LSSupportsOpeningDocumentsInPlace</key>
    <true/>
    <key>LSApplicationQueriesSchemes</key>
    <array>
      <string>https</string>
      <string>http</string>
    </array>
    <key>UIBackgroundModes</key>
    <array>
       <string>fetch</string>
       <string>remote-notification</string>
    </array>
    <key>NSCameraUsageDescription</key>
    <string>$(PRODUCT_NAME) cần bạn chấp nhận cho truy cập camera để chụp ảnh profile hoặc cho upload ảnh.</string>
    <key>NSPhotoLibraryAddUsageDescription</key>
    <string>$(PRODUCT_NAME) cần bạn chấp nhận cho truy cập thư viện ảnh để chụp ảnh thêm ảnh profile hoặc cho upload ảnh.</string>
    <key>NSPhotoLibraryUsageDescription</key>
    <string>$(PRODUCT_NAME) cần bạn chấp nhận cho truy cập thư viện ảnh để thêm ảnh profile hoặc cho upload ảnh.</string>
    <key>NSAppleMusicUsageDescription</key>
    <string>$(PRODUCT_NAME) cần bạn chấp nhận cho truy cập thư viện audio để thêm audio.</string>


### iOS

Make sure you add the following key to `Info.plist` for iOS

```
<key>io.flutter.embedded_views_preview</key><true/>
```

### Android

Android P Unable to download kernel Solution

Add a piece of code in label `application` on `AndroidManifst.xml` file

```
android:networkSecurityConfig="@xml/network_security_config"
```

Add a file named `network_security_config.xml` in `res/xml` directory, The content of the file is

```xml
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <base-config cleartextTrafficPermitted="true" />
</network-security-config>
```

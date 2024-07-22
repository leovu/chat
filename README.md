
# Chat

Plugin Chat

## Bắt đầu

## Flutter
```dart
Chat.open(BuildContext, email, password, appIcon, domain: domain);
```

## Android:

Manifest:

```xml
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
```

## iOS:

InfoPlist:

```xml
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
```

### iOS

Đảm bảo bạn đã thêm khóa sau vào `Info.plist` cho iOS

```xml
<key>io.flutter.embedded_views_preview</key>
<true/>
```

### Android

Android P không thể tải kernel giải pháp

Thêm đoạn mã vào nhãn `application` trong tệp `AndroidManifest.xml`

```xml
android:networkSecurityConfig="@xml/network_security_config"
```

Thêm tệp có tên `network_security_config.xml` trong thư mục `res/xml`, nội dung của tệp là

```xml
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <base-config cleartextTrafficPermitted="true" />
</network-security-config>
```

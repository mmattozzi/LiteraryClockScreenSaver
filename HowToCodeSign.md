Code signing a screensaver is not straightforward. As of March 2023, this procedure works: 

Prelim: 
* Create an application specific password at https://appleid.apple.com/
* Store application specifc password using:
```
xcrun altool --store-password-in-keychain-item "AC_PASSWORD" -u "APPLE ID" -p “insert App-specific PW from Apple here”
```
* Give developer certificate an easy to reference alias (this resolves any issues with multiple certificates of the same name):
  * Open Keychain Access
  * Right click on Developer ID Application and pick New Identity Preference
  * Enter `codesign-dev-id-app`

Regular signing commands:
```
codesign -f -o runtime --timestamp --sign codesign-dev-id-app LiteraryClockScreenSaver.saver
zip -r LiteraryClockScreenSaver.saver.zip LiteraryClockScreenSaver.saver/
xcrun altool --verbose --notarize-app --primary-bundle-id LiteraryClockScreenSaver -u "APPLE ID" -p "@keychain:AC_PASSWORD" -t osx -f LiteraryClockScreenSaver.saver.zip
/usr/bin/xcrun altool --notarization-history 0 -u "APPLE ID" -p "@keychain:AC_PASSWORD"
xcrun stapler staple LiteraryClockScreenSaver.saver
zip -r LiteraryClockScreenSaver.saver.zip LiteraryClockScreenSaver.saver
```

Solution sourced from: https://developer.apple.com/forums/thread/15483

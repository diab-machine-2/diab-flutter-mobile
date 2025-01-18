#!/bin/bash

# remove old ipa
rm ios/Runner.ipa >> /dev/null 2>&1
rm ios/Runner.app.dSYM.zip >> /dev/null 2>&1

# get version from pubspec.yaml
VERSION_LINE=$(grep -e 'version: ' pubspec.yaml)

if [[ $VERSION_LINE =~ ^version:\ ([^+-]+)(.*)$ ]]; then
  VERSION="${BASH_REMATCH[1]}"
  SUFFIX="${BASH_REMATCH[2]}"
  # remove + from suffix
  SUFFIX=$(echo "$SUFFIX" | sed 's/+//')
  
  # Trim whitespace from suffix
  SUFFIX=$(echo "$SUFFIX" | xargs)

  echo "Flutter version: $VERSION"
  echo "Suffix: $SUFFIX"

  sed -i '' "s/FLUTTER_BUILD_NAME=.*/FLUTTER_BUILD_NAME=$VERSION/" ios/Flutter/Generated.xcconfig
  sed -i '' "s/FLUTTER_BUILD_NUMBER=.*/FLUTTER_BUILD_NUMBER=$SUFFIX/" ios/Flutter/Generated.xcconfig
else
  echo "Failed to extract version and suffix from pubspec.yaml"

  # normal build
  flutter build ios --no-codesign --flavor=Stag.Release
fi

# upload to testflight
cd ios
fastlane upload_beta
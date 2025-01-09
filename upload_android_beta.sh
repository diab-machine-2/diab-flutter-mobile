#!/bin/bash
# build android to generate correct version
rm -rf build/app/outputs/ >> /dev/null 2>&1
flutter build appbundle

# upload to firebase app distribution
cd android
fastlane upload_beta
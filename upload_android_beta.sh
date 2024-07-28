#!/bin/bash
# build android to generate correct version
flutter build appbundle

# upload to firebase app distribution
cd android
fastlane upload_beta
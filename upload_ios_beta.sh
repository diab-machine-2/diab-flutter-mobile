#!/bin/bash

# build ios to generate correct version
flutter build ios --no-codesign --flavor=Stag.Release

# upload to testflight
cd ios
APPLE_ID=$APPLE_ID fastlane beta

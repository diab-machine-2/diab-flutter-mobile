#!/bin/bash

# build ios to generate correct version
flutter build ios --no-codesign --flavor=Stag.Release

# upload to testflight
cd ios
fastlane upload_beta

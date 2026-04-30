#!/bin/sh
set -e

# Write GoogleService-Info.plist from the Xcode Cloud secret environment variable.
# In App Store Connect → Xcode Cloud → your workflow → Environment → Secrets,
# add a secret named GOOGLE_SERVICE_INFO_PLIST with the full plist file contents.

if [ -n "$GOOGLE_SERVICE_INFO_PLIST" ]; then
    echo "$GOOGLE_SERVICE_INFO_PLIST" > "$CI_PRIMARY_REPOSITORY_PATH/WorkoutCave/Resources/GoogleService-Info.plist"
    echo "GoogleService-Info.plist written."
else
    echo "Error: GOOGLE_SERVICE_INFO_PLIST secret is not set." >&2
    exit 1
fi

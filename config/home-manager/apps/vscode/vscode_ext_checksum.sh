#!/bin/bash

# Check if extension name and version are provided
if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Usage: $0 <publisher.extension-name> <version>"
  exit 1
fi

# Extract Publisher and Extension Name
EXTENSION_FULL="$1"
VERSION="$2"

if [[ ! "$EXTENSION_FULL" =~ \. ]]; then
  echo "Error: Extension name must be in the format 'publisher.extension-name'"
  exit 1
fi

PUBLISHER=$(echo "$EXTENSION_FULL" | cut -d '.' -f1)
EXTENSION_NAME=$(echo "$EXTENSION_FULL" | cut -d '.' -f2)

# Construct download URL
URL="https://marketplace.visualstudio.com/_apis/public/gallery/publisher/$PUBLISHER/extension/$EXTENSION_NAME/$VERSION/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage"

# Temporary filename
FILENAME="$EXTENSION_NAME-$VERSION.vsix"

# Download the extension
echo "Downloading $FILENAME..."
wget -q --show-progress -O "$FILENAME" "$URL"

# Verify download success
if [ $? -ne 0 ]; then
  echo "❌ Failed to download extension. Check if the name and version are correct."
  exit 1
fi

# Compute SHA256 checksum
echo "Computing SHA256 checksum..."
SHA256=$(shasum -a 256 "$FILENAME" | awk '{ print $1 }')

# Delete the downloaded file
rm -f "$FILENAME"
echo "🧹 Deleted temporary file: $FILENAME"

# Generate Nix configuration
echo "✅ Generated Nix configuration:"
echo
cat <<EOF
  ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
    {
      name = "$EXTENSION_NAME";
      publisher = "$PUBLISHER";
      version = "$VERSION";
      sha256 = "$SHA256";
    }
  ]
EOF

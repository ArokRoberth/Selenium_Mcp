#!/bin/bash

# MCP Selenium Installation Script
# This script downloads and installs MCP Selenium for Claude Desktop

set -e

echo "🚀 Installing MCP Selenium..."

# Check if Java is installed
if ! command -v java &> /dev/null; then
    echo "❌ Java is not installed. Please install Java 11+ first"
    exit 1
fi

# Check Java version
JAVA_VERSION=$(java -version 2>&1 | head -n1 | cut -d'"' -f2 | cut -d'.' -f1)
if [ "$JAVA_VERSION" -lt 11 ]; then
    echo "❌ Java 11+ required. Current version: $JAVA_VERSION"
    exit 1
fi

echo "✅ Java $JAVA_VERSION found"

# Create installation directory
INSTALL_DIR="$HOME/.mcp-selenium"
mkdir -p "$INSTALL_DIR"

echo "📦 Downloading MCP Selenium..."

# Download the latest release
JAR_URL="https://github.com/ArokRoberth/Selenium_Mcp/releases/latest/download/mcp-selenium-1.0.1.jar"
JAR_PATH="$INSTALL_DIR/mcp-selenium.jar"

# Download the JAR file
if command -v wget &> /dev/null; then
    wget -O "$JAR_PATH" "$JAR_URL"
elif command -v curl &> /dev/null; then
    curl -L -o "$JAR_PATH" "$JAR_URL"
else
    echo "❌ Neither wget nor curl found. Please install one of them."
    exit 1
fi

if [ ! -f "$JAR_PATH" ]; then
    echo "❌ Failed to download MCP Selenium JAR"
    exit 1
fi

echo "✅ MCP Selenium downloaded successfully"

# Detect OS for config file location
if [[ "$OSTYPE" == "darwin"* ]]; then
    CONFIG_DIR="$HOME/Library/Application Support/Claude"
    OS_NAME="macOS"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    CONFIG_DIR="$HOME/.config/Claude"
    OS_NAME="Linux"
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    # Windows (Git Bash, MSYS2, Cygwin)
    CONFIG_DIR="$APPDATA/Claude"
    OS_NAME="Windows"
    # Convert Windows path to Unix style for this script
    CONFIG_DIR=$(cygpath -u "$CONFIG_DIR" 2>/dev/null || echo "$CONFIG_DIR")
else
    CONFIG_DIR="$HOME/.config/Claude"
    OS_NAME="Unknown"
fi

CONFIG_FILE="$CONFIG_DIR/claude_desktop_config.json"

echo "📁 Detected OS: $OS_NAME"
echo "📄 Config location: $CONFIG_FILE"

# Create Claude config directory if it doesn't exist
mkdir -p "$CONFIG_DIR"

# Check if config file exists
if [ -f "$CONFIG_FILE" ]; then
    echo "⚠️  Claude Desktop config already exists."
    echo "   Please manually add MCP Selenium to: $CONFIG_FILE"
    echo ""
    echo "   Add this configuration to the mcpServers section:"
    if [[ "$OS_NAME" == "Windows" ]]; then
        # For Windows, use escaped backslashes in JSON
        WIN_JAR_PATH=$(echo "$JAR_PATH" | sed 's|/|\\\\|g')
        echo '   "selenium": {'
        echo '     "command": "java",'
        echo "     \"args\": [\"-jar\", \"$WIN_JAR_PATH\"]"
        echo '   }'
    else
        echo '   "selenium": {'
        echo '     "command": "java",'
        echo '     "args": ["-jar", "'"$JAR_PATH"'"]'
        echo '   }'
    fi
else
    echo "📝 Creating Claude Desktop config..."
    if [[ "$OS_NAME" == "Windows" ]]; then
        # For Windows, escape backslashes for JSON
        WIN_JAR_PATH=$(echo "$JAR_PATH" | sed 's|/|\\\\|g')
        cat > "$CONFIG_FILE" << EOF
{
  "mcpServers": {
    "selenium": {
      "command": "java",
      "args": ["-jar", "$WIN_JAR_PATH"]
    }
  }
}
EOF
    else
        cat > "$CONFIG_FILE" << EOF
{
  "mcpServers": {
    "selenium": {
      "command": "java",
      "args": ["-jar", "$JAR_PATH"]
    }
  }
}
EOF
    fi
    echo "✅ Config created at: $CONFIG_FILE"
fi

echo ""
echo "🎉 Installation completed!"
echo ""
echo "Next steps:"
echo "1. Restart Claude Desktop"
echo "2. Test with: 'Using selenium MCP tools, navigate to google.com and take a screenshot'"
echo ""
echo "For support, visit: https://github.com/ArokRoberth/Selenium_Mcp"

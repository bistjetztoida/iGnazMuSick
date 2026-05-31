#!/bin/bash
# ═══════════════════════════════════════════════════════════
# Build script for oida.mo standalone application
# ═══════════════════════════════════════════════════════════

set -e

VERSION="1.3.0"
APP_NAME="oida"
BUILD_DIR="./build"
SRC_DIR="./src"
DIST_DIR="./dist"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}🦞 oida.mo Build System v${VERSION}${NC}"

# Check for Nim
if ! command -v nim &> /dev/null; then
    echo -e "${YELLOW}⚠️  Nim not found. Install from: https://nim-lang.org${NC}"
    exit 1
fi

# Create directories
mkdir -p "$BUILD_DIR" "$DIST_DIR"

# Detect OS and architecture
OS=$(uname -s)
ARCH=$(uname -m)

case "$OS" in
    Linux)
        TARGET="${APP_NAME}-${VERSION}-linux-${ARCH}"
        ;;
    Darwin)
        TARGET="${APP_NAME}-${VERSION}-macos-${ARCH}"
        ;;
    MINGW*|MSYS*|CYGWIN*)
        TARGET="${APP_NAME}-${VERSION}-windows-${ARCH}.exe"
        ;;
    *)
        TARGET="${APP_NAME}-${VERSION}-${OS}-${ARCH}"
        ;;
esac

echo -e "${BLUE}📦 Target: $TARGET${NC}"

# Build with optimization flags
echo -e "${BLUE}🔨 Compiling...${NC}"
nim c \
    -d:release \
    --gc:arc \
    -d:danger \
    --opt:speed \
    -o:"${DIST_DIR}/${TARGET}" \
    "${SRC_DIR}/main.nim"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Build successful: ${DIST_DIR}/${TARGET}${NC}"
    
    # Make executable
    chmod +x "${DIST_DIR}/${TARGET}"
    
    # Create symlink for convenience
    ln -sf "$TARGET" "${DIST_DIR}/${APP_NAME}"
    echo -e "${GREEN}📁 Symlink created: ${DIST_DIR}/${APP_NAME}${NC}"
    
    # Show build info
    echo -e "${GREEN}📊 Build Info:${NC}"
    ls -lh "${DIST_DIR}/${TARGET}"
else
    echo -e "${YELLOW}❌ Build failed${NC}"
    exit 1
fi

#!/bin/bash

# Xcode Cleanup Script
# Deletes all unnecessary Xcode cache files and shows freed disk space

set -e  # Exit on errors

# Colors for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to measure available space
get_available_space() {
    df -h / | awk 'NR==2{print $4}' | sed 's/Gi//' | sed 's/G//'
}

# Function to calculate directory size
get_directory_size() {
    if [ -d "$1" ]; then
        du -sh "$1" 2>/dev/null | cut -f1 | sed 's/G//' | sed 's/M/0.001/' | sed 's/K/0.000001/' | sed 's/B/0.000000001/'
    else
        echo "0"
    fi
}

echo -e "${BLUE}🧹 Xcode Cleanup Script${NC}"
echo "====================================="

# Measure disk space before cleanup
echo -e "${YELLOW}📊 Measuring available disk space...${NC}"
SPACE_BEFORE=$(get_available_space)
echo -e "Available space before: ${GREEN}${SPACE_BEFORE}GB${NC}"
echo

# Show warning
echo -e "${RED}⚠️  WARNING: This script will delete Xcode cache files!${NC}"
echo "The following areas will be cleaned:"
echo "  • CoreSimulator Devices (unavailable simulators)"
echo "  • iOS DeviceSupport (old iOS versions)"
echo "  • CoreSimulator Caches"
echo "  • DerivedData (build caches)"
echo "  • Archives (app archives)"
echo "  • iOS Device Logs"
echo "  • Additional cache folders"
echo

read -p "Do you want to continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Aborted.${NC}"
    exit 0
fi

echo -e "${BLUE}🚀 Starting cleanup...${NC}"
echo

# 1. CoreSimulator - Delete unavailable simulators
echo -e "${YELLOW}1. Deleting unavailable simulators...${NC}"
if command -v xcrun >/dev/null 2>&1; then
    xcrun simctl delete unavailable 2>/dev/null || echo "No unavailable simulators found"
    echo "✅ Unavailable simulators deleted"
else
    echo "⚠️  xcrun not found - skipping simulator cleanup"
fi

# 2. Delete iOS DeviceSupport
echo -e "${YELLOW}2. Deleting iOS DeviceSupport...${NC}"
IOS_DEVICE_SUPPORT="$HOME/Library/Developer/Xcode/iOS DeviceSupport"
if [ -d "$IOS_DEVICE_SUPPORT" ]; then
    SIZE_BEFORE=$(get_directory_size "$IOS_DEVICE_SUPPORT")
    rm -rf "$IOS_DEVICE_SUPPORT"/*
    echo "✅ iOS DeviceSupport cleared (${SIZE_BEFORE} GB)"
else
    echo "📁 iOS DeviceSupport folder not found"
fi

# 3. Delete CoreSimulator Caches
echo -e "${YELLOW}3. Deleting CoreSimulator Caches...${NC}"
CORESIM_CACHES="$HOME/Library/Developer/CoreSimulator/Caches"
if [ -d "$CORESIM_CACHES" ]; then
    SIZE_BEFORE=$(get_directory_size "$CORESIM_CACHES")
    rm -rf "$CORESIM_CACHES"/*
    echo "✅ CoreSimulator Caches cleared (${SIZE_BEFORE} GB)"
else
    echo "📁 CoreSimulator Caches folder not found"
fi

# 4. Delete DerivedData (build caches)
echo -e "${YELLOW}4. Deleting DerivedData...${NC}"
DERIVED_DATA="$HOME/Library/Developer/Xcode/DerivedData"
if [ -d "$DERIVED_DATA" ]; then
    SIZE_BEFORE=$(get_directory_size "$DERIVED_DATA")
    rm -rf "$DERIVED_DATA"/*
    echo "✅ DerivedData cleared (${SIZE_BEFORE} GB)"
else
    echo "📁 DerivedData folder not found"
fi

# 5. Delete Archives
echo -e "${YELLOW}5. Deleting Archives...${NC}"
ARCHIVES="$HOME/Library/Developer/Xcode/Archives"
if [ -d "$ARCHIVES" ]; then
    SIZE_BEFORE=$(get_directory_size "$ARCHIVES")
    rm -rf "$ARCHIVES"/*
    echo "✅ Archives cleared (${SIZE_BEFORE} GB)"
else
    echo "📁 Archives folder not found"
fi

# 6. Delete iOS Device Logs
echo -e "${YELLOW}6. Deleting iOS Device Logs...${NC}"
DEVICE_LOGS="$HOME/Library/Developer/Xcode/iOS Device Logs"
if [ -d "$DEVICE_LOGS" ]; then
    SIZE_BEFORE=$(get_directory_size "$DEVICE_LOGS")
    rm -rf "$DEVICE_LOGS"/*
    echo "✅ iOS Device Logs cleared (${SIZE_BEFORE} GB)"
else
    echo "📁 iOS Device Logs folder not found"
fi

# 7. Delete additional cache folders
echo -e "${YELLOW}7. Deleting additional caches...${NC}"

# Xcode UserData
USERDATA="$HOME/Library/Developer/Xcode/UserData"
if [ -d "$USERDATA/IB Support" ]; then
    rm -rf "$USERDATA/IB Support"
    echo "✅ Xcode IB Support Cache deleted"
fi

# Swift Package Manager Caches
SPM_CACHE="$HOME/Library/Caches/org.swift.swiftpm"
if [ -d "$SPM_CACHE" ]; then
    SIZE_BEFORE=$(get_directory_size "$SPM_CACHE")
    rm -rf "$SPM_CACHE"/*
    echo "✅ Swift Package Manager Cache cleared (${SIZE_BEFORE} GB)"
fi

# Xcode Previews
PREVIEWS="$HOME/Library/Developer/Xcode/Previews"
if [ -d "$PREVIEWS" ]; then
    SIZE_BEFORE=$(get_directory_size "$PREVIEWS")
    rm -rf "$PREVIEWS"/*
    echo "✅ Xcode Previews cleared (${SIZE_BEFORE} GB)"
fi

# System-Level Caches (carefully)
echo -e "${YELLOW}8. Deleting System-Level Caches...${NC}"
SYSTEM_CACHES=(
    "$HOME/Library/Caches/com.apple.dt.Xcode"
    "$HOME/Library/Caches/com.apple.CoreSimulator.CoreSimulatorService"
    "$HOME/Library/Caches/com.apple.dt.XCTest"
)

for cache in "${SYSTEM_CACHES[@]}"; do
    if [ -d "$cache" ]; then
        SIZE_BEFORE=$(get_directory_size "$cache")
        rm -rf "$cache"/*
        echo "✅ $(basename "$cache") Cache cleared (${SIZE_BEFORE} GB)"
    fi
done

echo
echo -e "${BLUE}🔄 Cleanup completed!${NC}"
echo

# Measure disk space after cleanup
echo -e "${YELLOW}📊 Measuring available disk space after cleanup...${NC}"
sleep 2  # Wait briefly for filesystem updates
SPACE_AFTER=$(get_available_space)

# Calculate the difference
SPACE_FREED=$(echo "$SPACE_AFTER - $SPACE_BEFORE" | bc -l 2>/dev/null || echo "Calculation error")

echo "====================================="
echo -e "Available space before:  ${RED}${SPACE_BEFORE}GB${NC}"
echo -e "Available space after:   ${GREEN}${SPACE_AFTER}GB${NC}"

if [[ "$SPACE_FREED" != "Calculation error" ]]; then
    if (( $(echo "$SPACE_FREED > 0" | bc -l) )); then
        echo -e "💾 ${GREEN}Space freed: +${SPACE_FREED}GB${NC}"
    else
        # Sometimes measurement can be inaccurate
        echo -e "💾 ${YELLOW}Cleanup completed${NC}"
        echo "   (Space calculation may be inaccurate)"
    fi
else
    echo -e "💾 ${YELLOW}Cleanup completed${NC}"
    echo "   (bc not installed for accurate calculation)"
fi

echo "====================================="
echo -e "${GREEN}✨ Xcode is now clean!${NC}"

# Optional: Empty trash
echo
read -p "Do you also want to empty the trash? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    osascript -e 'tell application "Finder" to empty trash'
    echo -e "${GREEN}🗑️  Trash emptied!${NC}"
fi

echo -e "${BLUE}🎉 Done!${NC}"

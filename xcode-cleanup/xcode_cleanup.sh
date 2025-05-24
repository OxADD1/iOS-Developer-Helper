#!/bin/bash

# Xcode Cleanup Script
# Löscht alle unnötigen Xcode-Cache-Dateien und zeigt den freigegebenen Speicherplatz an

set -e  # Beende bei Fehlern

# Farben für bessere Ausgabe
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Funktion um Speicherplatz zu messen
get_available_space() {
    df -h / | awk 'NR==2{print $4}' | sed 's/Gi//' | sed 's/G//'
}

# Funktion um Ordnergröße zu berechnen
get_directory_size() {
    if [ -d "$1" ]; then
        du -sh "$1" 2>/dev/null | cut -f1 | sed 's/G//' | sed 's/M/0.001/' | sed 's/K/0.000001/' | sed 's/B/0.000000001/'
    else
        echo "0"
    fi
}

echo -e "${BLUE}🧹 Xcode Cleanup Script${NC}"
echo "====================================="

# Speicherplatz vor der Bereinigung messen
echo -e "${YELLOW}📊 Messe verfügbaren Speicherplatz...${NC}"
SPACE_BEFORE=$(get_available_space)
echo -e "Verfügbarer Speicher vorher: ${GREEN}${SPACE_BEFORE}GB${NC}"
echo

# Warnung anzeigen
echo -e "${RED}⚠️  WARNUNG: Dieses Script löscht Xcode-Cache-Dateien!${NC}"
echo "Folgende Bereiche werden bereinigt:"
echo "  • CoreSimulator Devices (nicht verfügbare Simulatoren)"
echo "  • iOS DeviceSupport (alte iOS-Versionen)"
echo "  • CoreSimulator Caches"
echo "  • DerivedData (Build-Caches)"
echo "  • Archives (App-Archive)"
echo "  • iOS Device Logs"
echo "  • Weitere Cache-Ordner"
echo

read -p "Möchtest du fortfahren? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Abgebrochen.${NC}"
    exit 0
fi

echo -e "${BLUE}🚀 Starte Bereinigung...${NC}"
echo

# 1. CoreSimulator - Nicht verfügbare Simulatoren löschen
echo -e "${YELLOW}1. Lösche nicht verfügbare Simulatoren...${NC}"
if command -v xcrun >/dev/null 2>&1; then
    xcrun simctl delete unavailable 2>/dev/null || echo "Keine nicht verfügbaren Simulatoren gefunden"
    echo "✅ Nicht verfügbare Simulatoren gelöscht"
else
    echo "⚠️  xcrun nicht gefunden - überspringe Simulator-Bereinigung"
fi

# 2. iOS DeviceSupport löschen
echo -e "${YELLOW}2. Lösche iOS DeviceSupport...${NC}"
IOS_DEVICE_SUPPORT="$HOME/Library/Developer/Xcode/iOS DeviceSupport"
if [ -d "$IOS_DEVICE_SUPPORT" ]; then
    SIZE_BEFORE=$(get_directory_size "$IOS_DEVICE_SUPPORT")
    rm -rf "$IOS_DEVICE_SUPPORT"/*
    echo "✅ iOS DeviceSupport geleert (${SIZE_BEFORE} GB)"
else
    echo "📁 iOS DeviceSupport Ordner nicht gefunden"
fi

# 3. CoreSimulator Caches löschen
echo -e "${YELLOW}3. Lösche CoreSimulator Caches...${NC}"
CORESIM_CACHES="$HOME/Library/Developer/CoreSimulator/Caches"
if [ -d "$CORESIM_CACHES" ]; then
    SIZE_BEFORE=$(get_directory_size "$CORESIM_CACHES")
    rm -rf "$CORESIM_CACHES"/*
    echo "✅ CoreSimulator Caches geleert (${SIZE_BEFORE} GB)"
else
    echo "📁 CoreSimulator Caches Ordner nicht gefunden"
fi

# 4. DerivedData löschen (Build-Caches)
echo -e "${YELLOW}4. Lösche DerivedData...${NC}"
DERIVED_DATA="$HOME/Library/Developer/Xcode/DerivedData"
if [ -d "$DERIVED_DATA" ]; then
    SIZE_BEFORE=$(get_directory_size "$DERIVED_DATA")
    rm -rf "$DERIVED_DATA"/*
    echo "✅ DerivedData geleert (${SIZE_BEFORE} GB)"
else
    echo "📁 DerivedData Ordner nicht gefunden"
fi

# 5. Archives löschen
echo -e "${YELLOW}5. Lösche Archives...${NC}"
ARCHIVES="$HOME/Library/Developer/Xcode/Archives"
if [ -d "$ARCHIVES" ]; then
    SIZE_BEFORE=$(get_directory_size "$ARCHIVES")
    rm -rf "$ARCHIVES"/*
    echo "✅ Archives geleert (${SIZE_BEFORE} GB)"
else
    echo "📁 Archives Ordner nicht gefunden"
fi

# 6. iOS Device Logs löschen
echo -e "${YELLOW}6. Lösche iOS Device Logs...${NC}"
DEVICE_LOGS="$HOME/Library/Developer/Xcode/iOS Device Logs"
if [ -d "$DEVICE_LOGS" ]; then
    SIZE_BEFORE=$(get_directory_size "$DEVICE_LOGS")
    rm -rf "$DEVICE_LOGS"/*
    echo "✅ iOS Device Logs geleert (${SIZE_BEFORE} GB)"
else
    echo "📁 iOS Device Logs Ordner nicht gefunden"
fi

# 7. Weitere Cache-Ordner löschen
echo -e "${YELLOW}7. Lösche weitere Caches...${NC}"

# Xcode UserData
USERDATA="$HOME/Library/Developer/Xcode/UserData"
if [ -d "$USERDATA/IB Support" ]; then
    rm -rf "$USERDATA/IB Support"
    echo "✅ Xcode IB Support Cache gelöscht"
fi

# Swift Package Manager Caches
SPM_CACHE="$HOME/Library/Caches/org.swift.swiftpm"
if [ -d "$SPM_CACHE" ]; then
    SIZE_BEFORE=$(get_directory_size "$SPM_CACHE")
    rm -rf "$SPM_CACHE"/*
    echo "✅ Swift Package Manager Cache geleert (${SIZE_BEFORE} GB)"
fi

# Xcode Previews
PREVIEWS="$HOME/Library/Developer/Xcode/Previews"
if [ -d "$PREVIEWS" ]; then
    SIZE_BEFORE=$(get_directory_size "$PREVIEWS")
    rm -rf "$PREVIEWS"/*
    echo "✅ Xcode Previews geleert (${SIZE_BEFORE} GB)"
fi

# System-Level Caches (vorsichtig)
echo -e "${YELLOW}8. Lösche System-Level Caches...${NC}"
SYSTEM_CACHES=(
    "$HOME/Library/Caches/com.apple.dt.Xcode"
    "$HOME/Library/Caches/com.apple.CoreSimulator.CoreSimulatorService"
    "$HOME/Library/Caches/com.apple.dt.XCTest"
)

for cache in "${SYSTEM_CACHES[@]}"; do
    if [ -d "$cache" ]; then
        SIZE_BEFORE=$(get_directory_size "$cache")
        rm -rf "$cache"/*
        echo "✅ $(basename "$cache") Cache geleert (${SIZE_BEFORE} GB)"
    fi
done

echo
echo -e "${BLUE}🔄 Bereinigung abgeschlossen!${NC}"
echo

# Speicherplatz nach der Bereinigung messen
echo -e "${YELLOW}📊 Messe verfügbaren Speicherplatz nach Bereinigung...${NC}"
sleep 2  # Kurz warten für Dateisystem-Updates
SPACE_AFTER=$(get_available_space)

# Berechne die Differenz
SPACE_FREED=$(echo "$SPACE_AFTER - $SPACE_BEFORE" | bc -l 2>/dev/null || echo "Fehler bei Berechnung")

echo "====================================="
echo -e "Verfügbarer Speicher vorher:  ${RED}${SPACE_BEFORE}GB${NC}"
echo -e "Verfügbarer Speicher nachher: ${GREEN}${SPACE_AFTER}GB${NC}"

if [[ "$SPACE_FREED" != "Fehler bei Berechnung" ]]; then
    if (( $(echo "$SPACE_FREED > 0" | bc -l) )); then
        echo -e "💾 ${GREEN}Speicher freigebeben: +${SPACE_FREED}GB${NC}"
    else
        # Manchmal kann die Messung ungenau sein
        echo -e "💾 ${YELLOW}Bereinigung abgeschlossen${NC}"
        echo "   (Speicherberechnung möglicherweise ungenau)"
    fi
else
    echo -e "💾 ${YELLOW}Bereinigung abgeschlossen${NC}"
    echo "   (bc nicht installiert für genaue Berechnung)"
fi

echo "====================================="
echo -e "${GREEN}✨ Xcode ist jetzt sauber!${NC}"

# Optional: Mülleimer leeren
echo
read -p "Möchtest du auch den Papierkorb leeren? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    osascript -e 'tell application "Finder" to empty trash'
    echo -e "${GREEN}🗑️  Papierkorb geleert!${NC}"
fi

echo -e "${BLUE}🎉 Fertig!${NC}"

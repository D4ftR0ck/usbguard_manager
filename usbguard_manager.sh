#!/bin/bash

# Définir les codes de couleur ANSI
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction pour afficher la liste des périphériques autorisés
list_allowed_devices() {
    echo -e "${GREEN}Liste des périphériques autorisés :${NC}"
    usbguard list-devices | grep "allow id" | while read -r line; do
        id_list=$(echo $line | awk '{print $1}')
        device_id=$(echo $line | awk '{print $4}')
        serial=$(echo $line | awk '{print $6}')
        name=$(echo $line | awk -F'name "' '{gsub(/".*/, "", $2); print $2}')
        hash=$(echo $line | awk -F'hash "' '{gsub(/".*/, "", $2); print $2}')
        parent_hash=$(echo $line | awk -F'parent-hash "' '{gsub(/".*/, "", $2); print $2}')
        via_port=$(echo $line | awk -F'via-port "' '{gsub(/".*/, "", $2); print $2}')
        with_connect_type=$(echo $line | awk -F'with-connect-type "' '{gsub(/".*/, "", $2); print $2}')
        # Extraire with-interface
        if [[ $line == *"with-interface {"* ]]; then
            with_interface=$(echo $line | awk -F'with-interface {' '{gsub(/}.*/, "", $2); print $2}')
        else
            with_interface=$(echo $line | awk -F'with-interface ' '{print $2}' | awk '{print $1}')
        fi
        echo -e "allow id ${YELLOW}$device_id${NC} serial ${GREEN}$serial${NC} name ${BLUE}$name${NC} hash ${YELLOW}$hash${NC} parent-hash ${YELLOW}$parent_hash${NC} via-port ${BLUE}$via_port${NC} with-interface ${GREEN}$with_interface${NC} with-connect-type ${RED}$with_connect_type${NC}"
    done
}

# Fonction pour afficher la liste des périphériques bloqués
list_blocked_devices() {
    echo -e "${RED}Liste des périphériques bloqués :${NC}"
    usbguard list-devices | grep "block id" | while read -r line; do
        id_list=$(echo $line | awk '{print $1}')
        device_id=$(echo $line | awk '{print $4}')
        serial=$(echo $line | awk '{print $6}')
        name=$(echo $line | awk -F'name "' '{gsub(/".*/, "", $2); print $2}')
        hash=$(echo $line | awk -F'hash "' '{gsub(/".*/, "", $2); print $2}')
        parent_hash=$(echo $line | awk -F'parent-hash "' '{gsub(/".*/, "", $2); print $2}')
        via_port=$(echo $line | awk -F'via-port "' '{gsub(/".*/, "", $2); print $2}')
        with_connect_type=$(echo $line | awk -F'with-connect-type "' '{gsub(/".*/, "", $2); print $2}')
        # Extraire with-interface
        if [[ $line == *"with-interface {"* ]]; then
            with_interface=$(echo $line | awk -F'with-interface {' '{gsub(/}.*/, "", $2); print $2}')
        else
            with_interface=$(echo $line | awk -F'with-interface ' '{print $2}' | awk '{print $1}')
        fi
        echo -e "block id ${YELLOW}$device_id${NC} serial ${GREEN}$serial${NC} name ${BLUE}$name${NC} hash ${YELLOW}$hash${NC} parent-hash ${YELLOW}$parent_hash${NC} via-port ${BLUE}$via_port${NC} with-interface ${GREEN}$with_interface${NC} with-connect-type ${RED}$with_connect_type${NC}"
    done
}

# Fonction pour ajouter un périphérique à la whitelist
add_device_to_whitelist() {
    if [ -z "$1" ]; then
        echo "Veuillez fournir l'ID du périphérique à ajouter à la whitelist."
        return
    fi

    device_id=$1
    echo -e "Ajout du périphérique ${YELLOW}$device_id${NC} à la whitelist..."
    usbguard allow-device $device_id
    sudo usbguard list-devices | sed 's/^[0-9]*: //' | sudo tee /etc/usbguard/rules.conf
}

# Fonction pour retirer un périphérique de la whitelist
remove_device_to_whitelist() {
    if [ -z "$1" ]; then
        echo "Veuillez fournir l'ID du périphérique à retirer à la whitelist."
        return
    fi

    device_id=$1
    echo -e "Suppression du périphérique ${YELLOW}$device_id${NC} de la whitelist..."
    usbguard block-device $device_id
    sudo usbguard list-devices | sed 's/^[0-9]*: //' | sudo tee /etc/usbguard/rules.conf
}

# Menu principal
while true; do
    echo -e "${BLUE}Menu USBGuard${NC}"
    echo "1. Voir la liste des périphériques autorisés"
    echo "2. Voir la liste des périphériques bloqués"
    echo "3. Ajouter un périphérique à la whitelist"
    echo "4. Supprimer un périphérique de la whitelist"
    echo "5. Quitter"
    read -p "Choisissez une option : " choice

    case $choice in
        1)
            list_allowed_devices
            ;;
        2)
            list_blocked_devices
            ;;
        3)
            read -p "Entrez l'ID du périphérique à ajouter à la whitelist : " device_id
            add_device_to_whitelist $device_id
            ;;
        4)
            read -p "Entrez l'ID du périphérique pour le supprimer de la whitelist : " device_id
            remove_device_to_whitelist $device_id
            ;;
        5)
            echo "Quitter le script."
            exit 0
            ;;
        *)
            echo "Option invalide. Veuillez réessayer."
            ;;
    esac
done

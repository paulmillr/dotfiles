#!/bin/bash

LIB_DIR="$HOME/Library"
APP_DIR="$HOME/Library/Application Support"
BACKUP_DIR="$HOME/Downloads/backup"
mkdir $BACKUP_DIR

function cpdir() {
  cp -R "$APP_DIR/$1" "$BACKUP_DIR/"
}

cp -R "$APP_DIR/1Password/1Password.agilekeychain" "$BACKUP_DIR/"
cp -R "$LIB_DIR/Keychains" "$BACKUP_DIR/"
cpdir "AddressBook"
cpdir "Adobe"
cpdir "Tower"
cpdir "Transmission"
cpdir "Transmit"
zip -r "$BACKUP_DIR/code.zip" "$HOME/Documents/code" > /dev/null
#!/bin/bash

# TODO: merge this and backup_system to one file.

LIB_DIR="$HOME/Library"
APP_DIR="$HOME/Library/Application Support"
BACKUP_DIR="$HOME/Downloads/backup"
mkdir $BACKUP_DIR

function cpdir() {
  cp -R "$BACKUP_DIR/" "$APP_DIR/$1"
}

cp -R "$BACKUP_DIR/1Password.agilekeychain" "$APP_DIR/1Password/"
cp -R "$BACKUP_DIR/Keychains" "$LIB_DIR/"
cpdir "AddressBook"
cpdir "Adobe"
cpdir "Tower"
cpdir "Transmission"
cpdir "Transmit"
mkdir "$HOME/Documents/code"
unzip "$BACKUP_DIR/code.zip" -d "$HOME/Documents/code" > /dev/null
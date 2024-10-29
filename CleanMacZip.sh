#!/bin/bash

# Initial settings
lang="ita"

# Set the interface language
function select_language() {
  echo "Scegli la lingua / Choose language:"
  echo "1) Italiano"
  echo "2) English"
  read choice
  case "$choice" in
    1) lang="ita" ;;
    2) lang="eng" ;;
    *) echo "Scelta non valida / Invalid choice"; select_language ;;
  esac
}

# Multilingual messages
function get_message() {
  local message_key=$1
  local additional_info=$2

  if [ "$lang" = "ita" ]; then
    case $message_key in
      "request_folder") echo "Inserisci il percorso della cartella da comprimere:" ;;
      "error_folder") echo "Errore: La cartella specificata non esiste." ;;
      "request_destination") echo "Vuoi salvare il file zip nella stessa directory della cartella? (s/n)" ;;
      "request_new_destination") echo "Inserisci il percorso della directory di destinazione:" ;;
      "error_destination") echo "Errore: La directory di destinazione non esiste." ;;
      "removing_files") echo "Rimozione dei file inutili dalla cartella..." ;;
      "creating_zip") echo "Creazione dello zip senza struttura directory superflua..." ;;
      "zip_success") echo "Zip pulito creato con successo: $additional_info" ;;
    esac
  else
    case $message_key in
      "request_folder") echo "Enter the folder path to compress:" ;;
      "error_folder") echo "Error: The specified folder does not exist." ;;
      "request_destination") echo "Do you want to save the zip file in the same directory as the folder? (y/n)" ;;
      "request_new_destination") echo "Enter the destination directory path:" ;;
      "error_destination") echo "Error: The destination directory does not exist." ;;
      "removing_files") echo "Removing unnecessary files from the folder..." ;;
      "creating_zip") echo "Creating zip file without unnecessary directory structure..." ;;
      "zip_success") echo "Clean zip created successfully: $additional_info" ;;
    esac
  fi
}

# Ask for the folder path and remove single quotes
function get_folder_path() {
  get_message "request_folder"
  read folder_path
  folder_path="${folder_path//\'/}"  # Remove single quotes

  if [ ! -d "$folder_path" ]; then
    get_message "error_folder"
    exit 1
  fi
}

# Ask and set the zip destination
function set_zip_destination() {
  get_message "request_destination"
  read same_directory

  if [[ "$same_directory" =~ ^[Nn]$ ]]; then
    get_message "request_new_destination"
    read destination
    destination="${destination//\'/}"  # Remove single quotes
    if [ ! -d "$destination" ]; then
      get_message "error_destination"
      exit 1
    fi
  else
    destination="$(dirname "$folder_path")"
  fi
}

# Remove unnecessary files before zipping
function clean_folder() {
  get_message "removing_files"
  find "$folder_path" \( -name "__MACOSX" -o -name ".DS_Store" -o -name "._*" \) -exec rm -rf {} +
}

# Create the zip without including unnecessary directory structure
function create_clean_zip() {
  zip_name="$destination/$(basename "$folder_path").zip"

  get_message "creating_zip"
  (
    cd "$(dirname "$folder_path")" || exit
    zip -r "$zip_name" "$(basename "$folder_path")"
  )

  get_message "zip_success" "$zip_name"
}

# Main function
function main() {
  select_language
  get_folder_path
  set_zip_destination
  clean_folder
  create_clean_zip
}

# Start main script
main

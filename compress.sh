#!/bin/bash

# Function to check if a directory or file exists
validate_existence() {
    if [ -e "$1" ]; then
        return 0
    else
        return 1
    fi
}

# Function to validate if the input is a valid integer
validate_integer() {
    if [[ "$1" =~ ^[0-9]+$ ]]; then
        return 0
    else
        return 1
    fi
}

# Function to validate if the input is a valid string without spaces
validate_string() {
    if [[ ! "$1" =~ [[:space:]] ]]; then
        return 0
    else
        return 1
    fi
}

# Function to ask for compression options
choose_compression_options() {
    echo "Choose compression options:"
    echo "1. Fast compression"
    echo "2. Normal compression"
    echo "3. Moderate compression"
    echo "4. Best compression"
    read -p "Enter the option number: " compression_option
    while ! validate_integer "$compression_option" || (( compression_option < 1 )) || (( compression_option > 4 )); do
        read -p "Invalid input. Enter a valid option number: " compression_option
    done
}

# Function to ask whether to add a password
ask_password() {
    read -p "Do you want to add a password? (y/n): " password_option
    while [[ ! "$password_option" =~ ^[yn]$ ]]; do
        read -p "Invalid input. Enter 'y' or 'n': " password_option
    done
    if [ "$password_option" = "y" ]; then
        read -s -p "Enter the password: " password
        echo
        while ! validate_string "$password"; do
            read -s -p "Invalid password. Please enter a password without spaces: " password
            echo
        done
        password_option="-p$password"
    else
        password_option=""
    fi
}

# Function to ask whether to split the file and the size of volumes
ask_splitting() {
    read -p "Do you want to split the file? (y/n): " split_option
    while [[ ! "$split_option" =~ ^[yn]$ ]]; do
        read -p "Invalid input. Enter 'y' or 'n': " split_option
    done
    if [ "$split_option" = "y" ]; then
        read -p "Enter the size of volumes in gigabytes or megabytes (g/m): " size_unit
        while [[ ! "$size_unit" =~ ^[gm]$ ]]; do
            read -p "Invalid input. Enter 'g' or 'm': " size_unit
        done
        read -p "Enter the size of volumes: " volume_size
        while ! validate_integer "$volume_size" || (( volume_size <= 0 )); do
            read -p "Invalid input. Enter a valid positive integer: " volume_size
        done
        case $size_unit in
            g)
                volume_option="-v${volume_size}g"
                ;;
            m)
                volume_option="-v${volume_size}m"
                ;;
        esac
    else
        volume_option=""
    fi
}

# Function to ask whether to delete the original file or folder after compression
ask_deletion() {
    read -p "Do you want to delete the original file or folder after compression? (y/n): " delete_option
    while [[ ! "$delete_option" =~ ^[yn]$ ]]; do
        read -p "Invalid input. Enter 'y' or 'n': " delete_option
    done
    if [ "$delete_option" = "y" ]; then
        delete_option="-sdel"
    else
        delete_option=""
    fi
}

# Function to compress the directory or file
compress_directory_or_file() {
    case $compression_option in
        1)
            compression_method="-m0=lzma -mx=1 -mfb=128 -md=16m -ms=on"
            ;;
        2)
            compression_method="-m0=lzma -mx=5 -mfb=64 -md=32m -ms=on"
            ;;
        3)
            compression_method="-m0=lzma -mx=7 -mfb=32 -md=64m -ms=on"
            ;;
        4)
            compression_method="-m0=lzma -mx=9 -mfb=64 -md=32m -ms=on"
            ;;
    esac
    7z a -t7z $password_option $volume_option $compression_method "$1.7z" "$1" $delete_option
}

# Main script
echo "Welcome to the file compression script!"
read -e -p "Enter the directory or file to compress: " input_path

while ! validate_existence "$input_path"; do
    read -e -p "Invalid path. Please enter a valid directory or file: " input_path
done

choose_compression_options

ask_password

ask_splitting

ask_deletion

compress_directory_or_file "$input_path"

echo "Compression completed successfully!"

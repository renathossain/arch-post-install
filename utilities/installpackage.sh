#!/bin/bash

# Clone and Install External Packages
install_external_package() {
    local package_name=$1
    local repo_link=$2
    local folder_name=$(basename "$repo_link" .git)

    if ! command -v $package_name &> /dev/null; then
        current_dir=$(pwd)
        cd /tmp
        git clone "$repo_link"
        cd $folder_name
        makepkg -si --noconfirm
        cd ..
        rm -rf $folder_name
        cd "$current_dir"
    fi
}

# Call the function with arguments passed to the script
install_external_package "$1" "$2"

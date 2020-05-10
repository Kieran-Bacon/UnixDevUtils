#!/bin/bash

if [ ! -f "./$1" ]; then
    echo "Unrecognised name. Exitting"
    exit
fi

if [ "$2" == "-g" ]; then
    global_flag="True"
else
    global_flag="False"
fi


sudo_link_install () {
    # Create a symbolic link to the file such that updates shall automatically be deployed
    sudo ln -s "$(pwd)/$1" "/usr/local/bin"

    # Update the permissions of file
    sudo chmod +x "/usr/local/bin/$1"
}

local_link_install () {
    # Create a symbolic link to the file such that updates shall automatically be deployed
    ln -s "$(pwd)/$1" "$HOME/bin"

    # Update the permissions of file
    chmod +x "$HOME/bin/$1"
}

link_install () {

    if [ $global_flag == "True" ]; then
        sudo_link_install $1
    else
        local_link_install $1
    fi

}

# Ensure that the user binary directory is made
if [ ! -d "$HOME/bin" ]; then
    mkdir "$HOME/bin"
fi

if [ $1 == "cloud" ]; then

    # Installing dependencies
    if [ $(uname) = "Darwin" ]; then
        brew install putty
    else
        sudo apt-get install putty-tools
    fi

    # Ensure that strong is installed before continuing
    if [ ! -f "$HOME/bin/strong" ]; then
        $0 "strong"
    fi

    # Add the alias for cloud
    echo "alias cloud=\"source cloud\"" >> "$HOME/.bash_aliases"

    # Ensure that cloud file exists
    if [ ! -f "$HOME/.cloud_addresses" ]; then
        touch "$HOME/.cloud_addresses"
    fi

    # Ensure that cloud file exists
    if [ ! -d "$HOME/.cloud_keys" ]; then
        mkdir "$HOME/.cloud_keys"
    fi

    # Install cloud ssh
    link_install "cloud_ssh"
    echo "alias ssh=cloud_ssh" >> "$HOME/.bash_aliases"

    # Trigger install for cloud sub system
    link_install "cloud_sftp"
    echo "alias sftp=cloud_sftp" >> "$HOME/.bash_aliases"

fi

if [ $1 == "strong" ]; then
    # Install the strong wrapper

    if [ ! -f "$HOME/.bash_aliases" ]; then
        touch "$HOME/.bash_aliases"
    fi

    echo "alias strong=\"source strong\"" >> "$HOME/.bash_aliases"
fi

if [ $1 == "pyenv" ]; then
    # Install the necessary python packages
    sudo apt-get install python3-pip python3-venv

    # Ensure that jupyter is installed and so is it's kernel
    pip3 install jupyter ipykernel

    # make the directory to save environments
    mkdir "$HOME/.pyenvs"

    # add the aliase of the
    echo "alias pyenv='source pyenv'" >> "$HOME/.bash_aliases"
fi

if [ $1 == "backup" ]; then
    # Make the backup directory - install the
    sudo apt-get install inotify-tools

    # Make the directory for storing info about backup logging
    mkdir "$HOME/.backup"
fi

if [ $1 == "profile" ]; then
    mkdir "$HOME/.profiles"
fi

link_install "$1"

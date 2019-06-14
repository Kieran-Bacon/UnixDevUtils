# installer

if [ ! -f "./$1" ]; then
    echo "Unrecognised name. Exitting"
    exit
fi

if [ $1 == "strong" ]; then
    # Install the strong wrapper

    if [ ! -f "$HOME/.bash_aliases" ]; then
        touch "$HOME/.bash_aliases"
    fi

    echo "alias strong=\"source strong\"" >> "$HOME/.bash_aliases"
fi

if [ $1 == "pyenv" ]; then
    # Install the virtual environment
    sudo apt-get install python3-venv

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

# Ensure that the user binary directory is made
if [ ! -d "$HOME/bin" ]; then
    mkdir "$HOME/bin"
fi

# Create a symbolic link to the file such that updates shall automatically be deployed
ln -s "$(pwd)/$1" "$HOME/bin"

# Update the permissions of file
chmod +x "$HOME/bin/$1"
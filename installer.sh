# installer

if [ $1 == "pyenv" ]; then
    # Install the virtual environment
    sudo apt-get install python3-venv

    # make the directory to save environments
    mkdir "$HOME/.pyenvs"

    # add the aliase of the
    echo "alias pyenv='source pyenv'" >> "$HOME/.bash_aliases"

    # Ensure that the user binary directory is made
    if [ ! -d "$HOME/bin" ]; then
        mkdir "$HOME/bin"
    fi

    # Copy the software to the binary directory
    cp ./pyenv "$HOME/bin/"

    # Update the permissions of file
    sudo chmod +x "$HOME/bin/pyenv"
fi

if [ $1 == "backup" ]; then
    # Make the backup directory - install the
    sudo apt-get install inotify-tools

    # Make the directory for storing info about backup logging
    mkdir "$HOME/.backup"

    # Copy the software to the binary directory
    cp ./backup "$HOME/bin/"

    # Update the permissions of file
    sudo chmod +x "$HOME/bin/backup"
fi
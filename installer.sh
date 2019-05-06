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

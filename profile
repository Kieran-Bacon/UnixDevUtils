#!/bin/bash

WORKDIR="$HOME/.config/.profiles"
CONFIGS="$WORKDIR/.configs"

help () {
    echo "USAGE: profile (options) (ARGS...) [GROUP] (OPTIONS) (ARGS...) [PROFILE]"
    echo ""
    echo "Profile is a system for switching application configuration files with another named file 'profile'."
    echo "This allows for easy switching of application behaviours - This system is not specifically integrated with"
    echo "anything."
    echo ""
    echo "      -a, --add       (GROUPNAME) (CONFIGPATH) *(PROFILENAME)"
    echo "                                              Create a new group config path is switch location, if config at"
    echo "                                              location then it becomes the initial profile config"
    echo "      -e, --edit      (GROUPNAME)         Edit the currently active config for the group"
    echo "      -d, --delete    (GROUPNAME)         Delete a group"
    echo "      -l, --list                          Show all groups"
    echo "      -h, --help                          Display the help page"
    echo ""
    echo "GROUP options"
    echo "      -a, --add       (PROFILENAME)       Add a new profile"
    echo "      -e, --edit      (PROFILENAME)       Edit the config of the profile given"
    echo "      -c, --copy      (PROFILENAME) (ANOTHER PROFILENAME)"
    echo "                                          Copy a profile to act as the starting point for a new profile (or"
    echo "                                              overwrite the profile at destination)"
    echo "      -d, --delete    (PROFILENAME)       Detele profile"
    echo "      -l, --list                          Show all profiles"
    echo ""
    echo "Examples:"
    echo "      $ profile -a aws ~/.aws/credentials     # Create a new profile setup for aws (profile name defaults to default)"
    echo "      $ profile aws -a local                  # Opens up an editor to a new config profile named local"
    echo "      $ profile aws local                     # Switch the active profile to the newly created profile"
    echo "      $ profile -e aws                        # Starts editting the profile local"
    echo "      $ profile aws -e default                # Edit the original config file at the point of setup"
    echo "      $ profile aws default                   # Switch the active profile back to the original config"
    echo ""
    echo ""

}

getActiveProfile () {
    config=$(dict $CONFIGS -g $1)
    profile=$(readlink -f $config)
    echo $(basename $profile)
}

# check that argumenta have been passed
if [ $# -eq "0" ]; then
    help
    exit
fi

argIndex=0  # Setup parse counter
arguments=($@)  # Pack arguments into a list
group=

for var in "$@"
do
    # Parse the arguments
    if [ $var == "-h" ] || [ $var == "--help" ]; then
        help
        break
    fi

    if [ $argIndex == 0 ]; then

        if [[ $var = -* ]]; then
            # An option passed

            if [ $var = "-a" ] || [ $var = "--add" ]; then
                # Add a new group to Profile

                # Process the given group name
                groupname=${arguments[1]}
                group="$WORKDIR/$groupname"

                if [ -d "$group" ]; then
                    # The group already exists raise error and end
                    echo "ERROR: A group by that name already exists - delete it first"
                    exit
                fi

                # Get the abspath for the config or exit if not viable
                config=$(realpath ${arguments[2]})
                if [ $? == 1 ]; then
                    echo "ERROR: Invalid config path"
                    exit
                fi

                # Define the profile name to be created
                if [ ! -z "${arguments[3]}" ]; then
                    profilename=${arguments[3]}
                else
                    profilename="default"
                fi
                profile="$group/$profilename"

                echo "Creating group '$groupname' with profile '$profilename'"

                # Make the group
                mkdir "$group"

                if [ -f $config ]; then
                    mv $config $profile
                else
                    touch $profile
                fi

                ln -s $profile $config
                dict $CONFIGS -a $groupname $config

            elif [ $var = "-e" ] || [ $var = "--edit" ]; then

                groupname=${arguments[1]}
                group="$WORKDIR/$groupname"

                if [ -d $group ]; then
                    nano "$group/$(getActiveProfile $groupname)"
                else
                    echo "ERROR: Group ($groupname) doesn't exit have a profile with that name ($profilename)"
                    exit
                fi

            elif [ $var = "-d" ] || [ $var = "--delete" ]; then
                # Delete a group and restore application config

                groupname=${arguments[1]}
                group="$WORKDIR/$groupname"

                if [ -d $group ]; then

                    # Get the group config location and the path to the currently selected config
                    configpath=$(dict $CONFIGS -g $groupname)
                    selectedConfig=$(readlink -f $configpath)

                    echo "Deleting group $groupname - restoring config to be profile $(basename $selectedConfig)"

                    # Remove the symlink to Profile and replace with the currently active config
                    rm $configpath
                    mv $selectedConfig $configpath

                    # Remove the group information
                    rm -r $group

                    # Remove the group config path record
                    dict $CONFIGS -d $groupname

                else
                    echo "ERROR: Cannot delete group $groupname as it does not exist"
                    exit
                fi
            elif [ $var = "-l" ] || [ $var = "--list" ]; then

                echo "Groups:"
                dict $CONFIGS --keys

            else
                echo "ERROR: Unrecognised option: $var"
                echo ""
                help
                exit
            fi

            # There actions end on this iteration
            exit
        else
            # Accessing Group information

            groupname=$var
            group="$WORKDIR/$groupname"

            if [ ! -d "$WORKDIR/$var" ]; then
                echo "ERROR: Could not find group with the given name: $var"
                exit
            fi

        fi

    fi

    if [ $argIndex == 1 ]; then
        # Working on the profile

        if [[ $var = -* ]]; then

            if [ $var = "-a" ] || [ $var = "--add" ]; then
                # Add profile
                profilename=${arguments[2]}
                echo "Creating profile $profilename for $groupname"
                touch "$group/$profilename"

            elif [ $var = "-e" ] || [ $var = "--edit" ]; then

                profilename=${arguments[2]}
                profile="$group/$profilename"

                if [ -f $profile ]; then
                    nano $profile
                else
                    echo "ERROR: Group ($groupname) doesn't have a profile with that name ($profilename)"
                    exit
                fi

            elif [ $var = "-c" ] || [ $var = "--copy" ]; then

                profilename=${arguments[2]}
                profile="$group/$profilename"

                newprofilename=${arguments[3]}
                newprofile="$group/$newprofilename"

                if [ -f $profile ]; then
                    cp $profile $newprofile
                else
                    echo "ERROR: Group ($groupname) doesn't have a profile with that name ($profilename)"
                    exit
                fi

            elif [ $var = "-d" ] || [ $var = "--delete" ]; then

                profilename=${arguments[2]}
                profile="$group/$profilename"

                if [ -f $profile ]; then

                    # Get the currently active profile
                    activeProfile=$(getActiveProfile $groupname)

                    if [ $profilename == $activeProfile ]; then
                        echo "ERROR: You cannot delete the active profile. Switch before deleting."
                        exit
                    fi

                    echo "Deleting profile $profilename from $groupname"

                    rm $profile

                else
                    echo "ERROR: Group ($groupname) doesn't have a profile with that name ($profilename)"
                    exit
                fi

            elif [ $var = "-l" ] || [ $var = "--list" ]; then

                echo "$groupname profiles:"
                activeProfile=$(getActiveProfile $groupname)

                for profile in $(ls $group)
                do
                    if [ $profile == $activeProfile ]; then
                        profile="*$profile"
                    fi
                    echo "    $profile"
                done
            else
                echo "Unrecognised option: $var"
                echo ""
                help
                exit
            fi

        else
            # Select the profile given
            profile="$group/$var"

            if [ -f $profile ]; then
                echo "Switching profile for $groupname to $(basename $profile)"

                # The profile exists
                configpath=$(dict $CONFIGS -g $groupname)

                rm $configpath
                ln -s $profile $configpath
            else
                echo "A profile with the given name doesn't exist"
                exit
            fi
        fi
    fi

    # Increment the argument parser index
    let argIndex=argIndex+1
done
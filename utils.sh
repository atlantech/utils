#!/bin/bash

# contains set of useful commands 
# for development purposes

UTIL="$1"
HANDLER="$1-util"
FILENAME="$0"

csfixer=$(which php-cs-fixer)
commands=("cs-fixer" "git")

if [ -x /usr/bin/tput ] && tput setaf 1 &> /dev/null ; then
    color_prompt="true"
else
    color_prompt=
fi

if [ "$color_prompt" == "true" ] ; then
    usage=(
        "\033[33mUsage:\033[30m\n  ./utils [util] [options]\n"
        "\033[33mOptions:"
        "\033[32m  --help\033[30m        Display help message\n"
        "\033[33mAvailable utils:\033[32m")
else
    usage=(
        "Usage:\n./utils [util] [options]\n"
        "Options:"
        "  --help        Display help message\n"
        "Available utils:")
fi

for command in "${commands[@]}" ; do
    usage+=("  $command")
done

if [ ! "$1" ] || [ "$1" == "--help" ] || [ "$1" == "help" ] ; then
    for line in "${usage[@]}" ; do
        echo -e "$line"
    done
    exit 0
fi

function cs-fixer-util {
    if [[ ! -x "$csfixer" ]] ; then
        echo "Php-cs-fixer.phar not found."
        while true; do
            read -p "Would you like to install php-cs-fixer locally? [y/n] " YN
            case $YN in
                [Yy]* )
                    echo "Downloading..."
                    wget http://get.sensiolabs.org/php-cs-fixer.phar
                    chmod a+x php-cs-fixer.phar
                    csfixer="./php-cs-fixer.phar"
                    break
                    ;;
                [Nn]* ) exit ;;
                    * ) echo "Yes or no: ";;
            esac
        done
    fi

    case "$1" in
        "fix" ) shift; eval "git diff --name-only HEAD | grep .php | xargs -i $csfixer fix {} $@";;
        *)  
            if [ "$color_prompt" == "true" ] ; then
                usage="\033[33mUsage:\033[30m"
                description="\033[32mDescription:\033[30m"
            else
                usage="Usage:"
                description="Description:"
            fi
            echo -e $usage
            echo -e "  $FILENAME $UTIL fix [cs-fixer-args]\n"
            echo -e $description
            echo    "  Perform codestyle fix in modified .php files."
            exit 1  
    esac 

    exit 0
}

function git-util {
    case "$1" in
        "clear-branches" )
            pattern=${2:-task}
            remote=${3:-origin}
            IFS='\n ' read -r -a branches <<< $(git branch | grep $pattern)
            for branch in "${branches[@]}" ; do
                (git push origin --force --delete $branch)
                (git branch -D $branch)
            done
            ;;
        * )
            if [ "$color_prompt" == "true" ] ; then
                usage="\033[33mUsage:\033[30m"
                description="\033[32mDescription:\033[30m"
            else
                usage="Usage:"
                description="Description:"
            fi

            echo -e $usage
            echo -e "  $FILENAME $UTIL clear-branches [grep-pattern] [remote]\n"
            echo -e $description
            echo    "  Remove git branches both local and remote by pattern."
            echo    "  Pattern by default is 'task', remote 'origin'."

            exit 1
            ;;
    esac

    exit 0
}

shift
eval "$HANDLER" "$@"
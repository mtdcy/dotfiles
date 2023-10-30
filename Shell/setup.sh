#!/bin/bash

cd $(dirname $0) && cd $(pwd -P)
. xlib.sh

function usage {
    cat << EOF
setup.sh [options]
    +git                        - setup git alias
    +git-user [name] [email]    - setup git user name and email
    +git-proxy [url] [proxy]    - setup proxy for url
    +proxy [iterface] [proxy]   - setup system proxy
EOF
}

function setup_git_alias {
    which git > /dev/null || ( xlog "git is missing..."; exit 1 )

	which less > /dev/null && 
	git config --global --replace-all core.pager "less -F -X" ||
	git config --global --replace-all core.pager "more"

    git config --global --replace-all push.default simple
    git config --global --replace-all core.editor vim
    git config --global --replace-all merge.tool vimdiff
    git config --global --replace-all merge.conflictstyle diff3
    git config --global --replace-all mergetool.prompt false
    git config --global --replace-all diff.tool vimdiff

    git config --global --replace-all core.autocrlf false
    git config --global --replace-all core.mergeoptions --no-edit
    git config --global --replace-all core.excludesfile '*.swp'
    echo "setting alias"
    git config --global --replace-all alias.pl "pull --rebase"
    git config --global --replace-all alias.st status 
    git config --global --replace-all alias.co checkout
    git config --global --replace-all alias.ci commit
    git config --global --replace-all alias.br branch 
    git config --global --replace-all alias.cp "cherry-pick --no-ff -x" 
    git config --global --replace-all alias.lg1 "log -n 1 --color --name-status --parents"
    git config --global --replace-all alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cn - %ci)'"
    git config --global --replace-all alias.lga "log --color --graph --all --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cn - %cr)'"
    git config --global --replace-all alias.list "log --oneline --no-merges --reverse"
}

# setup_git_user [name] [email]
function setup_git_user {
    name=$1
    email=$2
    [ -z "$name" ] && read -p "Please enter git user name: " name
    [ -z "$email" ] && read -p "Please enter git user email: " email 

    #echo "git user name: $name, email: $email"
    [ ! -z "$name" ] && git config --global --replace-all user.name  "$name"
    [ ! -z "$email" ] && git config --global --replace-all user.email "$email"
}

# setup_git_proxy <url> [proxy]
function setup_git_proxy {
    [ $# -lt 1 ] && exit 1

    url=$1
    proxy=$2
    if [ -z "$proxy" ]; then
        read -p "Please enter proxy for $url: " proxy
        proxy=${proxy#http://}
        proxy=${proxy#https://}
    fi

    if [ -z "$proxy" ]; then
        echo "unset proxy for $url"
        case "$url" in
            "http://"*)
                eval -- git config --global --unset http.$url.proxy
                ;;
            "https://"*)
                eval -- git config --global --unset https.$url.proxy
                ;;
            *)
                eval -- git config --global --unset http.http://$url.proxy
                eval -- git config --global --unset https.https://$url.proxy
                ;;
        esac
    else
        echo "set proxy for $url @ $proxy"
        case "$url" in
            "http://"*)
                git config --global --replace http.$url.proxy socks5://$proxy 
                ;;
            "https://"*)
                git config --global --replace https.$url.proxy socks5://$proxy 
                ;;
            *)
                git config --global --replace http.http://$url.proxy socks5://$proxy 
                git config --global --replace https.https://$url.proxy socks5://$proxy 
                ;;
        esac
    fi
}

# setup_system_proxy [iterface] [proxy]
function setup_system_proxy {
    itf=$1
    proxy=$1

    [ -z "$itf" ] && itf=$(select_network_interface)
    [ -z "$proxy" ] && read -p "Please enter proxy(e.g: 127.0.0.1:7070, leave it blank to disable proxy): " proxy

    case $(os_name) in 
        macOS)
            if [ -z "$proxy" ]; then
                echo "disable system proxy @ $itf"
                networksetup -setwebproxystate "$itf" off
                networksetup -setsecurewebproxystate "$itf" off
                networksetup -setsocksfirewallproxystate "$itf" off
            else
                echo "set system proxy to $proxy @ $itf"
                host=$(echo $proxy | cut -d: -f1)
                port=$(echo $proxy | cut -d: -f2)
                networksetup -setwebproxystate "$itf" on 
                networksetup -setsecurewebproxystate "$itf" on
                networksetup -setsocksfirewallproxystate "$itf" on

                networksetup -setwebproxy "$itf" $host $port
                networksetup -setsecurewebproxy "$itf" $host $port
                networksetup -setsocksfirewallproxy "$itf" $host $port
            fi
            ;;
        *)
            ;;
    esac
}

while [ $# -gt 0 ]; do
    opt=$1; shift
    pars=()
    while [ $# -gt 0 ] && [ "$1" != "+"* ]; do
        pars+=($1); shift
    done

    #echo "opt: $opt, pars: ${pars[@]}"
    case "$opt" in
        "+git")
            setup_git_alias
            ;;
        "+git-user")
            setup_git_user ${pars[@]}
            ;;
        "+git-proxy")
            setup_git_proxy ${pars[@]}
            ;;
        "+proxy")
            setup_system_proxy ${pars[@]}
            ;;
        *)
            usage 
            break
            ;;
    esac
done

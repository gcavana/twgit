#!/bin/bash

##
# Bash completion support for twgit.
# Dest path: /etc/bash_completion.d/twgit
# Install: sudo make install
#
# Copyright (c) 2011 Twenga SA.
#
# This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
# To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/
# or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
#
# @copyright 2011 Twenga SA
# @copyright 2012 Geoffroy Aubry <geoffroy.aubry@free.fr>
# @license http://creativecommons.org/licenses/by-nc-sa/3.0/
#



function _twgit () {
    COMPREPLY=()
    local cur="${COMP_WORDS[COMP_CWORD]}"

    if [ "$COMP_CWORD" = "1" ]; then
        local opts="clean feature help init hotfix release tag update"
        COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )

    elif [ "$COMP_CWORD" = "2" ]; then
        local command="${COMP_WORDS[COMP_CWORD-1]}"
        case "${command}" in
            feature)
                local opts="committers help list merge-into-release migrate remove show-modified-files start"
                COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
                ;;
            hotfix)
                local opts="finish help list remove start"
                COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
                ;;
            release)
                local opts="committers finish help list remove reset start"
                COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
                ;;
            tag)
                local opts="help list"
                COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
                ;;
        esac

    elif [ "$COMP_CWORD" -gt "2" ]; then
        local command="${COMP_WORDS[1]}"
        local action="${COMP_WORDS[2]}"
        case "${command}" in
            feature)
                case "${action}" in
                    committers)
                         if [[ ${cur} != -* ]] ; then
                            local opts=$((git branch -r | grep "feature-" | sed 's/^[* ]*//' | sed 's#^origin/feature-##' | tr '\n' ' ') 2>/dev/null)
                            COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
                        else
                            local opts="-F"
                            COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
                        fi
                        ;;
                    list)
                        if [[ ${cur} == -* ]] ; then
                            local opts="-F -c -x"
                            COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
                        fi
                        ;;
                    start)
                        if [[ ${cur} == -* ]] ; then
                            local opts="-d"
                            COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
                        fi
                        ;;
                esac
                ;;

            hotfix)
                case "${action}" in
                    xxxxxxx)
                         if [[ ${cur} != -* ]] ; then
                            local opts=$((git branch -r | grep "hotfix-" | sed 's/^[* ]*//' | sed 's#^origin/hotfix-##' | tr '\n' ' ') 2>/dev/null)
                            COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
                        fi
                        ;;
                        finish)
                        if [[ ${cur} == -* ]] ; then
                            local opts="-I"
                            COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
                        fi
                        ;;
                    list)
                        if [[ ${cur} == -* ]] ; then
                            local opts="-F"
                            COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
                        fi
                        ;;
                esac
                ;;

            release)
                case "${action}" in
                    committers)
                         if [[ ${cur} == -* ]] ; then
                            local opts="-F"
                            COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
                        fi
                        ;;
                    finish)
                         if [[ ${cur} != -* ]] ; then
                            local opts=$((git branch -r | grep "release-" | sed 's/^[* ]*//' | sed 's#^origin/release-##' | tr '\n' ' ') 2>/dev/null)
                            COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
                        else
                            local opts="-I"
                            COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
                        fi
                        ;;
                    list)
                        if [[ ${cur} == -* ]] ; then
                            local opts="-F"
                            COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
                        fi
                        ;;
                    start)
                        if [[ ${cur} == -* ]] ; then
                            local opts="-I -M -m"
                            COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
                        fi
                        ;;
                esac
                ;;
        esac
    fi
}

complete -F _twgit twgit
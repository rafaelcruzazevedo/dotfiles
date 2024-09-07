#!/bin/bash
# STATUS PLUS.
#
# Show git status grouped by commit id.
# Handy tool before fixup.
#
# Features:
# - Show file present in multiple commits
# - Show only branch commits based on multiple methods
# - Colorful
# - KISS
git-st-plus() {
    initialHash='';
    branchName=`git branch | sed -n '/\* /s///p'`;
    hasOriginMaster=`git log origin/master..  2>&1 | head -n1 | cut -c1-5`;
    hasUpstreamMaster=`git log upstream/master..  2>&1 | head -n1 | cut -c1-5`;
    # Check branch hashes form upstream or origin or local.
    if [[ "fatal" != "$hasUpstreamMaster" ]]; then
        branchHashes=`
            git log upstream/master.. |
            cat |
            cut -c1- | cut -d ' ' -f 1 |
            perl -pe 's/\e\[?.*?[\@-~]//g'
        `;
    else
        if [[ "fatal" != "$hasOriginMaster" ]]; then
            branchHashes=`
                git log origin/master.. |
                cat |
                cut -c1- | cut -d ' ' -f 1 |
                perl -pe 's/\e\[?.*?[\@-~]//g'
            `;
        else
            # Git log to get commits only for a specific branch by: @dimirc
            # http://stackoverflow.com/q/14848274
            branchHashes=`
                git log $branchName --not $(git for-each-ref --format='%(refname)' refs/heads/ | grep -v "refs/heads/$branchName") |
                cat |
                cut -c1- | cut -d ' ' -f 1 |
                perl -pe 's/\e\[?.*?[\@-~]//g'
            `;
        fi
    fi
    if [[ '' == "$branchHashes" ]]; then
        echo;
        echo "$(tput setaf 1)No commits in this branch yet!$(tput sgr0)";
        echo;
        git status -s;
        return;
    fi
    firstHash=`echo $branchHashes | cut -d' ' -f 1`;
    lastHash=`echo $branchHashes | rev | cut -d' ' -f 1 | rev`;
    # Suggest amend instead.
    if [[ "$firstHash" == "$lastHash" ]]; then
        echo "Only one commit in this branch use amend instead:";
        echo "$(tput setaf 2)git$(tput sgr0) ci --amend";
        echo;
    fi
    lastHash=`echo "$lastHash~1"`;
    header=`echo "## $branchName $(tput setaf 2)$lastHash$(tput sgr0)..$(tput setaf 1)$firstHash$(tput sgr0)"`;
    # Show header with branch name and hashes interval.
    # echo $header;
    # For each file in current `git status -s`
    git status -s --porcelain --untracked-files=no |
        # Remove moves, paths with ' -> '
        grep -v '>' |
        # Avoid trim with a trailing `=`.
        sed -E 's/(^.)/=\1/' |
        perl -pe 's/\e\[?.*?[\@-~]//g' |
        sed -E 's/\"//g' |
        while
            read file;
        do
            # Remove `=`
            file=`echo "$file" | cut -c2-`;
            state=`echo "$file" | cut -c1-2`;
            file=`echo "$file" | cut -c4-`;
            if [[ 'D ' != $state ]]; then
                if [[ ' D' != $state ]]; then
                    if [[ 'R ' != $state ]]; then
                        hash=`git log --pretty=oneline --abbrev-commit "$lastHash..$firstHash" "$file" | cut -c1-7 | perl -pe 's/\n/_/g' | sed 's/_$//'`;
                    fi
                fi
            fi
            coloredHash="$(tput setaf 1)$hash$(tput sgr0)";
            if [ '' == "$hash" ]; then
                hash='-------'
            fi
            if [ '' == "$state" ]; then
                state="--"
            fi
            echo "$state $hash $file";
            initialHash="$hash"
        done |
        # Avoid trim with a trailing `=`.
        sed -E 's/^\ /=/' |
        sed -E 's/^(.)\ /\1=/' |
        sed -E 's/\"//g' |
        sort -r -k2 |
        while
            read st;
        do
            # Remove `=`
            st=`echo "$st" | sed -E 's/(^=)/ /'`;
            st=`echo "$st" | sed -E 's/^(.)=/\1 /'`;
            state=`echo "$st" | cut -c1-2`;
            hash=`echo "$st" | cut -c4-10`;
            hashesSeparator=`echo "$st" | cut -c11-11`;
            hashes=`echo "$st" | cut -c4- | cut -d ' ' -f1 | sed 's/_/ /'`;
            file=`echo "$st" | rev | cut -d ' ' -f1 | rev`;
            coloredHash="$(tput setaf 1)$hash$(tput sgr0)";
            coloredHashes="$(tput setaf 1)$hashes$(tput sgr0)";
            coloredState=`
                echo "$state" |
                sed "s/^\(.\)M/\\1$(tput setaf 3)M$(tput sgr0)/" |
                sed "s/^M/$(tput setaf 2)M$(tput sgr0)/" |
                sed "s/^R/$(tput setaf 2)R$(tput sgr0)/" |
                sed "s/^D/$(tput setaf 1)D$(tput sgr0)/" |
                sed "s/\ D/$(tput setaf 1) D$(tput sgr0)/" |
                sed "s/^A/$(tput setaf 2)A$(tput sgr0)/" |
                sed "s/^??/$(tput setaf 6)??$(tput sgr0)/"
            `;
            if [ '-------' != "$hash" ]; then
                if [ "$initialHash" != "$hash" ]; then
                    echo;
                    # Commit name.
                    echo -n "$coloredHash `git log -n 1 --pretty=format:'%C(yellow)%s%Creset (%cr) <%an>' --abbrev-commit $hash`";
                    echo;
                fi
            else
                if [ "$initialHash" != "$hash" ]; then
                    echo;
                    echo "$(tput setaf 6)#######$(tput sgr0) Not commited in this branch yet";
                fi
            fi
            echo "$coloredState $file";
            if [[ '_' == "$hashesSeparator" ]]; then
                echo "$(tput setaf 6)   ^-- $(tput sgr0)$coloredHashes$(tput setaf 6) File present in multiple commits.$(tput sgr0)";
            fi
            initialHash="$hash"
        done;
    # Show untracked.
    git status -s | grep ?? | cat | sed "s/^??/$(tput setaf 6)??$(tput sgr0)/";
    # Show rename
    renameFiles=`git status -s | grep '>' | cat | sed "s/^??/$(tput setaf 6)??$(tput sgr0)/"`;
    if [[ $renameFiles ]]; then
        echo;
        echo "$(tput setaf 6)#######$(tput sgr0) Rename";
        echo "$renameFiles";
    fi
}
git-st-plus;

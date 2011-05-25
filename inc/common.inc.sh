#!/bin/bash


#^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# User interface
#____________________________________________________________________

# Map des colorations et en-têtes des messages du superviseur :
declare -A UI
UI=(
	[error.header]='\033[0;33m/!\ '
	[error.color]='\033[1;31m'
	[info.color]='\033[1;37m'
	[help.header]='\033[1;36m(i) '
	[help.color]='\033[0;36m'
	[help_detail.header]='    '
	[help_detail.color]='\033[0;37m'
	[help_detail.bold.color]='\033[1;37m'
	[normal.color]='\033[0;37m'
	[warning.header]='\033[33m/!\ '
	[warning.color]='\033[0;33m'
	[processing.color]='\033[1;30m'
)

function processing {
	displayMsg processing "$1"; 
}

function info { 
	displayMsg info "$1"; 
}

function help { 
	displayMsg help "$1"; 
}

function help_detail { 
	displayMsg help_detail "$1"; 
}

function warn { 
	displayMsg warning "$1" >&2; 
}

function error { 
	displayMsg error "$1" >&2;
}

function die {
	error "$1"
	echo
	exit 1
}

# Affiche un message dans la couleur et avec l'en-tête correspondant au type spécifié.
#
# @param string $1 type de message à afficher : conditionne l'éventuelle en-tête et la couleur
# @ parma string $2 message à afficher
function displayMsg {
	local type=$1
	local msg=$2
	
	local is_defined=`echo ${!UI[*]} | grep "\b$type\b" | wc -l`
	[ $is_defined = 0 ] && echo "Unknown display type '$type'!" >&2 && exit 1
	local escape_color=$(echo ${UI[$type'.color']} | sed 's/\\/\\\\/g')
	local escape_bold_color=$(echo ${UI[$type'.bold.color']} | sed 's/\\/\\\\/g')
	
	if [ ! -z "${UI[$type'.header']}" ]; then
		echo -en "${UI[$type'.header']}"
	fi
	msg=$(echo "$msg" | sed "s/<b>/$escape_bold_color/g" | sed "s#</b>#$escape_color#g")
	echo -e "${UI[$type'.color']}$msg${UI['normal.color']}"
}



#^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# Get
#____________________________________________________________________

function get_all_branches { 
	( git branch --no-color; git branch -r --no-color) | sed 's/^[* ] //';
}

function get_local_branches { 
	git branch --no-color | sed 's/^[* ] //';
}

function get_remote_branches { 
	git branch -r --no-color | sed 's/^[* ] //'; 
}

function get_current_branch { 
	git branch --no-color | grep '^\* ' | grep -v 'no branch' | sed 's/^* //g'
}

function get_all_tags {
	git tag | sort -n;
}

function get_last_tag {
	git tag | sort -rn | head -n1
}



#^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# Questions
#____________________________________________________________________

function is_branch_exists {
	has $1 $(get_all_branches)
}



#^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# Assertions
#____________________________________________________________________

function assert_git_configured {
	if ! git config --global user.name 1>/dev/null; then
		die "Unknown user.name! Do: git config --global user.name 'Firstname Lastname'"
	elif ! git config --global user.email 1>/dev/null; then
		die "Unknown user.email! Do: git config --global user.email 'firstname.lastname@twenga.com'"
	fi
}

function assert_git_repository {
	local errormsg=$(git rev-parse --git-dir 2>&1 1>/dev/null)
	[ ! -z "$errormsg" ] && die "[Git error msg] $errormsg"
}

function assert_branches_equal {
	assert_local_branch "$1"
	assert_remote_branch "$2"
	git_compare_branches "$1" "$2"
	local status=$?
	if [ $status -gt 0 ]; then
		warn "Branches '$1' and '$2' have diverged."
		if [ $status -eq 1 ]; then
			die "And branch '$1' may be fast-forwarded."
		elif [ $status -eq 2 ]; then
			# Warn here, since there is no harm in being ahead
			warn "And local branch '$1' is ahead of '$2'."
		else
			die "Branches need merging first."
		fi
	fi
}

function require_arg {
	if [ -z "$2" ]; then
		error "Missing argument <$1>!"
		usage
		exit 1
	fi	
}

function assert_clean_working_tree {
	if [ `git status --porcelain --ignore-submodules=all | wc -l` -ne 0 ]; then
		die 'Untracked files or changes to be committed in your working tree! Try: git status'
	fi
}

function assert_valid_ref_name {
	git check-ref-format --branch "$1" 1>/dev/null 2>&1
	if [ $? -ne 0 ]; then
		die "'$1' is not a valid reference name!"
	fi
	
	echo $1 | grep -vP "^$TWGIT_PREFIX_FEATURE" \
		| grep -vP "^$TWGIT_PREFIX_RELEASE" \
		| grep -vP "^$TWGIT_PREFIX_HOTFIX" \
		| grep -vP "^$TWGIT_PREFIX_DEMO" 1>/dev/null
	if [ $? -ne 0 ]; then
		die 'Unauthorized reference prefix! Pick another name.'
	fi
}

function assert_valid_release_name {
	local release="$1"
	assert_valid_ref_name "$release"
}



#^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# Tools
#____________________________________________________________________

function escape {
	echo "$1" | sed 's/\([\.\+\$\*]\)/\\\1/g'
}

function has {
	local item=$1; shift
	echo " $@ " | grep -q " $(escape $item) "
}
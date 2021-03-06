#compdef faas

__faas-cli_bash_source() {
	alias shopt=':'
	alias _expand=_bash_expand
	alias _complete=_bash_comp
	emulate -L sh
	setopt kshglob noshglob braceexpand
	source "$@"
}
__faas-cli_type() {
	# -t is not supported by zsh
	if [ "$1" == "-t" ]; then
		shift
		# fake Bash 4 to disable "complete -o nospace". Instead
		# "compopt +-o nospace" is used in the code to toggle trailing
		# spaces. We don't support that, but leave trailing spaces on
		# all the time
		if [ "$1" = "__faas-cli_compopt" ]; then
			echo builtin
			return 0
		fi
	fi
	type "$@"
}
__faas-cli_compgen() {
	local completions w
	completions=( $(compgen "$@") ) || return $?
	# filter by given word as prefix
	while [[ "$1" = -* && "$1" != -- ]]; do
		shift
		shift
	done
	if [[ "$1" == -- ]]; then
		shift
	fi
	for w in "${completions[@]}"; do
		if [[ "${w}" = "$1"* ]]; then
			echo "${w}"
		fi
	done
}
__faas-cli_compopt() {
	true # don't do anything. Not supported by bashcompinit in zsh
}
__faas-cli_ltrim_colon_completions()
{
	if [[ "$1" == *:* && "$COMP_WORDBREAKS" == *:* ]]; then
		# Remove colon-word prefix from COMPREPLY items
		local colon_word=${1%${1##*:}}
		local i=${#COMPREPLY[*]}
		while [[ $((--i)) -ge 0 ]]; do
			COMPREPLY[$i]=${COMPREPLY[$i]#"$colon_word"}
		done
	fi
}
__faas-cli_get_comp_words_by_ref() {
	cur="${COMP_WORDS[COMP_CWORD]}"
	prev="${COMP_WORDS[${COMP_CWORD}-1]}"
	words=("${COMP_WORDS[@]}")
	cword=("${COMP_CWORD[@]}")
}
__faas-cli_filedir() {
	local RET OLD_IFS w qw
	__faas-cli_debug "_filedir $@ cur=$cur"
	if [[ "$1" = \~* ]]; then
		# somehow does not work. Maybe, zsh does not call this at all
		eval echo "$1"
		return 0
	fi
	OLD_IFS="$IFS"
	IFS=$'\n'
	if [ "$1" = "-d" ]; then
		shift
		RET=( $(compgen -d) )
	else
		RET=( $(compgen -f) )
	fi
	IFS="$OLD_IFS"
	IFS="," __faas-cli_debug "RET=${RET[@]} len=${#RET[@]}"
	for w in ${RET[@]}; do
		if [[ ! "${w}" = "${cur}"* ]]; then
			continue
		fi
		if eval "[[ \"\${w}\" = *.$1 || -d \"\${w}\" ]]"; then
			qw="$(__faas-cli_quote "${w}")"
			if [ -d "${w}" ]; then
				COMPREPLY+=("${qw}/")
			else
				COMPREPLY+=("${qw}")
			fi
		fi
	done
}
__faas-cli_quote() {
	if [[ $1 == \'* || $1 == \"* ]]; then
		# Leave out first character
		printf %q "${1:1}"
	else
	printf %q "$1"
	fi
}
autoload -U +X bashcompinit && bashcompinit
# use word boundary patterns for BSD or GNU sed
LWORD='[[:<:]]'
RWORD='[[:>:]]'
if sed --help 2>&1 | grep -q GNU; then
	LWORD='\<'
	RWORD='\>'
fi
__faas-cli_convert_bash_to_zsh() {
	sed \
	-e 's/declare -F/whence -w/' \
	-e 's/_get_comp_words_by_ref "\$@"/_get_comp_words_by_ref "\$*"/' \
	-e 's/local \([a-zA-Z0-9_]*\)=/local \1; \1=/' \
	-e 's/flags+=("\(--.*\)=")/flags+=("\1"); two_word_flags+=("\1")/' \
	-e 's/must_have_one_flag+=("\(--.*\)=")/must_have_one_flag+=("\1")/' \
	-e "s/${LWORD}_filedir${RWORD}/__faas-cli_filedir/g" \
	-e "s/${LWORD}_get_comp_words_by_ref${RWORD}/__faas-cli_get_comp_words_by_ref/g" \
	-e "s/${LWORD}__ltrim_colon_completions${RWORD}/__faas-cli_ltrim_colon_completions/g" \
	-e "s/${LWORD}compgen${RWORD}/__faas-cli_compgen/g" \
	-e "s/${LWORD}compopt${RWORD}/__faas-cli_compopt/g" \
	-e "s/${LWORD}declare${RWORD}/builtin declare/g" \
	-e "s/\\\$(type${RWORD}/\$(__faas-cli_type/g" \
	<<'BASH_COMPLETION_EOF'
# bash completion for faas-cli                             -*- shell-script -*-

__faas-cli_debug()
{
    if [[ -n ${BASH_COMP_DEBUG_FILE} ]]; then
        echo "$*" >> "${BASH_COMP_DEBUG_FILE}"
    fi
}

# Homebrew on Macs have version 1.3 of bash-completion which doesn't include
# _init_completion. This is a very minimal version of that function.
__faas-cli_init_completion()
{
    COMPREPLY=()
    _get_comp_words_by_ref "$@" cur prev words cword
}

__faas-cli_index_of_word()
{
    local w word=$1
    shift
    index=0
    for w in "$@"; do
        [[ $w = "$word" ]] && return
        index=$((index+1))
    done
    index=-1
}

__faas-cli_contains_word()
{
    local w word=$1; shift
    for w in "$@"; do
        [[ $w = "$word" ]] && return
    done
    return 1
}

__faas-cli_handle_reply()
{
    __faas-cli_debug "${FUNCNAME[0]}"
    case $cur in
        -*)
            if [[ $(type -t compopt) = "builtin" ]]; then
                compopt -o nospace
            fi
            local allflags
            if [ ${#must_have_one_flag[@]} -ne 0 ]; then
                allflags=("${must_have_one_flag[@]}")
            else
                allflags=("${flags[*]} ${two_word_flags[*]}")
            fi
            COMPREPLY=( $(compgen -W "${allflags[*]}" -- "$cur") )
            if [[ $(type -t compopt) = "builtin" ]]; then
                [[ "${COMPREPLY[0]}" == *= ]] || compopt +o nospace
            fi

            # complete after --flag=abc
            if [[ $cur == *=* ]]; then
                if [[ $(type -t compopt) = "builtin" ]]; then
                    compopt +o nospace
                fi

                local index flag
                flag="${cur%=*}"
                __faas-cli_index_of_word "${flag}" "${flags_with_completion[@]}"
                COMPREPLY=()
                if [[ ${index} -ge 0 ]]; then
                    PREFIX=""
                    cur="${cur#*=}"
                    ${flags_completion[${index}]}
                    if [ -n "${ZSH_VERSION}" ]; then
                        # zsh completion needs --flag= prefix
                        eval "COMPREPLY=( \"\${COMPREPLY[@]/#/${flag}=}\" )"
                    fi
                fi
            fi
            return 0;
            ;;
    esac

    # check if we are handling a flag with special work handling
    local index
    __faas-cli_index_of_word "${prev}" "${flags_with_completion[@]}"
    if [[ ${index} -ge 0 ]]; then
        ${flags_completion[${index}]}
        return
    fi

    # we are parsing a flag and don't have a special handler, no completion
    if [[ ${cur} != "${words[cword]}" ]]; then
        return
    fi

    local completions
    completions=("${commands[@]}")
    if [[ ${#must_have_one_noun[@]} -ne 0 ]]; then
        completions=("${must_have_one_noun[@]}")
    fi
    if [[ ${#must_have_one_flag[@]} -ne 0 ]]; then
        completions+=("${must_have_one_flag[@]}")
    fi
    COMPREPLY=( $(compgen -W "${completions[*]}" -- "$cur") )

    if [[ ${#COMPREPLY[@]} -eq 0 && ${#noun_aliases[@]} -gt 0 && ${#must_have_one_noun[@]} -ne 0 ]]; then
        COMPREPLY=( $(compgen -W "${noun_aliases[*]}" -- "$cur") )
    fi

    if [[ ${#COMPREPLY[@]} -eq 0 ]]; then
		if declare -F __faas-cli_custom_func >/dev/null; then
			# try command name qualified custom func
			__faas-cli_custom_func
		else
			# otherwise fall back to unqualified for compatibility
			declare -F __custom_func >/dev/null && __custom_func
		fi
    fi

    # available in bash-completion >= 2, not always present on macOS
    if declare -F __ltrim_colon_completions >/dev/null; then
        __ltrim_colon_completions "$cur"
    fi

    # If there is only 1 completion and it is a flag with an = it will be completed
    # but we don't want a space after the =
    if [[ "${#COMPREPLY[@]}" -eq "1" ]] && [[ $(type -t compopt) = "builtin" ]] && [[ "${COMPREPLY[0]}" == --*= ]]; then
       compopt -o nospace
    fi
}

# The arguments should be in the form "ext1|ext2|extn"
__faas-cli_handle_filename_extension_flag()
{
    local ext="$1"
    _filedir "@(${ext})"
}

__faas-cli_handle_subdirs_in_dir_flag()
{
    local dir="$1"
    pushd "${dir}" >/dev/null 2>&1 && _filedir -d && popd >/dev/null 2>&1
}

__faas-cli_handle_flag()
{
    __faas-cli_debug "${FUNCNAME[0]}: c is $c words[c] is ${words[c]}"

    # if a command required a flag, and we found it, unset must_have_one_flag()
    local flagname=${words[c]}
    local flagvalue
    # if the word contained an =
    if [[ ${words[c]} == *"="* ]]; then
        flagvalue=${flagname#*=} # take in as flagvalue after the =
        flagname=${flagname%=*} # strip everything after the =
        flagname="${flagname}=" # but put the = back
    fi
    __faas-cli_debug "${FUNCNAME[0]}: looking for ${flagname}"
    if __faas-cli_contains_word "${flagname}" "${must_have_one_flag[@]}"; then
        must_have_one_flag=()
    fi

    # if you set a flag which only applies to this command, don't show subcommands
    if __faas-cli_contains_word "${flagname}" "${local_nonpersistent_flags[@]}"; then
      commands=()
    fi

    # keep flag value with flagname as flaghash
    # flaghash variable is an associative array which is only supported in bash > 3.
    if [[ -z "${BASH_VERSION}" || "${BASH_VERSINFO[0]}" -gt 3 ]]; then
        if [ -n "${flagvalue}" ] ; then
            flaghash[${flagname}]=${flagvalue}
        elif [ -n "${words[ $((c+1)) ]}" ] ; then
            flaghash[${flagname}]=${words[ $((c+1)) ]}
        else
            flaghash[${flagname}]="true" # pad "true" for bool flag
        fi
    fi

    # skip the argument to a two word flag
    if [[ ${words[c]} != *"="* ]] && __faas-cli_contains_word "${words[c]}" "${two_word_flags[@]}"; then
			  __faas-cli_debug "${FUNCNAME[0]}: found a flag ${words[c]}, skip the next argument"
        c=$((c+1))
        # if we are looking for a flags value, don't show commands
        if [[ $c -eq $cword ]]; then
            commands=()
        fi
    fi

    c=$((c+1))

}

__faas-cli_handle_noun()
{
    __faas-cli_debug "${FUNCNAME[0]}: c is $c words[c] is ${words[c]}"

    if __faas-cli_contains_word "${words[c]}" "${must_have_one_noun[@]}"; then
        must_have_one_noun=()
    elif __faas-cli_contains_word "${words[c]}" "${noun_aliases[@]}"; then
        must_have_one_noun=()
    fi

    nouns+=("${words[c]}")
    c=$((c+1))
}

__faas-cli_handle_command()
{
    __faas-cli_debug "${FUNCNAME[0]}: c is $c words[c] is ${words[c]}"

    local next_command
    if [[ -n ${last_command} ]]; then
        next_command="_${last_command}_${words[c]//:/__}"
    else
        if [[ $c -eq 0 ]]; then
            next_command="_faas-cli_root_command"
        else
            next_command="_${words[c]//:/__}"
        fi
    fi
    c=$((c+1))
    __faas-cli_debug "${FUNCNAME[0]}: looking for ${next_command}"
    declare -F "$next_command" >/dev/null && $next_command
}

__faas-cli_handle_word()
{
    if [[ $c -ge $cword ]]; then
        __faas-cli_handle_reply
        return
    fi
    __faas-cli_debug "${FUNCNAME[0]}: c is $c words[c] is ${words[c]}"
    if [[ "${words[c]}" == -* ]]; then
        __faas-cli_handle_flag
    elif __faas-cli_contains_word "${words[c]}" "${commands[@]}"; then
        __faas-cli_handle_command
    elif [[ $c -eq 0 ]]; then
        __faas-cli_handle_command
    elif __faas-cli_contains_word "${words[c]}" "${command_aliases[@]}"; then
        # aliashash variable is an associative array which is only supported in bash > 3.
        if [[ -z "${BASH_VERSION}" || "${BASH_VERSINFO[0]}" -gt 3 ]]; then
            words[c]=${aliashash[${words[c]}]}
            __faas-cli_handle_command
        else
            __faas-cli_handle_noun
        fi
    else
        __faas-cli_handle_noun
    fi
    __faas-cli_handle_word
}

_faas-cli_auth()
{
    last_command="faas-cli_auth"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--audience=")
    two_word_flags+=("--audience")
    local_nonpersistent_flags+=("--audience=")
    flags+=("--auth-url=")
    two_word_flags+=("--auth-url")
    local_nonpersistent_flags+=("--auth-url=")
    flags+=("--client-id=")
    two_word_flags+=("--client-id")
    local_nonpersistent_flags+=("--client-id=")
    flags+=("--client-secret=")
    two_word_flags+=("--client-secret")
    local_nonpersistent_flags+=("--client-secret=")
    flags+=("--gateway=")
    two_word_flags+=("--gateway")
    two_word_flags+=("-g")
    local_nonpersistent_flags+=("--gateway=")
    flags+=("--grant=")
    two_word_flags+=("--grant")
    local_nonpersistent_flags+=("--grant=")
    flags+=("--launch-browser")
    local_nonpersistent_flags+=("--launch-browser")
    flags+=("--listen-port=")
    two_word_flags+=("--listen-port")
    local_nonpersistent_flags+=("--listen-port=")
    flags+=("--filter=")
    two_word_flags+=("--filter")
    flags+=("--regex=")
    two_word_flags+=("--regex")
    flags+=("--yaml=")
    two_word_flags+=("--yaml")
    flags_with_completion+=("--yaml")
    flags_completion+=("__faas-cli_handle_filename_extension_flag yaml|yml")
    two_word_flags+=("-f")
    flags_with_completion+=("-f")
    flags_completion+=("__faas-cli_handle_filename_extension_flag yaml|yml")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_faas-cli_build()
{
    last_command="faas-cli_build"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--build-arg=")
    two_word_flags+=("--build-arg")
    two_word_flags+=("-b")
    local_nonpersistent_flags+=("--build-arg=")
    flags+=("--build-label=")
    two_word_flags+=("--build-label")
    local_nonpersistent_flags+=("--build-label=")
    flags+=("--build-option=")
    two_word_flags+=("--build-option")
    two_word_flags+=("-o")
    local_nonpersistent_flags+=("--build-option=")
    flags+=("--envsubst")
    local_nonpersistent_flags+=("--envsubst")
    flags+=("--handler=")
    two_word_flags+=("--handler")
    flags_with_completion+=("--handler")
    flags_completion+=("_filedir -d")
    local_nonpersistent_flags+=("--handler=")
    flags+=("--image=")
    two_word_flags+=("--image")
    local_nonpersistent_flags+=("--image=")
    flags+=("--lang=")
    two_word_flags+=("--lang")
    local_nonpersistent_flags+=("--lang=")
    flags+=("--name=")
    two_word_flags+=("--name")
    local_nonpersistent_flags+=("--name=")
    flags+=("--no-cache")
    local_nonpersistent_flags+=("--no-cache")
    flags+=("--parallel=")
    two_word_flags+=("--parallel")
    local_nonpersistent_flags+=("--parallel=")
    flags+=("--shrinkwrap")
    local_nonpersistent_flags+=("--shrinkwrap")
    flags+=("--squash")
    local_nonpersistent_flags+=("--squash")
    flags+=("--tag=")
    two_word_flags+=("--tag")
    local_nonpersistent_flags+=("--tag=")
    flags+=("--filter=")
    two_word_flags+=("--filter")
    flags+=("--regex=")
    two_word_flags+=("--regex")
    flags+=("--yaml=")
    two_word_flags+=("--yaml")
    flags_with_completion+=("--yaml")
    flags_completion+=("__faas-cli_handle_filename_extension_flag yaml|yml")
    two_word_flags+=("-f")
    flags_with_completion+=("-f")
    flags_completion+=("__faas-cli_handle_filename_extension_flag yaml|yml")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_faas-cli_cloud_seal()
{
    last_command="faas-cli_cloud_seal"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--cert=")
    two_word_flags+=("--cert")
    two_word_flags+=("-c")
    local_nonpersistent_flags+=("--cert=")
    flags+=("--from-file=")
    two_word_flags+=("--from-file")
    two_word_flags+=("-i")
    local_nonpersistent_flags+=("--from-file=")
    flags+=("--literal=")
    two_word_flags+=("--literal")
    two_word_flags+=("-l")
    local_nonpersistent_flags+=("--literal=")
    flags+=("--name=")
    two_word_flags+=("--name")
    local_nonpersistent_flags+=("--name=")
    flags+=("--namespace=")
    two_word_flags+=("--namespace")
    two_word_flags+=("-n")
    local_nonpersistent_flags+=("--namespace=")
    flags+=("--output-file=")
    two_word_flags+=("--output-file")
    two_word_flags+=("-o")
    local_nonpersistent_flags+=("--output-file=")
    flags+=("--filter=")
    two_word_flags+=("--filter")
    flags+=("--regex=")
    two_word_flags+=("--regex")
    flags+=("--yaml=")
    two_word_flags+=("--yaml")
    flags_with_completion+=("--yaml")
    flags_completion+=("__faas-cli_handle_filename_extension_flag yaml|yml")
    two_word_flags+=("-f")
    flags_with_completion+=("-f")
    flags_completion+=("__faas-cli_handle_filename_extension_flag yaml|yml")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_faas-cli_cloud()
{
    last_command="faas-cli_cloud"

    command_aliases=()

    commands=()
    commands+=("seal")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--filter=")
    two_word_flags+=("--filter")
    flags+=("--regex=")
    two_word_flags+=("--regex")
    flags+=("--yaml=")
    two_word_flags+=("--yaml")
    flags_with_completion+=("--yaml")
    flags_completion+=("__faas-cli_handle_filename_extension_flag yaml|yml")
    two_word_flags+=("-f")
    flags_with_completion+=("-f")
    flags_completion+=("__faas-cli_handle_filename_extension_flag yaml|yml")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_faas-cli_completion()
{
    last_command="faas-cli_completion"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--help")
    flags+=("-h")
    local_nonpersistent_flags+=("--help")
    flags+=("--shell=")
    two_word_flags+=("--shell")
    local_nonpersistent_flags+=("--shell=")
    flags+=("--filter=")
    two_word_flags+=("--filter")
    flags+=("--regex=")
    two_word_flags+=("--regex")
    flags+=("--yaml=")
    two_word_flags+=("--yaml")
    flags_with_completion+=("--yaml")
    flags_completion+=("__faas-cli_handle_filename_extension_flag yaml|yml")
    two_word_flags+=("-f")
    flags_with_completion+=("-f")
    flags_completion+=("__faas-cli_handle_filename_extension_flag yaml|yml")

    must_have_one_flag=()
    must_have_one_flag+=("--shell=")
    must_have_one_noun=()
    noun_aliases=()
}

_faas-cli_deploy()
{
    last_command="faas-cli_deploy"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--annotation=")
    two_word_flags+=("--annotation")
    local_nonpersistent_flags+=("--annotation=")
    flags+=("--constraint=")
    two_word_flags+=("--constraint")
    local_nonpersistent_flags+=("--constraint=")
    flags+=("--env=")
    two_word_flags+=("--env")
    two_word_flags+=("-e")
    local_nonpersistent_flags+=("--env=")
    flags+=("--envsubst")
    local_nonpersistent_flags+=("--envsubst")
    flags+=("--fprocess=")
    two_word_flags+=("--fprocess")
    local_nonpersistent_flags+=("--fprocess=")
    flags+=("--gateway=")
    two_word_flags+=("--gateway")
    two_word_flags+=("-g")
    local_nonpersistent_flags+=("--gateway=")
    flags+=("--handler=")
    two_word_flags+=("--handler")
    flags_with_completion+=("--handler")
    flags_completion+=("_filedir -d")
    local_nonpersistent_flags+=("--handler=")
    flags+=("--image=")
    two_word_flags+=("--image")
    local_nonpersistent_flags+=("--image=")
    flags+=("--label=")
    two_word_flags+=("--label")
    two_word_flags+=("-l")
    local_nonpersistent_flags+=("--label=")
    flags+=("--lang=")
    two_word_flags+=("--lang")
    local_nonpersistent_flags+=("--lang=")
    flags+=("--name=")
    two_word_flags+=("--name")
    local_nonpersistent_flags+=("--name=")
    flags+=("--namespace=")
    two_word_flags+=("--namespace")
    two_word_flags+=("-n")
    local_nonpersistent_flags+=("--namespace=")
    flags+=("--network=")
    two_word_flags+=("--network")
    local_nonpersistent_flags+=("--network=")
    flags+=("--read-template")
    local_nonpersistent_flags+=("--read-template")
    flags+=("--readonly")
    local_nonpersistent_flags+=("--readonly")
    flags+=("--replace")
    local_nonpersistent_flags+=("--replace")
    flags+=("--secret=")
    two_word_flags+=("--secret")
    local_nonpersistent_flags+=("--secret=")
    flags+=("--send-registry-auth")
    flags+=("-a")
    local_nonpersistent_flags+=("--send-registry-auth")
    flags+=("--tag=")
    two_word_flags+=("--tag")
    local_nonpersistent_flags+=("--tag=")
    flags+=("--tls-no-verify")
    local_nonpersistent_flags+=("--tls-no-verify")
    flags+=("--token=")
    two_word_flags+=("--token")
    two_word_flags+=("-k")
    local_nonpersistent_flags+=("--token=")
    flags+=("--update")
    local_nonpersistent_flags+=("--update")
    flags+=("--filter=")
    two_word_flags+=("--filter")
    flags+=("--regex=")
    two_word_flags+=("--regex")
    flags+=("--yaml=")
    two_word_flags+=("--yaml")
    flags_with_completion+=("--yaml")
    flags_completion+=("__faas-cli_handle_filename_extension_flag yaml|yml")
    two_word_flags+=("-f")
    flags_with_completion+=("-f")
    flags_completion+=("__faas-cli_handle_filename_extension_flag yaml|yml")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_faas-cli_describe()
{
    last_command="faas-cli_describe"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--envsubst")
    local_nonpersistent_flags+=("--envsubst")
    flags+=("--gateway=")
    two_word_flags+=("--gateway")
    two_word_flags+=("-g")
    local_nonpersistent_flags+=("--gateway=")
    flags+=("--name=")
    two_word_flags+=("--name")
    local_nonpersistent_flags+=("--name=")
    flags+=("--namespace=")
    two_word_flags+=("--namespace")
    two_word_flags+=("-n")
    local_nonpersistent_flags+=("--namespace=")
    flags+=("--tls-no-verify")
    local_nonpersistent_flags+=("--tls-no-verify")
    flags+=("--token=")
    two_word_flags+=("--token")
    two_word_flags+=("-k")
    local_nonpersistent_flags+=("--token=")
    flags+=("--filter=")
    two_word_flags+=("--filter")
    flags+=("--regex=")
    two_word_flags+=("--regex")
    flags+=("--yaml=")
    two_word_flags+=("--yaml")
    flags_with_completion+=("--yaml")
    flags_completion+=("__faas-cli_handle_filename_extension_flag yaml|yml")
    two_word_flags+=("-f")
    flags_with_completion+=("-f")
    flags_completion+=("__faas-cli_handle_filename_extension_flag yaml|yml")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_faas-cli_generate()
{
    last_command="faas-cli_generate"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api=")
    two_word_flags+=("--api")
    local_nonpersistent_flags+=("--api=")
    flags+=("--envsubst")
    local_nonpersistent_flags+=("--envsubst")
    flags+=("--from-store=")
    two_word_flags+=("--from-store")
    local_nonpersistent_flags+=("--from-store=")
    flags+=("--namespace=")
    two_word_flags+=("--namespace")
    two_word_flags+=("-n")
    local_nonpersistent_flags+=("--namespace=")
    flags+=("--tag=")
    two_word_flags+=("--tag")
    local_nonpersistent_flags+=("--tag=")
    flags+=("--filter=")
    two_word_flags+=("--filter")
    flags+=("--regex=")
    two_word_flags+=("--regex")
    flags+=("--yaml=")
    two_word_flags+=("--yaml")
    flags_with_completion+=("--yaml")
    flags_completion+=("__faas-cli_handle_filename_extension_flag yaml|yml")
    two_word_flags+=("-f")
    flags_with_completion+=("-f")
    flags_completion+=("__faas-cli_handle_filename_extension_flag yaml|yml")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_faas-cli_invoke()
{
    last_command="faas-cli_invoke"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--async")
    flags+=("-a")
    local_nonpersistent_flags+=("--async")
    flags+=("--content-type=")
    two_word_flags+=("--content-type")
    local_nonpersistent_flags+=("--content-type=")
    flags+=("--envsubst")
    local_nonpersistent_flags+=("--envsubst")
    flags+=("--gateway=")
    two_word_flags+=("--gateway")
    two_word_flags+=("-g")
    local_nonpersistent_flags+=("--gateway=")
    flags+=("--header=")
    two_word_flags+=("--header")
    two_word_flags+=("-H")
    local_nonpersistent_flags+=("--header=")
    flags+=("--key=")
    two_word_flags+=("--key")
    local_nonpersistent_flags+=("--key=")
    flags+=("--method=")
    two_word_flags+=("--method")
    two_word_flags+=("-m")
    local_nonpersistent_flags+=("--method=")
    flags+=("--name=")
    two_word_flags+=("--name")
    local_nonpersistent_flags+=("--name=")
    flags+=("--query=")
    two_word_flags+=("--query")
    local_nonpersistent_flags+=("--query=")
    flags+=("--sign=")
    two_word_flags+=("--sign")
    local_nonpersistent_flags+=("--sign=")
    flags+=("--tls-no-verify")
    local_nonpersistent_flags+=("--tls-no-verify")
    flags+=("--filter=")
    two_word_flags+=("--filter")
    flags+=("--regex=")
    two_word_flags+=("--regex")
    flags+=("--yaml=")
    two_word_flags+=("--yaml")
    flags_with_completion+=("--yaml")
    flags_completion+=("__faas-cli_handle_filename_extension_flag yaml|yml")
    two_word_flags+=("-f")
    flags_with_completion+=("-f")
    flags_completion+=("__faas-cli_handle_filename_extension_flag yaml|yml")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_faas-cli_list()
{
    last_command="faas-cli_list"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--envsubst")
    local_nonpersistent_flags+=("--envsubst")
    flags+=("--gateway=")
    two_word_flags+=("--gateway")
    two_word_flags+=("-g")
    local_nonpersistent_flags+=("--gateway=")
    flags+=("--namespace=")
    two_word_flags+=("--namespace")
    two_word_flags+=("-n")
    local_nonpersistent_flags+=("--namespace=")
    flags+=("--tls-no-verify")
    local_nonpersistent_flags+=("--tls-no-verify")
    flags+=("--token=")
    two_word_flags+=("--token")
    two_word_flags+=("-k")
    local_nonpersistent_flags+=("--token=")
    flags+=("--verbose")
    flags+=("-v")
    local_nonpersistent_flags+=("--verbose")
    flags+=("--filter=")
    two_word_flags+=("--filter")
    flags+=("--regex=")
    two_word_flags+=("--regex")
    flags+=("--yaml=")
    two_word_flags+=("--yaml")
    flags_with_completion+=("--yaml")
    flags_completion+=("__faas-cli_handle_filename_extension_flag yaml|yml")
    two_word_flags+=("-f")
    flags_with_completion+=("-f")
    flags_completion+=("__faas-cli_handle_filename_extension_flag yaml|yml")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_faas-cli_login()
{
    last_command="faas-cli_login"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--gateway=")
    two_word_flags+=("--gateway")
    two_word_flags+=("-g")
    local_nonpersistent_flags+=("--gateway=")
    flags+=("--password=")
    two_word_flags+=("--password")
    two_word_flags+=("-p")
    local_nonpersistent_flags+=("--password=")
    flags+=("--password-stdin")
    flags+=("-s")
    local_nonpersistent_flags+=("--password-stdin")
    flags+=("--tls-no-verify")
    local_nonpersistent_flags+=("--tls-no-verify")
    flags+=("--username=")
    two_word_flags+=("--username")
    two_word_flags+=("-u")
    local_nonpersistent_flags+=("--username=")
    flags+=("--filter=")
    two_word_flags+=("--filter")
    flags+=("--regex=")
    two_word_flags+=("--regex")
    flags+=("--yaml=")
    two_word_flags+=("--yaml")
    flags_with_completion+=("--yaml")
    flags_completion+=("__faas-cli_handle_filename_extension_flag yaml|yml")
    two_word_flags+=("-f")
    flags_with_completion+=("-f")
    flags_completion+=("__faas-cli_handle_filename_extension_flag yaml|yml")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_faas-cli_logout()
{
    last_command="faas-cli_logout"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--gateway=")
    two_word_flags+=("--gateway")
    two_word_flags+=("-g")
    local_nonpersistent_flags+=("--gateway=")
    flags+=("--filter=")
    two_word_flags+=("--filter")
    flags+=("--regex=")
    two_word_flags+=("--regex")
    flags+=("--yaml=")
    two_word_flags+=("--yaml")
    flags_with_completion+=("--yaml")
    flags_completion+=("__faas-cli_handle_filename_extension_flag yaml|yml")
    two_word_flags+=("-f")
    flags_with_completion+=("-f")
    flags_completion+=("__faas-cli_handle_filename_extension_flag yaml|yml")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_faas-cli_logs()
{
    last_command="faas-cli_logs"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--follow")
    local_nonpersistent_flags+=("--follow")
    flags+=("--format=")
    two_word_flags+=("--format")
    local_nonpersistent_flags+=("--format=")
    flags+=("--gateway=")
    two_word_flags+=("--gateway")
    two_word_flags+=("-g")
    local_nonpersistent_flags+=("--gateway=")
    flags+=("--instance")
    local_nonpersistent_flags+=("--instance")
    flags+=("--name")
    local_nonpersistent_flags+=("--name")
    flags+=("--since=")
    two_word_flags+=("--since")
    local_nonpersistent_flags+=("--since=")
    flags+=("--since-time=")
    two_word_flags+=("--since-time")
    local_nonpersistent_flags+=("--since-time=")
    flags+=("--tail=")
    two_word_flags+=("--tail")
    local_nonpersistent_flags+=("--tail=")
    flags+=("--time-format=")
    two_word_flags+=("--time-format")
    local_nonpersistent_flags+=("--time-format=")
    flags+=("--tls-no-verify")
    local_nonpersistent_flags+=("--tls-no-verify")
    flags+=("--token=")
    two_word_flags+=("--token")
    two_word_flags+=("-k")
    local_nonpersistent_flags+=("--token=")
    flags+=("--filter=")
    two_word_flags+=("--filter")
    flags+=("--regex=")
    two_word_flags+=("--regex")
    flags+=("--yaml=")
    two_word_flags+=("--yaml")
    flags_with_completion+=("--yaml")
    flags_completion+=("__faas-cli_handle_filename_extension_flag yaml|yml")
    two_word_flags+=("-f")
    flags_with_completion+=("-f")
    flags_completion+=("__faas-cli_handle_filename_extension_flag yaml|yml")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_faas-cli_new()
{
    last_command="faas-cli_new"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--append=")
    two_word_flags+=("--append")
    two_word_flags+=("-a")
    local_nonpersistent_flags+=("--append=")
    flags+=("--cpu-limit=")
    two_word_flags+=("--cpu-limit")
    local_nonpersistent_flags+=("--cpu-limit=")
    flags+=("--cpu-request=")
    two_word_flags+=("--cpu-request")
    local_nonpersistent_flags+=("--cpu-request=")
    flags+=("--gateway=")
    two_word_flags+=("--gateway")
    two_word_flags+=("-g")
    local_nonpersistent_flags+=("--gateway=")
    flags+=("--handler=")
    two_word_flags+=("--handler")
    local_nonpersistent_flags+=("--handler=")
    flags+=("--lang=")
    two_word_flags+=("--lang")
    local_nonpersistent_flags+=("--lang=")
    flags+=("--list")
    local_nonpersistent_flags+=("--list")
    flags+=("--memory-limit=")
    two_word_flags+=("--memory-limit")
    local_nonpersistent_flags+=("--memory-limit=")
    flags+=("--memory-request=")
    two_word_flags+=("--memory-request")
    local_nonpersistent_flags+=("--memory-request=")
    flags+=("--prefix=")
    two_word_flags+=("--prefix")
    two_word_flags+=("-p")
    local_nonpersistent_flags+=("--prefix=")
    flags+=("--quiet")
    flags+=("-q")
    local_nonpersistent_flags+=("--quiet")
    flags+=("--filter=")
    two_word_flags+=("--filter")
    flags+=("--regex=")
    two_word_flags+=("--regex")
    flags+=("--yaml=")
    two_word_flags+=("--yaml")
    flags_with_completion+=("--yaml")
    flags_completion+=("__faas-cli_handle_filename_extension_flag yaml|yml")
    two_word_flags+=("-f")
    flags_with_completion+=("-f")
    flags_completion+=("__faas-cli_handle_filename_extension_flag yaml|yml")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_faas-cli_push()
{
    last_command="faas-cli_push"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--envsubst")
    local_nonpersistent_flags+=("--envsubst")
    flags+=("--parallel=")
    two_word_flags+=("--parallel")
    local_nonpersistent_flags+=("--parallel=")
    flags+=("--tag=")
    two_word_flags+=("--tag")
    local_nonpersistent_flags+=("--tag=")
    flags+=("--filter=")
    two_word_flags+=("--filter")
    flags+=("--regex=")
    two_word_flags+=("--regex")
    flags+=("--yaml=")
    two_word_flags+=("--yaml")
    flags_with_completion+=("--yaml")
    flags_completion+=("__faas-cli_handle_filename_extension_flag yaml|yml")
    two_word_flags+=("-f")
    flags_with_completion+=("-f")
    flags_completion+=("__faas-cli_handle_filename_extension_flag yaml|yml")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_faas-cli_remove()
{
    last_command="faas-cli_remove"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--envsubst")
    local_nonpersistent_flags+=("--envsubst")
    flags+=("--gateway=")
    two_word_flags+=("--gateway")
    two_word_flags+=("-g")
    local_nonpersistent_flags+=("--gateway=")
    flags+=("--namespace=")
    two_word_flags+=("--namespace")
    two_word_flags+=("-n")
    local_nonpersistent_flags+=("--namespace=")
    flags+=("--tls-no-verify")
    local_nonpersistent_flags+=("--tls-no-verify")
    flags+=("--token=")
    two_word_flags+=("--token")
    two_word_flags+=("-k")
    local_nonpersistent_flags+=("--token=")
    flags+=("--filter=")
    two_word_flags+=("--filter")
    flags+=("--regex=")
    two_word_flags+=("--regex")
    flags+=("--yaml=")
    two_word_flags+=("--yaml")
    flags_with_completion+=("--yaml")
    flags_completion+=("__faas-cli_handle_filename_extension_flag yaml|yml")
    two_word_flags+=("-f")
    flags_with_completion+=("-f")
    flags_completion+=("__faas-cli_handle_filename_extension_flag yaml|yml")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_faas-cli_secret_create()
{
    last_command="faas-cli_secret_create"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--from-file=")
    two_word_flags+=("--from-file")
    local_nonpersistent_flags+=("--from-file=")
    flags+=("--from-literal=")
    two_word_flags+=("--from-literal")
    local_nonpersistent_flags+=("--from-literal=")
    flags+=("--gateway=")
    two_word_flags+=("--gateway")
    two_word_flags+=("-g")
    local_nonpersistent_flags+=("--gateway=")
    flags+=("--namespace=")
    two_word_flags+=("--namespace")
    two_word_flags+=("-n")
    local_nonpersistent_flags+=("--namespace=")
    flags+=("--tls-no-verify")
    local_nonpersistent_flags+=("--tls-no-verify")
    flags+=("--token=")
    two_word_flags+=("--token")
    two_word_flags+=("-k")
    local_nonpersistent_flags+=("--token=")
    flags+=("--filter=")
    two_word_flags+=("--filter")
    flags+=("--regex=")
    two_word_flags+=("--regex")
    flags+=("--yaml=")
    two_word_flags+=("--yaml")
    flags_with_completion+=("--yaml")
    flags_completion+=("__faas-cli_handle_filename_extension_flag yaml|yml")
    two_word_flags+=("-f")
    flags_with_completion+=("-f")
    flags_completion+=("__faas-cli_handle_filename_extension_flag yaml|yml")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_faas-cli_secret_list()
{
    last_command="faas-cli_secret_list"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--gateway=")
    two_word_flags+=("--gateway")
    two_word_flags+=("-g")
    local_nonpersistent_flags+=("--gateway=")
    flags+=("--namespace=")
    two_word_flags+=("--namespace")
    two_word_flags+=("-n")
    local_nonpersistent_flags+=("--namespace=")
    flags+=("--tls-no-verify")
    local_nonpersistent_flags+=("--tls-no-verify")
    flags+=("--token=")
    two_word_flags+=("--token")
    two_word_flags+=("-k")
    local_nonpersistent_flags+=("--token=")
    flags+=("--filter=")
    two_word_flags+=("--filter")
    flags+=("--regex=")
    two_word_flags+=("--regex")
    flags+=("--yaml=")
    two_word_flags+=("--yaml")
    flags_with_completion+=("--yaml")
    flags_completion+=("__faas-cli_handle_filename_extension_flag yaml|yml")
    two_word_flags+=("-f")
    flags_with_completion+=("-f")
    flags_completion+=("__faas-cli_handle_filename_extension_flag yaml|yml")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_faas-cli_secret_remove()
{
    last_command="faas-cli_secret_remove"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--gateway=")
    two_word_flags+=("--gateway")
    two_word_flags+=("-g")
    local_nonpersistent_flags+=("--gateway=")
    flags+=("--namespace=")
    two_word_flags+=("--namespace")
    two_word_flags+=("-n")
    local_nonpersistent_flags+=("--namespace=")
    flags+=("--tls-no-verify")
    local_nonpersistent_flags+=("--tls-no-verify")
    flags+=("--token=")
    two_word_flags+=("--token")
    two_word_flags+=("-k")
    local_nonpersistent_flags+=("--token=")
    flags+=("--filter=")
    two_word_flags+=("--filter")
    flags+=("--regex=")
    two_word_flags+=("--regex")
    flags+=("--yaml=")
    two_word_flags+=("--yaml")
    flags_with_completion+=("--yaml")
    flags_completion+=("__faas-cli_handle_filename_extension_flag yaml|yml")
    two_word_flags+=("-f")
    flags_with_completion+=("-f")
    flags_completion+=("__faas-cli_handle_filename_extension_flag yaml|yml")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_faas-cli_secret_update()
{
    last_command="faas-cli_secret_update"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--from-file=")
    two_word_flags+=("--from-file")
    local_nonpersistent_flags+=("--from-file=")
    flags+=("--from-literal=")
    two_word_flags+=("--from-literal")
    local_nonpersistent_flags+=("--from-literal=")
    flags+=("--gateway=")
    two_word_flags+=("--gateway")
    two_word_flags+=("-g")
    local_nonpersistent_flags+=("--gateway=")
    flags+=("--namespace=")
    two_word_flags+=("--namespace")
    two_word_flags+=("-n")
    local_nonpersistent_flags+=("--namespace=")
    flags+=("--tls-no-verify")
    local_nonpersistent_flags+=("--tls-no-verify")
    flags+=("--token=")
    two_word_flags+=("--token")
    two_word_flags+=("-k")
    local_nonpersistent_flags+=("--token=")
    flags+=("--filter=")
    two_word_flags+=("--filter")
    flags+=("--regex=")
    two_word_flags+=("--regex")
    flags+=("--yaml=")
    two_word_flags+=("--yaml")
    flags_with_completion+=("--yaml")
    flags_completion+=("__faas-cli_handle_filename_extension_flag yaml|yml")
    two_word_flags+=("-f")
    flags_with_completion+=("-f")
    flags_completion+=("__faas-cli_handle_filename_extension_flag yaml|yml")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_faas-cli_secret()
{
    last_command="faas-cli_secret"

    command_aliases=()

    commands=()
    commands+=("create")
    commands+=("list")
    if [[ -z "${BASH_VERSION}" || "${BASH_VERSINFO[0]}" -gt 3 ]]; then
        command_aliases+=("ls")
        aliashash["ls"]="list"
    fi
    commands+=("remove")
    if [[ -z "${BASH_VERSION}" || "${BASH_VERSINFO[0]}" -gt 3 ]]; then
        command_aliases+=("rm")
        aliashash["rm"]="remove"
    fi
    commands+=("update")
    if [[ -z "${BASH_VERSION}" || "${BASH_VERSINFO[0]}" -gt 3 ]]; then
        command_aliases+=("u")
        aliashash["u"]="update"
    fi

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--filter=")
    two_word_flags+=("--filter")
    flags+=("--regex=")
    two_word_flags+=("--regex")
    flags+=("--yaml=")
    two_word_flags+=("--yaml")
    flags_with_completion+=("--yaml")
    flags_completion+=("__faas-cli_handle_filename_extension_flag yaml|yml")
    two_word_flags+=("-f")
    flags_with_completion+=("-f")
    flags_completion+=("__faas-cli_handle_filename_extension_flag yaml|yml")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_faas-cli_store_deploy()
{
    last_command="faas-cli_store_deploy"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--annotation=")
    two_word_flags+=("--annotation")
    local_nonpersistent_flags+=("--annotation=")
    flags+=("--constraint=")
    two_word_flags+=("--constraint")
    local_nonpersistent_flags+=("--constraint=")
    flags+=("--env=")
    two_word_flags+=("--env")
    two_word_flags+=("-e")
    local_nonpersistent_flags+=("--env=")
    flags+=("--gateway=")
    two_word_flags+=("--gateway")
    two_word_flags+=("-g")
    local_nonpersistent_flags+=("--gateway=")
    flags+=("--label=")
    two_word_flags+=("--label")
    two_word_flags+=("-l")
    local_nonpersistent_flags+=("--label=")
    flags+=("--name=")
    two_word_flags+=("--name")
    local_nonpersistent_flags+=("--name=")
    flags+=("--namespace=")
    two_word_flags+=("--namespace")
    two_word_flags+=("-n")
    local_nonpersistent_flags+=("--namespace=")
    flags+=("--network=")
    two_word_flags+=("--network")
    local_nonpersistent_flags+=("--network=")
    flags+=("--replace")
    local_nonpersistent_flags+=("--replace")
    flags+=("--secret=")
    two_word_flags+=("--secret")
    local_nonpersistent_flags+=("--secret=")
    flags+=("--send-registry-auth")
    flags+=("-a")
    local_nonpersistent_flags+=("--send-registry-auth")
    flags+=("--tls-no-verify")
    local_nonpersistent_flags+=("--tls-no-verify")
    flags+=("--token=")
    two_word_flags+=("--token")
    two_word_flags+=("-k")
    local_nonpersistent_flags+=("--token=")
    flags+=("--update")
    local_nonpersistent_flags+=("--update")
    flags+=("--filter=")
    two_word_flags+=("--filter")
    flags+=("--regex=")
    two_word_flags+=("--regex")
    flags+=("--url=")
    two_word_flags+=("--url")
    two_word_flags+=("-u")
    flags+=("--yaml=")
    two_word_flags+=("--yaml")
    flags_with_completion+=("--yaml")
    flags_completion+=("__faas-cli_handle_filename_extension_flag yaml|yml")
    two_word_flags+=("-f")
    flags_with_completion+=("-f")
    flags_completion+=("__faas-cli_handle_filename_extension_flag yaml|yml")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_faas-cli_store_inspect()
{
    last_command="faas-cli_store_inspect"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--verbose")
    flags+=("-v")
    local_nonpersistent_flags+=("--verbose")
    flags+=("--filter=")
    two_word_flags+=("--filter")
    flags+=("--regex=")
    two_word_flags+=("--regex")
    flags+=("--url=")
    two_word_flags+=("--url")
    two_word_flags+=("-u")
    flags+=("--yaml=")
    two_word_flags+=("--yaml")
    flags_with_completion+=("--yaml")
    flags_completion+=("__faas-cli_handle_filename_extension_flag yaml|yml")
    two_word_flags+=("-f")
    flags_with_completion+=("-f")
    flags_completion+=("__faas-cli_handle_filename_extension_flag yaml|yml")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_faas-cli_store_list()
{
    last_command="faas-cli_store_list"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--verbose")
    flags+=("-v")
    local_nonpersistent_flags+=("--verbose")
    flags+=("--filter=")
    two_word_flags+=("--filter")
    flags+=("--regex=")
    two_word_flags+=("--regex")
    flags+=("--url=")
    two_word_flags+=("--url")
    two_word_flags+=("-u")
    flags+=("--yaml=")
    two_word_flags+=("--yaml")
    flags_with_completion+=("--yaml")
    flags_completion+=("__faas-cli_handle_filename_extension_flag yaml|yml")
    two_word_flags+=("-f")
    flags_with_completion+=("-f")
    flags_completion+=("__faas-cli_handle_filename_extension_flag yaml|yml")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_faas-cli_store()
{
    last_command="faas-cli_store"

    command_aliases=()

    commands=()
    commands+=("deploy")
    commands+=("inspect")
    commands+=("list")
    if [[ -z "${BASH_VERSION}" || "${BASH_VERSINFO[0]}" -gt 3 ]]; then
        command_aliases+=("ls")
        aliashash["ls"]="list"
    fi

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--url=")
    two_word_flags+=("--url")
    two_word_flags+=("-u")
    flags+=("--filter=")
    two_word_flags+=("--filter")
    flags+=("--regex=")
    two_word_flags+=("--regex")
    flags+=("--yaml=")
    two_word_flags+=("--yaml")
    flags_with_completion+=("--yaml")
    flags_completion+=("__faas-cli_handle_filename_extension_flag yaml|yml")
    two_word_flags+=("-f")
    flags_with_completion+=("-f")
    flags_completion+=("__faas-cli_handle_filename_extension_flag yaml|yml")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_faas-cli_template_pull()
{
    last_command="faas-cli_template_pull"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--debug")
    local_nonpersistent_flags+=("--debug")
    flags+=("--overwrite")
    local_nonpersistent_flags+=("--overwrite")
    flags+=("--filter=")
    two_word_flags+=("--filter")
    flags+=("--regex=")
    two_word_flags+=("--regex")
    flags+=("--yaml=")
    two_word_flags+=("--yaml")
    flags_with_completion+=("--yaml")
    flags_completion+=("__faas-cli_handle_filename_extension_flag yaml|yml")
    two_word_flags+=("-f")
    flags_with_completion+=("-f")
    flags_completion+=("__faas-cli_handle_filename_extension_flag yaml|yml")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_faas-cli_template_store_describe()
{
    last_command="faas-cli_template_store_describe"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--url=")
    two_word_flags+=("--url")
    two_word_flags+=("-u")
    flags+=("--debug")
    flags+=("--filter=")
    two_word_flags+=("--filter")
    flags+=("--overwrite")
    flags+=("--regex=")
    two_word_flags+=("--regex")
    flags+=("--yaml=")
    two_word_flags+=("--yaml")
    flags_with_completion+=("--yaml")
    flags_completion+=("__faas-cli_handle_filename_extension_flag yaml|yml")
    two_word_flags+=("-f")
    flags_with_completion+=("-f")
    flags_completion+=("__faas-cli_handle_filename_extension_flag yaml|yml")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_faas-cli_template_store_list()
{
    last_command="faas-cli_template_store_list"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--platform=")
    two_word_flags+=("--platform")
    two_word_flags+=("-p")
    local_nonpersistent_flags+=("--platform=")
    flags+=("--url=")
    two_word_flags+=("--url")
    two_word_flags+=("-u")
    flags+=("--verbose")
    flags+=("-v")
    local_nonpersistent_flags+=("--verbose")
    flags+=("--debug")
    flags+=("--filter=")
    two_word_flags+=("--filter")
    flags+=("--overwrite")
    flags+=("--regex=")
    two_word_flags+=("--regex")
    flags+=("--yaml=")
    two_word_flags+=("--yaml")
    flags_with_completion+=("--yaml")
    flags_completion+=("__faas-cli_handle_filename_extension_flag yaml|yml")
    two_word_flags+=("-f")
    flags_with_completion+=("-f")
    flags_completion+=("__faas-cli_handle_filename_extension_flag yaml|yml")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_faas-cli_template_store_pull()
{
    last_command="faas-cli_template_store_pull"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--url=")
    two_word_flags+=("--url")
    two_word_flags+=("-u")
    flags+=("--debug")
    flags+=("--filter=")
    two_word_flags+=("--filter")
    flags+=("--overwrite")
    flags+=("--regex=")
    two_word_flags+=("--regex")
    flags+=("--yaml=")
    two_word_flags+=("--yaml")
    flags_with_completion+=("--yaml")
    flags_completion+=("__faas-cli_handle_filename_extension_flag yaml|yml")
    two_word_flags+=("-f")
    flags_with_completion+=("-f")
    flags_completion+=("__faas-cli_handle_filename_extension_flag yaml|yml")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_faas-cli_template_store()
{
    last_command="faas-cli_template_store"

    command_aliases=()

    commands=()
    commands+=("describe")
    commands+=("list")
    if [[ -z "${BASH_VERSION}" || "${BASH_VERSINFO[0]}" -gt 3 ]]; then
        command_aliases+=("ls")
        aliashash["ls"]="list"
    fi
    commands+=("pull")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--debug")
    flags+=("--overwrite")
    flags+=("--filter=")
    two_word_flags+=("--filter")
    flags+=("--regex=")
    two_word_flags+=("--regex")
    flags+=("--yaml=")
    two_word_flags+=("--yaml")
    flags_with_completion+=("--yaml")
    flags_completion+=("__faas-cli_handle_filename_extension_flag yaml|yml")
    two_word_flags+=("-f")
    flags_with_completion+=("-f")
    flags_completion+=("__faas-cli_handle_filename_extension_flag yaml|yml")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_faas-cli_template()
{
    last_command="faas-cli_template"

    command_aliases=()

    commands=()
    commands+=("pull")
    commands+=("store")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--filter=")
    two_word_flags+=("--filter")
    flags+=("--regex=")
    two_word_flags+=("--regex")
    flags+=("--yaml=")
    two_word_flags+=("--yaml")
    flags_with_completion+=("--yaml")
    flags_completion+=("__faas-cli_handle_filename_extension_flag yaml|yml")
    two_word_flags+=("-f")
    flags_with_completion+=("-f")
    flags_completion+=("__faas-cli_handle_filename_extension_flag yaml|yml")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_faas-cli_up()
{
    last_command="faas-cli_up"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--annotation=")
    two_word_flags+=("--annotation")
    local_nonpersistent_flags+=("--annotation=")
    flags+=("--build-arg=")
    two_word_flags+=("--build-arg")
    two_word_flags+=("-b")
    local_nonpersistent_flags+=("--build-arg=")
    flags+=("--build-label=")
    two_word_flags+=("--build-label")
    local_nonpersistent_flags+=("--build-label=")
    flags+=("--build-option=")
    two_word_flags+=("--build-option")
    two_word_flags+=("-o")
    local_nonpersistent_flags+=("--build-option=")
    flags+=("--constraint=")
    two_word_flags+=("--constraint")
    local_nonpersistent_flags+=("--constraint=")
    flags+=("--env=")
    two_word_flags+=("--env")
    two_word_flags+=("-e")
    local_nonpersistent_flags+=("--env=")
    flags+=("--envsubst")
    local_nonpersistent_flags+=("--envsubst")
    flags+=("--fprocess=")
    two_word_flags+=("--fprocess")
    local_nonpersistent_flags+=("--fprocess=")
    flags+=("--gateway=")
    two_word_flags+=("--gateway")
    two_word_flags+=("-g")
    local_nonpersistent_flags+=("--gateway=")
    flags+=("--handler=")
    two_word_flags+=("--handler")
    flags_with_completion+=("--handler")
    flags_completion+=("_filedir -d")
    local_nonpersistent_flags+=("--handler=")
    flags+=("--image=")
    two_word_flags+=("--image")
    local_nonpersistent_flags+=("--image=")
    flags+=("--label=")
    two_word_flags+=("--label")
    two_word_flags+=("-l")
    local_nonpersistent_flags+=("--label=")
    flags+=("--lang=")
    two_word_flags+=("--lang")
    local_nonpersistent_flags+=("--lang=")
    flags+=("--name=")
    two_word_flags+=("--name")
    local_nonpersistent_flags+=("--name=")
    flags+=("--namespace=")
    two_word_flags+=("--namespace")
    two_word_flags+=("-n")
    local_nonpersistent_flags+=("--namespace=")
    flags+=("--network=")
    two_word_flags+=("--network")
    local_nonpersistent_flags+=("--network=")
    flags+=("--no-cache")
    local_nonpersistent_flags+=("--no-cache")
    flags+=("--parallel=")
    two_word_flags+=("--parallel")
    local_nonpersistent_flags+=("--parallel=")
    flags+=("--read-template")
    local_nonpersistent_flags+=("--read-template")
    flags+=("--readonly")
    local_nonpersistent_flags+=("--readonly")
    flags+=("--replace")
    local_nonpersistent_flags+=("--replace")
    flags+=("--secret=")
    two_word_flags+=("--secret")
    local_nonpersistent_flags+=("--secret=")
    flags+=("--send-registry-auth")
    flags+=("-a")
    local_nonpersistent_flags+=("--send-registry-auth")
    flags+=("--shrinkwrap")
    local_nonpersistent_flags+=("--shrinkwrap")
    flags+=("--skip-deploy")
    local_nonpersistent_flags+=("--skip-deploy")
    flags+=("--skip-push")
    local_nonpersistent_flags+=("--skip-push")
    flags+=("--squash")
    local_nonpersistent_flags+=("--squash")
    flags+=("--tag=")
    two_word_flags+=("--tag")
    local_nonpersistent_flags+=("--tag=")
    flags+=("--tls-no-verify")
    local_nonpersistent_flags+=("--tls-no-verify")
    flags+=("--token=")
    two_word_flags+=("--token")
    two_word_flags+=("-k")
    local_nonpersistent_flags+=("--token=")
    flags+=("--update")
    local_nonpersistent_flags+=("--update")
    flags+=("--filter=")
    two_word_flags+=("--filter")
    flags+=("--regex=")
    two_word_flags+=("--regex")
    flags+=("--yaml=")
    two_word_flags+=("--yaml")
    flags_with_completion+=("--yaml")
    flags_completion+=("__faas-cli_handle_filename_extension_flag yaml|yml")
    two_word_flags+=("-f")
    flags_with_completion+=("-f")
    flags_completion+=("__faas-cli_handle_filename_extension_flag yaml|yml")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_faas-cli_version()
{
    last_command="faas-cli_version"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--envsubst")
    local_nonpersistent_flags+=("--envsubst")
    flags+=("--gateway=")
    two_word_flags+=("--gateway")
    two_word_flags+=("-g")
    local_nonpersistent_flags+=("--gateway=")
    flags+=("--short-version")
    local_nonpersistent_flags+=("--short-version")
    flags+=("--tls-no-verify")
    local_nonpersistent_flags+=("--tls-no-verify")
    flags+=("--token=")
    two_word_flags+=("--token")
    two_word_flags+=("-k")
    local_nonpersistent_flags+=("--token=")
    flags+=("--filter=")
    two_word_flags+=("--filter")
    flags+=("--regex=")
    two_word_flags+=("--regex")
    flags+=("--yaml=")
    two_word_flags+=("--yaml")
    flags_with_completion+=("--yaml")
    flags_completion+=("__faas-cli_handle_filename_extension_flag yaml|yml")
    two_word_flags+=("-f")
    flags_with_completion+=("-f")
    flags_completion+=("__faas-cli_handle_filename_extension_flag yaml|yml")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_faas-cli_root_command()
{
    last_command="faas-cli"

    command_aliases=()

    commands=()
    commands+=("auth")
    commands+=("build")
    commands+=("cloud")
    commands+=("completion")
    commands+=("deploy")
    commands+=("describe")
    commands+=("generate")
    commands+=("invoke")
    commands+=("list")
    if [[ -z "${BASH_VERSION}" || "${BASH_VERSINFO[0]}" -gt 3 ]]; then
        command_aliases+=("ls")
        aliashash["ls"]="list"
    fi
    commands+=("login")
    commands+=("logout")
    commands+=("logs")
    if [[ -z "${BASH_VERSION}" || "${BASH_VERSINFO[0]}" -gt 3 ]]; then
        command_aliases+=("ls")
        aliashash["ls"]="logs"
    fi
    commands+=("new")
    commands+=("push")
    commands+=("remove")
    if [[ -z "${BASH_VERSION}" || "${BASH_VERSINFO[0]}" -gt 3 ]]; then
        command_aliases+=("rm")
        aliashash["rm"]="remove"
    fi
    commands+=("secret")
    commands+=("store")
    commands+=("template")
    commands+=("up")
    commands+=("version")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--filter=")
    two_word_flags+=("--filter")
    flags+=("--regex=")
    two_word_flags+=("--regex")
    flags+=("--yaml=")
    two_word_flags+=("--yaml")
    flags_with_completion+=("--yaml")
    flags_completion+=("__faas-cli_handle_filename_extension_flag yaml|yml")
    two_word_flags+=("-f")
    flags_with_completion+=("-f")
    flags_completion+=("__faas-cli_handle_filename_extension_flag yaml|yml")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

__start_faas-cli()
{
    local cur prev words cword
    declare -A flaghash 2>/dev/null || :
    declare -A aliashash 2>/dev/null || :
    if declare -F _init_completion >/dev/null 2>&1; then
        _init_completion -s || return
    else
        __faas-cli_init_completion -n "=" || return
    fi

    local c=0
    local flags=()
    local two_word_flags=()
    local local_nonpersistent_flags=()
    local flags_with_completion=()
    local flags_completion=()
    local commands=("faas-cli")
    local must_have_one_flag=()
    local must_have_one_noun=()
    local last_command
    local nouns=()

    __faas-cli_handle_word
}

if [[ $(type -t compopt) = "builtin" ]]; then
    complete -o default -F __start_faas-cli faas-cli
else
    complete -o default -o nospace -F __start_faas-cli faas-cli
fi

# ex: ts=4 sw=4 et filetype=sh

BASH_COMPLETION_EOF
}
__faas-cli_bash_source <(__faas-cli_convert_bash_to_zsh)
_complete faas-cli 2>/dev/null

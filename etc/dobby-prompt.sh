DOBBY_PROMPT_DIR=`dirname ${BASH_SOURCE[0]}`
DOBBY="${DOBBY_PROMPT_DIR}/../dobby.rb"

# Bam!

alias dobby='ruby -w $DOBBY'


# Now the autocomplete

__dobby_complete_running()
{
	__dobby_complete "$(dobby list_running)"
}

__dobby_complete_startable()
{
	__dobby_complete "$(dobby list_services)"
}

__dobby_complete_editable()
{
	__dobby_complete "$(dobby list_configs)"
}

__dobby_complete()
{
	local cmds="$1"
	local cur="${COMP_WORDS[COMP_CWORD]}"

	local IFS=$'\n'
	COMPREPLY=($(compgen -W "$cmds" -- "$cur"))
}

_dobby()
{
	if [[ $COMP_CWORD -gt 1 ]]; then
		subcmd="${COMP_WORDS[1]}"

		case "$subcmd" in
			stop) __dobby_complete_running;;
			restart) __dobby_complete_running;;
			start) __dobby_complete_startable;;
			edit) __dobby_complete_editable;;
			*) ;;
		esac
	else
		__dobby_complete "$(dobby list_commands)"
	fi
}

complete -o default -F _dobby dobby

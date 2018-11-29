declare-option -hidden str tidal_tmp_dir

define-command -docstring %{Start the TidalCycles server} \
	tidal-start %{
    	evaluate-commands %sh{
        	dir=$(mktemp -d "${TMPDIR:-/tmp}"/kak-tidal.XXXXXXXX)
        	mkfifo ${dir}/stdin
        	mkfifo ${dir}/stdout
        	printf %s\\n "set-option buffer tidal_tmp_dir ${dir}"
    	}
	evaluate-commands %sh{
    		dir="$kak_opt_tidal_tmp_dir"
		$(
			ghci < ${dir}/stdin > ${dir}/stdout 
		) > /dev/null 2>&1 < /dev/null &
	}
	}

define-command -docstring %{Send the current line to the TidalCycles server} \
	tidal-eval-line %{
	execute-keys -draft <space>x:tidal-eval-selection<ret>
	}

define-command -docstring %{Send the full selection to the TidalCycles server} \
	tidal-eval-selection %{
    	%sh{
        	cat ${kak_selection} > ${tidal_tmp_dir}/stdin
    	}
	}

# Detection
# _________

hook global BufCreate .*[.](tidal) %{
    set-option buffer filetype tidal
}

# Options
# _______

declare-option -hidden str tidal_tmp_dir

# Commands
# ________

define-command -docstring %{Start the TidalCycles server} \
	tidal-start %{
    	evaluate-commands %sh{
        	dir=$(mktemp -d "${TMPDIR:-/tmp}"/kak-tidal.XXXXXXXX)
        	mkfifo ${dir}/stdin
        	mkfifo ${dir}/stdout
        	printf %s\\n "set-option buffer tidal_tmp_dir ${dir}"
        	printf %s\\n "evaluate-commands -draft %{
            		edit! -fifo ${dir}/stdout -debug *tidal*
            		set-option buffer filetype haskell
            		set-option buffer make_current_error_line 0
            		hook -once -always buffer BufCloseFifo .* %{ nop %sh{ rm -r ${dir} } }
        	}"
    	}

	nop %sh{
    		dir=${kak_opt_tidal_tmp_dir}
		(
			tail -n +1 -f "${dir}/stdin" | exec ghci -XOverloadedStrings > "${dir}"/stdout
		) > /dev/null 2>&1 < /dev/null &
	}
	tidal-setup
	}

define-command -hidden \
	tidal-setup %{
    		nop %sh{
        		cat ${kak_opt_plug_install_dir}/tidal-kak/BootTidal.hs > ${dir}/stdin
    		}
	}

define-command -hidden -params 1 \
	tidal-send-line %{
    		nop %sh{
        		printf %s "$1" > ${kak_opt_tidal_tmp_dir}/stdin
        		printf %b "\n" > ${kak_opt_tidal_tmp_dir}/stdin
    		}
	}

define-command -docstring %{Send the current line to the TidalCycles server} \
	tidal-eval-line %{
	execute-keys -draft <space>x:tidal-eval-selection<ret>
	}

define-command -docstring %{Send the current selection to the TidalCycles server} \
	tidal-eval-selection %{
        	tidal-send-line %< :{ >
        	tidal-send-line %val{selection}
        	tidal-send-line %< :} >
	}

hook -once -always buffer BufClose \.tidal %{
    tidal-send-line %< exit >
}


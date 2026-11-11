vim9script

# DWTFYW License
# Version -1
#
# Do Whatever The Fudge You Want

var command = 'yazi'

var exec_on_open = 'edit'
if exists('g:yazi_exec_on_open')
	var exec_on_open = g:yazi_exec_on_open
endif

def OpenYaziIn(path: string)
	var chosen_file_path: string = tempname()
	
	var current_path = expand(path)
	if current_path == null_string
		current_path = expand('.')
	endif
	
	silent execute '!' command  .. ' --chooser-file ' .. chosen_file_path .. ' "' .. current_path .. '"'
	
	if filereadable(chosen_file_path)
		var chosen_dir: string
		for chosen_path in readfile(chosen_file_path)
			var simplified_path: string = simplify(chosen_path)
			if isdirectory(simplified_path)
				chosen_dir = simplified_path # last one wins
			else
				execute exec_on_open .. ' ' .. fnamemodify(simplified_path, ":~:.")
			endif
		endfor

		# If a directory was chosen, open it in the current window
		if chosen_dir != null
			vim9cmd OpenYaziIn(chosen_dir)
		endif
		if chosen_file_path != null_string
			vim9cmd delete(chosen_file_path)
		endif
	endif
	redraw!
	# reset the filetype to fix the issue that happens
	# when opening yazi on VimEnter (with `vim .`)
	filetype detect
enddef

command! YaziCurrentFile vim9cmd OpenYaziIn("%")
command! YaziCurrentDirectory vim9cmd OpenYaziIn("%:p:h")
command! YaziWorkingDirectory vim9cmd OpenYaziIn(".")
command! Yazi YaziCurrentFile

def Isdir(dir: string): bool
	if &bufhidden =~ '\vunload|delete|wipe'
		return 0
	# In a temporary special buffer (likely from a plugin).
	else
	return !empty(dir) && (isdirectory(dir) || (!empty($SYSTEMDRIVE) && isdirectory('/' .. tolower($SYSTEMDRIVE[0]) .. dir )))
	endif
enddef
augroup yazi
	autocmd!
	# Remove netrw directory handlers.
	autocmd VimEnter * if exists('#FileExplorer') | exe 'au! FileExplorer *' | endif
	autocmd BufEnter * if Isdir(expand('%:p')) | vim9cmd OpenYaziIn('%:p') | endif
augroup END
defcompile

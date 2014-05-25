" Selective undo for Vim
" This is a dirty hack, but it came up in r/vim and I wanted
" to see if it would work or not
" MIT licensed, please feel free to PR it and improve
"
" Written in the UCF library on a hot, hot day

function! s:undoLine()
	let originalline = getline('.')
	let newLine = getline('.')
	let line = line('.')

	let skipper = 0

	let i = 0
	while i < 40
		silent undo

		execute ":" . line

		if getline('.') != originalline
			if skipper < b:undoPosition
				let skipper += 1
			else
				let newLine = getline('.')

				let c = 0
				while c <= i
					silent redo
					let c += 1
				endwhile

				break
			endif
		endif

		let i += 1
	endwhile

	call setline(line, newLine)
	execute ":" . line

endfunction

function! s:undoRegion()
	let [linestart, col1] = getpos("'<")[1:2]
	let [lineend, col2] = getpos("'>")[1:2]

	while linestart <= lineend
		execute ":" . linestart

		call s:undoLine()
		let linestart += 1
	endwhile

	let b:undoPosition += 2

	normal gv
endfunction

function! s:resetCounter()
	let b:undoPosition = 0
endfunction

command! -nargs=0 UndoLine call s:undoLine()
command! -range -nargs=0 UndoRegion call s:undoRegion()
vnoremap u :UndoRegion<cr>

nnoremap v :call <SID>resetCounter()<cr>v
nnoremap V :call <SID>resetCounter()<cr>V
nnoremap <C-v> :call <SID>resetCounter()<cr><C-v>


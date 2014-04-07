function! s:ninja_prepare(mode, direction)
	let s:direction = a:direction
	let s:operator = v:operator
	let s:cursor_pos = getpos('.')
	let s:operatorfunc = &operatorfunc
	call feedkeys(a:mode)
endfunction

function! s:ninja_strike(mode)
	call setpos('.', s:cursor_pos)
	let &operatorfunc = s:operatorfunc
	let mode = a:mode == 'line' ? "'" : "`"
	if s:direction == ']'
		" Manually adjust for inclusive behaviour.
		" TODO: Find a cleaner solution
		let pos = getpos("'".s:direction)
		if mode == '`' && pos[2] == strlen(getline(pos[1]))
			" End marks end of line. Just use $.
			let mode = ''
			let s:direction = '$'
		else
			" Add one to the mark column position
			let pos[2] = pos[2] + 1
			call setpos("'".s:direction, pos)
		endif
	endif
	call feedkeys(s:operator.mode.s:direction)
endfunction

onoremap <silent> <Plug>(ninja-left-foot-inner) <Esc>:<C-U>call <SID>ninja_prepare('i', '[')<CR>:<C-U>set operatorfunc=<SID>ninja_strike<CR>g@
onoremap <silent> <Plug>(ninja-left-foot-a) <Esc>:<C-U>call <SID>ninja_prepare('a', '[')<CR>:<C-U>set operatorfunc=<SID>ninja_strike<CR>g@
onoremap <silent> <Plug>(ninja-right-foot-inner) <Esc>:<C-U>call <SID>ninja_prepare('i', ']')<CR>:<C-U>set operatorfunc=<SID>ninja_strike<CR>g@
onoremap <silent> <Plug>(ninja-right-foot-a) <Esc>:<C-U>call <SID>ninja_prepare('a', ']')<CR>:<C-U>set operatorfunc=<SID>ninja_strike<CR>g@
omap [i <Plug>(ninja-left-foot-inner)
omap [a <Plug>(ninja-left-foot-a)
omap ]i <Plug>(ninja-right-foot-inner)
omap ]a <Plug>(ninja-right-foot-a)

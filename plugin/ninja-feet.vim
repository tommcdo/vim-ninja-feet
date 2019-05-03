function! s:ninja_prepare(mode, direction, count)
	let s:direction = a:direction
	let s:operator = v:operator
	let s:register = '"' . v:register
	let s:cursor_pos = getpos('.')
	let s:operatorfunc = &operatorfunc
	call feedkeys(a:count.a:mode)
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
	" `s:register`, here, might not be the same as the current active register.
	" Upon feeding the keys, however, s:register would overtake as the active
	" register. To get around that:
	" 1 - first record the active register,
	let active_register = v:register
	" 2 - feed the keys with the recorded `s:register`,
	call feedkeys(s:register.s:operator.mode.s:direction, 'n')
	" 3 - then re-active the active register recorded on 1.
	call feedkeys('"' . active_register . "\<Plug>NINJAFEET_ResetActiveRegister")
endfunction
nnoremap <silent> <Plug>NINJAFEET_ResetActiveRegister <nop>

function! s:ninja_insert(mode)
	let op = a:mode == 'line' ? 'O' : 'i'
	call feedkeys('`['.op, 'n')
endfunction

function! s:ninja_append(mode)
	let op = a:mode == 'line' ? 'o' : 'a'
	call feedkeys('`]'.op, 'n')
endfunction

function! s:map_expr(sid, type, direction, count)
	let map = ''
	let map .= "\<Esc>"
	let map .= ":\<C-U>call ".a:sid."ninja_prepare('".a:type."', '".a:direction."', '".a:count."')\<CR>"
	let map .= ":\<C-U>set operatorfunc=".a:sid."ninja_strike\<CR>g@"
	return map
endfunction

function! s:map(lhs, rhs, mode)
	if !hasmapto(a:rhs, a:mode)
		execute a:mode.'map '.a:lhs.' '.a:rhs
	endif
endfunction

onoremap <silent> <expr> <Plug>(ninja-left-foot-inner)  <SID>map_expr("<SID>", 'i', '[', v:count1)
onoremap <silent> <expr> <Plug>(ninja-left-foot-a)      <SID>map_expr("<SID>", 'a', '[', v:count1)
onoremap <silent> <expr> <Plug>(ninja-right-foot-inner) <SID>map_expr("<SID>", 'i', ']', v:count1)
onoremap <silent> <expr> <Plug>(ninja-right-foot-a)     <SID>map_expr("<SID>", 'a', ']', v:count1)

nnoremap <silent> <Plug>(ninja-insert) :<C-U>set operatorfunc=<SID>ninja_insert<CR>g@
nnoremap <silent> <Plug>(ninja-append) :<C-U>set operatorfunc=<SID>ninja_append<CR>g@

if !exists('g:ninja_feet_no_mappings')
	call s:map('[i', "<Plug>(ninja-left-foot-inner)", 'o')
	call s:map('[a', "<Plug>(ninja-left-foot-a)", 'o')
	call s:map(']i', "<Plug>(ninja-right-foot-inner)", 'o')
	call s:map(']a', "<Plug>(ninja-right-foot-a)", 'o')

	call s:map('z[', "<Plug>(ninja-insert)", 'n')
	call s:map('z]', "<Plug>(ninja-append)", 'n')
endif

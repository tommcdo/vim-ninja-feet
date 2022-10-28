" Keep track of the current cursor position in the active buffer
au CursorMoved,InsertLeave,BufEnter * let s:curpos = getpos('.')

fun! s:ninja_strike(direction, operator, opfunc, mode)
	let mode = a:mode == 'line' ? "'" : "`"
	let reg = v:register == '"' ? '' : '"'.v:register
	let inclusive_toggle = ''

	" Reset the cursor position to where it was before the motion/text object
	call setpos('.', s:curpos)

	if a:direction == ']'
		call setpos("'[", getpos("."))

		if a:mode == 'char'
			let inclusive_toggle = 'v'
		endif
	else
		call setpos("']", getpos("."))
	endif

	" c and ! are the only operators that require additional input after
	" selecting the motion/text object, which makes it hard to repeat them
	if a:operator == 'c' || a:operator == '!'
		" TODO: Fix repeating c and ! operators
		call feedkeys(reg.a:operator.inclusive_toggle.mode.a:direction)
	elseif a:operator == 'g@'
		call call(a:opfunc, [a:mode])
	else
		exec "normal" reg.a:operator.inclusive_toggle.mode.a:direction
	endif
endfun

fun! s:ninja_insert(mode)
	let op = a:mode == 'line' ? 'O' : 'i'
	call feedkeys('`['.op, 'n')
endfun

fun! s:ninja_append(mode)
	let op = a:mode == 'line' ? 'o' : 'a'
	call feedkeys('`]'.op, 'n')
endfun

fun! s:map_expr(direction, type, opfunc)
	" opfunc is passed as an argument since locally-scoped variables seem to
	" have issues in partial functions
	set opfunc=funcref('s:ninja_strike',[a:direction,v:operator,a:opfunc])
	return "\<Esc>\"".v:register."g@".v:count1.a:type
endfun

fun! s:map(lhs, rhs, mode)
	if !hasmapto(a:rhs, a:mode)
		execute a:mode.'map '.a:lhs.' '.a:rhs
	endif
endfun

onoremap <expr> <Plug>(ninja-left-foot)        <SID>map_expr('[', '',  &opfunc)
onoremap <expr> <Plug>(ninja-left-foot-inner)  <SID>map_expr('[', 'i', &opfunc)
onoremap <expr> <Plug>(ninja-left-foot-a)      <SID>map_expr('[', 'a', &opfunc)
onoremap <expr> <Plug>(ninja-right-foot)       <SID>map_expr(']', '',  &opfunc)
onoremap <expr> <Plug>(ninja-right-foot-inner) <SID>map_expr(']', 'i', &opfunc)
onoremap <expr> <Plug>(ninja-right-foot-a)     <SID>map_expr(']', 'a', &opfunc)

nnoremap <Plug>(ninja-insert) <Cmd>set operatorfunc=<SID>ninja_insert<CR>g@
nnoremap <Plug>(ninja-append) <Cmd>set operatorfunc=<SID>ninja_append<CR>g@

if !get(g:, 'ninja_feet_no_mappings', 0)
	call s:map('[i', "<Plug>(ninja-left-foot-inner)", 'o')
	call s:map('[a', "<Plug>(ninja-left-foot-a)", 'o')
	call s:map(']i', "<Plug>(ninja-right-foot-inner)", 'o')
	call s:map(']a', "<Plug>(ninja-right-foot-a)", 'o')

	call s:map('z[', "<Plug>(ninja-insert)", 'n')
	call s:map('z]', "<Plug>(ninja-append)", 'n')
endif

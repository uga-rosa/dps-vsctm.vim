if has('nvim')
  function! s:clear() abort
    let ns = nvim_create_namespace('denops_std:buffer:decoration:decorate')
    call nvim_buf_clear_namespace(0, ns, 0, -1)
  endfunction

  function! s:get_all_line() abort
    return nvim_buf_get_lines(0, 0, -1, v:false)
  endfunction
else
  function! s:clear() abort
    call prop_clear(1, line('$'))
  endfunction

  function! s:get_all_line() abort
    return getline(1, '$')
  endfunction
endif

function! vsctm#update() abort
  let path = expand('%:p')
  let all_line = s:get_all_line()
  call denops#plugin#wait_async('vsctm', {
        \ -> denops#notify('vsctm', 'highlight', [path, all_line]) })
endfunction

function! vsctm#enable() abort
  augroup Vsctm
    autocmd! * <buffer>
    autocmd TextChanged,TextChangedI,TextChangedP,WinScrolled
          \ <buffer> call vsctm#util#debounce('call vsctm#update()', 100)
  augroup END
  call s:clear()
  call vsctm#update()
  set syntax=OFF
endfunction

function! vsctm#disable() abort
  augroup Vsctm
    autocmd! * <buffer>
  augroup END
  call s:clear()
  set syntax=ON
endfunction

function! vsctm#show_scope() abort
  call denops#request('vsctm', 'showScope', [expand('%:p'), s:all_lines()])
endfunction

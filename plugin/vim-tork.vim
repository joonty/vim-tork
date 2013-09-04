" ------------------------------------------------------------------------------
" Tork plugin for Vim                                                {{{
"
" Author: Jon Cairns <jon@joncairns.com>
"
" Description:
" Send tork commands from within Vim and provide methods for parsing the log
" files into the quickfix list.
"
" Requires: Vim 6.0 or newer
"
" Install:
" Put this file and the ruby file in the vim plugins directory (~/.vim/plugin)
" to load it automatically, or load it manually with :so sauce.vim.
"
" License: MIT
"
" }}}
" ------------------------------------------------------------------------------

" Debug enabled
if !exists("g:tork_debug")
    let g:tork_debug=1
endif

" Pre-tork command
if !exists("g:tork_pre_command")
    let g:tork_pre_command=""
endif

command! -nargs=* -complete=file TorkRun call s:TorkSendFile(<q-args>)
command! TorkRunAll call s:TorkSend("run_all_test_files")
command! TorkStop call s:TorkSend("stop_running_test_files")
command! TorkKill call s:TorkSend("stop_running_test_files SIGKILL")
command! TorkRerunPassed call s:TorkSend("rerun_passed_test_files")
command! TorkRerunFailed call s:TorkSend("rerun_failed_test_files")
command! TorkAbsorb call s:TorkSend("reabsorb_overhead")
command! -nargs=+ -complete=customlist,s:TorkSendOptions Tork call s:TorkSend(<q-args>)

function! s:TorkSend(arg_string)
    let l:cmd = s:TorkCdCmd()
    if len(g:tork_pre_command) > 0
      let l:cmd .= g:tork_pre_command . " && "
    endif
    let l:cmd .= "echo " . a:arg_string . " | tork-remote tork-driver"
    if g:tork_debug == 1
        echo "tork: running `" . l:cmd . "`"
    endif
    let l:op = system(l:cmd)
    if len(l:op) > 0
        echoerr "tork: " . l:op
    endif
endfunction

function! s:TorkCdCmd()
    if exists("*g:TorkDir")
        if g:tork_debug == 1
            echo "vim-tork: calling user function g:TorkDir"
        endif
        return "cd " . g:TorkDir() . " && "
    else
        return ""
    endif
endfunction

function! s:TorkSendOptions(A, L, P)
    let l:options = ["run_test_file",
                    \"run_test_files",
                    \"reabsorb_overhead",
                    \"stop_running_test_files",
                    \"rerun_failed_test_files",
                    \"rerun_passed_test_files",
                    \"quit"]
    return filter(l:options, 'v:val =~ a:A')
endfunction

function! s:TorkSendFile(file)
    if len(a:file) == 0
        let l:file = expand("%:p")
    else
        let l:file = a:file
    endif
    if len(l:file) == 0
        echoerr "tork: no test file specified"
    else
        call s:TorkSend("run_test_file " . l:file)
    endif
endfunction

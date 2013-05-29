" ------------------------------------------------------------------------------
" Tork plugin for Vim                                                {{{
"
" Author: Jon Cairns <jon@joncairns.com>
"
" Description:
" Send tork commands from within Vim and provide methods for parsing the log
" files into the quickfix list.
"
" Requires: Vim 6.0 or newer, compiled with Python.
"
" Install:
" Put this file and the ruby file in the vim plugins directory (~/.vim/plugin)
" to load it automatically, or load it manually with :so sauce.vim.
"
" License: MIT
"
" }}}
" ------------------------------------------------------------------------------

if filereadable($VIMRUNTIME."/plugin/tork.rb")
    rubyfile $VIMRUNTIME/plugin/tork.rb
elseif filereadable($HOME."/.vim/plugin/tork.rb")
    rubyfile $HOME/.vim/plugin/tork.rb
else
    " when we use pathogen for instance
    let $CUR_DIRECTORY=expand("<sfile>:p:h")

    if filereadable($CUR_DIRECTORY."/tork.rb")
        rubyfile $CUR_DIRECTORY/tork.rb
    else
        call confirm('tork.vim: Unable to find tork.rb. Place it in either your home vim directory or in the Vim runtime directory.', 'OK')
        finish
    endif
endif

" Debug enabled
if !exists("g:tork_debug")
    let g:tork_debug=1
endif

command! -nargs=* -complete=file TorkRun call s:TorkSendFile(<q-args>)
command! TorkRunAll call s:TorkSend("run_test_files")
command! TorkStop call s:TorkSend("stop_running_test_files")
command! TorkKill call s:TorkSend("stop_running_test_files SIGKILL")
command! TorkRerunPassed call s:TorkSend("rerun_passed_test_files")
command! TorkRerunFailed call s:TorkSend("rerun_failed_test_files")
command! TorkReabsorb call s:TorkSend("reabsorb_overhead")
command! -nargs=1 -complete=file TorkParseLog call s:TorkParseLog(<f-args>)
command! -nargs=+ -complete=customlist,s:TorkSendOptions Tork call s:TorkSend(<q-args>)

function! s:TorkSend(arg_string)
    let l:cmd = "echo " . a:arg_string . " | tork-remote tork-engine"
    if g:tork_debug == 1
        echo "tork: ". l:cmd
    endif
    call system(l:cmd)
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

function! s:TorkParseLog(log_file)
    ruby tork_parse_log(VIM::evaluate("a:log_file"), VIM::evaluate("g:tork_debug == 1"))
endfunction

function! s:TorkSendFile(file)
    if len(a:file) == 0
        let l:file = expand("%:p")
    else
        let l:file = a:file
    endif
    if len(l:file) == 0
        echoerr "No test file specified"
    else
        call s:TorkSend("run_test_file " . l:file)
    endif
endfunction

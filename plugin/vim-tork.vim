" ------------------------------------------------------------------------------
" Vim PHPUnitQf                                                {{{
"
" Author: Jon Cairns <jon@joncairnsMaintainer.com>
"
" Description:
" Run PHPUnit from within Vim and parse the output into the quickfix list, to
" allow for easy navigation to failed test methods.
"
" Requires: Vim 6.0 or newer, compiled with Python.
"
" Install:
" Put this file and the python file in the vim plugins directory (~/.vim/plugin)
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

    if filereadable($CUR_DIRECTORY."/tork.py")
        rubyfile $CUR_DIRECTORY/tork.rb
    else
        call confirm('tork.vim: Unable to find tork.rb. Place it in either your home vim directory or in the Vim runtime directory.', 'OK')
        finish
    endif
endif

" Debug enabled
if !exists("g:tork_debug")
    let g:tork_debug=0
endif
command! TorkRunAll <nop>
command! Tork <nop>

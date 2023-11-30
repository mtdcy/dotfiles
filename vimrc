""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""{{{
" Copyright 2018 (c) Chen Fang
"
" Redistribution and use in source and binary forms, with or without
" modification, are permitted provided that the following conditions are met:
"
" 1. Redistributions of source code must retain the above copyright notice, this
" list of conditions and the following disclaimer.
"
" 2. Redistributions in binary form must reproduce the above copyright notice,
" this list of conditions and the following disclaimer in the documentation
" and/or other materials provided with the distribution.
"
" THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
" IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
" DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
" FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
" DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
" SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
" CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
" OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
" OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
"
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""}}}

" => General Options "{{{

" set color and theme
set termguicolors
set background=dark
colorscheme solarized8_flat

" 字体
if has('gui_running')
    set macligatures
    if has('linux')
        set guifont=Droid\ Sans\ Mono\ 12
        "set guifont=Fira\ Code\ 12
    else
        set guifont=Droid\ Sans\ Mono:h12
        "set guifont=Fira\ Code:h12
    endif
    if has('gui_win32')         " why this only work on win32 gui
        language en             " always English
        language messages en
    endif
    " remove left and right scrollbars
    set guioptions-=rl
else
    " fix paste without gui, like ssh + vim
    "set paste => cause inoremap stop working
    set pastetoggle=<F12>
endif
"set antialias

" 显示行号
set number

" 文件编码
set fileencoding=utf-8
set fileencodings=utf-8,gb18030,gbk,latin1

" 文件类型
set fileformat=unix
set ffs=unix,dos

" 不备份文件
set nobackup
set nowritebackup

" 上下移动时，留3行
set so=3

" Don't ask me to save file before switching buffers
set hidden

" 高亮当前行
set cursorline
set nocursorcolumn

" 语法高亮
syntax on
"set regexpengine=1  " force old regex engine, solve slow problem

" 使用非兼容模式
set nocompatible

" 有关搜索的选项
set hls
set incsearch
au InsertEnter * set noic 
au InsertLeave * set ic
set smartcase

" 一直启动鼠标
set mouse=a

" show command on the bottom of the screen
set showcmd

" 设置mapleader
let mapleader = ";"
let g:mapleader = ";"

" set backspace behavior
set backspace=indent,eol,start

" no bracket match 
set noshowmatch

" Smart way to move btw. windows
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l

" }}}

" => Status Line {{{


set laststatus=2
set statusline=[%{mode()}][%n]\ %<%F%m%r%q%w        " buffer property
set statusline+=\ %#warningmsg#                     " syntastic 
set statusline+=\ %{SyntasticStatuslineFlag()}      " syntastic
set statusline+=%*                                  " syntastic: reset color
set statusline+=%=                                  " separation
set statusline+=\ %l/%L:%c\ %p%%                    " cursor position
set statusline+=\ %y[%{&fenc}][%{&ff}]              " file property

" }}}

" => Files "{{{
"
" ts    - tabstop       - tab宽度
" sts   - softtabstop   - 按下tab时的宽度（用tab和space组合填充）
" sw    - shiftwidth    - 自动缩进宽度
" et    - expandtab     - 是否展开tab
" tw    - textwidth     - 文本宽
" ai    - autoindent

" For all
"set autochdir 		        " may cause problem to some plugins
autocmd BufEnter * silent! lcd %:p:h " alternative for autochdir

filetype plugin indent on

" common settings
set ts=4 sts=4 sw=4 et ff=unix
set autoindent 
set smartindent
set cindent
set cinwords=if,else,while,do,for,switch
set cinkeys=0{,0},0(,0),0[,0],:,;,0#,~^F,o,O,0=if,e,0=switch,0=case,0=break,0=whilea,0=for,0=do
set cinoptions=>s,e0,n0,f0,{0,}0,^0,Ls,:s,=s,l1,b1,g0,hs,N-s,E-s,ps,t0,is,+-s,t0,cs,C0,/0,(0,us,U0,w0,W0,k0,m1,M0,#0,P0

" fold default by marker
set foldmethod=marker
set foldlevelstart=99

function! JumpToLastPos()
    if line("'\"") > 0 && line ("'\"") <= line("$") && &ft !~# 'commit'
        exe "normal! g'\""
    endif
endfunction

" autocmd for all files
augroup files
    au!
    " 自动跳转到上一次打开的位置
    au BufReadPost * call JumpToLastPos()
    " set extra properties for interest files
    "au FileType c,cpp,rust setlocal tw=79 ff=unix
    au FileType c,cpp,rust setlocal ff=unix fdm=syntax
augroup END

" For LiteOS project
au FileType *.pkg setlocal filetype=sh

"}}}

" => Plugin "{{{
" bufexplorer 

" NERDTreeToggle
nmap <F9> :NERDTreeToggle <CR>

" tagbar [FIXME: tagbar use on fly tags, but we have loaded a tag file]
nmap <F10> :TagbarToggle<CR>
let g:tagbar_autofocus = 1
let g:tagbar_autoshowtag = 1
let g:tagbar_iconchars = ['+', '-']     "
let g:tagbar_compact = 1                "

" syntastic - auto errors check on :w
"  => syntastic is deprecated, keep it here for old languages
"   => install new plugin for new languages 
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 0
let g:syntastic_vim_checkers = ['vint', 'shfmt']
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 1
let g:syntastic_vim_vint_quiet_messages = { "!level" : "errors" }

" neosnippet
imap <C-o>  <Plug>(neosnippet_expand_or_jump)
smap <C-o>  <Plug>(neosnippet_expand_or_jump)
let g:neosnippet#enable_snipmate_compatibility = 1

" vim-go
set autowrite   " auto save file before run or build
let g:go_def_mode='gopls'
let g:go_info_mode='gopls'

let g:go_highlight_types = 1
let g:go_highlight_fields = 1
let g:go_highlight_functions = 1
let g:go_highlight_function_calls = 1
let g:go_highlight_operators = 1
let g:go_highlight_extra_types = 1

augroup Go
    autocmd FileType go nmap <buffer> gb        <Plug>(go-build)
    autocmd FileType go nmap <buffer> gr        <Plug>(go-run)
    autocmd FileType go nmap <buffer> gd        <Plug>(go-def)
    autocmd FileType go nmap <buffer> fj        <Plug>(go-def)
augroup END

" vim-racer
let g:racer_experimental_completer = 1
augroup Racer
    autocmd!
    autocmd FileType rust nmap <buffer> fj          <Plug>(rust-def)
    autocmd FileType rust nmap <buffer> fJ          <Plug>(rust-def-split)
    "autocmd FileType rust nmap <buffer> gs         <Plug>(rust-def-split)
    "autocmd FileType rust nmap <buffer> gx         <Plug>(rust-def-vertical)
    "autocmd FileType rust nmap <buffer> gt         <Plug>(rust-def-tab)
    "autocmd FileType rust nmap <buffer> <leader>gd <Plug>(rust-doc)
    "autocmd FileType rust nmap <buffer> <leader>gD <Plug>(rust-doc-tab)
augroup END

augroup cgroup
    autocmd!
    autocmd FileType c,c++  nmap <buffer> fj        <C-]>
    autocmd FileType *      nmap <buffer> bj        <C-T>
augroup END

" deoplete
if has('nvim')
    set completeopt=menu,longest
    set complete=],.,i,d,b,u,w " :h 'complete'

    let g:deoplete#enable_at_startup = 1

    call deoplete#custom#source('_',
                \ 'smart_case', v:true 
                \ )

    " 为每个语言定义completion source
    " 是的vim script和zsh script都有，这就是deoplete
    call deoplete#custom#option( 
                \ 'sources', {
                \   'cpp'   : ['LanguageClient'],
                \   'c'     : ['LanguageClient'],
                \   'vim'   : ['vim'],
                \   'zsh'   : ['zsh']
                \ })
    " for vim-go
    call deoplete#custom#option( 'omni_patterns', { 'go' : '[^. *\t]\.\w*' })

    " 补全结束或离开插入模式时，关闭预览窗口
    autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif

    function! SuperTab() abort
        if pumvisible() 
            return "\<C-N>"
        elseif neosnippet#jumpable()
            return "\<Plug>(neosnippet_jump)"
        else
            return "\<TAB>"
        endif 
    endfunction 
    imap <silent> <expr><TAB>  SuperTab()

    " Space: 只选择候选词，区别于Enter，这样可以避免snippets
    function! SuperSpace()
        if pumvisible()
            return "\<C-Y>\<Space>"
        else
            return "\<Space>"
        endif 
    endfunction()
    imap <silent> <expr><Space> SuperSpace()

    " Enter: 候选词选择 + snippets
    function! SuperEnter() abort
        if neosnippet#expandable() 
            return "\<Plug>(neosnippet_expand)"
        elseif pumvisible()
            return "\<C-Y>"
        else
            return "\<Enter>"
        endif
    endfunction
    imap <silent> <expr><Enter> SuperEnter()

    " echodoc 
    let g:echodoc#enable_at_startup = 1
    let g:echodoc#type = "floating"
    let g:echodoc#floating_config = {'border': 'single'}
    highlight link EchoDocFloat Pmenu
endif

" }}}

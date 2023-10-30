""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""{{{
" Copyright 2018 (c) Chen Fang
"
" Redistribution and use in source and binary forms, with or without
" modification, are permized provided that the following conditions are met:
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

" simple IDE setup by Chen Fang
" ==> options {{{
"if exists("g:simple_ide_setup")
"    finish
"endif

" this options set should work in global
" set completopt and preview window on the bottom
set completeopt=menuone,longest
set complete=],.,i,d,b,u,w " :h 'complete'

" use cstag instead of tag
"set cst
"set csto=1
"set cscopequickfix=s-,g-,c-,d-,i-,t-,e-

let g:simple_ide_setup = 1
let s:select_first = 1
let s:completing = 0

let s:types = '\.\(asm\|c\|cpp\|cc\|h\|rs\)$'
let s:fileList = ".files"
let s:ctagsDB = ".ctags"
let s:cscopeDB = ".cscope"
let s:ctagsCMD = "ctags -f " . s:ctagsDB
let s:cscopeCMD = "cscope -bkq -f " . s:cscopeDB
" <== END }}}

" ==> Functions for tags management {{{
function! z#find_root()
    if expand("%:p") =~? s:types 
        if exists('b:root') && !empty('b:root')     " cache
            echo "cached b:root: [" . b:root . "]"
            return b:root
        endif

        exe "lcd " . expand("%:p:h")
        let tags = findfile(s:fileList, ".;")
        if (empty(tags))
            let b:root = ''
        else
            let b:root = fnamemodify(tags, ":p:h")
        endif
        echo "b:root: [" . b:root . "]"
        lcd -
        return b:root
    endif
    return ''
endfunction

" load tags and cscope db
function! z#tags_load()
    if expand("%:p") =~? s:types 
        let root = z#find_root()
        if (empty(root))
            return
        else
            exe "lcd " . root
            if (filereadable(s:ctagsDB))                     " load ctags db
                exe "set tags=" . root . "/" . s:ctagsDB
            endif
            if (filereadable(s:cscopeDB))                    " load cscope db
                set nocscopeverbose
                exe "cs reset"
                exe "cs add " . root . "/" . s:cscopeDB . " " . root
                set cscopeverbose
            endif
            lcd -
        endif
    endif
endfunction

" create tags and cscope db
function! z#tags_create()
    let b:root = input("project root: ", expand("%:p:h"))   " project root
    exe "lcd " . b:root 
    let files = glob("**", v:false, v:true)
    call filter(files, 'filereadable(v:val)')               " filter out directory
    call filter(files, 'v:val =~? s:types')                 " only interested files
    call writefile(files, b:root . "/" . s:fileList)        " save list
    exe "silent !" . s:ctagsCMD . " -L " . s:fileList
    exe "silent !" . s:cscopeCMD . " -i " . s:fileList
    lcd -
    call z#tags_load()
    exe "redraw!"
endfunction

" update tags and cscope db if loaded
function! z#tags_update()
    let root = z#find_root()
    if (empty(root))
        return
    endif

    exe "lcd " . root
    let file = fnamemodify(expand("%:p"), ":.")                 " path related to project root
    if file =~? s:types
        let files = readfile(s:fileList)
        if match(files, file) < 0
            files+=file
            call writefile(files, s:fileList)
        endif

        if (filewritable(s:ctagsDB))                           " update ctags
            exe "silent !" . s:ctagsCMD . " " . file
            " no need to reload
        endif
        if (filewritable(s:cscopeDB))                          " update cscope db and reload
            exe "silent !" . s:cscopeCMD . " " . file
            exe "silent cs reset"
        endif
    endif
    lcd -
    exe "redraw!"
endfunction

function! z#gettext_before_cursor()
    if col('.') > 1
        return strpart(getline('.'), 0, col('.') - 1)
    else
        return ''
    endif 
endfunction

function! z#select_first()
    if exists('s:select_first') && s:select_first == 1
        return "\<C-N>"
    else
        return ""
    endif
endfunction

function! z#startcomplete()
    let s:completing = 1
    "set ic
endfunction

function! z#endcomplete()
    "set noic
    let s:completing = 0
endfunction

function! z#supertab()
    if pumvisible()
        call z#endcomplete()
        " next candidate on pop list
        return "\<C-N>"
    else
        call z#startcomplete()
        let word = z#gettext_before_cursor()
        if word =~? '\(\s\+\|^\|,\|;\|"\|(\|)\|[\|]\|{\|}\)$'   " spcaces or empty line
            return "\<TAB>"                             " insert tab
        elseif word =~? '\(\.\|->\|::\)$'
            return "\<C-X>\<C-O>" . z#select_first()    " using omni complete
        else
            return "\<C-N>" . z#select_first() 
        endif
    endif
    return "\<TAB>"
endfunction

function! z#superbs() 
    if pumvisible()                                             " undo & close popup
        call z#endcomplete()
        return "\<C-E>"
    endif
    return "\<BS>"
endfunction

function! z#superenter() 
    if pumvisible()
        call z#endcomplete()
        return "\<C-Y>"
    else
        return "\<Enter>"
    endif
endfunction

function! z#superspace()
    if pumvisible()
        call z#endcomplete()
        " select candidate and insert space
        return "\<C-Y>\<Space>"
    else
        return "\<Space>"
    endif
endfunction

function! z#superesc()
    if pumvisible()
        call z#endcomplete()
        return "\<C-E>\<ESC>"
    endif
    return "\<ESC>"
endfunction
" <== END }}}

" ==> Configurations {{{
augroup tagsmngr
    au!
    " load tags on BufEnter
    au BufReadPost * silent call z#tags_load()
    " update tags on :w
    au BufWritePost * silent call z#tags_update()
    " omni complete for c,cpp
    "au FileType * call z#setup_completion()
augroup END

" supertab
inoremap <silent> <expr><TAB>   z#supertab()
inoremap <silent> <expr><BS>    z#superbs()
inoremap <silent> <expr><Enter> z#superenter()
inoremap <silent> <expr><Space> z#superspace()
inoremap <silent> <expr><ESC>   z#superesc()

" set cscope key map
"set cscopequickfix=s-,g-,d-,c-,t-,e-,f-,i-                          " ???
"nnoremap <leader>j :cstag <C-R>=expand("<cword>")<CR><CR>           " junp with cscope tag
"nnoremap <leader>fa :cs find a <C-R>=expand("<cword>")<CR><CR>      " a: find assignment to this symbol
"nnoremap <leader>fs :cs find s <C-R>=expand("<cword>")<CR><CR>      " s: find this symbol
"nnoremap <leader>fg :cs find g <C-R>=expand("<cword>")<CR><CR>      " g: find this definition
"nnoremap <leader>fc :cs find c <C-R>=expand("<cword>")<CR><CR>      " c: find functions calling this function
"nnoremap <leader>fd :cs find d <C-R>=expand("<cword>")<CR><CR>      " d: find functions called by this function
"nnoremap <leader>ff :cs find f <C-R>=expand("<cfile>")<CR><CR>      " f: find this file

" <== END }}}

" ==> Commands {{{
command! -nargs=0 -bar InitTags call z#tags_create()

" <== END }}}

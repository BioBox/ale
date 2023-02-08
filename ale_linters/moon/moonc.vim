" Author: Daniel James Perry https://github.com/BioBox
" Description: moonc linter for moonscript files

call ale#Set('moon_moonc_executable', 'moonc')

function! ale_linters#moon#moonc#Handle(buffer, lines) abort
    " Matches the following:
    "
    " line 2: assigned but unused `uin`
    " ===================================
    " > uin = require "user-input-module"
    "
    " Failed to parse:
    "  [5] >>    new: (local tpos, loop_state) =>
    let l:pattern = ['\v^.*(\d+): (.{-})\n', '\v^(.+):\n \[(\d+)\].*$']
    let l:warning = l:pattern[0]
    let l:error = l:pattern[1]
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:warning)
        call add(l:output, {
        \   'lnum': l:match[1] + 0,
        \   'type': 'W',
        \   'text': l:match[2],
        \})
    endfor

    for l:match in ale#util#GetMatches(a:lines, l:error)
        call add(l:output, {
        \   'lnum': l:match[2] + 0,
        \   'type': 'E',
        \   'text': l:match[1],
        \})
    endfor

    return l:output
endfunction


call ale#linter#Define('moon', {
\   'name': 'moonc',
\   'executable': {b -> ale#Var(b, 'moon_moonc_executable')},
\   'output_stream': 'stderr',
\   'lint_file': 0,
\   'command': '%e -l %s',
\   'callback': 'ale_linters#moon#moonc#Handle',
\})


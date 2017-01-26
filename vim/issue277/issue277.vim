scripte utf8

" This is a test-script for the virtcol-function, i.e.
" the charset.c/getvcol-procedure. 
"
" For different 'test-lines' (a.k.a. test cases)
" the vim-function virtcol() is called for different
" byte-positions in order to get the visual/virtual 
" column/result of the virtcol-function. These 
" results are then compared to given expected values.
"
" In order to see the details, of a line, before the
" tests (for each test-line) a overview table is generated.
" Here the bytes, Unicode codepoints and visual columns
" are shown.
" After this overview table, the tests are done and
" the results appended after the overview table.
"
" To start the test 
" :so issue277.vim
" in an (empty) modifiable buffer or call
"
" gvim -u NONE -U NONE -N -c ':so issue277.vim'


fu! ByteCodePointsTableForLine()
  " This is a helper function to return a multiline-string with a
  " table showing the bytes, codepoints columns and 
  " visual columns of the current line of the current buffer.
  let byte_no=0 | let vc_no=1 |  let result=''

  let result .= "─────┬────┬──────────┬────┬──────────────────\n"
  let result .= " Ind.│Byte│codepoint │Vcol│ grapheme cluster\n"

  let last_col = strlen(getline('.'))
  normal |

  while getpos('.')[2]<=last_col
    normal ""vy
    let line_v_start = 1
    let result .= "─────┼────┼──────────┼────┼──────────────────\n"
    let no_chars = strchars(@") | let charpos=0
    while charpos<=no_chars
      let codepoint = strcharpart(@",charpos,1)
      let codenumber = char2nr(codepoint)
      let byte_size = strlen(codepoint)
      let bytepos=0 | let line_cp_start = 1
      while bytepos<byte_size
        let byte = codepoint[bytepos]
        let cn_str = line_cp_start?printf("U+%06x",codenumber):"        "
        let vn_str = line_v_start?printf("%02x",vc_no):"  "
        let result .= printf("  %02x │ %02x │ %s │ %s │ %s\n",
           \byte_no, char2nr(byte), cn_str, vn_str, line_v_start?@":"")
        let bytepos += 1      | let byte_no += 1
        let line_v_start = 0  | let line_cp_start = 0
      endwhile
      let charpos += 1
    endwhile
    let vc_no += strdisplaywidth(@") | normal l
  endwhile
  let result .= "─────┴────┴──────────┴────┴──────────────────\n"
  return result
endfu

fu! Issue277Test()
  " This is the function doing the tests.
  set ve=all
  let sep="════════════════════════════════════════════════════"
  " Here are the test cases
  let test_list = [
    \  { 'line' : "abc", 'tests': [ [0,1], [1,2], [2,3], [3,4], [4,0]        ] },
    \  { 'line' : "aâ" , 'tests': [ [0,1], [1,2], [2,2], [3,2], [4,3], [5,0] ] },
    \  { 'line' : "â"  , 'tests': [ [0,1], [1,1], [2,1], [3,2], [4,0]        ] },
    \  { 'line' : "─"  , 'tests': [ [0,1], [1,1], [2,1], [3,2], [4,0]        ] },
    \  { 'line' : "😀a", 'tests': [ [0,2], [1,2], [2,2], [3,2], [4,3],
    \                               [5,4], [6,0]                             ] },
    \  { 'line' : "a😀", 'tests': [ [0,1], [1,3], [2,3], [3,3], [4,3], [5,4],
    \                               [6,0]                                    ] },
    \  { 'line' : "â̲😀", 'tests': [ [0,1], [1,1], [2,1], [3,1], [4,1],
    \                               [5,3], [6,3], [7,3], [8,3], [9,4], [10,0]] },
    \  { 'line' : "😀â̲", 'tests': [ [0,2], [1,2], [2,2], [3,2], [4,3], [5,3],
    \                               [6,3], [7,3], [8,3], [9,4], [10,0]       ] }
    \ ]
  1,$d
  for test_line in test_list
    call append(line('$'), sep) | call append(line('$'), test_line["line"])
    normal G1|
    let test_pos = getcurpos()
    silent put =ByteCodePointsTableForLine()
    for test in test_line['tests']
      let bytepos = test[0] | let col = bytepos+1
      let result = virtcol([test_pos[1],col])
      call append(line('$'), printf(
        \ "vcol(Ind=%2i)=virtcol([<line>,%2i])=%2i; expected=%2i %s",
        \ bytepos, col, result, test[1], result!=test[1]?"⁇":"✓"))
    endfor
    call append(line('$'), sep) | call append(line('$'),"")
  endfor
  normal 1G
endfu

call Issue277Test()

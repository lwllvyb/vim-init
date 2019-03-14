"======================================================================
"
" init-plugins.vim - 
"
" Created by skywind on 2018/05/31
" Last Modified: 2018/05/31 10:52:41
"
"======================================================================

if !exists('g:bundle_group')
	let g:bundle_group = ['basic', 'tags', 'enhanced', 'filetypes', 'textobj']
	let g:bundle_group += ['tags', 'airline', 'nerdtree', 'ale', 'echodoc']
	let g:bundle_group += ['quickfix']
endif


"----------------------------------------------------------------------
" 计算当前 vim-init 的子路径
"----------------------------------------------------------------------
let s:home = fnamemodify(resolve(expand('<sfile>:p')), ':h')

function! s:path(path)
	let path = expand(s:home . '/' . a:path )
	return substitute(path, '\\', '/', 'g')
endfunc


"----------------------------------------------------------------------
" 在 ~/.vim/bundles 下安装插件
"----------------------------------------------------------------------
call plug#begin(get(g:, 'bundle_home', '~/.vim/bundles'))

let mapleader='space'

"----------------------------------------------------------------------
" 默认插件 
"----------------------------------------------------------------------
Plug 'easymotion/vim-easymotion'
Plug 'justinmk/vim-dirvish'
Plug 'tpope/vim-unimpaired'
Plug 'godlygeek/tabular', { 'on': 'Tabularize' }
Plug 'skywind3000/asyncrun.vim'
" Plug 'hecal3/vim-leader-guide'
Plug 'zhenyangze/vim-leader-guide'
Plug 'scrooloose/nerdcommenter'
Plug 'dracula/vim', { 'as': 'dracula' }


"----------------------------------------------------------------------
" 编译运行 C/C++ 项目
" 详细见：http://www.skywind.me/blog/archives/2084
"----------------------------------------------------------------------

" 自动打开 quickfix window ，高度为 6
let g:asyncrun_open = 6

" 任务结束时候响铃提醒
let g:asyncrun_bell = 1

" 设置 F10 打开/关闭 Quickfix 窗口
nnoremap <F10> :call asyncrun#quickfix_toggle(6)<cr>

" F9 编译 C/C++ 文件
nnoremap <silent> <F9> :AsyncRun gcc -Wall -O2 "$(VIM_FILEPATH)" -o "$(VIM_FILEDIR)/$(VIM_FILENOEXT)" <cr>

" F5 运行文件
nnoremap <silent> <F5> :AsyncRun -raw -cwd=$(VIM_FILEDIR) "$(VIM_FILEDIR)/$(VIM_FILENOEXT)" <cr>

" F7 编译项目
nnoremap <silent> <F7> :AsyncRun -cwd=<root> make <cr>

" F8 运行项目
nnoremap <silent> <F8> :AsyncRun -cwd=<root> -raw make run <cr>

" F6 测试项目
nnoremap <silent> <F6> :AsyncRun -cwd=<root> -raw make test <cr>

" 更新 cmake
nnoremap <silent> <F4> :AsyncRun -cwd=<root> cmake . <cr>

" Windows 下支持直接打开新 cmd 窗口运行
if has('win32') || has('win64')
	nnoremap <silent> <F5> :AsyncRun -cwd=$(VIM_FILEDIR) -mode=4 "$(VIM_FILEDIR)/$(VIM_FILENOEXT)" <cr>
	nnoremap <silent> <F8> :AsyncRun -cwd=<root> -mode=4 make run <cr>
endif


"----------------------------------------------------------------------
" F2 在项目目录下 Grep 光标下单词，默认 C/C++/Py/Js ，扩展名自己扩充
"----------------------------------------------------------------------
if executable('rg')
	noremap <silent><F2> :AsyncRun! -cwd=<root> rg -n --no-heading 
				\ --color never -g *.h -g *.c* -g *.py -g *.js -g *.vim 
				\ <C-R><C-W> "<root>" <cr>
elseif has('win32') || has('win64')
    noremap <silent><F2> :AsyncRun! -cwd=<root> findstr /n /s /C:"<C-R><C-W>" 
				\ "\%CD\%\*.h" "\%CD\%\*.c*" "\%CD\%\*.py" "\%CD\%\*.js"
				\ "\%CD\%\*.vim"
				\ <cr>
else
    noremap <silent><F2> :AsyncRun! -cwd=<root> grep -n -s -R <C-R><C-W> 
				\ --include='*.h' --include='*.c*' --include='*.py' 
				\ --include='*.js' --include='*.vim'
				\ '<root>' <cr>
endif



"----------------------------------------------------------------------
" Dirvish 设置：自动排序并隐藏文件，同时定位到相关文件
"----------------------------------------------------------------------
function! s:setup_dirvish()
	if &buftype != 'nofile' && &filetype != 'dirvish'
		return
	endif
	let text = getline('.')
	if ! get(g:, 'dirvish_hide_visible', 0)
		exec 'silent keeppatterns g@\v[\/]\.[^\/]+[\/]?$@d _'
	endif
	" 排序文件名
	exec 'sort ,^.*[\/],'
	let name = '^' . escape(text, '.*[]~\') . '[/*|@=|\\*]\=\%($\|\s\+\)'
	" 定位到之前光标处的文件
	call search(name, 'wc')
	noremap <silent><buffer> ~ :Dirvish ~<cr>
	noremap <buffer> % :e %
endfunc

augroup MyPluginSetup
	autocmd!
	autocmd FileType dirvish call s:setup_dirvish()
augroup END


"----------------------------------------------------------------------
" 基础插件
"----------------------------------------------------------------------
if index(g:bundle_group, 'basic') >= 0
	Plug 'tpope/vim-fugitive'
	Plug 'mhinz/vim-startify'
	Plug 'flazz/vim-colorschemes'
	Plug 'xolox/vim-misc'
	Plug 'terryma/vim-expand-region'
	Plug 'kshenoy/vim-signature'
	Plug 'mhinz/vim-signify'
	Plug 'mh21/errormarker.vim'
	Plug 't9md/vim-choosewin'
	Plug 'junegunn/fzf'
	Plug 'Raimondi/delimitMate'
	Plug 'skywind3000/vim-preview'
	Plug 'Yggdroot/LeaderF'

	" 使用 ALT+E 来选择窗口
	nmap <m-e> <Plug>(choosewin)

	" 默认不显示 startify
	let g:startify_disable_at_vimenter = 1
	let g:startify_session_dir = '~/.vim/session'
endif

"----------------------------------------------------------------------
" 与quickfix 相关的配置
"----------------------------------------------------------------------
if index(g:bundle_group, 'quickfix') >= 0
	Plug 'romainl/vim-qf'
endif

"----------------------------------------------------------------------
" 自动生成 ctags/gtags，并提供自动索引功能
" 详细用法见：https://zhuanlan.zhihu.com/p/36279445
"----------------------------------------------------------------------
if index(g:bundle_group, 'tags') >= 0
	Plug 'ludovicchabant/vim-gutentags'
	Plug 'skywind3000/gutentags_plus'

	" 设定项目目录标志：除了 .git/.svn 外，还有 .root 文件
	let g:gutentags_project_root = ['.root']
	let g:gutentags_ctags_tagfile = '.tags'

	" 默认生成的数据文件集中到 ~/.cache/tags 避免污染项目目录，好清理
	let g:gutentags_cache_dir = expand('~/.cache/tags')

	" 默认禁用自动生成
	let g:gutentags_modules = [] 

	" 如果有 ctags 可执行就允许动态生成 ctags 文件
	if executable('ctags')
		let g:gutentags_modules += ['ctags']
	endif

	" 如果有 gtags 可执行就允许动态生成 gtags 数据库
	if executable('gtags') && executable('gtags-cscope')
		let g:gutentags_modules += ['gtags_cscope']
	endif

	" 设置 ctags 的参数
	let g:gutentags_ctags_extra_args = []
	let g:gutentags_ctags_extra_args = ['--fields=+niazS', '--extra=+q']
	let g:gutentags_ctags_extra_args += ['--c++-kinds=+px']
	let g:gutentags_ctags_extra_args += ['--c-kinds=+px']

	" 使用 universal-ctags 的话需要下面这行，请反注释
	" let g:gutentags_ctags_extra_args += ['--output-format=e-ctags']

	" 禁止 gutentags 自动链接 gtags 数据库
	let g:gutentags_auto_add_gtags_cscope = 0

	noremap <space>pt :PreviewTag <C-R><C-W><cr>
	noremap <space>pc :PreviewClose <cr>
	noremap <silent> <space>cs :GscopeFind s <C-R><C-W><cr>
	noremap <silent> <space>cg :GscopeFind g <C-R><C-W><cr>
	noremap <silent> <space>cc :GscopeFind c <C-R><C-W><cr>
	noremap <silent> <space>ct :GscopeFind t <C-R><C-W><cr>
	noremap <silent> <space>ce :GscopeFind e <C-R><C-W><cr>
	noremap <silent> <space>cf :GscopeFind f <C-R>=expand("<cfile>")<cr><cr>
	noremap <silent> <space>ci :GscopeFind i <C-R>=expand("<cfile>")<cr><cr>
	noremap <silent> <space>cd :GscopeFind d <C-R><C-W><cr>
	noremap <silent> <space>ca :GscopeFind a <C-R><C-W><cr>
endif


"----------------------------------------------------------------------
" 文本对象
"----------------------------------------------------------------------
if index(g:bundle_group, 'textobj')
	Plug 'kana/vim-textobj-user'
	Plug 'kana/vim-textobj-indent'
	Plug 'kana/vim-textobj-syntax'
	Plug 'kana/vim-textobj-function', { 'for':['c', 'cpp', 'vim', 'java'] }
	Plug 'sgur/vim-textobj-parameter'
	Plug 'bps/vim-textobj-python', {'for': 'python'}
	Plug 'jceb/vim-textobj-uri'
endif


"----------------------------------------------------------------------
" 文件类型扩展
"----------------------------------------------------------------------
if index(g:bundle_group, 'filetypes') >= 0
	Plug 'lambdalisue/vim-gista', { 'on': 'Gista' }
	Plug 'pprovost/vim-ps1', { 'for': 'ps1' }
	Plug 'tbastos/vim-lua', { 'for': 'lua' }
	Plug 'octol/vim-cpp-enhanced-highlight', { 'for': ['c', 'cpp'] }
	Plug 'justinmk/vim-syntax-extra', { 'for': ['c', 'bison', 'flex', 'cpp'] }
	Plug 'vim-python/python-syntax', { 'for': ['python'] }
endif


"----------------------------------------------------------------------
" airline
"----------------------------------------------------------------------
if index(g:bundle_group, 'airline') >= 0
	Plug 'vim-airline/vim-airline'
	Plug 'vim-airline/vim-airline-themes'
	let g:airline_left_sep = ''
	let g:airline_left_alt_sep = ''
	let g:airline_right_sep = ''
	let g:airline_right_alt_sep = ''
	let g:airline_powerline_fonts = 0
	let g:airline_exclude_preview = 1
	let g:airline_section_b = '%n'
	let g:airline_theme='deus'
	let g:airline#extensions#branch#enabled = 0
	let g:airline#extensions#syntastic#enabled = 0
	let g:airline#extensions#fugitiveline#enabled = 0
	let g:airline#extensions#csv#enabled = 0
	let g:airline#extensions#vimagit#enabled = 0
endif


"----------------------------------------------------------------------
" NERDTree
"----------------------------------------------------------------------
if index(g:bundle_group, 'nerdtree') >= 0
	Plug 'scrooloose/nerdtree', {'on': ['NERDTree', 'NERDTreeFocus', 'NERDTreeToggle', 'NERDTreeCWD', 'NERDTreeFind'] }
	Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
	Plug 'airblade/vim-rooter'
	let g:NERDTreeMinimalUI = 1
	let g:NERDTreeDirArrows = 1
	let g:NERDTreeHijackNetrw = 0
""	noremap <space>nn :NERDTree<cr>
""	noremap <space>no :NERDTreeFocus<cr>
""	noremap <space>nm :NERDTreeMirror<cr>
""	noremap <space>nt :NERDTreeToggle<cr>
endif


"----------------------------------------------------------------------
" LanguageTool 语法检查
"----------------------------------------------------------------------
if index(g:bundle_group, 'grammer') >= 0
	Plug 'rhysd/vim-grammarous'
	noremap <space>rg :GrammarousCheck --lang=en-US --no-move-to-first-error --no-preview<cr>
	map <space>rr <Plug>(grammarous-open-info-window)
	map <space>rv <Plug>(grammarous-move-to-info-window)
	map <space>rs <Plug>(grammarous-reset)
	map <space>rx <Plug>(grammarous-close-info-window)
	map <space>rm <Plug>(grammarous-remove-error)
	map <space>rd <Plug>(grammarous-disable-rule)
	map <space>rn <Plug>(grammarous-move-to-next-error)
	map <space>rp <Plug>(grammarous-move-to-previous-error)
endif


"----------------------------------------------------------------------
" ale：动态语法检查
"----------------------------------------------------------------------
if index(g:bundle_group, 'ale') >= 0
	Plug 'w0rp/ale'

	" 设定延迟和提示信息
	let g:ale_completion_delay = 500
	let g:ale_echo_delay = 20
	let g:ale_lint_delay = 500
	let g:ale_echo_msg_format = '[%linter%] %code: %%s'

	" 设定检测的时机：normal 模式文字改变，或者离开 insert模式
	" 禁用默认 INSERT 模式下改变文字也触发的设置，太频繁外，还会让补全窗闪烁
	let g:ale_lint_on_text_changed = 'normal'
	let g:ale_lint_on_insert_leave = 1

	" 在 linux/mac 下降低语法检查程序的进程优先级（不要卡到前台进程）
	if has('win32') == 0 && has('win64') == 0 && has('win32unix') == 0
		let g:ale_command_wrapper = 'nice -n5'
	endif

	" 允许 airline 集成
	let g:airline#extensions#ale#enabled = 1

	" 编辑不同文件类型需要的语法检查器
	let g:ale_linters = {
				\ 'c': ['gcc', 'cppcheck'], 
				\ 'cpp': ['gcc', 'cppcheck'], 
				\ 'python': ['flake8', 'pylint'], 
				\ 'lua': ['luac'], 
				\ 'go': ['go build', 'gofmt'],
				\ 'java': ['javac'],
				\ 'javascript': ['eslint'], 
				\ }


	" 获取 pylint, flake8 的配置文件，在 vim-init/tools/conf 下面
	function s:lintcfg(name)
		let conf = s:path('tools/conf/')
		let path1 = conf . a:name
		let path2 = expand('~/.vim/linter/'. a:name)
		if filereadable(path2)
			return path2
		endif
		return shellescape(filereadable(path2)? path2 : path1)
	endfunc

	" 设置 flake8/pylint 的参数
	let g:ale_python_flake8_options = '--conf='.s:lintcfg('flake8.conf')
	let g:ale_python_pylint_options = '--rcfile='.s:lintcfg('pylint.conf')
	let g:ale_python_pylint_options .= ' --disable=W'
	let g:ale_c_gcc_options = '-Wall -O2 -std=c99'
	let g:ale_cpp_gcc_options = '-Wall -O2 -std=c++14'
	let g:ale_c_cppcheck_options = ''
	let g:ale_cpp_cppcheck_options = ''

	let g:ale_linters.text = ['textlint', 'write-good', 'languagetool']

	" 如果没有 gcc 只有 clang 时（FreeBSD）
	if executable('gcc') == 0 && executable('clang')
		let g:ale_linters.c += ['clang']
		let g:ale_linters.cpp += ['clang']
	endif
endif


"----------------------------------------------------------------------
" echodoc
"----------------------------------------------------------------------
if index(g:bundle_group, 'echodoc') >= 0
	Plug 'Shougo/echodoc.vim'
	set noshowmode
	let g:echodoc#enable_at_startup = 1
endif


"----------------------------------------------------------------------
" 结束插件安装
"----------------------------------------------------------------------
call plug#end()



"-----------------------------------------------------
" YouCompleteMe 默认设置
"-----------------------------------------------------
let g:ycm_add_preview_to_completeopt = 0
let g:ycm_show_diagnostics_ui = 0
let g:ycm_server_log_level = 'info'
let g:ycm_min_num_identifier_candidate_chars = 2
let g:ycm_collect_identifiers_from_comments_and_strings = 1
let g:ycm_complete_in_strings=1
let g:ycm_key_invoke_completion = '<c-z>'
set completeopt=menu,menuone

" noremap <c-z> <NOP>

let g:ycm_semantic_triggers =  {
			\ 'c,cpp,python,java,go,erlang,perl': ['re!\w{2}'],
			\ 'cs,lua,javascript': ['re!\w{2}'],
			\ }


autocmd FileType qf nnoremap <silent><buffer> p :PreviewQuickfix<cr>
autocmd FileType qf nnoremap <silent><buffer> P :PreviewClose<cr>


fun! QuickfixToggle()
    let nr = winnr("$")
    copen
    let nr2 = winnr("$")
    if nr == nr2
        cclose
    endif
endfunction 

let g:lmap =  {
			\'n' : ['NERDTreeToggle', 'toggle nerdtree'],
			\}
let g:lmap.c = {
			\'name' : 'ctags',
			\' ' : ['call feedkeys("\<Plug>NERDCommenterToggle")','Toggle'],
			\}
let g:lmap.p = {'name' : 'preview'}

" Second level dictionaries:
let g:lmap.f = { 
			\'name' : 'File Menu',
			\'f' : ['LeaderfFile', 'find file'],
			\'m' : ['LeaderfMru', 'find in recent files'],
			\}
let g:lmap.f.c = {
			\'name' : 'vimrc operations',
			\'o' : ['e $MYVIMRC' , 'Open vimrc'],
			\'s' : ['so %', 'Source file'],
			\}
let g:lmap.e = { 
			\'name' : 'error config',
			\'o' : ['call QuickfixToggle()', 'Open quickfix toggle'],
			\}
let g:lmap.b = {
			\'name' : 'buffer operations',
			\'d' : ['bd', 'close current buffer'],
			\'p' : ['bprevious', 'goto previous buffer'],
			\'n' : ['bnext', 'goto next buffer'],
			\}
let g:lmap.l = {
			\'name' : 'leader operations',
			\'o' : ['LeaderGuideToggle', 'toggle leader guide'],
			\}
let g:lmap.w = {
			\'name' : 'windows operations',
			\'h' : ['call feedkeys("<C-W>h")', 'goto left  window'],
			\'j' : ['call feedkeys("<C-W>j")', 'goto down  window'],
			\'k' : ['call feedkeys("<C-W>k")', 'goto up    window'],
			\'l' : ['call feedkeys("<C-W>l")', 'goto right window'],
			\}

let g:lmap.t = {
			\'name' : 'tag operations',
			\'c' : ['LeaderfFunction!', 'search tag current buffer'],
			\}

" 设置触发 leaderguilde 快捷键
call leaderGuide#register_prefix_descriptions("<Space>", "g:lmap")
nnoremap <silent> <Space> :<c-u>LeaderGuide '<Space>'<CR>
vnoremap <silent> <Space> :<c-u>LeaderGuideVisual '<Space>'<CR>

" 设置 leaderguide 默认不开启
let g:leaderGuide_toggle_show = 0
" 过滤前缀、后缀信息
function! s:my_displayfunc()
	let g:leaderGuide#displayname =
	\ substitute(g:leaderGuide#displayname, '\c<cr>$', '', '')
	let g:leaderGuide#displayname =
	\ substitute(g:leaderGuide#displayname, '^<Plug>', '', '')
endfunction
let g:leaderGuide_displayfunc = [function("s:my_displayfunc")]

" vim-rooter
let g:rooter_patterns = ['.git/', '.root/']
let g:rooter_resolve_links = 1
let g:rooter_silent_chdir = 1

" leaderf
let g:Lf_UseVersionControlTool = 0
let g:Lf_WildIgnore = {
            \ 'dir': ['.vscode*', '.git*'],
            \ 'file': []
            \}

" nerdcommenter
let g:NERDCreateDefaultMappings = 0


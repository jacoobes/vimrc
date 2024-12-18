call plug#begin()
 Plug 'hrsh7th/nvim-cmp'
 Plug 'hrsh7th/cmp-nvim-lsp'
 Plug 'hrsh7th/cmp-vsnip'
 Plug 'hrsh7th/cmp-path'
 Plug 'hrsh7th/cmp-buffer'

 Plug 'stevearc/oil.nvim'
 Plug 'nvim-tree/nvim-web-devicons'

 Plug 'preservim/nerdcommenter'
 Plug 'mhinz/vim-startify'
 Plug 'nvim-lua/lsp_extensions.nvim'
 " Snippet engine
 Plug 'hrsh7th/vim-vsnip'

 " Fuzzy finder
 " Optional
 Plug 'nvim-lua/popup.nvim'
 Plug 'nvim-telescope/telescope.nvim'
 Plug 'nvim-lua/plenary.nvim'
 Plug 'hoob3rt/lualine.nvim'
 Plug 'tpope/vim-fugitive'
 Plug 'lukas-reineke/indent-blankline.nvim'
 Plug 'neovim/nvim-lspconfig'
" Debugging
 Plug 'mfussenegger/nvim-dap'
 Plug 'glepnir/lspsaga.nvim'
 Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
 "Plug 'maxmellon/vim-jsx-pretty'

" Color schemes
 Plug 'rebelot/kanagawa.nvim'

 " Autosave
 Plug 'Pocco81/auto-save.nvim'
 
 Plug 'MunifTanjim/nui.nvim'
 Plug 'Olical/conjure'
 Plug 'Shougo/deoplete.nvim'
 Plug 'simrat39/rust-tools.nvim'
 Plug 'guns/vim-sexp'
 Plug 'tpope/vim-sexp-mappings-for-regular-people'
 Plug 'PaterJason/cmp-conjure'
call plug#end()

 if has('termguicolors')
    set termguicolors
 endif
 set background=light

let g:conjure#filetypes = ["clojure", "fennel", "janet", "hy", "julia", "racket", "scheme", "lua", "lisp"]
let maplocalleader=","

lua <<EOF

local cmp = require'cmp'

require('auto-save').setup {
    condition = function (buf)
                    local ft = vim.bo.filetype
                    return not (ft == "oil")
                end
}

require("oil").setup({
    view_options = {
        show_hidden=true     
    }
})

vim.cmd.colorscheme "kanagawa-dragon"

require('lualine').setup {
	options = {
            theme = "kanagawa"
	}
}

require 'nvim-treesitter.install'.prefer_git = false
require 'nvim-treesitter.install'.compilers = { "gcc", "clang" }
-- nvim_lsp object
local nvim_lsp = require'lspconfig'
local rt = require("rust-tools")
local opts = {
    server = {
        on_attach = function(_, bufnr)
          -- Hover actions
          vim.keymap.set("n", "<C-space>", rt.hover_actions.hover_actions, { buffer = bufnr })
          -- Code action groups
          vim.keymap.set("n", "<Leader>a", rt.code_action_group.code_action_group, { buffer = bufnr })
        end,
        settings = {
            -- to enable rust-analyzer settings visit:
            -- https://github.com/rust-analyzer/rust-analyzer/blob/master/docs/user/generated_config.adoc
            ["rust-analyzer"] = {
                -- enable clippy on save
                checkOnSave = {
                    command = "clippy"
                },
            }
        }
    },
}

require'nvim-treesitter.configs'.setup {
  highlight = {
    enable = true,
    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },
}
nvim_lsp.ts_ls.setup{};
rt.setup(opts);
nvim_lsp.rust_analyzer.setup{}
nvim_lsp.clangd.setup{}
nvim_lsp.pyright.setup{}

vim.api.nvim_create_autocmd('TermOpen', {
    group = vim.api.nvim_create_augroup('custom-term-open', { clear=true }),
    callback = function()
        vim.opt.number=false
        vim.opt.relativenumber = false
    end
})

cmp.setup({
  snippet = {
    expand = function(args)
        vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  mapping = {
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-n>'] = cmp.mapping.select_next_item(),
    -- Add tab support
    ['<S-Tab>'] = cmp.mapping.select_prev_item(),
    ['<Tab>'] = cmp.mapping.select_next_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
    ['<CR>'] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Insert,
      select = true,
    })
  },

  -- Installed sources
  sources = {
    { name = 'nvim_lsp' },
    { name = 'vsnip' },
    { name = 'path' },
    { name = 'buffer' },
    { name = 'conjure'}
  },
})

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
vim.keymap.set('n', '<leader>fc', builtin.commands, { desc = 'neovim commands' })
vim.keymap.set('n', '<leader>fv', function()
        builtin.find_files {
            cwd = vim.fn.stdpath("config")
        }
    end)

vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(args)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = args.buf })
        vim.keymap.set('n', 'gD', vim.lsp.buf.implementation, { buffer = args.buf })
        vim.keymap.set('n', '<c-]>', vim.lsp.buf.definition, { buffer = args.buf })
        vim.keymap.set('n', '<c-k>', vim.lsp.buf.signature_help, { buffer = args.buf })
        vim.keymap.set('n', '1gD', vim.lsp.buf.type_definition, { buffer = args.buf })
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, { buffer = args.buf })
        vim.keymap.set('n', 'g0', vim.lsp.buf.document_symbol, { buffer = args.buf })
        vim.keymap.set('n', 'gW', vim.lsp.buf.workspace_symbol, { buffer = args.buf })
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { buffer = args.buf })
        vim.keymap.set('n', 'ga', vim.lsp.buf.code_action, { buffer = args.buf })
        vim.keymap.set('n', 'ga', vim.lsp.buf.code_action(), { buffer = args.buf })
    end,
})
EOF


" Quick-fix

" toggle tree
nnoremap <silent> `` :Oil<CR>
" Setup Completion 
" See https://github.com/hrsh7th/nvim-cmp#basic-configuration
nnoremap <leader>n :ASToggle<CR>


set signcolumn=yes

" Set updatetime for CursorHold
" 300ms of no cursor movement to trigger CursorHold
set updatetime=300
" Show diagnostic popup on cursor hover
autocmd CursorHold * lua vim.diagnostic.open_float(nil, { focusable = false })

" Goto previous/next diagnostic warning/error
nnoremap  g[ <cmd>lua vim.diagnostic.goto_prev()<CR>
nnoremap  g] <cmd>lua vim.diagnostic.goto_next()<CR>

autocmd VimEnter *
            \   if !argc()
            \ |   Startify
            \ |   wincmd w
            \ | endif

set nocompatible
set colorcolumn=0
set showmatch               " show matching
set ignorecase              " case insensitive
set mouse=v                 " middle-click paste with
set hlsearch                " highlight search set incsearch               " incremental search set tabstop=4               " number of columns occupied by a tab
set softtabstop=4           " see multiple spaces as tabstops so <BS> does the right thing
set expandtab               " converts tabs to white space
set shiftwidth=4            " width for autoindents
set autoindent              " indent a new line the same amount as the line just typed
set number                  " add line numbers
set wildmode=longest,list   " get bash-like tab completions
set cc=0                    " set an 80 column border for good coding style
filetype plugin indent off   "allow auto-indenting depending on file type
set mouse=a                 " enable mouse click
set clipboard=unnamedplus   " using system clipboard
filetype plugin on
set ttyfast                 " Speed up scrolling in Vim


" Highlight cursor line underneath the cursor horizontally.
set cursorline

" Highlight cursor line underneath the cursor vertically.
set cursorcolumn

" set spell                 " enable spell check (may need to download language package)
" set noswapfile            " disable creating swap file
" set backupdir=~/.cache/vim " Directory to store backup files.

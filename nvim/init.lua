-- provider
vim.g.python3_host_prog = os.getenv("NVIM_PYTHON3_HOST_PROG")
vim.g.node_host_prog = os.getenv("NVIM_NODE_HOST_PROG")

-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- set termguicolors to enable highlight groups
vim.opt.termguicolors = true

-- スワップファイルを無効化
vim.opt.swapfile = false
-- バックアップファイルを無効化
vim.opt.backup = false
-- バッファ切り替え時にhidden状態にすることで、切り替え前の保存を不要にする
vim.opt.hidden = true

-- デフォルトシェルをpwshに変更
vim.opt.shell = "pwsh"
vim.opt.shellcmdflag = "-c"
vim.opt.shellquote = ""
vim.opt.shellxquote = ""
vim.opt.shellpipe = "|"

-- ヘルプファイルを日本語に
vim.opt.helplang = 'ja'
-- クリップボード連携
vim.opt.clipboard:append({unnamedplus = true})

-- IME関連の設定
-- Insertモード離脱時にIMEをオフにする
-- zenhan.exeにパスを通しておく必要あり
vim.api.nvim_create_augroup("imeoff", {})
vim.api.nvim_create_autocmd({"InsertLeave", "CmdlineLeave"}, {
  group = "imeoff",
  command = "call system('zenhan 0')"
})


-- 行番号を表示
vim.opt.number = true
-- Tabをwhitespaceに変換
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
-- ESC*2 でハイライトやめる
vim.keymap.set("n", "<Esc><Esc>", ":<C-u>set nohlsearch<Return>")

-- ~/.local/share/nvim 配下に配置
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
-- lazy.nvim ディレクトリが存在しない場合
if not vim.loop.fs_stat(lazypath) then
  -- lazy.nvim を clone
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
-- runtimepath の先頭にlazy.nvim を追加
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate" -- :MasonUpdate updates registry contents
  },
  { "williamboman/mason-lspconfig.nvim" },
  { "neovim/nvim-lspconfig" },
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/vim-vsnip",
      "saadparwaiz1/cmp_luasnip",
      {
        "L3MON4D3/LuaSnip",
        version = "1.*",
        build = "make install_jsregexp"
      },
    }
  },
  { "nvim-tree/nvim-tree.lua" },
  { "nvim-tree/nvim-web-devicons", lazy = true },
  { "akinsho/toggleterm.nvim", version = "*", config = true },
  {
    "nvim-telescope/telescope.nvim", tag = "0.1.2",
    dependencies = {
      "nvim-lua/plenary.nvim",
    }
  },
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd([[colorscheme tokyonight]])
    end
  },
  { "vim-denops/denops.vim", lazy = false },
  {
    "vim-skk/skkeleton",
    lazy = false,
    dependencies = {
      "vim-denops/denops.vim",
    },
    init = function()
      vim.keymap.set("i", "<C-j>", "<Plug>(skkeleton-enable)")
      vim.keymap.set("c", "<C-j>", "<Plug>(skkeleton-enable)")

      -- 辞書を探す
      local dictionaries = {}
      -- local handle = io.popen("ls $APPDATA/CorvusSKK/*") -- フルバスで取得
      local dictionary_dir = os.execute("test -d $HOME/.skk/") and "$HOME/.skk/*" or "$APPDATA/CorvusSKK/*"
      local handle = io.popen("ls " .. dictionary_dir) -- フルバスで取得
      if handle then
        for file in handle:lines() do
          table.insert(dictionaries, file)
        end
        handle:close()
      end

      vim.api.nvim_create_autocmd("User", {
        pattern = "skkeleton-initialize-pre",
        callback = function()
          vim.fn["skkeleton#config"]({
            eggLikeNewline = true,
            registerConvertResult = true,
            globalDictionaries = dictionaries,
          })
        end,
      })
    end,
  }
})
require("mason").setup()

local on_attach = function (client, bufnr)
  if client.server_capabilities.documentHighlightProvider then
    vim.api.nvim_create_augroup("lsp_document_highlight", { clear = true })
    vim.api.nvim_clear_autocmds { buffer = bufnr, group = "lsp_document_highlight" }
    vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
      callback = vim.lsp.buf.document_highlight,
      buffer = bufnr,
      group = "lsp_document_highlight",
      desc = "Document Highlight",
    })
    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI"}, {
      callback = vim.lsp.buf.clear_references,
      buffer = bufnr,
      group = "lsp_document_highlight",
      desc = "Clear All the References",
    })
  end
end

-- Add additional capabilities supported by nvim-cmp
local capabilities = require("cmp_nvim_lsp").default_capabilities()

require('lspconfig').lua_ls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
        version = 'LuaJIT',
      },
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = {'vim'},
      },
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false
      },
      -- Do not send telemetry data containing a randomized but unique identifier
      telemetry = {
        enable = false,
      },
    },
  },
}

local function is_win ()
  local os_name = vim.loop.os_uname().sysname
  if os_name:match("Windows") or os_name:match("MSYS") then
    return true
  else
    return false
  end
end

local function get_python_path ()
  if is_win then
    return ".\\.venv\\Scripts\\python.exe"
  else
     return "./.venv/bin/python"
  end
end


require("lspconfig").pyright.setup{
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    python = {
      venvPath = ".",
      -- poetry + venv で作成した仮想環境を見るように設定
      pythonPath = get_python_path(),
      analysis = {
        extraPaths = {"."}
      }
    }
  }
}

require("lspconfig").tsserver.setup{
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = {
    "javascript",
    "javascriptreact",
    "javascript.jsx",
    "typescript",
    "typescriptreact",
    "typescript.tsx"
  },
  init_options = { hostInfo = "neovim" },
}
require("lspconfig").html.setup{
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = {"html"}
}
require("lspconfig").cssls.setup{
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = {"css", "scss"}
}


-- keymap
vim.keymap.set('n', 'K',  '<cmd>lua vim.lsp.buf.hover()<CR>')
vim.keymap.set('n', 'gf', '<cmd>lua vim.lsp.buf.formatting()<CR>')
vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>')
vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>')
vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>')
vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>')
vim.keymap.set('n', 'gt', '<cmd>lua vim.lsp.buf.type_definition()<CR>')
vim.keymap.set('n', 'gn', '<cmd>lua vim.lsp.buf.rename()<CR>')
vim.keymap.set('n', 'ga', '<cmd>lua vim.lsp.buf.code_action()<CR>')
vim.keymap.set('n', 'ge', '<cmd>lua vim.diagnostic.open_float()<CR>')
vim.keymap.set('n', 'g]', '<cmd>lua vim.diagnostic.goto_next()<CR>')
vim.keymap.set('n', 'g[', '<cmd>lua vim.diagnostic.goto_prev()<CR>')

local luasnip = require("luasnip")

-- nvim-cmp setup
local cmp = require 'cmp'
cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-u>'] = cmp.mapping.scroll_docs(-4), -- Up
    ['<C-d>'] = cmp.mapping.scroll_docs(4), -- Down
    -- C-b (back) C-f (forward) for snippet placeholder navigation.
    ['<S-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'vsnip' },
    { name = 'luasnip' },
  }, {
    { name = "buffer" },
  }),
}
-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ '/', '?' }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  }
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
})

-- empty setup using defaults
require("nvim-tree").setup()
require("toggleterm").setup{
  size = function(term)
    if term.direction == "horizontal" then
      return 15
    elseif term.direction == "vertical" then
      return vim.o.columns * 0.4
    end
  end,
  start_in_insert = true,
  direction = "horizontal",
}

function _G.set_terminal_keymaps()
  local opts = {buffer = 0}
  vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
  vim.keymap.set('t', 'jk', [[<C-\><C-n>]], opts)
  vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
  vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
  vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
  vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
  vim.keymap.set('t', '<C-w>', [[<C-\><C-n><C-w>]], opts)
end

vim.api.nvim_create_autocmd({ "TermOpen" }, {
  pattern = "term://*",
  callback = function()
    set_terminal_keymaps()
  end,
  desc = "Keymap for Terminal",
})

local telescope_builtin = require("telescope.builtin")
vim.keymap.set('n', '<leader>ff', telescope_builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', telescope_builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', telescope_builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', telescope_builtin.help_tags, {})

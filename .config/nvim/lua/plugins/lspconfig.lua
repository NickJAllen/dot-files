-- LSP Plugins
local nick = require 'nick'

local function on_lsp_attach(event)
  local function map(keys, func, desc, mode)
    mode = mode or 'n'
    vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = desc })
  end

  local refactor = function(func)
    return function()
      nick.utils.before_refactoring()
      func()
    end
  end

  map('<leader>cr', refactor(vim.lsp.buf.rename), 'Rename')

  map('<leader>ca', refactor(vim.lsp.buf.code_action), 'Code Action', { 'n', 'x' })

  map('<leader>ce', vim.diagnostic.open_float, 'Show full diagnostic error message')

  local client = vim.lsp.get_client_by_id(event.data.client_id)

  if not client then
    return
  end

  if client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
    local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
    vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
      buffer = event.buf,
      group = highlight_augroup,
      callback = vim.lsp.buf.document_highlight,
    })

    vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
      buffer = event.buf,
      group = highlight_augroup,
      callback = vim.lsp.buf.clear_references,
    })

    vim.api.nvim_create_autocmd('LspDetach', {
      group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
      callback = function(event2)
        vim.lsp.buf.clear_references()
        vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
      end,
    })
  end

  if client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
    map('<leader>th', function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
    end, 'Toggle Inlay Hints')
  end

  if client.name == 'jdtls' then
    map('<leader>dH', ':JdtUpdateHotcode<CR>', 'Hotswap Java Code')

    local jdtls = require 'jdtls'

    map('gs', function()
      jdtls.super_implementation()
    end, 'Go to super implementation')

    map('<leader>co', function()
      jdtls.organize_imports()
    end, 'Organize Imports')

    map('<leader>cv', function()
      jdtls.extract_variable()
    end, 'Extract Variable')

    map('<leader>cc', function()
      jdtls.extract_constant()
    end, 'Extract Constant')

    map('<leader>cm', function()
      jdtls.extract_method()
    end, 'Extract Method')

    map('<leader>dt', function()
      jdtls.test_nearest_method()
    end, 'Debug Test Method')

    map('<leader>dT', function()
      jdtls.test_class()
    end, 'Debug Test Class')

    map('<leader>sO', function()
      jdtls.extended_symbols()
    end, 'Extended Outline')

    map('<leader>cb', ':JdtCompile<CR>', 'Build Java')
  elseif client.name == 'clangd' then
    map('gh', ':LspClangdSwitchSourceHeader<CR>', 'Switch Between Header and Source file')
  end
end

return {
  {
    -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
    -- used for completion, annotations and signatures of Neovim apis
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs and related tools to stdpath for Neovim
      -- Mason must be loaded before its dependents so we need to set it up here.
      -- NOTE: `opts = {}` is the same as calling `require('mason').setup({})`
      { 'mason-org/mason.nvim', opts = {} },
      'mason-org/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',

      -- Useful status updates for LSP.
      -- { 'j-hui/fidget.nvim', opts = {} },

      -- Allows extra capabilities provided by blink.cmp
      'saghen/blink.cmp',
    },
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = on_lsp_attach,
      })

      -- Diagnostic Config
      -- See :help vim.diagnostic.Opts
      vim.diagnostic.config {
        severity_sort = true,
        float = { border = 'rounded', source = 'if_many' },
        underline = { severity = vim.diagnostic.severity.ERROR },
        signs = vim.g.have_nerd_font and {
          text = {
            [vim.diagnostic.severity.ERROR] = '󰅚 ',
            [vim.diagnostic.severity.WARN] = '󰀪 ',
            [vim.diagnostic.severity.INFO] = '󰋽 ',
            [vim.diagnostic.severity.HINT] = '󰌶 ',
          },
        } or {},
        virtual_text = {
          source = 'if_many',
          spacing = 2,
          format = function(diagnostic)
            local diagnostic_message = {
              [vim.diagnostic.severity.ERROR] = diagnostic.message,
              [vim.diagnostic.severity.WARN] = diagnostic.message,
              [vim.diagnostic.severity.INFO] = diagnostic.message,
              [vim.diagnostic.severity.HINT] = diagnostic.message,
            }
            return diagnostic_message[diagnostic.severity]
          end,
        },
      }

      local servers = {
        clangd = {},
        jdtls = {},
        rust_analyzer = {},
        lua_ls = {
          settings = {
            Lua = {
              completion = {
                callSnippet = 'Replace',
              },
              runtime = { pathStrict = false },
              -- diagnostics = {
              --   globals = { 'vim' },
              -- },
            },
          },
        },
      }

      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        'stylua', -- Used to format Lua code
      })
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      for server_name, server_config in pairs(servers) do
        vim.lsp.config(server_name, server_config)
        vim.lsp.enable(server_name)
      end
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_python3_provider = 0

local opt = vim.opt
opt.number = true
opt.relativenumber = true
opt.mouse = "a"
opt.clipboard = "unnamedplus"
opt.breakindent = true
opt.undofile = true
opt.ignorecase = true
opt.smartcase = true
opt.signcolumn = "yes"
opt.updatetime = 250
opt.timeoutlen = 300
opt.splitright = true
opt.splitbelow = true
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
opt.inccommand = "split"
opt.cursorline = true
opt.scrolloff = 8
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.winborder = "single"

vim.api.nvim_create_autocmd("FileType", {
  desc = "Use PEP8 4-space indentation for Python files",
  pattern = "python",
  callback = function()
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  desc = "Keymap to run the current Python file in a terminal split",
  pattern = "python",
  callback = function(args)
    vim.keymap.set("n", "<leader>pr", function()
      vim.cmd("write")
      vim.cmd("split | terminal python3 " .. vim.fn.shellescape(vim.fn.expand("%")))
    end, { buffer = args.buf, desc = "Run Python file" })
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  desc = "Keymap to run the current Go file in a terminal split",
  pattern = "go",
  callback = function(args)
    vim.keymap.set("n", "<leader>gr", function()
      vim.cmd("write")
      vim.cmd("split | terminal go run " .. vim.fn.shellescape(vim.fn.expand("%")))
    end, { buffer = args.buf, desc = "Run Go file" })
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  desc = "Keymap to run the current Rust file in a terminal split",
  pattern = "rust",
  callback = function(args)
    vim.keymap.set("n", "<leader>rr", function()
      vim.cmd("write")
      vim.cmd("split | terminal cargo run")
    end, { buffer = args.buf, desc = "Run Rust project" })
  end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight yanked text",
  group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

local map = vim.keymap.set

map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })
map("n", "<C-h>", "<C-w><C-h>", { desc = "Move to left window" })
map("n", "<C-l>", "<C-w><C-l>", { desc = "Move to right window" })
map("n", "<C-j>", "<C-w><C-j>", { desc = "Move to window below" })
map("n", "<C-k>", "<C-w><C-k>", { desc = "Move to window above" })
map("n", "<leader>e", "<cmd>Explore<CR>", { desc = "Open file explorer (netrw)" })
map("v", "<", "<gv", { desc = "Indent left, stay in visual mode" })
map("v", ">", ">gv", { desc = "Indent right, stay in visual mode" })
map("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Close buffer" })

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local out = vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({ { "Failed to clone lazy.nvim:\n", "ErrorMsg" }, { out, "WarningMsg" } }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({

  {
    "folke/tokyonight.nvim",
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("tokyonight-night")
    end,
  },

  {
    "echasnovski/mini.nvim",
    config = function()
      require("mini.statusline").setup()
      require("mini.pairs").setup()
      require("mini.comment").setup()
      require("mini.surround").setup()
      require("mini.icons").setup()

      local starter = require("mini.starter")
      starter.setup({
        evaluate_single = true,
        header = "NEOVIM",
        items = {
          starter.sections.builtin_actions(),
          starter.sections.recent_files(5, false),
        },
        content_hooks = {
          starter.gen_hook.adding_bullet("  "),
          starter.gen_hook.aligning("center", "center"),
        },
        footer = "",
      })

      vim.api.nvim_create_autocmd("User", {
        pattern = "MiniStarterOpened",
        callback = function(args)
          local buf = args.buf
          local opts = { buffer = buf, remap = true, silent = true }
          vim.keymap.set("n", "j", "<Down>", opts)
          vim.keymap.set("n", "k", "<Up>", opts)
          vim.keymap.set("n", "l", "<CR>", opts)
          vim.keymap.set("n", "h", "<BS>", opts)
        end,
      })
    end,
  },

  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "Find files" },
      { "<leader>fg", "<cmd>Telescope live_grep<CR>", desc = "Grep project" },
      { "<leader>fb", "<cmd>Telescope buffers<CR>", desc = "Find open buffers" },
      { "<leader>fh", "<cmd>Telescope help_tags<CR>", desc = "Search nvim help" },
      { "<leader>fd", "<cmd>Telescope diagnostics<CR>", desc = "Search LSP diagnostics" },
      { "<leader>fr", "<cmd>Telescope oldfiles<CR>", desc = "Recently opened files" },
    },
    config = function()
      require("telescope").setup({})
      pcall(require("telescope").load_extension, "fzf")
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      ensure_installed = {
        "bash", "c", "diff", "html", "css", "javascript", "typescript", "tsx",
        "json", "lua", "luadoc", "markdown", "markdown_inline", "python",
        "query", "regex", "rust", "go", "yaml", "toml", "vim", "vimdoc",
        "cpp", "c_sharp", "java", "sql", "dockerfile",
      },
      auto_install = true,
      highlight = { enable = true },
      indent = { enable = true },
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
  },

  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "_" },
      },
    },
  },

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {},
  },

  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      { "<leader>lf", function() require("conform").format({ async = true }) end, desc = "Format buffer" },
    },
    opts = {
      notify_on_error = false,
      format_on_save = { timeout_ms = 500, lsp_format = "fallback" },
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "black" },
        javascript = { "prettierd", "prettier", stop_after_first = true },
        typescript = { "prettierd", "prettier", stop_after_first = true },
        json = { "prettierd", "prettier", stop_after_first = true },
        sh = { "shfmt" },
        go = { "goimports", "gofumpt" },
        rust = { "rustfmt" },
      },
    },
  },

  {
    "neovim/nvim-lspconfig",
    dependencies = {
      { "williamboman/mason.nvim", opts = {} },
      "williamboman/mason-lspconfig.nvim",
      {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        opts = {
          ensure_installed = { "ruff", "eslint_d", "shellcheck", "debugpy", "delve", "goimports", "gofumpt", "golangci-lint", "rust-analyzer" },
        },
      },
      "saghen/blink.cmp",
    },
    config = function()
      local servers = {
        lua_ls = {
          settings = { Lua = { diagnostics = { globals = { "vim" } } } },
        },
        pyright = {},
        ts_ls = {},
        bashls = {},
        jsonls = {},
        html = {},
        cssls = {},
        gopls = {},
        rust_analyzer = {},
        clangd = {},
      }

      require("mason-lspconfig").setup({
        ensure_installed = vim.tbl_keys(servers),
        automatic_enable = true,
      })

      local capabilities = require("blink.cmp").get_lsp_capabilities()
      for name, cfg in pairs(servers) do
        vim.lsp.config(name, vim.tbl_deep_extend("force", { capabilities = capabilities }, cfg))
      end

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
        callback = function(event)
          local nmap = function(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
          end
          nmap("gd", vim.lsp.buf.definition, "Go to definition")
          nmap("gr", vim.lsp.buf.references, "Find references")
          nmap("gI", vim.lsp.buf.implementation, "Go to implementation")
          nmap("K", vim.lsp.buf.hover, "Hover info")
          nmap("<leader>rn", vim.lsp.buf.rename, "Rename")
          nmap("<leader>ca", vim.lsp.buf.code_action, "Code action")
          nmap("<leader>D", vim.lsp.buf.type_definition, "Type definition")
        end,
      })

      vim.diagnostic.config({
        virtual_text = { prefix = "●" },
        severity_sort = true,
      })
    end,
  },

  {
    "saghen/blink.cmp",
    version = "*",
    dependencies = { "rafamadriz/friendly-snippets" },
    opts = {
      keymap = { preset = "default" },
      appearance = { nerd_font_variant = "mono" },
      sources = { default = { "lsp", "path", "snippets", "buffer" } },
      signature = { enabled = true },
    },
  },

  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lint = require("lint")
      lint.linters_by_ft = {
        python = { "ruff" },
        javascript = { "eslint_d" },
        typescript = { "eslint_d" },
        sh = { "shellcheck" },
        go = { "golangci-lint" },
        rust = { "clippy" },
      }

      vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
        group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },

  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "mfussenegger/nvim-dap-python",
      "leoluz/nvim-dap-go",
    },
    keys = {
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle breakpoint" },
      { "<leader>dc", function() require("dap").continue() end, desc = "Continue / start debug" },
      { "<leader>di", function() require("dap").step_into() end, desc = "Step into" },
      { "<leader>do", function() require("dap").step_over() end, desc = "Step over" },
      { "<leader>dO", function() require("dap").step_out() end, desc = "Step out" },
      { "<leader>dt", function() require("dap").terminate() end, desc = "Terminate debug session" },
      { "<leader>du", function() require("dapui").toggle() end, desc = "Toggle debug UI" },
    },
    config = function()
      local dap, dapui = require("dap"), require("dapui")
      dapui.setup()

      local mason_debugpy = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
      require("dap-python").setup(mason_debugpy)
      require("dap-go").setup({ delve = { path = "dlv" } })

      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
    end,
  },

}, {
  ui = { border = "single" },
  rocks = { enabled = false },
})

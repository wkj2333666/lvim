-- Read the docs: https://www.lunarvim.org/docs/configuration
-- Example configs: https://github.com/LunarVim/starter.lvim
-- Video Tutorials: https://www.youtube.com/watch?v=sFA9kX-Ud_c&list=PLhoH5vyxr6QqGu0i7tt_XoVK9v-KvZ3m6
-- Forum: https://www.reddit.com/r/lunarvim/
-- Discord: https://discord.com/invite/Xb9B4Ny

-- 设置全局缩进为4空格
vim.opt.tabstop = 4       -- 一个Tab键显示为4个空格
vim.opt.shiftwidth = 4    -- 自动缩进使用的空格数
vim.opt.softtabstop = 4   -- 编辑时按Tab键插入的空格数
vim.opt.expandtab = true  -- 将Tab转换为空格
vim.opt.number = true         -- 显示绝对行号
vim.opt.relativenumber = true -- 同时显示相对行号

-- 设置文件树位置（左侧）
lvim.builtin.nvimtree.setup.view.side = "left"
lvim.builtin.nvimtree.setup.view.width = 30

-- 2. 配置自动打开终端 (toggleterm)
local terminal = require("toggleterm.terminal")

-- 创建自定义终端命令
local auto_term = terminal.Terminal:new({
  cmd = "fish",        -- 默认 shell
  direction = "horizontal", -- 水平窗口 (可选: float, vertical)
})

-- 添加启动自动命令
vim.api.nvim_create_autocmd("VimEnter", {
  pattern = "*",
  callback = function()
      -- 打开终端
      auto_term:open()
      auto_term:resize(15, 100)  -- 调整浮动终端大小

       if not require("nvim-tree.view").is_visible() then
        require("nvim-tree.api").tree.open()
      end
        vim.cmd("wincmd l")
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, true, true), 'n', true)
    end
})

-- 设置文件树不关闭（当打开文件时）
lvim.builtin.nvimtree.setup.actions = {
  open_file = {
    quit_on_open = false,  -- 打开文件后关闭树
    window_picker = {
      enable = false
    }
  }
}

-- 4. 添加快捷键映射 --------------------------
lvim.keys.normal_mode["<C-\\>"] = "<cmd>ToggleTerm<CR>"  -- 切换终端
lvim.keys.normal_mode["<leader>e"] = "<cmd>NvimTreeToggle<CR>" -- 切换文件树

vim.keymap.set("i", "<C-w>", "<Esc>:w!<CR>a", {noremap = true})
vim.keymap.set("i", "<C-q>", "<Esc>:qa!<CR>", {noremap = true})
vim.keymap.set("i", "<C-a>", "<Esc>A", {noremap = true})
vim.keymap.set("n", "<C-w>", ":w!<CR>", {noremap = true})
vim.keymap.set("n", "<C-q>", ":qa!<CR>", {noremap = true})

lvim.plugins = {
  -- DAP 核心功能
  "mfussenegger/nvim-dap",
  -- DAP UI 界面
  "rcarriga/nvim-dap-ui",
  -- 调试信息显示
  "theHamsta/nvim-dap-virtual-text",
  -- 调试图标
  "nvim-telescope/telescope-dap.nvim"
}

-- 在 config.lua 底部添加
local dap = require("dap")
local dapui = require("dapui")

-- 初始化 UI
dapui.setup({
  icons = { expanded = "▾", collapsed = "▸" },
  mappings = {
    expand = { "<CR>", "<2-LeftMouse>" },
    open = "o",
    remove = "d",
    edit = "e",
    repl = "r",
    toggle = "t",
  },
  layouts = {
    {
      elements = {
        { id = "scopes", size = 0.5 },
        { id = "breakpoints", size = 0.5 },
      },
      size = 40,
      position = "left",
    },
    {
      elements = {
        { id = "repl", size = 0.8 },
        { id = "console", size = 0.2 },
      },
      size = 10,
      position = "bottom",
    },
  },
})

-- 自动打开/关闭 UI
dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close()
end

-- 虚拟文本显示变量值
require("nvim-dap-virtual-text").setup()

-- Python
local mason_path = vim.fn.stdpath("data") .. "/mason"
local debugpy_path = mason_path .. "/packages/debugpy/venv/bin/python"

dap.adapters.python = {
  type = "executable",
  command = debugpy_path,
  args = { "-m", "debugpy.adapter" }
}

dap.configurations.python = {
  {
    type = "python",
    request = "launch",
    name = "启动当前文件",
    program = "${file}",

    pythonPath = function()
      -- 优先使用项目虚拟环境
      local venv_python = vim.fn.getcwd() .. "/.venv/bin/python"
      if vim.fn.filereadable(venv_python) == 1 then
        return venv_python
      end
      -- 回退到系统 Python
      return vim.fn.exepath('python3') or vim.fn.exepath('python') or 'python'
    end,
    console = "integratedTerminal",
    justMyCode = false,
    -- Mason 专用环境变量
    env = {
      PYTHONPATH = mason_path .. "/packages/debugpy/venv/lib/python3.9/site-packages"
    }
  },
  {
    type = "python",
    request = "attach",
    name = "附加到进程",
    processId = require('dap.utils').pick_process,
    pathMappings = {
      {
        localRoot = vim.fn.getcwd(),
        remoteRoot = "${workspaceFolder}",
      },
    },
    host = "127.0.0.1",
    port = 5678,
  }
}

-- C++
dap.adapters.codelldb = {
  type = "server",
  port = "${port}",
  executable = {
    command = vim.fn.expand("/home/wkj/.local/share/lvim/mason/packages/codelldb/codelldb"),
    args = { "--port", "${port}" },
  }
}

dap.configurations.cpp = {
  {
    name = "启动调试",
    type = "codelldb",
    request = "launch",
    program = function()
      return vim.fn.input('可执行文件路径: ', vim.fn.getcwd() .. '/', 'file')
    end,
    cwd = "${workspaceFolder}",
    stopOnEntry = false,
    args = {},
  },
}
dap.configurations.c = dap.configurations.cpp

-- 调试控制
vim.keymap.set('n', '<F5>', dap.continue)
vim.keymap.set('n', '<F9>', dap.toggle_breakpoint)
vim.keymap.set('n', '<F10>', dap.step_over)
vim.keymap.set('n', '<F11>', dap.step_into)
vim.keymap.set('n', '<F12>', dap.step_out)
vim.keymap.set('n', '<leader>db', dap.toggle_breakpoint)
vim.keymap.set('n', '<leader>dc', dap.continue)
vim.keymap.set('n', '<leader>di', dap.step_into)
vim.keymap.set('n', '<leader>do', dap.step_over)

-- UI 控制
vim.keymap.set('n', '<leader>du', dapui.toggle)
vim.keymap.set('n', '<leader>de', dapui.eval)
vim.keymap.set('v', '<leader>de', dapui.eval)

-- 断点管理
vim.keymap.set('n', '<leader>dB', function()
  dap.set_breakpoint(vim.fn.input('断点条件: '))
end)

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

-- 1. 配置自动打开文件树 (nvim-tree)
-- lvim.builtin.nvimtree.setup.open_on_setup = true  -- 启动时自动打开文件树
-- lvim.builtin.nvimtree.setup.open_on_setup_file = false -- 不自动聚焦文件

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

-- 3. 可选：配置类 VSCode 布局 -----------------
-- 设置浮动终端样式（圆角 + 边框）
-- lvim.builtin.terminal.float_opts = {
--   border = "rounded",
--   width = 100,
--   height = 15,
-- }

-- 设置文件树自动关闭（当打开文件时）
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

-- -- Use treesitter vimdoc parser !
-- vim.api.nvim_create_autocmd('FileType', {
--   pattern = 'help',
--   callback = function()
--     vim.treesitter.language.register('vimdoc', 'help')
--   end
-- })

-- -- Disable vimdoc highlight!
-- require('nvim-treesitter.configs').setup {
--   highlight = {
--     enable = true,
--     disable = {'vimdoc'}  -- Disable for vimdoc files
--   }
-- }

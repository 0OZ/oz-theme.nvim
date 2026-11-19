-- Seeded Neovim session behind assets/screenshot.png (run scripts/screenshot/run.sh).
-- Everything here is sample state, not configuration: two buffers, a selection, a
-- search and a few diagnostics, so every soft background and role color shows up.
local repo = assert(vim.env.OZ_THEME_REPO, "OZ_THEME_REPO is not set")
local ready_file = assert(vim.env.OZ_THEME_READY, "OZ_THEME_READY is not set")
local samples = repo .. "/scripts/screenshot/samples/"

vim.opt.rtp:prepend(repo)

-- `--clean` leaves out the data dir, which is where nvim-treesitter installs parsers
-- and queries. Without them the shot is monochrome, so fail instead of rendering it.
local site = vim.fn.stdpath("data") .. "/site"
if not vim.tbl_contains(vim.opt.rtp:get(), site) then
  vim.opt.rtp:append(site)
end
for _, lang in ipairs({ "typescript", "rust" }) do
  assert(#vim.api.nvim_get_runtime_file("parser/" .. lang .. ".*", true) > 0, "missing tree-sitter parser: " .. lang)
  assert(#vim.api.nvim_get_runtime_file("queries/" .. lang .. "/highlights.scm", true) > 0, "missing highlights query: " .. lang)
end

vim.cmd("filetype plugin indent on") -- `--clean` starts without filetype detection
vim.o.termguicolors = true
vim.o.number = true
vim.o.signcolumn = "no"
vim.o.cursorline = true
vim.o.wrap = false
vim.o.laststatus = 2
vim.o.statusline = " %t %m%=%l:%c "
vim.o.showmode = false
vim.o.showcmd = false
vim.o.ruler = false
vim.o.shortmess = vim.o.shortmess .. "I"
vim.o.fillchars = "eob: ,vert: "
vim.o.splitright = true
vim.o.hlsearch = true

vim.cmd.colorscheme("oz-theme")

vim.diagnostic.config({
  virtual_text = { prefix = "●", spacing = 2 },
  signs = false,
  underline = true,
  severity_sort = true,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "typescript", "rust" },
  callback = function(args)
    vim.treesitter.start(args.buf)
  end,
})

---Zero-based (line, col, end_col) of `word` on the first line containing `line_text`.
local function locate(buf, line_text, word)
  for index, text in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
    if text:find(line_text, 1, true) then
      local col = assert(text:find(word, 1, true), "word not on line: " .. word)
      return index - 1, col - 1, col - 1 + #word
    end
  end
  error("line not found: " .. line_text)
end

local function diagnostic(buf, line_text, word, severity, message)
  local line, col, end_col = locate(buf, line_text, word)
  return { lnum = line, col = col, end_col = end_col, severity = severity, message = message }
end

local function highlight_word(win, group, word)
  vim.api.nvim_win_call(win, function()
    vim.fn.matchadd(group, [[\<]] .. word .. [[\>]])
  end)
end

vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  nested = true, -- let :edit inside the callback fire BufRead/FileType
  callback = function()
    vim.cmd.edit(vim.fn.fnameescape(samples .. "library.ts"))
    local left = vim.api.nvim_get_current_win()
    local left_buf = vim.api.nvim_win_get_buf(left)
    vim.cmd.vsplit(vim.fn.fnameescape(samples .. "library.rs"))
    local right = vim.api.nvim_get_current_win()
    local right_buf = vim.api.nvim_win_get_buf(right)

    local severity = vim.diagnostic.severity
    local ns = vim.api.nvim_create_namespace("oz-theme-screenshot")
    vim.diagnostic.set(ns, left_buf, {
      diagnostic(left_buf, "this.catalog", "catalog", severity.ERROR, "no property 'catalog'"),
      diagnostic(left_buf, "const attempt", "attempt", severity.WARN, "'attempt' is never read"),
      diagnostic(left_buf, "private cache", "cache", severity.HINT, "'cache' is never read"),
    })
    vim.diagnostic.set(ns, right_buf, {
      diagnostic(right_buf, "extra += fee.amount", "fee.amount", severity.ERROR, "expected `u32`, found `u64`"),
      diagnostic(right_buf, "let mut extra", "extra", severity.WARN, "unused assignment to `extra`"),
    })

    vim.fn.setreg("/", [[\<Loan\>]])
    vim.v.hlsearch = 1
    highlight_word(left, "LspReferenceText", "MAX_LOANS")
    highlight_word(right, "LspReferenceText", "due_days")

    local book_line = locate(left_buf, "const book", "book")
    vim.api.nvim_win_set_cursor(left, { book_line + 1, 10 })
    local loop_line = locate(right_buf, "for fee", "fee")
    vim.api.nvim_win_set_cursor(right, { loop_line + 1, 0 })
    -- Typed after the callback returns, so Visual mode is still active when the shot is taken.
    vim.api.nvim_feedkeys("V3j", "n", false)

    -- Tell run.sh the screen is drawn, and hand it the colors the page should default to.
    vim.defer_fn(function()
      vim.cmd.redraw()
      local normal = vim.api.nvim_get_hl(0, { name = "Normal" })
      vim.fn.writefile({ string.format("#%06x #%06x", normal.fg, normal.bg) }, ready_file)
    end, 300)
  end,
})

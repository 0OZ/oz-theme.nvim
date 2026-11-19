-- Run: nvim --clean --headless --cmd "set rtp+=." -l tests/smoke.lua
-- Checks contracts, not palette values: text stays readable on every soft
-- background, and semantic tokens never recolor what tree-sitter already painted.

local MIN_TEXT_CONTRAST = 4.5 -- WCAG AA for body text

local failures = {}

local function check(ok, message)
  if not ok then
    failures[#failures + 1] = message
  end
end

local function hl(name)
  return vim.api.nvim_get_hl(0, { name = name, link = false })
end

local function luminance(rgb)
  local function channel(shift)
    local c = bit.band(bit.rshift(rgb, shift), 0xff) / 255
    return c <= 0.03928 and c / 12.92 or ((c + 0.055) / 1.055) ^ 2.4
  end
  return 0.2126 * channel(16) + 0.7152 * channel(8) + 0.0722 * channel(0)
end

local function contrast(a, b)
  local hi, lo = math.max(luminance(a), luminance(b)), math.min(luminance(a), luminance(b))
  return (hi + 0.05) / (lo + 0.05)
end

vim.cmd.colorscheme("oz-theme")
check(vim.g.colors_name == "oz-theme", "colors_name is not oz-theme")

local normal = hl("Normal")
local readable_on = {
  Visual = normal.fg,
  CursorLine = normal.fg,
  Search = hl("Search").fg,
  LspReferenceText = normal.fg,
  DiagnosticVirtualTextError = hl("DiagnosticVirtualTextError").fg,
  DiagnosticVirtualTextWarn = hl("DiagnosticVirtualTextWarn").fg,
  DiagnosticVirtualTextInfo = hl("DiagnosticVirtualTextInfo").fg,
  CurSearch = hl("CurSearch").fg,
}
for group, text in pairs(readable_on) do
  local bg = hl(group).bg
  check(bg ~= nil, group .. " has no background")
  check(
    bg == nil or contrast(text, bg) >= MIN_TEXT_CONTRAST,
    string.format("%s: text contrast %.2f is below %.1f", group, bg and contrast(text, bg) or 0, MIN_TEXT_CONTRAST)
  )
end

-- Semantic tokens must agree with tree-sitter or be cleared, so attaching an LSP
-- cannot flip a color.
for semantic, treesitter in pairs({
  ["@lsp.type.property"] = "@property",
  ["@lsp.type.parameter"] = "@variable.parameter",
  ["@lsp.type.type"] = "@type",
}) do
  check(hl(semantic).fg == hl(treesitter).fg, semantic .. " differs from " .. treesitter)
end
for _, cleared in ipairs({ "@lsp.type.function", "@lsp.type.keyword", "@lsp.type.variable" }) do
  check(next(hl(cleared)) == nil, cleared .. " should be cleared so tree-sitter decides")
end

-- Loading twice must not error (colorscheme reload).
check(pcall(vim.cmd.colorscheme, "oz-theme"), "reloading the colorscheme failed")

if #failures > 0 then
  io.stderr:write("FAIL\n  " .. table.concat(failures, "\n  ") .. "\n")
  os.exit(1)
end
print("oz-theme smoke: ok")

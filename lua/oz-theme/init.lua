-- oz-theme - Neovim colorscheme
-- A vibrant, colorful dark theme

local M = {}

---Mix `fg` into `bg` ("#rrggbb" both): alpha 0 gives `bg`, 1 gives `fg`.
---Derives soft tinted backgrounds from the accents so they stay in the palette.
local function blend(fg, bg, alpha)
  local function mix(i)
    local from, to = tonumber(fg:sub(i, i + 1), 16), tonumber(bg:sub(i, i + 1), 16)
    return math.floor(from * alpha + to * (1 - alpha) + 0.5)
  end
  return string.format("#%02x%02x%02x", mix(2), mix(4), mix(6))
end

-- How much of an accent tints its soft background (0 = none, 1 = full accent).
local TINT = {
  diagnostic = 0.12,
  diff = 0.10,
  diff_text = 0.22,
  search = 0.30,
  current_search = 0.75,
  operator = 0.60, -- cyan toward muted grey, so operators sit apart from builtins
}

M.colors = {
  -- Base colors
  bg = "#050505",
  bg_dark = "#030303",
  bg_highlight = "#252830", -- UI surfaces (telescope prompt, buttons)
  bg_cursorline = "#13151a",
  bg_visual = "#2b3140",
  bg_ref = "#1e222b", -- word under cursor (LspReference / illuminate)
  bg_ref_write = "#283040",
  bg_float = "#0d0e0e",
  bg_popup = "#0d0e0e",
  bg_sidebar = "#050505",
  bg_statusline = "#050505",

  fg = "#e0e4eb",
  fg_dark = "#dadada",
  fg_muted = "#8892a0",
  fg_gutter = "#495162",
  fg_comment = "#6b7280",

  -- Border
  border = "#222222",
  border_highlight = "#5a6374",

  -- Accent colors (vibrant)
  red = "#ff5370",
  red_bright = "#ff6b8a",
  green = "#69ff69",
  green_bright = "#8aff8a",
  yellow = "#ffb454",
  yellow_bright = "#ffc970",
  gold = "#ffd454",
  blue = "#5cb8ff",
  blue_bright = "#7dcfff",
  magenta = "#e06cff",
  magenta_bright = "#f08fff",
  cyan = "#4ae0eb",
  cyan_bright = "#6ef0f8",
  orange = "#ffb454",
  coral = "#ff8a65", -- builtin constants: null, nil, true, false
  lavender = "#b8b5ff", -- properties and fields

  -- Semantic colors
  error = "#ff5370",
  warning = "#ffb454",
  info = "#5cb8ff",
  hint = "#4a5568",
  success = "#69ff69",

  -- Git colors
  git_add = "#69ff69",
  git_change = "#ffd454",
  git_delete = "#ff5370",
  git_conflict = "#ffb454",

  -- Terminal colors
  terminal = {
    black = "#3f4451",
    black_bright = "#5c6370",
    red = "#ff5370",
    red_bright = "#ff6b8a",
    green = "#69ff69",
    green_bright = "#8aff8a",
    yellow = "#ffb454",
    yellow_bright = "#ffc970",
    blue = "#5cb8ff",
    blue_bright = "#7dcfff",
    magenta = "#e06cff",
    magenta_bright = "#f08fff",
    cyan = "#4ae0eb",
    cyan_bright = "#6ef0f8",
    white = "#e0e4eb",
    white_bright = "#ffffff",
  },
}

-- Derived colors: diff and diagnostic backgrounds, search, operator.
local palette = M.colors
palette.diff_add_bg = blend(palette.green, palette.bg, TINT.diff)
palette.diff_change_bg = blend(palette.gold, palette.bg, TINT.diff)
palette.diff_delete_bg = blend(palette.red, palette.bg, TINT.diff)
palette.diff_text_bg = blend(palette.gold, palette.bg, TINT.diff_text)
palette.search_bg = blend(palette.gold, palette.bg, TINT.search)
palette.current_search_bg = blend(palette.orange, palette.bg, TINT.current_search)
palette.error_bg = blend(palette.error, palette.bg, TINT.diagnostic)
palette.warning_bg = blend(palette.warning, palette.bg, TINT.diagnostic)
palette.info_bg = blend(palette.info, palette.bg, TINT.diagnostic)
palette.success_bg = blend(palette.success, palette.bg, TINT.diagnostic)
palette.operator = blend(palette.cyan, palette.fg_muted, TINT.operator)

function M.setup(opts)
  opts = opts or {}

  if vim.g.colors_name then
    vim.cmd("hi clear")
  end

  vim.o.termguicolors = true
  vim.g.colors_name = "oz-theme"

  local c = M.colors

  -- Highlight groups
  local highlights = {
    -- Editor UI
    Normal = { fg = c.fg, bg = c.bg },
    NormalNC = { fg = c.fg, bg = c.bg },
    NormalFloat = { fg = c.fg, bg = c.bg_float },
    FloatBorder = { fg = c.border_highlight, bg = c.bg_float },
    FloatTitle = { fg = c.gold, bg = c.bg_float, bold = true },
    Cursor = { fg = c.bg, bg = c.fg },
    CursorLine = { bg = c.bg_cursorline },
    CursorLineNr = { fg = c.fg_dark, bold = true },
    CursorColumn = { bg = c.bg_cursorline },
    ColorColumn = { bg = c.bg_cursorline },
    LineNr = { fg = c.fg_gutter },
    SignColumn = { fg = c.fg_gutter, bg = c.bg },
    VertSplit = { fg = c.border },
    WinSeparator = { fg = c.border },
    Folded = { fg = c.fg_comment, bg = c.bg_highlight },
    FoldColumn = { fg = c.fg_gutter },
    NonText = { fg = c.fg_gutter },
    SpecialKey = { fg = c.fg_gutter },
    Whitespace = { fg = c.fg_gutter },
    EndOfBuffer = { fg = c.bg },

    -- Popup menu
    Pmenu = { fg = c.fg, bg = c.bg_popup },
    PmenuSel = { fg = c.fg, bg = c.bg_visual },
    PmenuSbar = { bg = c.bg_popup },
    PmenuThumb = { bg = c.fg_gutter },

    -- Search
    Search = { fg = c.fg, bg = c.search_bg },
    IncSearch = { fg = c.bg, bg = c.current_search_bg, bold = true },
    CurSearch = { fg = c.bg, bg = c.current_search_bg, bold = true },
    Substitute = { fg = c.bg, bg = c.red },

    -- Visual
    Visual = { bg = c.bg_visual },
    VisualNOS = { bg = c.bg_visual },

    -- Statusline
    StatusLine = { fg = c.fg, bg = c.bg_statusline },
    StatusLineNC = { fg = c.fg_muted, bg = c.bg_statusline },
    WinBar = { fg = c.fg, bg = c.bg },
    WinBarNC = { fg = c.fg_muted, bg = c.bg },

    -- Tabs
    TabLine = { fg = c.fg_muted, bg = c.bg_statusline },
    TabLineFill = { bg = c.bg_statusline },
    TabLineSel = { fg = c.fg, bg = c.bg },

    -- Messages
    ModeMsg = { fg = c.fg, bold = true },
    MsgArea = { fg = c.fg },
    MoreMsg = { fg = c.blue },
    Question = { fg = c.blue },
    WarningMsg = { fg = c.warning },
    ErrorMsg = { fg = c.error },

    -- Spelling
    SpellBad = { sp = c.error, undercurl = true },
    SpellCap = { sp = c.warning, undercurl = true },
    SpellLocal = { sp = c.info, undercurl = true },
    SpellRare = { sp = c.hint, undercurl = true },

    -- Diff
    DiffAdd = { bg = c.diff_add_bg },
    DiffChange = { bg = c.diff_change_bg },
    DiffDelete = { bg = c.diff_delete_bg },
    DiffText = { bg = c.diff_text_bg },

    -- Diagnostics
    DiagnosticError = { fg = c.error },
    DiagnosticWarn = { fg = c.warning },
    DiagnosticInfo = { fg = c.info },
    DiagnosticHint = { fg = c.hint },
    DiagnosticOk = { fg = c.success },
    DiagnosticVirtualTextError = { fg = c.error, bg = c.error_bg },
    DiagnosticVirtualTextWarn = { fg = c.warning, bg = c.warning_bg },
    DiagnosticVirtualTextInfo = { fg = c.info, bg = c.info_bg },
    DiagnosticVirtualTextHint = { fg = c.hint, bg = c.bg_cursorline },
    DiagnosticVirtualTextOk = { fg = c.success, bg = c.success_bg },
    DiagnosticUnderlineError = { sp = c.error, undercurl = true },
    DiagnosticUnderlineWarn = { sp = c.warning, undercurl = true },
    DiagnosticUnderlineInfo = { sp = c.info, undercurl = true },
    DiagnosticUnderlineHint = { sp = c.hint, undercurl = true },
    DiagnosticUnderlineOk = { sp = c.success, undercurl = true },
    DiagnosticFloatingError = { fg = c.error },
    DiagnosticFloatingWarn = { fg = c.warning },
    DiagnosticFloatingInfo = { fg = c.info },
    DiagnosticFloatingHint = { fg = c.hint },
    DiagnosticSignError = { fg = c.error },
    DiagnosticSignWarn = { fg = c.warning },
    DiagnosticSignInfo = { fg = c.info },
    DiagnosticSignHint = { fg = c.hint },

    -- LSP
    LspReferenceText = { bg = c.bg_ref },
    LspReferenceRead = { bg = c.bg_ref },
    LspReferenceWrite = { bg = c.bg_ref_write },
    LspSignatureActiveParameter = { fg = c.orange, bold = true },
    LspCodeLens = { fg = c.fg_comment },
    LspCodeLensSeparator = { fg = c.fg_gutter },

    -- Inlay hints (dimmed)
    LspInlayHint = { fg = c.hint, bg = "#1a1d23" },

    -- Syntax highlighting
    Comment = { fg = c.fg_comment, italic = true },
    Constant = { fg = c.orange },
    String = { fg = c.green },
    Character = { fg = c.green },
    Number = { fg = c.orange },
    Boolean = { fg = c.orange },
    Float = { fg = c.orange },

    Identifier = { fg = c.fg },
    Function = { fg = c.blue },

    Statement = { fg = c.magenta },
    Conditional = { fg = c.magenta },
    Repeat = { fg = c.magenta },
    Label = { fg = c.red_bright },
    Operator = { fg = c.cyan },
    Keyword = { fg = c.magenta },
    Exception = { fg = c.magenta },

    PreProc = { fg = c.magenta },
    Include = { fg = c.magenta },
    Define = { fg = c.magenta },
    Macro = { fg = c.magenta },
    PreCondit = { fg = c.magenta },

    Type = { fg = c.gold },
    StorageClass = { fg = c.magenta },
    Structure = { fg = c.gold },
    Typedef = { fg = c.gold },

    Special = { fg = c.cyan },
    SpecialChar = { fg = c.cyan },
    Tag = { fg = c.red_bright },
    Delimiter = { fg = c.fg_muted },
    SpecialComment = { fg = c.fg_comment },
    Debug = { fg = c.orange },

    Underlined = { underline = true },
    Bold = { bold = true },
    Italic = { italic = true },

    Ignore = { fg = c.fg_gutter },
    Error = { fg = c.error },
    Todo = { fg = c.gold, bold = true },

    -- Treesitter
    ["@comment"] = { link = "Comment" },
    ["@comment.documentation"] = { fg = "#7a8595", italic = true },
    ["@error"] = { fg = c.error },
    ["@none"] = {},
    ["@preproc"] = { fg = c.magenta },
    ["@define"] = { fg = c.magenta },
    ["@operator"] = { fg = c.operator },

    ["@punctuation.delimiter"] = { fg = c.fg_muted },
    ["@punctuation.bracket"] = { fg = c.fg_muted },
    ["@punctuation.special"] = { fg = c.cyan },

    ["@string"] = { fg = c.green },
    ["@string.regex"] = { fg = c.red_bright },
    ["@string.escape"] = { fg = c.cyan },
    ["@string.special"] = { fg = c.cyan },
    ["@string.special.symbol"] = { fg = c.orange },
    ["@string.special.url"] = { fg = c.blue, underline = true },

    ["@character"] = { fg = c.green },
    ["@character.special"] = { fg = c.cyan },

    ["@boolean"] = { fg = c.coral },
    ["@number"] = { fg = c.orange },
    ["@number.float"] = { fg = c.orange },

    -- Declarations are bold, calls stay plain.
    ["@function"] = { fg = c.blue, bold = true },
    ["@function.builtin"] = { fg = c.cyan },
    ["@function.call"] = { fg = c.blue },
    ["@function.macro"] = { fg = c.magenta },
    ["@function.method"] = { fg = c.blue, bold = true },
    ["@function.method.call"] = { fg = c.blue },

    ["@constructor"] = { fg = c.red_bright },
    ["@parameter"] = { fg = c.orange, italic = true },
    ["@argument"] = { fg = c.orange },

    ["@keyword"] = { fg = c.magenta },
    ["@keyword.coroutine"] = { fg = c.magenta, italic = true },
    ["@keyword.modifier"] = { fg = c.magenta, italic = true },
    ["@keyword.function"] = { fg = c.magenta },
    ["@keyword.operator"] = { fg = c.magenta },
    ["@keyword.import"] = { fg = c.magenta },
    ["@keyword.storage"] = { fg = c.magenta },
    -- Control flow reads brighter than declarations.
    ["@keyword.repeat"] = { fg = c.magenta_bright, bold = true },
    ["@keyword.return"] = { fg = c.magenta_bright, bold = true },
    ["@keyword.debug"] = { fg = c.magenta },
    ["@keyword.exception"] = { fg = c.magenta_bright, bold = true },
    ["@keyword.conditional"] = { fg = c.magenta_bright, bold = true },
    ["@keyword.conditional.ternary"] = { fg = c.magenta_bright, bold = true },
    ["@keyword.directive"] = { fg = c.magenta },
    ["@keyword.directive.define"] = { fg = c.magenta },

    ["@conditional"] = { fg = c.magenta },
    ["@repeat"] = { fg = c.magenta },
    ["@label"] = { fg = c.red_bright },
    ["@include"] = { fg = c.magenta },
    ["@exception"] = { fg = c.magenta },

    ["@type"] = { fg = c.gold },
    ["@type.builtin"] = { fg = c.cyan },
    ["@type.definition"] = { fg = c.gold },
    ["@type.qualifier"] = { fg = c.magenta },

    ["@storageclass"] = { fg = c.magenta },
    ["@attribute"] = { fg = c.red_bright }, -- annotations, decorators, #[derive]
    ["@attribute.builtin"] = { fg = c.cyan },
    ["@field"] = { fg = c.lavender },
    ["@property"] = { fg = c.lavender },

    ["@variable"] = { fg = c.fg },
    ["@variable.builtin"] = { fg = c.orange, italic = true }, -- self, this, it
    ["@variable.parameter"] = { fg = c.orange, italic = true },
    ["@variable.member"] = { fg = c.lavender },

    -- Constants: bold orange; numbers stay plain orange, null/nil/true/false are coral.
    ["@constant"] = { fg = c.orange, bold = true },
    ["@constant.builtin"] = { fg = c.coral },
    ["@constant.macro"] = { fg = c.orange, bold = true },

    -- Paths are context, not types.
    ["@module"] = { fg = c.fg_muted },
    ["@module.builtin"] = { fg = c.cyan },
    ["@namespace"] = { fg = c.fg_muted },

    ["@symbol"] = { fg = c.orange },

    ["@text"] = { fg = c.fg },
    ["@text.strong"] = { bold = true },
    ["@text.emphasis"] = { italic = true },
    ["@text.underline"] = { underline = true },
    ["@text.strike"] = { strikethrough = true },
    ["@text.title"] = { fg = c.red_bright, bold = true },
    ["@text.literal"] = { fg = c.green },
    ["@text.uri"] = { fg = c.blue, underline = true },
    ["@text.math"] = { fg = c.cyan },
    ["@text.environment"] = { fg = c.magenta },
    ["@text.environment.name"] = { fg = c.gold },
    ["@text.reference"] = { fg = c.blue },
    ["@text.todo"] = { fg = c.gold, bold = true },
    ["@text.note"] = { fg = c.info },
    ["@text.warning"] = { fg = c.warning },
    ["@text.danger"] = { fg = c.error },
    ["@text.diff.add"] = { fg = c.git_add },
    ["@text.diff.delete"] = { fg = c.git_delete },

    ["@tag"] = { fg = c.red_bright },
    ["@tag.attribute"] = { fg = c.lavender },
    ["@tag.delimiter"] = { fg = c.fg_muted },

    -- Kotlin's highlights query paints a whole parameter list as @constructor.
    ["@constructor.kotlin"] = { fg = c.fg },

    -- Markup (new treesitter captures)
    ["@markup.heading"] = { fg = c.red_bright, bold = true },
    ["@markup.heading.1"] = { fg = c.red_bright, bold = true },
    ["@markup.heading.2"] = { fg = c.orange, bold = true },
    ["@markup.heading.3"] = { fg = c.gold, bold = true },
    ["@markup.heading.4"] = { fg = c.green, bold = true },
    ["@markup.heading.5"] = { fg = c.blue, bold = true },
    ["@markup.heading.6"] = { fg = c.magenta, bold = true },
    ["@markup.quote"] = { fg = c.fg_muted, italic = true },
    ["@markup.math"] = { fg = c.cyan },
    ["@markup.link"] = { fg = c.blue },
    ["@markup.link.label"] = { fg = c.blue },
    ["@markup.link.url"] = { fg = c.cyan, underline = true },
    ["@markup.raw"] = { fg = c.green },
    ["@markup.raw.block"] = { fg = c.green },
    ["@markup.list"] = { fg = c.red_bright },
    ["@markup.list.checked"] = { fg = c.green },
    ["@markup.list.unchecked"] = { fg = c.fg_muted },
    ["@markup.strikethrough"] = { strikethrough = true },
    ["@markup.italic"] = { italic = true },
    ["@markup.strong"] = { bold = true },
    ["@markup.underline"] = { underline = true },

    -- LSP Semantic tokens
    -- Semantic tokens paint over tree-sitter, so each type either links to the same
    -- tree-sitter group (no color flip when the server attaches) or is cleared where
    -- tree-sitter knows more: declaration vs call, which keyword role, comment kind.
    ["@lsp.type.class"] = { link = "@type" },
    ["@lsp.type.comment"] = {},
    ["@lsp.type.decorator"] = { link = "@attribute" },
    ["@lsp.type.enum"] = { link = "@type" },
    ["@lsp.type.enumMember"] = { link = "@constant" },
    ["@lsp.type.function"] = {},
    ["@lsp.type.interface"] = { link = "@type" },
    ["@lsp.type.keyword"] = {},
    ["@lsp.type.macro"] = { link = "@function.macro" },
    ["@lsp.type.method"] = {},
    ["@lsp.type.namespace"] = { link = "@module" },
    ["@lsp.type.number"] = { link = "@number" },
    ["@lsp.type.operator"] = {},
    ["@lsp.type.parameter"] = { link = "@variable.parameter" },
    ["@lsp.type.property"] = { link = "@property" },
    ["@lsp.type.regexp"] = { link = "@string.regexp" },
    ["@lsp.type.string"] = { link = "@string" },
    ["@lsp.type.struct"] = { link = "@type" },
    ["@lsp.type.type"] = { link = "@type" },
    ["@lsp.type.typeParameter"] = { link = "@type" },
    ["@lsp.type.variable"] = {},
    ["@lsp.typemod.function.defaultLibrary"] = { link = "@function.builtin" },
    ["@lsp.typemod.variable.defaultLibrary"] = { link = "@variable.builtin" },
    ["@lsp.typemod.variable.readonly"] = { fg = c.orange },
    ["@lsp.mod.deprecated"] = { strikethrough = true },

    -- Git signs
    GitSignsAdd = { fg = c.git_add },
    GitSignsChange = { fg = c.git_change },
    GitSignsDelete = { fg = c.git_delete },
    GitSignsAddNr = { fg = c.git_add },
    GitSignsChangeNr = { fg = c.git_change },
    GitSignsDeleteNr = { fg = c.git_delete },
    GitSignsAddLn = { bg = c.diff_add_bg },
    GitSignsChangeLn = { bg = c.diff_change_bg },
    GitSignsDeleteLn = { bg = c.diff_delete_bg },
    GitSignsCurrentLineBlame = { fg = c.fg_comment },

    -- Telescope
    TelescopeNormal = { fg = c.fg, bg = c.bg_float },
    TelescopeBorder = { fg = c.border_highlight, bg = c.bg_float },
    TelescopeTitle = { fg = c.gold, bold = true },
    TelescopePromptNormal = { fg = c.fg, bg = c.bg_highlight },
    TelescopePromptBorder = { fg = c.border_highlight, bg = c.bg_highlight },
    TelescopePromptTitle = { fg = c.gold, bg = c.bg_highlight, bold = true },
    TelescopePromptPrefix = { fg = c.blue },
    TelescopePromptCounter = { fg = c.fg_muted },
    TelescopeResultsNormal = { fg = c.fg, bg = c.bg_float },
    TelescopeResultsBorder = { fg = c.border_highlight, bg = c.bg_float },
    TelescopeResultsTitle = { fg = c.gold, bold = true },
    TelescopePreviewNormal = { fg = c.fg, bg = c.bg_float },
    TelescopePreviewBorder = { fg = c.border_highlight, bg = c.bg_float },
    TelescopePreviewTitle = { fg = c.gold, bold = true },
    TelescopeSelection = { fg = c.fg, bg = c.bg_visual },
    TelescopeSelectionCaret = { fg = c.blue },
    TelescopeMultiSelection = { fg = c.gold },
    TelescopeMultiIcon = { fg = c.blue },
    TelescopeMatching = { fg = c.orange, bold = true },

    -- NvimTree
    NvimTreeNormal = { fg = c.fg, bg = c.bg_sidebar },
    NvimTreeNormalNC = { fg = c.fg, bg = c.bg_sidebar },
    NvimTreeRootFolder = { fg = c.blue, bold = true },
    NvimTreeFolderName = { fg = c.blue },
    NvimTreeFolderIcon = { fg = c.blue },
    NvimTreeOpenedFolderName = { fg = c.blue_bright },
    NvimTreeEmptyFolderName = { fg = c.fg_muted },
    NvimTreeSymlink = { fg = c.cyan },
    NvimTreeSpecialFile = { fg = c.gold },
    NvimTreeImageFile = { fg = c.magenta },
    NvimTreeIndentMarker = { fg = c.fg_gutter },
    NvimTreeGitDirty = { fg = c.git_change },
    NvimTreeGitNew = { fg = c.git_add },
    NvimTreeGitDeleted = { fg = c.git_delete },
    NvimTreeGitStaged = { fg = c.git_add },

    -- Neo-tree
    NeoTreeNormal = { fg = c.fg, bg = c.bg_sidebar },
    NeoTreeNormalNC = { fg = c.fg, bg = c.bg_sidebar },
    NeoTreeDirectoryName = { fg = c.blue },
    NeoTreeDirectoryIcon = { fg = c.blue },
    NeoTreeRootName = { fg = c.blue, bold = true },
    NeoTreeFileName = { fg = c.fg },
    NeoTreeFileIcon = { fg = c.fg },
    NeoTreeFileNameOpened = { fg = c.gold },
    NeoTreeSymbolicLinkTarget = { fg = c.cyan },
    NeoTreeIndentMarker = { fg = c.fg_gutter },
    NeoTreeGitAdded = { fg = c.git_add },
    NeoTreeGitConflict = { fg = c.git_conflict },
    NeoTreeGitDeleted = { fg = c.git_delete },
    NeoTreeGitIgnored = { fg = c.fg_muted },
    NeoTreeGitModified = { fg = c.git_change },
    NeoTreeGitUnstaged = { fg = c.git_change },
    NeoTreeGitUntracked = { fg = c.git_add },
    NeoTreeGitStaged = { fg = c.git_add },

    -- Nvim-cmp
    CmpItemAbbr = { fg = c.fg },
    CmpItemAbbrDeprecated = { fg = c.fg_muted, strikethrough = true },
    CmpItemAbbrMatch = { fg = c.blue, bold = true },
    CmpItemAbbrMatchFuzzy = { fg = c.blue, bold = true },
    CmpItemKind = { fg = c.magenta },
    CmpItemMenu = { fg = c.fg_muted },
    CmpItemKindClass = { fg = c.gold },
    CmpItemKindColor = { fg = c.cyan },
    CmpItemKindConstant = { fg = c.orange },
    CmpItemKindConstructor = { fg = c.red_bright },
    CmpItemKindEnum = { fg = c.gold },
    CmpItemKindEnumMember = { fg = c.orange },
    CmpItemKindEvent = { fg = c.orange },
    CmpItemKindField = { fg = c.fg },
    CmpItemKindFile = { fg = c.fg },
    CmpItemKindFolder = { fg = c.blue },
    CmpItemKindFunction = { fg = c.blue },
    CmpItemKindInterface = { fg = c.gold },
    CmpItemKindKeyword = { fg = c.magenta },
    CmpItemKindMethod = { fg = c.blue },
    CmpItemKindModule = { fg = c.gold },
    CmpItemKindOperator = { fg = c.cyan },
    CmpItemKindProperty = { fg = c.fg },
    CmpItemKindReference = { fg = c.red_bright },
    CmpItemKindSnippet = { fg = c.green },
    CmpItemKindStruct = { fg = c.gold },
    CmpItemKindText = { fg = c.fg },
    CmpItemKindTypeParameter = { fg = c.gold },
    CmpItemKindUnit = { fg = c.orange },
    CmpItemKindValue = { fg = c.orange },
    CmpItemKindVariable = { fg = c.fg },

    -- Indent blankline
    IndentBlanklineChar = { fg = c.fg_gutter },
    IndentBlanklineContextChar = { fg = c.border_highlight },
    IndentBlanklineContextStart = { sp = c.border_highlight, underline = true },
    IblIndent = { fg = c.fg_gutter },
    IblScope = { fg = c.border_highlight },

    -- Illuminate
    IlluminatedWordText = { bg = c.bg_ref },
    IlluminatedWordRead = { bg = c.bg_ref },
    IlluminatedWordWrite = { bg = c.bg_ref_write },

    -- Navic / Barbecue (breadcrumbs)
    NavicText = { fg = c.fg_muted },
    NavicSeparator = { fg = c.fg_gutter },
    NavicIconsFile = { fg = c.fg },
    NavicIconsModule = { fg = c.gold },
    NavicIconsNamespace = { fg = c.gold },
    NavicIconsPackage = { fg = c.gold },
    NavicIconsClass = { fg = c.gold },
    NavicIconsMethod = { fg = c.blue },
    NavicIconsProperty = { fg = c.fg },
    NavicIconsField = { fg = c.fg },
    NavicIconsConstructor = { fg = c.red_bright },
    NavicIconsEnum = { fg = c.gold },
    NavicIconsInterface = { fg = c.gold },
    NavicIconsFunction = { fg = c.blue },
    NavicIconsVariable = { fg = c.fg },
    NavicIconsConstant = { fg = c.orange },
    NavicIconsString = { fg = c.green },
    NavicIconsNumber = { fg = c.orange },
    NavicIconsBoolean = { fg = c.orange },
    NavicIconsArray = { fg = c.gold },
    NavicIconsObject = { fg = c.gold },
    NavicIconsKey = { fg = c.magenta },
    NavicIconsNull = { fg = c.orange },
    NavicIconsEnumMember = { fg = c.orange },
    NavicIconsStruct = { fg = c.gold },
    NavicIconsEvent = { fg = c.orange },
    NavicIconsOperator = { fg = c.cyan },
    NavicIconsTypeParameter = { fg = c.gold },

    -- Which-key
    WhichKey = { fg = c.blue },
    WhichKeyGroup = { fg = c.magenta },
    WhichKeyDesc = { fg = c.fg },
    WhichKeySeparator = { fg = c.fg_gutter },
    WhichKeyFloat = { bg = c.bg_float },
    WhichKeyBorder = { fg = c.border_highlight },
    WhichKeyValue = { fg = c.fg_muted },

    -- Lazy
    LazyH1 = { fg = c.bg, bg = c.blue, bold = true },
    LazyButton = { fg = c.fg, bg = c.bg_highlight },
    LazyButtonActive = { fg = c.bg, bg = c.blue },
    LazySpecial = { fg = c.magenta },
    LazyProgressDone = { fg = c.green },
    LazyProgressTodo = { fg = c.fg_gutter },

    -- Mason
    MasonHeader = { fg = c.bg, bg = c.blue, bold = true },
    MasonHighlight = { fg = c.blue },
    MasonHighlightBlock = { fg = c.bg, bg = c.blue },
    MasonHighlightBlockBold = { fg = c.bg, bg = c.blue, bold = true },
    MasonMuted = { fg = c.fg_muted },
    MasonMutedBlock = { fg = c.fg_muted, bg = c.bg_highlight },

    -- Noice
    NoiceFormatProgressDone = { fg = c.bg, bg = c.green },
    NoiceFormatProgressTodo = { fg = c.fg, bg = c.bg_highlight },
    NoiceLspProgressSpinner = { fg = c.blue },
    NoiceLspProgressTitle = { fg = c.fg },
    NoiceLspProgressClient = { fg = c.blue },

    -- Notify
    NotifyERRORBorder = { fg = c.error },
    NotifyWARNBorder = { fg = c.warning },
    NotifyINFOBorder = { fg = c.info },
    NotifyDEBUGBorder = { fg = c.fg_muted },
    NotifyTRACEBorder = { fg = c.magenta },
    NotifyERRORIcon = { fg = c.error },
    NotifyWARNIcon = { fg = c.warning },
    NotifyINFOIcon = { fg = c.info },
    NotifyDEBUGIcon = { fg = c.fg_muted },
    NotifyTRACEIcon = { fg = c.magenta },
    NotifyERRORTitle = { fg = c.error },
    NotifyWARNTitle = { fg = c.warning },
    NotifyINFOTitle = { fg = c.info },
    NotifyDEBUGTitle = { fg = c.fg_muted },
    NotifyTRACETitle = { fg = c.magenta },
    NotifyERRORBody = { fg = c.fg },
    NotifyWARNBody = { fg = c.fg },
    NotifyINFOBody = { fg = c.fg },
    NotifyDEBUGBody = { fg = c.fg },
    NotifyTRACEBody = { fg = c.fg },

    -- Mini
    MiniStatuslineDevinfo = { fg = c.fg, bg = c.bg_highlight },
    MiniStatuslineFileinfo = { fg = c.fg, bg = c.bg_highlight },
    MiniStatuslineFilename = { fg = c.fg_muted, bg = c.bg_statusline },
    MiniStatuslineInactive = { fg = c.fg_muted, bg = c.bg_statusline },
    MiniStatuslineModeCommand = { fg = c.bg, bg = c.gold, bold = true },
    MiniStatuslineModeInsert = { fg = c.bg, bg = c.green, bold = true },
    MiniStatuslineModeNormal = { fg = c.bg, bg = c.blue, bold = true },
    MiniStatuslineModeOther = { fg = c.bg, bg = c.cyan, bold = true },
    MiniStatuslineModeReplace = { fg = c.bg, bg = c.red, bold = true },
    MiniStatuslineModeVisual = { fg = c.bg, bg = c.magenta, bold = true },

    -- Trouble
    TroubleText = { fg = c.fg },
    TroubleCount = { fg = c.magenta, bg = c.bg_highlight },
    TroubleNormal = { fg = c.fg, bg = c.bg_sidebar },

    -- Flash
    FlashLabel = { fg = c.bg, bg = c.magenta, bold = true },
    FlashMatch = { fg = c.fg, bg = c.bg_visual },
    FlashCurrent = { fg = c.gold, bg = c.bg_visual },
    FlashBackdrop = { fg = c.fg_muted },

    -- Bufferline
    BufferLineFill = { bg = c.bg_dark },
    BufferLineBackground = { fg = c.fg_muted, bg = c.bg_dark },
    BufferLineBuffer = { fg = c.fg_muted, bg = c.bg_dark },
    BufferLineBufferSelected = { fg = c.fg, bg = c.bg, bold = true },
    BufferLineBufferVisible = { fg = c.fg_muted, bg = c.bg },
    BufferLineCloseButton = { fg = c.fg_muted, bg = c.bg_dark },
    BufferLineCloseButtonSelected = { fg = c.red, bg = c.bg },
    BufferLineCloseButtonVisible = { fg = c.fg_muted, bg = c.bg },
    BufferLineIndicatorSelected = { fg = c.blue, bg = c.bg },
    BufferLineIndicatorVisible = { fg = c.bg, bg = c.bg },
    BufferLineModified = { fg = c.git_change, bg = c.bg_dark },
    BufferLineModifiedSelected = { fg = c.git_change, bg = c.bg },
    BufferLineModifiedVisible = { fg = c.git_change, bg = c.bg },
    BufferLineSeparator = { fg = c.bg_dark, bg = c.bg_dark },
    BufferLineSeparatorSelected = { fg = c.bg_dark, bg = c.bg },
    BufferLineSeparatorVisible = { fg = c.bg_dark, bg = c.bg },
    BufferLineTab = { fg = c.fg_muted, bg = c.bg_dark },
    BufferLineTabSelected = { fg = c.fg, bg = c.bg },
    BufferLineTabClose = { fg = c.red, bg = c.bg_dark },

    -- Dashboard
    DashboardHeader = { fg = c.blue },
    DashboardCenter = { fg = c.magenta },
    DashboardFooter = { fg = c.fg_muted, italic = true },
    DashboardShortCut = { fg = c.cyan },
    DashboardKey = { fg = c.orange },
    DashboardDesc = { fg = c.fg },
    DashboardIcon = { fg = c.blue },

    -- Alpha
    AlphaHeader = { fg = c.blue },
    AlphaButtons = { fg = c.cyan },
    AlphaShortcut = { fg = c.orange },
    AlphaFooter = { fg = c.fg_muted, italic = true },

    -- Fidget
    FidgetTitle = { fg = c.blue },
    FidgetTask = { fg = c.fg_muted },

    -- Leap
    LeapMatch = { fg = c.gold, bold = true, underline = true },
    LeapLabelPrimary = { fg = c.bg, bg = c.magenta, bold = true },
    LeapLabelSecondary = { fg = c.bg, bg = c.cyan, bold = true },
    LeapBackdrop = { fg = c.fg_muted },

    -- Rainbow delimiters
    RainbowDelimiterRed = { fg = c.red },
    RainbowDelimiterYellow = { fg = c.gold },
    RainbowDelimiterBlue = { fg = c.blue },
    RainbowDelimiterOrange = { fg = c.orange },
    RainbowDelimiterGreen = { fg = c.green },
    RainbowDelimiterViolet = { fg = c.magenta },
    RainbowDelimiterCyan = { fg = c.cyan },
  }

  -- Apply highlights
  for group, hl in pairs(highlights) do
    vim.api.nvim_set_hl(0, group, hl)
  end

  -- Set terminal colors
  vim.g.terminal_color_0 = c.terminal.black
  vim.g.terminal_color_1 = c.terminal.red
  vim.g.terminal_color_2 = c.terminal.green
  vim.g.terminal_color_3 = c.terminal.yellow
  vim.g.terminal_color_4 = c.terminal.blue
  vim.g.terminal_color_5 = c.terminal.magenta
  vim.g.terminal_color_6 = c.terminal.cyan
  vim.g.terminal_color_7 = c.terminal.white
  vim.g.terminal_color_8 = c.terminal.black_bright
  vim.g.terminal_color_9 = c.terminal.red_bright
  vim.g.terminal_color_10 = c.terminal.green_bright
  vim.g.terminal_color_11 = c.terminal.yellow_bright
  vim.g.terminal_color_12 = c.terminal.blue_bright
  vim.g.terminal_color_13 = c.terminal.magenta_bright
  vim.g.terminal_color_14 = c.terminal.cyan_bright
  vim.g.terminal_color_15 = c.terminal.white_bright
end

return M

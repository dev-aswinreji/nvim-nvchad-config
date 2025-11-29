local cmp = require "cmp"
local luasnip = require "luasnip"
local lspkind = require "lspkind"

-- Helper: Check words before cursor
local function has_words_before()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  if col == 0 then return false end
  local text = vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]
  return text:sub(col, col):match("%s") == nil
end

return {
  "hrsh7th/nvim-cmp",

  config = function()
    cmp.setup({

      preselect = cmp.PreselectMode.Item,
      completion = {
        completeopt = "menu,menuone,noinsert",
      },
      -- UI: Borders + Icons + Better Formatting
      formatting = {
        format = lspkind.cmp_format({
          mode = "symbol_text", -- show icon + text
          maxwidth = 50,
          ellipsis_char = "...",
        })
      },

      window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
      },

      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },

      mapping = {

        -- ENTER accepts item
        ["<CR>"] = cmp.mapping.confirm({
          behavior = cmp.ConfirmBehavior.Replace,
          select = false,
        }),

        -- TAB = expand or jump snippet
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          elseif has_words_before() then
            cmp.complete()
          else
            fallback()
          end
        end, { "i", "s" }),

        -- SHIFT-TAB = jump backward
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { "i", "s" }),
      },

      sources = cmp.config.sources({
        { name = "luasnip", priority = 1000 },
        { name = "nvim_lsp", priority = 800 },
        { name = "buffer", priority = 500 },
        { name = "path", priority = 300 },
      }),

      sorting = {
        priority_weight = 2,
        comparators = {

          -- Snippets first
          function(entry1, entry2)
            local snippet = cmp.lsp.CompletionItemKind.Snippet
            local k1 = entry1:get_kind()
            local k2 = entry2:get_kind()
            if k1 == snippet and k2 ~= snippet then return true end
            if k2 == snippet and k1 ~= snippet then return false end
          end,

          cmp.config.compare.offset,
          cmp.config.compare.exact,
          cmp.config.compare.score,
          cmp.config.compare.recently_used,
          cmp.config.compare.kind,
          cmp.config.compare.sort_text,
          cmp.config.compare.length,
          cmp.config.compare.order,
        }
      },

    })
  end,
}

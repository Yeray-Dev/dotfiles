-- lua/plugins/blink.lua
return {
  "saghen/blink.cmp",
  opts = {
    sources = {
      default = { "lsp", "path" },
      providers = {
        lsp = {
          transform_items = function(_, items)
            return vim.tbl_filter(function(item)
              if item.additionalTextEdits and #item.additionalTextEdits > 0 then
                return false
              end
              local label = item.label or ""
              if label:match("^std::") then
                return false
              end
              if label:match("^__") then
                return false
              end
              return true
            end, items)
          end,
        },
      },
    },

    keymap = {
      preset = "none",
      ["<Tab>"] = { "select_next", "fallback" },
      ["<S-Tab>"] = { "select_prev", "fallback" },
      ["<CR>"] = { "accept", "fallback" },
      ["<C-e>"] = { "cancel", "fallback" },
      ["<Up>"] = { "cancel", "fallback" },
      ["<Down>"] = { "cancel", "fallback" },
      ["<Left>"] = { "cancel", "fallback" },
      ["<Right>"] = { "cancel", "fallback" },
      ["<Space>"] = {
        function(cmp)
          if cmp.is_visible() then
            cmp.cancel()
            return true -- consume la tecla: no se inserta el espacio
          end
        end,
        "fallback",
      },
    },

    completion = {
      ghost_text = { enabled = false },
      documentation = { auto_show = false },
      list = { selection = { preselect = false, auto_insert = false } },
    },
  },
}

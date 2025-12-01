require("nvchad.configs.lspconfig").defaults()

local servers = { "html", "cssls","ts_ls","csharp_ls","tailwindcss","rust_analyzer" }
vim.lsp.enable(servers)
-- read :h vim.lsp.config for changing options of lsp servers 
-- vim.lsp.enable('tailwindcss')

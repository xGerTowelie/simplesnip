local M = {}

M.config = {
	snippets_path = vim.fn.expand("~/.config/nvim/snippets"), -- Default path
	keymap_select = "<leader>ss", -- Default keymap for snippet select
	keymap_add = "<leader>sa", -- Default keymap for snippet add
}

function M.setup(user_config)
	M.config = vim.tbl_deep_extend("force", M.config, user_config or {})
end

return M

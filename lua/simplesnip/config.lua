local M = {}

M.config = {
	snippets_path = vim.fn.expand("~/snippets"), -- Default path
	keymap = "<leader>ss", -- Default keymap for snippet select
}

function M.setup(user_config)
	M.config = vim.tbl_deep_extend("force", M.config, user_config or {})
end

return M

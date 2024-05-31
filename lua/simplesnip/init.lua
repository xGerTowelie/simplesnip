local config = require("simplesnip.config")
local telescope = require("telescope.builtin")

local M = {}

function M.setup(user_config)
	config.setup(user_config)
	M.set_keymap()
end

function M.set_keymap()
	if config.config.keymap then
		vim.api.nvim_set_keymap(
			"n",
			config.config.keymap,
			"<cmd>lua require('simplesnip').select_snippet()<CR>",
			{ noremap = true, silent = true }
		)
	end
end

function M.select_snippet()
	local snippets_path = config.config.snippets_path

	if vim.fn.isdirectory(snippets_path) == 0 then
		print("Snippets path does not exist: " .. snippets_path)
		return
	end

	telescope.find_files({
		prompt_title = "Select Snippet",
		cwd = snippets_path,
		attach_mappings = function(_, map)
			map("i", "<CR>", function(prompt_bufnr)
				local entry = require("telescope.actions.state").get_selected_entry()
				require("telescope.actions").close(prompt_bufnr)
				M.insert_snippet(entry.path)
			end)
			return true
		end,
	})
end

function M.insert_snippet(file_path)
	local lines = vim.fn.readfile(file_path)
	vim.api.nvim_put(lines, "l", false, true)
end

return M

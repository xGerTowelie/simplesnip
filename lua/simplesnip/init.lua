local config = require("simplesnip.config")
local telescope = require("telescope.builtin")

local M = {}

function M.setup(user_config)
	config.setup(user_config)
	M.set_keymaps()
end

function M.set_keymaps()
	if config.config.keymap_select then
		vim.api.nvim_set_keymap(
			"n",
			config.config.keymap_select,
			"<cmd>lua require('simplesnip').select_snippet()<CR>",
			{ noremap = true, silent = true }
		)
	end
	if config.config.keymap_add then
		vim.api.nvim_set_keymap(
			"v",
			config.config.keymap_add,
			':<C-u>lua require("simplesnip").add_snippet()<CR>',
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

local function get_visual_selection()
	local s_start = vim.fn.getpos("'<")
	local s_end = vim.fn.getpos("'>")
	local n_lines = math.abs(s_end[2] - s_start[2]) + 1
	local lines = vim.api.nvim_buf_get_lines(0, s_start[2] - 1, s_end[2], false)
	lines[1] = string.sub(lines[1], s_start[3], -1)
	if n_lines == 1 then
		lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3] - s_start[3] + 1)
	else
		lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3])
	end
	return table.concat(lines, "\n")
end

function M.add_snippet()
	local lines = get_visual_selection()

	if not lines or #lines == 0 then
		print("Error: No lines selected.")
		return
	end

	-- Prompt the user for a snippet name
	local snippet_name = vim.fn.input("Enter snippet name: ")
	if snippet_name == "" then
		print("Snippet name cannot be empty")
		return
	end

	-- Save the snippet to a file
	local snippets_path = config.config.snippets_path
	if vim.fn.isdirectory(snippets_path) == 0 then
		vim.fn.mkdir(snippets_path, "p")
	end

	local snippet_file = snippets_path .. "/" .. snippet_name .. ".snippet"

	-- Open the snippet file in write mode
	local file = assert(io.open(snippet_file, "w"), "Error opening snippet file")

	-- Write the entire snippet to the file
	file:write(lines)

	file:close()

	print("Snippet saved to " .. snippet_file)
end

return M

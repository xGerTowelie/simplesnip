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
			"<cmd>lua require('simplesnip').add_snippet()<CR>",
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

function M.add_snippet()
	-- Ensure we are in visual mode when capturing the selection
	if vim.fn.mode() ~= "v" and vim.fn.mode() ~= "V" and vim.fn.mode() ~= "\22" then
		print("Error: add_snippet should be called in visual mode")
		return
	end

	-- Get the start and end positions of the visual selection
	local start_pos = vim.fn.getpos("'<")
	local end_pos = vim.fn.getpos("'>")

	print("start_pos:", vim.inspect(start_pos))
	print("end_pos:", vim.inspect(end_pos))

	if start_pos[2] == 0 or end_pos[2] == 0 then
		print("Error: Invalid visual selection positions.")
		return
	end

	-- Get the lines in the selected range
	local lines = vim.fn.getline(start_pos[2], end_pos[2])
	print("lines before adjustment:", vim.inspect(lines))

	if not lines or #lines == 0 then
		print("Error: No lines selected.")
		return
	end

	-- Adjust the first and last lines to include only the selected part
	if #lines == 1 then
		lines[1] = string.sub(lines[1], start_pos[3], end_pos[3])
	else
		lines[1] = string.sub(lines[1], start_pos[3])
		lines[#lines] = string.sub(lines[#lines], 1, end_pos[3])
	end

	print("lines after adjustment:", vim.inspect(lines))

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
	vim.fn.writefile(lines, snippet_file)

	print("Snippet saved to " .. snippet_file)
end

return M

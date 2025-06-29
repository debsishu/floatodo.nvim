local M = {}

local config = {
  -- Default todo path
	path = vim.fn.expand("~/.todo.md"),
	width_percent = 0.8,
	height_percent = 0.8,
	insert_on_open = true,
}

local win_id = nil
local buf_id = nil

function M.setup(opts)
	config = vim.tbl_deep_extend("force", config, opts or {})
end

local function ensure_today_heading()
	local today = os.date("## %Y-%m-%d")
	local lines = vim.api.nvim_buf_get_lines(buf_id, 0, -1, false)

	-- Ensure "# TODOs" is the first line
	if lines[1] ~= "# TODOs" then
		vim.api.nvim_buf_set_lines(buf_id, 0, 0, false, { "# TODOs" })
		lines = vim.api.nvim_buf_get_lines(buf_id, 0, -1, false) -- refresh lines
	end

	-- Check if today's date already exists
	for _, line in ipairs(lines) do
		if line == today then
			return
		end
	end

	-- Insert today's date and two empty TODOs below "# TODOs"
	vim.api.nvim_buf_set_lines(buf_id, 2, 2, false, {
		today,
		"",
		"- [ ] .",
		"- [ ] .",
		"",
	})
end

function M.floatodo_toggle()
	if win_id and vim.api.nvim_win_is_valid(win_id) then
		if buf_id and vim.api.nvim_buf_is_valid(buf_id) and vim.api.nvim_buf_get_option(buf_id, "modified") then
			vim.api.nvim_buf_call(buf_id, function()
				vim.cmd("write")
			end)
		end
		vim.api.nvim_win_close(win_id, true)
		win_id = nil
		return
	end

	local path = vim.fn.expand(config.path)
	buf_id = vim.fn.bufnr(path, true)
	vim.fn.bufload(buf_id)

	vim.api.nvim_buf_set_option(buf_id, "filetype", "markdown")
	vim.api.nvim_buf_set_option(buf_id, "bufhidden", "hide")
	vim.api.nvim_buf_set_option(buf_id, "swapfile", true)

	ensure_today_heading()

	local width = math.floor(vim.o.columns * config.width_percent)
	local height = math.floor(vim.o.lines * config.height_percent)
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	win_id = vim.api.nvim_open_win(buf_id, true, {
		relative = "editor",
		row = row,
		col = col,
		width = width,
		height = height,
		style = "minimal",
		border = "rounded",
	})

	if config.insert_on_open then
		vim.cmd("startinsert")
	end

	vim.keymap.set("n", "q", function()
		vim.cmd("write")
		vim.api.nvim_win_close(win_id, true)
	end, { buffer = buf_id })

	vim.keymap.set("n", "<Esc>", function()
		vim.cmd("write")
		vim.api.nvim_win_close(win_id, true)
	end, { buffer = buf_id })

	vim.api.nvim_create_autocmd("FileType", {
		buffer = buf_id,
		callback = function()
			vim.cmd([[
        syntax match TodoUnchecked /\[ \]/
        syntax match TodoChecked /\[x\]/
        highlight TodoUnchecked ctermfg=Yellow guifg=Yellow
        highlight TodoChecked ctermfg=Green guifg=Green
      ]])
		end,
		once = true,
	})

	vim.api.nvim_create_autocmd("WinClosed", {
		callback = function(args)
			if tonumber(args.match) == win_id then
				if vim.api.nvim_buf_is_valid(buf_id) and vim.api.nvim_buf_get_option(buf_id, "modified") then
					vim.api.nvim_buf_call(buf_id, function()
						vim.cmd("write")
					end)
				end
				win_id = nil
			end
		end,
		once = true,
	})
end

return M

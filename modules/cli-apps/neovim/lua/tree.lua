local tree = require("nvim-tree")

local function reload_tree()
	tree.api.reload()
end

tree.setup {
	disable_netrw = true,
	view = {
		mappings = {
			list = {
				{ key = "s", action = "vsplit" },
				{ key = "t", action = "tabnew" },
				{ key = "S", action = "split" },
				{ key = "O", action = "system_open" },
				{ key = "<C-r>", action_cb = reload_tree },
			}
		}
	}
}

local function map(mode, lhs, rhs, opts)
	local options = { noremap = true }

	if opts then
		options = vim.tbl_extend("force", options, opts)
	end

	vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

-- Toggle the file tree.
map("n", "<C-n>", ":NvimTreeToggle<CR>", { silent = true })

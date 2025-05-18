local Setup = {
	valid_options = {
		name = "",
		rte = "",
		lng = "",
		lcs = "",
		dcs = ""
	},
	documents = {
		readme = "README.md",
		license = "LICENSE",
		ignore = ".gitignore",
	},
	project_name = "",
	project_route = "",
	project_language = "",
	project_license = "",
	project_documents = {},

	-- Read the command line options and parse them to get their values
	parse_args = function (self)
		for i = 1, #arg do
			local option = arg[i]
			local possible_opt = false
			if string.sub(option, 1, 2) == "--" then
				possible_opt = true
			end
			local symbol_idx = string.find(option, "=", 5, 7)
			if possible_opt and symbol_idx then
				local key = string.sub(option, 3, symbol_idx - 1)
				if self.valid_options[key] then
					self.valid_options[key] = string.sub(option, symbol_idx + 1, -1)
				end
			end
		end
	end,

	show_opts_values = function (self)
		for key, value in pairs(self.valid_options) do
			print(key .. " = " .. value)
		end
	end,

	-- Create the documents according to the parsed options
	create_base_documents = function (self)
		print("")
	end,

	-- Modify the created documents according to the parsed options
	write_in_documents = function (self)
		print("")
	end,

	init = function (self)
		self.parse_args(self)
		self.show_opts_values(self)
	end,
}

Setup:init()

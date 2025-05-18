local Setup = {
	-- Note: Due to how options are parsed, any new option added must be a string of exactly 3 or 4 characters long.
	options = {
		name = "",
		rte = "",
		lng = "",
		lic = "",
		dcs = "",
	},
	documents = {
		readme = "README.md",
		license = "LICENSE",
		ignore = ".gitignore",
	},
}

-- Read the command line options and parse them to get their values
function Setup.parse_args(self)
	for i = 1, #arg do
		local option = arg[i]
		local possible_opt = false
		if string.sub(option, 1, 2) == "--" then
			possible_opt = true
		end
		local symbol_idx = string.find(option, "=", 5, 7)
		if possible_opt and symbol_idx then
			local key = string.sub(option, 3, symbol_idx - 1)
			if self.options[key] then
				self.options[key] = string.sub(option, symbol_idx + 1, -1)
			end
		end
	end
end

-- Validate the received values for each option
function Setup.validate_opts_values(self)
	print("")
end

-- Create the documents according to the parsed options
function Setup.create_base_documents(self)
	print("")
end

-- Modify the created documents according to the parsed options
function Setup.write_in_documents(self)
	print("")
end

function Setup.show_opts_values(self)
	for key, value in pairs(self.options) do
		print(key .. " = " .. value)
	end
end

function Setup.init (self)
	self.parse_args(self)
	self.show_opts_values(self)
end


Setup:init()


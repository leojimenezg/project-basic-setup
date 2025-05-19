local Setup = {
	-- Note: Due to how options are parsed, any new option added must be a string of exactly 3 or 4 characters long.
	options = { name = "", rte = "", lng = "", lic = "", dcs = "" },
	default_values = { name = "project", rte = "./", lng = "lua", lic = "mit", dcs = "all" },
	documents = { readme = "README.md", license = "LICENSE", ignore = ".gitignore" },
	languages = { python = "py", lua = "lua", cpp = "cpp", markdown = "md", java = "java", javascript = "js"},
	licenses = {mit = "MIT", gpl = "GPL", apache = "APACHE" },
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

-- Check if a string is empty or blank (spaces, tabs, new lines, etc)
function Setup.is_string_empty_blank(self, str)
	if str == nil or str == "" then
		return true
	end
	local cleaned = string.gsub(str, "%s", "")
	if string.len(cleaned) < 1 then
		return true
	end
	return false
end

-- Check the value of each option, if it's empty or blank set it a default value
function Setup.check_opts_values(self)
	for key, value in pairs(self.options) do
		if self.is_string_empty_blank(self, value) then
			self.options[key] = self.default_values[key]
		end
	end
end

-- Create the documents according to the parsed options
function Setup.create_base_documents(self)
	print("")
end

-- Modify the created documents according to the parsed options
function Setup.write_in_documents(self)
	print("")
end

-- Print the value of each option unordered (mainly for debugging)
function Setup.show_opts_values(self)
	for key, value in pairs(self.options) do
		print(key .. " = " .. value)
	end
end

-- Entry point to call subsequent functions to perform each necessary step.
function Setup.init(self)
	self.parse_args(self)
	self.check_opts_values(self)
	self.show_opts_values(self)
end


Setup:init()


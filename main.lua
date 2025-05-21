local Setup = {
	-- Note: Due to how options are parsed, any new option added must be a string of exactly 3 or 4 characters long.
	options = { name = "", rte = "", lng = "", lic = "", dcs = "" },
	default_values = { name = "project", rte = "./", lng = "lua", lic = "mit", dcs = "all" },
	languages = { python = "py", lua = "lua", cpp = "cpp", markdown = "md", java = "java", javascript = "js" },
	licenses = {mit = "MIT", gpl = "GPL", apache = "APACHE" },
	documents = { readme = "README.md", license = "LICENSE", ignore = ".gitignore", all = "all" },
}

-- Parses command-line arguments to extract options and their respective values.
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

-- Checks if a string is empty or consists only of whitespace characters.
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

-- Validates if a given value is recognized as valid anywhere across the defined tables.
-- Warning: This check does NOT ensure the value is appropriate for the specific option it's assigned to.
-- Example: "--lng=all" passes if "all" is a globally valid value, even if "--lng" specifically expects a language code.
function Setup.is_value_allowed(self, value)
	for lng, _ in pairs(self.languages) do
		if lng == value then
			return true
		end
	end
	for lic, _ in pairs(self.licenses) do
		if lic == value then
			return true
		end
	end
	for doc, _ in pairs(self.documents) do
		if doc == value then
			return true
		end
	end
	return false
end

-- Validates each option's value and assigns a default if it's missing or invalid.
function Setup.check_opts_values(self)
	for key, value in pairs(self.options) do
		if self.is_string_empty_blank(self, value) then
			self.options[key] = self.default_values[key]
		elseif key ~= "name" and key ~= "rte" then
			if not self.is_value_allowed(self, value) then
				self.options[key] = self.default_values[key]
			end
		end
	end
end

-- Establishes the primary directory for the new project based on the provided path and name.
-- Warning: This function's directory creation logic is specifically designed for Unix-like operating systems.
function Setup.create_project_dir(self)
	local base_path = self.options["rte"]
	local project_name = self.options["name"]
	local full_path = ""
	if string.sub(base_path, -1, -1) == "/" then
		full_path = base_path .. project_name
	else
		full_path = base_path .. "/" .. project_name
	end
	-- Quotes are used to properly handle paths containing spaces.
	local command = 'mkdir -p "' .. full_path .. '"'
	os.execute(command)
end

function Setup.create_base_documents(self)
	print("")
end

function Setup.write_in_documents(self)
	print("")
end

-- Prints the value of each option (mainly for debugging).
function Setup.show_opts_values(self)
	print("\n")
	for key, value in pairs(self.options) do
		print(key .. " = " .. value)
	end
	print("\n")
end

-- Entry point to call subsequent functions to perform each necessary step.
function Setup.init(self)
	self.parse_args(self)
	self.check_opts_values(self)
	self.show_opts_values(self)
	self.create_project_dir(self)
end


Setup:init()


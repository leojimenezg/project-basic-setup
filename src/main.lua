-- Checks if a string is empty or consists only of whitespace characters.
local function is_string_empty_or_blank(str)
	if str == nil or str == "" then
		return true
	end
	local clean_str = str:gsub("%s", "")
	if clean_str:len() < 1 then
		return true
	end
	return false
end

local Setup = {
	-- Note: Due to how options are parsed, any new option added must be a string of exactly 3 characters long.
	options = { nme = "", rte = "", lng = "", lic = "", dcs = "" },
	default_values = { name = "new-project", rte = "./", lng = "lua", lic = "mit", dcs = "all," },
	languages = { python = "py", lua = "lua", cpp = "cpp", c = "c", go = "go" },
	licenses = { mit = "mit", apache = "apache" },
	documents = { readme = "README.md", license = "LICENSE", ignore = ".gitignore", all = "all" },
	dcs_iterator_symbol = ',',
}

--[[
Parses command-line arguments to extract options and their respective values.
The parsing of each argument is based on specific positions, considering that a
valid argument has a total length of 6 characters: "--arg=", excluding its value.
]]
function Setup.parse_args(self)
	if #arg < 1 then return false end
	for i = 1, #arg do
		local full_arg = arg[i]
		local is_possible = false
		if full_arg:sub(1, 2) == "--" then
			is_possible = true
		end
		local value_indicator = full_arg:sub(6, 6)
		if is_possible and value_indicator == '=' then
			local arg_name = full_arg:sub(3, 5)
			if self.options[arg_name] then
				self.options[arg_name] = full_arg:sub(7, -1)
			end
		end
	end
	return true
end

 --[[
Validates if a given value is recognized as valid in its corresponding table.
The search process is based on the available options. Also, the validation of the
"dcs" option value is different from the others as it can accept multiple values.
]]
function Setup.is_value_allowed(self, option, value)
	if option == "lng" then
		if self.languages[value] == nil then
			return false
		end
	elseif option == "lic" then
		if self.licenses[value] == nil then
			return false
		end
	else
		--Add a "dcs_iterator_symbol" at the end for a proper format if needed.
		if value:sub(-1, -1) ~= self.dcs_iterator_symbol then
			value = value .. self.dcs_iterator_symbol
		end
		local start = 1
		local symbol_idx = value:find(self.dcs_iterator_symbol, start)
		while symbol_idx do
			local val = value:sub(start, symbol_idx - 1)
			if self.documents[val] == nil then
				return false
			end
			if symbol_idx + 1 > #value then
				break
			end
			start = symbol_idx + 1
			symbol_idx = value:find(self.dcs_iterator_symbol, start)
		end
	end
	return true
end

--[[
Goes through each option's value, validates if its allowed using the
"is_value_allowed" function. It assigns a default value to an option if
its value is missing or not allowed.
--]]
function Setup.check_opts_values(self)
	for option, value in pairs(self.options) do
		if is_string_empty_or_blank(value) then
			self.options[option] = self.default_values[option]
		elseif option ~= "nme" and option ~= "rte" then
			if not self:is_value_allowed(option, value) then
				self.options[option] = self.default_values[option]
			end
		end
	end
	return true
end

--[[
Creates the full project path based on the values of "rte" and "nme" options.
Warning: Path specifically designed for Unix-like OS.
]]
function Setup.create_project_path(self)
	local base_path = self.options["rte"]
	local project_name = self.options["nme"]
	if base_path:sub(-1, -1) ~= '/' then
		base_path = base_path .. '/'
	end
	return base_path .. project_name .. '/'
end

--[[
Creates the main project directory and subdirectories (/src, /tests, /assets/imgs, /assets/data)
using mkdir commands. Handles paths with blank spaces using quotes in the command.
Warning: Uses Unix-like commands (mkdir -p).
]]
function Setup.create_project_directories(self)
	local project_path = self:create_project_path()
	local commands = {
		'mkdir -p "' .. project_path .. '"',
		'mkdir "' .. project_path .. '/src"',
		'mkdir "' .. project_path .. '/tests"',
		'mkdir "' .. project_path .. '/assets"',
		'mkdir "' .. project_path .. '/assets/imgs"',
		'mkdir "' .. project_path .. '/assets/data"',
	}
	for i = 1, #commands do
		os.execute(commands[i])
	end
end

--[[
Reads the template file content and returns it as a table of strings.
Templates path: "./templates/{template_name}.txt".
License path: "./templates/license/{self.options["lic""]}.txt".
Returns nil if file cannot be opened.
]]
function Setup.get_template_content(self, template_name)
	local template_path = "./templates/" .. template_name
	if template_name == "license" then
		 template_path = template_path .. self.options["lic"]
	end
	template_path = template_path .. ".txt"
	local template_file = io.open(template_path, 'r')
	if template_file == nil then return nil end
	local template_content = {}
	for line in template_file:lines() do
		template_content:insert(line)
	end
	template_file:close()
	return template_content
end

--[[
Creates a file at the specified path and writes the template content to it.
Uses the "get_template_content" function to fetch the content.
Returns early if template content fetch or file creation fails.
]]
function Setup.create_and_write_file(self, file_path, file_name)
	local template_content = self:get_template_content(file_name)
	local file = io.open(file_path, "w")
	if template_content == nil or file == nil then return end
	for line in template_content do
		file:write(line)
		file:write("\n")
	end
	file:close()
end

-- Generates core project documents based on the provided configurations.
-- This process executes in three distinct phases:
-- 1. Primary File Creation: Creates a main source file. Creation is skipped if the language provided is not supported.
-- 2. Single Document Creation: Creates a single, specified document. Creation is skipped if the document is not supported.
-- 3. Complete File Creation: Creates all the supported project files, only if provided by the configuration.
function Setup.create_project_docs(self)
	local path = self.create_project_path(self)
	local full_path
	local main_file_language = self.languages[self.options["lng"]]
	if main_file_language then
		local main_file = "main." .. main_file_language
		full_path = path .. main_file
		local command = 'touch "' .. full_path .. '"'
		os.execute(command)
	end
	local dcs_value = self.options["dcs"]
	if dcs_value ~= "all" then
		local document_name = self.documents[document]
		if document_name then
			full_path = path .. document_name
			self.create_and_write_file(self, full_path, document_name)
			return true
		else
			return false
		end
	end
	for document, document_name in pairs(self.documents) do
		if document ~= "all" then
			full_path = path .. document_name
			self.create_and_write_file(self, full_path, document)
		end
	end
	return true
end

function Setup.show_options(self)
	for key, value in pairs(self.options) do
		print(key .. " -> " .. value)
	end
end

-- Entry point to call subsequent functions to perform each necessary step.
function Setup.init(self)
	self:parse_args()
	self:check_opts_values()
	self:create_project_directories()
	--[[
	self.create_project_docs(self)
	print("Your Project Basic Setup is ready!")
	]]
end


Setup:init()

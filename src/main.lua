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
Beware: The "dcs" value is converted into a table where the keys are the multiple values.
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
		--Add a "dcs_iterator_symbol" at the end to properly format it.
		if value:sub(-1, -1) ~= self.dcs_iterator_symbol then
			value = value .. self.dcs_iterator_symbol
		end
		local start = 1
		local symbol_idx = value:find(self.dcs_iterator_symbol, start)
		local dcs_value_table = {}
		while symbol_idx do
			local iteration_value = value:sub(start, symbol_idx - 1)
			if self.documents[iteration_value] == nil then
				return false
			end
			dcs_value_table[iteration_value] = true
			if symbol_idx + 1 > #value then
				break
			end
			start = symbol_idx + 1
			symbol_idx = value:find(self.dcs_iterator_symbol, start)
		end
		self.options["dcs"] = dcs_value_table
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
License path: "./templates/license/{self.options["lic"]}."txt".
Returns nil if file cannot be opened.
]]
function Setup.get_template_content(self, template_name)
	local template_path = "./templates/" .. template_name
	if template_name == "license" then
		 template_path = template_path .. '/' ..self.options["lic"]
	end
	template_path = template_path .. ".txt"
	local template_file = io.open(template_path, 'r')
	if template_file == nil then return nil end
	local template_content = {}
	for line in template_file:lines() do
		table.insert(template_content, line)
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
	local file = io.open(file_path, 'w')
	if template_content == nil or file == nil then return end
	for i = 1, #template_content do
		file:write(template_content[i])
		file:write('\n')
	end
	file:close()
end

--[[
Creates main source file and project documents based on "dcs" configuration.
Creates all documents if "all" is specified, otherwise only the specified ones.
]]
function Setup.create_project_docs(self)
	local path = self.create_project_path(self)
	--Main file.
	local main_file_path = path .. "/src/main." .. self.languages[self.options["lng"]]
	os.execute('touch "' .. main_file_path .. '"')
	--Extra files.
	local extra_files = self.options["dcs"]
	if type(extra_files) ~= "table" then return end
	if extra_files["all"] == nil then
		for file, _ in pairs(extra_files) do
			local file_path = path .. self.documents[file]
			self:create_and_write_file(file_path, file)
		end
		return
	end
	for file, _ in pairs(self.documents) do
		if file ~= "all" then
			local file_path = path .. self.documents[file]
			self:create_and_write_file(file_path, file)
		end
	end
end

-- Entry point to call subsequent functions to perform each necessary step.
function Setup.init(self)
	self:parse_args()
	self:check_opts_values()
	self:create_project_directories()
	self:create_project_docs()
	print("Your Project Basic Setup is ready!")
end


Setup:init()

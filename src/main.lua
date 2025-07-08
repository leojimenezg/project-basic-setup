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
	default_values = { name = "new-project", rte = "./", lng = "lua", lic = "mit", dcs = "all" },
	languages = { python = "py", lua = "lua", cpp = "cpp", c = "c", go = "go" },
	licenses = { mit = "mit", apache = "apache" },
	documents = { readme = "README.md", license = "LICENSE", ignore = ".gitignore", all = "all" },
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
TODO: Update function logic.
Validates if a given value is recognized as valid anywhere across the defined tables.
Warning: This check does NOT ensure the value is appropriate for the specific option
it's assigned to. Example: "--lng=all" passes if "all" is a globally valid value,
even if "--lng" specifically expects a language name.
]]
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

--[[
Goes through each option's value, validates if its allowed using the
"is_value_allowed" function. It assigns a default value to an option if
its value is missing or not allowed.
--]]
function Setup.check_opts_values(self)
	for option, value in pairs(self.options) do
		if is_string_empty_or_blank(value) then
			self.options[option] = self.default_values[option]
			--Skip to next iteration.
			goto continue
		end
		if option ~= "name" and option ~= "rte" then
			if not self.is_value_allowed(self, value) then
				self.options[option] = self.default_values[option]
			end
		end
		--Label to skip iteration code.
		::continue::
	end
	return true
end

--[[
Creates the full project path based on the provided path and name, and
makes a format validation.
Warning: This function is specifically designed for Unix-like OS.
]]
function Setup.create_project_path(self)
	local base_path = self.options["rte"]
	local project_name = self.options["name"]
	local full_path
	if base_path:sub(-1, -1) == '/' then
		full_path = base_path .. project_name .. '/'
	else
		full_path = base_path .. '/' .. project_name .. '/'
	end
	return full_path
end

--[[
Creates the main project directory and all the project directories
based on the created project path using "mkdir -p" command.
]]
function Setup.create_project_dir(self)
	local project_path = self.create_project_path(self)
	-- Quotes are used to properly handle paths containing spaces.
	local command = 'mkdir -p "' .. project_path .. '"'
	os.execute(command)
	return true
end

--[[
Reads the content of the specified template file and returns its
lines as a table. If it fails, returns nil.
]]
function Setup.get_template_content(self, template_name)
	local template_path = "./templates/" .. template_name .. ".txt"
	local template = io.open(template_path, 'r')
	if template ~= nil then
		local content = {}
		for line in template:lines() do
			if line:find("[project-name-placeholder]", 1, true) then
				line = "# " .. self.options["name"]:gsub("[-_]", ' ')
			end
			table.insert(content, line)
		end
		template:close()
		return content
	end
	return nil
end

-- Generates and writes the specified file with the retrieved template content.
function Setup.create_and_write_file(self, file_path, file_name)
	local template_content
	if file_name == "license" then
		local license_name = file_name .. '/' .. self.options["lic"]
		template_content = self.get_template_content(self, license_name)
	else
		template_content = self.get_template_content(self, file_name)
	end
	local file = io.open(file_path, "w")
	for i = 1, #template_content do
		file:write(template_content[i])
		file:write("\n")
	end
	return true
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
	self:show_options()
	self:check_opts_values()
	--[[
	self.create_project_dir(self)
	self.create_project_docs(self)
	print("Your Project Basic Setup is ready!")
	]]
end


Setup:init()

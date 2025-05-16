local Setup = {
	valid_options = {"--name", "--rte", "--lng", "--lcs", "--dcs"},
	project_name = "",
	project_route = "",
	project_language = "",
	project_license = "",
	project_documents = {},

	-- Read the command line options and parse them
	parse_args = function (self)
		for i=1, #arg do
			print(arg[i])
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
}

Setup:parse_args()
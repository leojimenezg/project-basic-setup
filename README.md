# Project Basic Setup

A Lua script designed to automate and streamline new project setup, quickly generating directory structures and base files from configurable templates.

---

## Installation

To get this project up and runnig on your local machine, follow the next instructions.

### Prerequisites
Before anything else, make sure you have installed **Lua 5.x.x** or a newer version in your system.

### Steps
1. **Clone the repository:**
Open your prefered terminal and clone the project to your local machine.
    ```bash
    git clone https://github.com/LeoJimenezG/project-basic-setup.git
    ```
2. **Navigate into the project directory:**
    ```bash
    cd project-basic-setup
    ```
3. **Run the Application**
Finally, execute the main script to launch the Project Basic Setup Program.
    ```bash
    lua main.lua --name=my-project --rte=./ --lng=lua --lic=mit --dcs=all
    ```

---

## How Does It Work?

**Important:** Please review the supported options and their values in detail. Understanding these is crucial for properly configuring the script to generate your basic project setup.

This script sets up your new project through a three-phase process. While the core setup is largely automated, the initial phase relies entirely on your input through the command line.

1. **User Input and Argument Provision:** This first phase is completely up to you. You'll provide the necessary arguments, ensuring they're correctly formatted and valid according to the script.
2. **Argument Parsing and Initial Setup (Automatic):** The script automatically parses your provided arguments. It then uses this information to begin generating the basic project structure and files.
3. **Templated Document and Directory Generation (Automatic):** Building on the parsed arguments, the script proceeds to automatically create the specified project documents and directory structures based on its internal logic and your given configuration.

To tailor the script's output to your specific needs, you'll work with **five distinct options**, each requiring a valid value:

### Provided Options
**Note:** All options have default values. If you don't specify an option or provide an unsupported value, its default will be used. Be aware that default settings might not be optimal for all project types.

* `--name`: Sets your project's name. It supports spaces, hyphens (-), and underscores (_), but must be enclosed in quotes if it contains spaces.
    * Examples:
        ```bash
        --name=my-project-name

        --name="my project name"
        ```
* `--rte`: Specifies the creation path for your project's directory. You can provide a full absolute path or a relative path (e.g., ./). Any non-existent parent directories in the path will be automatically created. And the presence or absence of a trailing slash (e.g., /) does not affect its functionality. It also supports spaces, hyphens (-), and underscores (_), but must be enclosed in quotes if it contains spaces.
    * Examples:
        ```bash
        --rte=./

        --rte="users/my_user/new dir/other-dir/projects"
        ```
* `--lng`: Defines the project's primary programming language. This only affects the creation of the main source file (e.g., main.py, main.cpp).
    * Examples:
        ```bash
        --lng=python

        --lng=cpp
        ```
* `--lic`: Specifies the project's license to be generated. This is a templated file, and it's the only document type that supports different template versions (e.g., MIT, Apache 2.0).
    * Examples:
        ```bash
        --lic=mit

        --lic=apache
        ```
* `--dcs`: Determines which auxiliary documents to generate. You can specify a single document type or generate all supported types. These are template-based files, each with only one available template version, excepting the license.
    * Examples:
        ```bash
        --dcs=ignore

        --dcs=all
        ```

### Provided Option Values
**Note:** Only three of the five available options require specific, predefined values. Using unsupported values for these options will lead to unexpected or unusable project setups.

* `--lng`: Accepts five predefined language values. You can easily add more by modifying the script's configuration.
    * ***python***
    * ***lua***
    * ***cpp***
    * ***java***
    * ***javascript***
* `--lic`: Supports two predefined license types. To add more, you'll need to modify the script's configuration and create a corresponding template file.
    * ***mit***
    * ***apache***
* `--dcs`: Accepts four predefined document types. You can easily extend this by modifying the script's configuration and adding new template files for documents with a single template version.
    * ***readme***
    * ***license***
    * ***ignore***
    * ***all***

### Default Option Values
**Note:** These default values are applied automatically when an option is either not specified during script execution or provided with an unsupported value.

* `--name`: ***project***
* `--rte`: ***./***
* `--lng`: ***lua***
* `--lic`: ***mit***
* `--dcs`: ***all***

---

## Script Configuration

This script is primarily optimized for its predefined options and values. While implementing significantly different behavior would require substantial code changes, certain parts are designed for easy modification.

This section focuses exclusively on these areas, guiding you on how to extend or adjust the script's options and features while preserving its core purpose.

### Options Configuration
* The `options` table, located within the `Setup` object, allows you to easily add new command-line options. The script will parse these new options just like the predefined ones. However, any new options you add **must be a string of exactly 3 or 4 characters** (e.g., `num`, `user`). Keep in mind that adding an option here only makes it available for parsing, you'll need to write additional code to implement its specific behavior within the script.
    * Example:
        ```lua
        local Setup = {
            options = { name = "", rte = "", lng = "", lic = "", dcs = "", user = "" }, -- Example: "user" option added
        }

        function Setup.work_with_new_opt(self)
            print(self.options["user"])
        end
        ```
* Related to the `options` table, the `default_values` table (also within the `Setup` object) is where you can modify the default value assigned to each option. Crucially, any new options you add to the `options` table **must also have a corresponding default value** defined here. Always ensure that the default values you set are valid and compatible with the script's intended logic.
    * Example:
        ```lua
        local Setup = {
            default_values = { name = "project", rte = "./", lng = "lua", lic = "mit", dcs = "all", user = "me" }, -- Example: "user" default added
        }
        ```
### Languages Configuration
* The `languages` table, found within the `Setup` object, lets you easily add new programming language extensions. These extensions are used when generating the main project file. You can add as many languages as you need without requiring any further script changes. Just make sure the language extension is correct and follows the proper format.
    * Example:
        ```lua
        local Setup = {
            languages = { python = "py", lua = "lua", cpp = "cpp", java = "java", javascript = "js", go = "go" }, -- Example: "go" language added
        }
        ```
### Documents Configuration
**Note:** All templates used for document generation must have the `.txt` extension.
* The `documents` table, located within the `Setup` object, allows you to easily add new project documents for generation. For each new document, the option name must be the **template name** (without its extension), and its assigned value must be the **exact output filename** (including its extension) that the file will be generated with. Remember to also place the corresponding template file inside the `./templates` project directory.
    * Example:
        ```lua
        local Setup = {
            documents = { readme = "README.md", license = "LICENSE", ignore = ".gitignore", all = "all", script = "my_script.sh" }, -- Example: "script" document added
        }

        -- Inside "./templates" place your template file
        -- Example: "./templates/script.txt"
        ```
### Licences Configuration
**Note:** All templates used for license generation must have the `.txt` extension and must be placed inside the `./templates/license` project directory.
* The `licenses` table, found within the `Setup` object, allows you to easily add new project licenses for generation. Unlike the **Documents Configuration**, here the key for each new license **must be the exact template filename** (without its `.txt` extension), corresponding to the template file in your `/templates/license` directory. The assigned value (e.g., `"MIT"`, `"GPL"`) is typically used for internal referencing or display, as the generated license file will always be named `LICENSE`. Remember to place the corresponding template file inside the `./templates/license` project directory.
    * Example:
        ```lua
        local Setup = {
            licenses = { mit = "MIT", apache = "APACHE", gpl = "GPL" }, -- Example: "gpl" license added
        }

        -- Inside "./templates/license" place your license template file
        -- Example: "./templates/license/gpl.txt"
        ```
---

## Notes

---

## Useful Resources


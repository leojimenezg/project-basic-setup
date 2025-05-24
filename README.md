# Project Basic Setup

A Lua script designed to automate and streamline new project setup, quickly generating directory structures and base files from configurable templates.

---

## Installation

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
        --name=my_project_name

        --name=my-project-name

        --name="my project name"
        ```
* `--rte`: Specifies the creation path for your project's directory. You can provide a full absolute path or a relative path (e.g., ./). Any non-existent parent directories in the path will be automatically created. And the presence or absence of a trailing slash (e.g., /) does not affect its functionality. It also supports spaces, hyphens (-), and underscores (_), but must be enclosed in quotes if it contains spaces.
    * Examples:
        ```bash
        --rte=./

        --rte=users/user/documents/projects/

        --rte=users/user/new_dir/other_dir/projects
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
        --dcs=license

        --dcs=ignore

        --dcs=all
        ```

### Provided Option Values
**Note:** Only three of the five available options require specific, predefined values. Using unsupported values for these options will lead to unexpected or unusable project setups.

* `--lng`: Accepts five predefined language values. You can easily add more by modifying the script's configuration.
    * *python*
    * *lua*
    * *cpp*
    * *java*
    * *javascript*
* `--lic`: Supports two predefined license types. To add more, you'll need to modify the script's configuration and create a corresponding template file.
    * *mit*
    * *apache*
* `--dcs`: Accepts four predefined document types. You can easily extend this by modifying the script's configuration and adding new template files for documents with a single template version.
    * *readme*
    * *license*
    * *ignore*
    * *all*

### Default Option Values
**Note:** These default values are applied automatically when an option is either not specified during script execution or provided with an unsupported value.

* `--name`: **project**.
* `--rte`: **./**.
* `--lng`: **lua**.
* `--lic`: **mit**.
* `--dcs`: **all**.

---

## Script Configuration

---

## Template Configuration

---

## Notes

---

## Useful Resources


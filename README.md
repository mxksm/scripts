# Quality of Life Scripts

## pdf

The ```pdf.zsh``` script helps open pdf files using Sioyek: appends ```.pdf``` at the end so it doesn't have to be specified, opens the ```main.pdf``` file by default if none specified.

## work

`work` is a CLI written in Python designed to eliminate the friction of managing academic documents.
It automates the scaffolding, state-tracking, and launching of Typst projects (homework, problem sessions, and lecture notes), and only launching for latex.

It is built specifically for a terminal-centric workflow, seamlessly integrating with **Neovim**, **Sioyek**, and **Typst's native local package manager**.

## Features

* **Smart Scaffolding (`init`):** Automatically locates course directories using fuzzy pattern matching (e.g., `525` finds `CS525`).
* **State-Aware Auto-Incrementing:** Intelligently checks previous assignments and creates the next logical folder (e.g., finds `hw02`, creates `hw03`).
* **Native Typst Templates:** Fully drops legacy file-copying and regex-parsing in favor of `typst init @local/...` for robust, multi-file template generation.
* **Regex-Free Variable Injection:** Dynamically generates a `meta.typ` file during initialization to pass metadata (course names, homework numbers).
* **Universal Opener (`open`):** A decoupled execution environment that can open specific course workflows or any random directory on your machine, instantly launching Neovim, compiling the document, and opening Sioyek in the background.
* **Highly Extensible:** Adding a new document type (like "exams" or "research papers") can be done by adding a new entry to the `WORKFLOWS` dictionary and creating new templates.

---

## Setup & Installation

### 1. Configure the Python Script

Place the `work` script anywhere in your `$PATH` and ensure it is executable. Update the `semester_path` variable inside the script to point to your current university directory.

### 2. Set Up Local Typst Templates
This script relies on Typst's `@local` namespace.
On macOS, this is located at `~/Library/Application Support/typst/packages/local`.

**Option A: Clone My Templates (Fastest)**
You can directly clone my pre-configured templates into your local Typst packages directory. 
```bash
# Clear the local folder if it exists, then clone the repository
rm -rf ~/Library/Application\ Support/typst/packages/local
git clone https://github.com/mxksm/typst-templates ~/Library/Application\ Support/typst/packages/local
```
The script dynamically generates ```hw-num``` and ```course``` variables upon creation. To use them, simply import the ```meta.typ``` file in one of the template files.

**Option B: Create Your Own Templates**
If you prefer to build your own, create a directory for your template (e.g., `my-hw/0.1.0/`) inside the local Typst packages folder. You must include a `typst.toml` manifest and a `template/` folder containing your `main.typ` and any support files.
To fully utilize the script, incorporate ```hw-num``` and ```course``` variables defined in the ```meta.typ```.

---

## Usage

### Scaffold a New Project (`init`)
Creates a new project directory, pulls your Typst template, injects the metadata, and instantly opens the environment.

```bash
# Create the next homework for a course matching "525"
work init 525

# Create a specific workflow type (hw, pso, notes)
work init -t notes 580
```

### Open an Existing Project (`open`)
Intelligently finds the target, opens the `main.typ` (or `main.tex`) in Neovim, and fires off a background Zsh compilation/PDF job.

```bash
# Open the latest homework for CS525
work open 525

# Open the lecture notes for CS581
work open -t notes 581

# Open the current directory as a project
work open .

# Open a specific path and open a new window of Sioyek
work open -wd ~/Downloads/some-repo
```

### Help
Use the `-h` flag to see dynamically generated help text based on your current configured workflows:

```bash
work -h
work init -h
work open -h
```

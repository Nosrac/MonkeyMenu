# MonkeyMenu
A developer tool to create searchable, hierarchical menus.

# Menus
- Menus are created from a zipped directory containing at least one file:  menu.json
- menu.json is a JSON representation of your menu, containing its name and a command which will output its children
- PWD/CWD contains all of the files in your zipped directory.  It is a sandboxed folder for your menu.  Feel free to read/write to this directory for caching and other purposes

# Menu API - JSON
- menu.json
	name: string

	// This command is expected to return a JSON-encoded array of *items*
	
	children_cmd: string

# Items
- *Items* are the centerpiece to Commander
- Each *item* has a title
- [Optional] Children menus (via bash command)
- [Optional] Actions

# Items API - JSON
- Output from a bash command
	name: string

	// This command is expected to return a JSON-encoded array of *items*
	
	children_cmd: string

	actions: array of *actions*

	preload_children: bool // Default = false

# Actions
- Each action has a name and can perform multiple tasks
- Run bash command
- Copy text to clipboard
- Open file
- Dismiss (close menu after running)
- Open *item*
- Child actions (include a sub menu of actions)
- In addition, separators can be used

# Actions API - JSON
- Included in *items*
	name: string

	// The following values are optional:
	
	child_actions: array of actions
	dismiss: bool // Hide Commander after running action?

	// Each performed task is run in the following order:
	
	confirmation_message: string // If 'Cancel' is clicked, the action is aborted
	
	cmd: string // Runs this CLI command
	
	copy: string // Copies this string to the user's clipboard
	
	open: string // Opens this file/URL for the user
	
	open_item: object of an item. //  This item's children are displayed

# API
- Commands should return JSON
- Commands are run, PWD is a persistent read-write directory


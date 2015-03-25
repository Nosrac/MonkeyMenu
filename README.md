# MonkeyMenu
A developer tool to create searchable, hierarchical menus.

# Menus
- Menus are *Items* that you can open
- The items displayed are the results of running the item's *children_cmd*
- Stored on disk as a JSON representation of your *item*

# Items
- *Items* are the centerpiece to Commander
- Each *item* has a title
- [Optional] Children menus (via bash command)
- [Optional] Actions

# Actions
- Each action has a name and can perform multiple tasks
- Run bash command
- Copy text to clipboard
- Open file
- Dismiss (close menu after running)
- Open *item*
- Child actions (include a sub menu)
- In addition, separators can be used


### API
- Commands should return JSON
- Commands are run, PWD is a persistent read-write directory

# Items
	name: string
	
	# This command is expected to return a JSON-encoded array of items
	children_cmd: string
	
	actions: array of actions
	
	preload_children: bool # Default = false

# Actions
	name: string

	# The following tasks are optional:
	child_actions : array of actions
	dismiss: bool # Hide Commander after running action?
	
	# Each performed task is run in the following order:

	confirmation_message: string # If 'Cancel' is clicked, the action is aborted
	cmd: string # Runs this CLI command
	copy: string # Copies this string to the user's clipboard
	open: string # Opens this file/URL for the user
	open_item: object of an item.  This item's children are displayed

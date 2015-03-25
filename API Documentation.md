### Commander Documentation

# Items
- Items the centerpiece to Commander
- Each item has a title
- [Optional] CLI command to get child items
- [Optional] Actions

# Actions
- Actions are performed on *items*
- Each action has a name and can perform multiple tasks
- Run CLI Command
- Copy Text to Clipboard
- Open File
- Dismiss (close Commander after running)
- Open Item
- In addition, dividers can be included
- Additionally, actions can also have child actions

# Libraries
- Libraries are *Items* that you can open
- The items displayed come from the *children_cmd* value
- Stored on disk as a JSON representation of your *item*


### API
- Commands should return JSON
- Commands are run, PWD is a persistent read-write directory

# Items
{
	name: string
	
	# This command is expected to return a JSON-encoded array of items
	children_cmd: string
	
	actions: array of actions
	
	preload_children: bool # Default = false
}

# Actions
{
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
}
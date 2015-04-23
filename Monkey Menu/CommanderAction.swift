//
//  CommanderSet.swift
//  Commander
//
//  Created by Kyle Carson on 12/21/14.
//  Copyright (c) 2014 Kyle Carson. All rights reserved.
//

import Cocoa
import Foundation

struct CommanderActionContext {
	let item : CommanderItem
	let itemViewController : CommanderItemViewController
}

class CommanderAction : NSObject , Printable {
	let name : String;
	
	let shellCommand : String?
	let copyString : String?
	let text : String?
	let dismiss : Bool
	let confirmationMessage : String?
	let open : String?
	let keystroke : String?
	let separator : Bool
	let alternate : Bool
	
	let openItem : CommanderItem?
	let childActions : [ CommanderAction ]
	
	
	convenience init? ( jsonString : String )
	{
		let json = JSON( string: jsonString )
		
		self.init( json: json )
	}
	
	convenience init? ( json : JSON )
	{
		let dict = json.asDictionary
		if dict == nil
		{
			Log.error("Invalid action: Invalid JSON")
			self.init(values: Dictionary())
			return nil
		}
		
		var actions : [ CommanderAction ] = []
		if let actionsJSON = json["child_actions"].asArray
		{
			for actionJSON in actionsJSON
			{
				if let action = CommanderAction(json: actionJSON)
				{
					actions.append( action )
				}
			}
		}
		
		let openItem : CommanderItem?
		if let item = json["open_item"].asDictionary
		{
			openItem = CommanderItem(json: json["open_item"])
		} else {
			openItem = nil
		}
		
		self.init(values: [
			"name" : json["name"].asString,
			"cmd" : json["cmd"].asString,
			"copy" : json["copy"].asString,
			"confirmation_message" : json["confirmation_message"].asString,
			"open" : json["open"].asString,
			"keystroke" : json["keystroke"].asString,
			"dismiss" : json["dismiss"].asBool,
			"separator" : json["separator"].asBool,
			"child_actions" : actions,
			"open_item" : openItem,
			"alternate" : json["alternate"].asBool
			]);
	}
	
	init? ( values : [ String : AnyObject? ] )
	{
		var error = false
		
		if let cmd = values["cmd"] as? String
		{
			self.shellCommand = cmd
		} else {
			self.shellCommand = nil
		}
		
		if let copy = values["copy"] as? String
		{
			self.copyString = copy
		} else {
			self.copyString = nil
		}
		
		if let text = values["text"] as? String
		{
			self.text = text
		} else {
			self.text = nil
		}
		
		if let keystroke = values["keystroke"] as? String
		{
			self.keystroke = keystroke
		} else {
			self.keystroke = nil
		}
		
		if let open = values["open_item"] as? CommanderItem
		{
			self.openItem = open
		} else {
			self.openItem = nil
		}
		
		if let dismiss = values["dismiss"] as? Bool
			where self.openItem == nil
		{
			self.dismiss = dismiss
		} else {
			self.dismiss = false
		}
		
		if let confirm = values["confirmation_message"] as? String
		{
			self.confirmationMessage = confirm
		} else {
			self.confirmationMessage = nil
		}
		
		if let file = values["open"] as? String
		{
			self.open = file
		} else {
			self.open = nil
		}
		
		if let separator = values["separator"] as? Bool
		{
			self.separator = separator
		} else {
			self.separator = false
		}
		
		if let actions = values["child_actions"] as? [CommanderAction]
		{
			self.childActions = actions
		} else {
			self.childActions = []
		}
		
		if let alternate = values["alternate"] as? Bool
		{
			self.alternate = alternate
		} else {
			self.alternate = false
		}
		
		if let aName = values["name"] as? String
		{
			name = aName
		} else {
			if self.separator
			{
				name = ""
			} else {
				error = true
				Log.error("Invalid Action: No Name")
				name = "[Unnamed Action]"
			}
		}
		
		super.init()
		if error
		{
			return nil
		}
	}
	
	func run( context : CommanderActionContext )
	{
		if self.separator
		{
			return;
		}
		
		if let confirm = confirmationMessage
		{
			let alert = NSAlert()
			alert.messageText = confirm
			alert.addButtonWithTitle("OK")
			alert.addButtonWithTitle("Cancel")
			
			if alert.runModal() != NSAlertFirstButtonReturn
			{
				return
			}
		}
	
		self.tryRunCommand(context)
		self.tryCopy(context)
		self.tryShowText(context)
		self.tryOpen(context)
		self.tryOpenItem( context )
		
		if self.dismiss
		{
			NSApplication.sharedApplication().hide(self)
			NSApplication.sharedApplication().unhide(self)
		}
	}
	
	func tryOpen ( context: CommanderActionContext )
	{
		if let file = self.open
		{
			let workspace = NSWorkspace.sharedWorkspace()
			
			if let range = file.rangeOfString("http", options: .allZeros),
				url = NSURL(string: file)
				where range.startIndex == file.startIndex
			{
				
				workspace.openURL( url )
			} else {
				workspace.openFile(file)
			}
		}
	}
	
	func tryCopy ( context: CommanderActionContext )
	{
		if let copy = self.copyString
		{
			Clipboard.copy( copy )
		}
	}
	
	func tryShowText ( context : CommanderActionContext )
	{
		if let text = self.text
		{
			if let window = context.itemViewController.view.window
			{
				let firstLine = text.componentsSeparatedByString("\n").first
				let alert = NSAlert()
				alert.informativeText = text
				alert.messageText = firstLine
				alert.beginSheetModalForWindow(window, completionHandler: { (response) -> Void in

				})
			}
		}
	}
	
	func tryRunCommand ( context: CommanderActionContext )
	{
		if let cmd = self.shellCommand
		{
			let cli = CommandLine()
			if let dir = context.item.directory()
			{
				cli.currentDirectory = dir
			}
			cli.runCommandAsync(cmd)
		}
	}
	
	func tryOpenItem( context : CommanderActionContext )
	{
		
		if let item = self.openItem
		{
			item.parent = context.item
			context.itemViewController.pushItem( item )
		}
	}
	
	func keystrokeMask () -> Int
	{
		var mask : UInt = 0
		if let keystroke = self.keystroke?.lowercaseString
		{
			let characterSet = NSCharacterSet.alphanumericCharacterSet().invertedSet
			var pieces = keystroke.componentsSeparatedByCharactersInSet(characterSet)
			pieces.removeLast()
			
			for option in pieces
			{
				if option == "cmd" || option == "command"
				{
					mask = mask | NSEventModifierFlags.CommandKeyMask.rawValue
				}
				if option == "alt" || option == "opt" || option == "option"
				{
					mask = mask | NSEventModifierFlags.AlternateKeyMask.rawValue
				}
				if option == "ctrl" || option == "control"
				{
					mask = mask | NSEventModifierFlags.ControlKeyMask.rawValue
				}
				if option == "shift" || option == "sh"
				{
					mask = mask | NSEventModifierFlags.ShiftKeyMask.rawValue
				}
				if option == "function" || option == "fn"
				{
					mask = mask | NSEventModifierFlags.FunctionKeyMask.rawValue
				}
			}
		}
		
		return Int(mask)
	}
	
	func keystrokeKey() -> String?
	{
		var key : String?
		if let keystroke = self.keystroke?.lowercaseString
		{
			let characterSet = NSCharacterSet.alphanumericCharacterSet().invertedSet
			var pieces = keystroke.componentsSeparatedByCharactersInSet(characterSet)
			
			if let lastPiece = pieces.last
			{
				key = lastPiece
			}
		}
		return key
	}
}
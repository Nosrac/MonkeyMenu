//
//  CommanderSet.swift
//  Commander
//
//  Created by Kyle Carson on 12/21/14.
//  Copyright (c) 2014 Kyle Carson. All rights reserved.
//

import Cocoa
import Foundation

class CommanderItem : NSObject , Printable {
	let name : String;
	var parent : CommanderItem?
	var file : String?
	
	let childrenCommand : String?
	let preloadChildren : Bool
	
	var actions : [CommanderAction]
	
	convenience init?( file aFile : String )
	{
		let jsonString : NSString
		if let data = NSData(contentsOfFile: aFile)
		{
			if let string = NSString(data: data, encoding: NSUTF8StringEncoding)
			{
				jsonString = string
				Log.success("Opened \(aFile)")
			} else {
				jsonString = ""
				
				Log.error("Couldn't read \(aFile)")
			}
			
		} else {
			jsonString = "";
			Log.error("Couldn't open \(aFile)")
		}
		
		self.init( jsonString: (jsonString as! String) );
		self.file = aFile
	}
	
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
			Log.error("Invalid Item: Invalid JSON")
			self.init(values: Dictionary())
			return nil
		}
		var actions : [CommanderAction] = []
		if let someActions = json["actions"].asArray
		{
			for someAction in someActions
			{
				if let action = CommanderAction(json: someAction)
				{
					actions.append(action)
				}
			}
		}
		
		self.init(values: [
			"name" : json["name"].asString,
			"children_cmd" : json["children_cmd"].asString,
			"actions" : actions,
			"preload_children" : json["preload_children"].asBool
			]);
	}
	
	init? ( values : [ String : AnyObject? ] )
	{
		var error = false;
		if let aName = values["name"] as? String
			where aName.length > 0
		{
			name = aName
		} else {
			error = true;
			Log.error("Invalid Item: No name")
			name = "[Error]"
		}
		if let cmd : String = values["children_cmd"] as? String
		{
			childrenCommand = cmd
		} else {
			childrenCommand = nil
		}
		
		if let someActions : [CommanderAction] = values["actions"] as? [CommanderAction]
			where someActions.count > 0
		{
			self.actions = someActions
		} else {
			self.actions = [];
		}
		
		if let preloadChildren = values["preload_children"] as? Bool
		{
			self.preloadChildren = preloadChildren
		} else {
			self.preloadChildren = false
		}
		
		super.init()
		
		if (error)
		{
			return nil
		}
	}
	
	var childrenCache : [CommanderItem]?
	
	func getChildren( callback : ( items : [CommanderItem]) -> () )
	{
		Async.background
		{
			var children = self.children
			
			callback( items: children )
		}
	}
	
	func hasChildren() -> Bool
	{
		if let children = childrenCommand
		{
			return true
		}
		return false
	}
	
	var isLoadingChildren = false
	
	var children : [ CommanderItem ]
	{
		while isLoadingChildren
		{
			// Wait
		}
		
		if let childrenCache = childrenCache
		{
			return childrenCache
		}
		
		isLoadingChildren = true
		
		var children : [ CommanderItem ] = [ ]
		if let cmd = childrenCommand
		{
            let cli = CommandLine();
            if let dir = self.directory()
            {
                cli.currentDirectory = dir
            }
            let output = cli.runCommand(cmd)
			if let output = output
				where output.length > 0
			{
				let json = JSON( string: output )
				
				for( i, child ) in json
				{
					if let aChild = CommanderItem(json: child)
					{
						children.append( aChild )
					}
				}
				
				Log.info("\(self) returned \(children.count) children (\(cmd))")
			} else {
				Log.error("\(self)'s children_cmd did not return output.  Expected JSON (\(cmd))")
			}
		}
		
		for (child) in children
		{
			child.parent = self
		}
		
		childrenCache = children
		
		isLoadingChildren = false
		
		return children
	}
	
	func directory() -> String?
	{
        if let file = self.file
        {
            return file.stringByDeletingLastPathComponent
        }
        if let parent = self.parent
        {
            return parent.directory()
        }
		return nil
	}
	
	func primaryAction() -> CommanderAction?
	{
		return actions.first
	}
	
	override var description: String {
		return String(format: "<\(name)>", arguments: [])
	}
}

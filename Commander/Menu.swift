//
//  Menu.swift
//  Monkey Menu
//
//  Created by Kyle Carson on 3/25/15.
//  Copyright (c) 2015 Kyle Carson. All rights reserved.
//

import Cocoa

class Menu : NSObject
{
	let uuid : String
	
	var info : [String:AnyObject] = [:]
	
	var directory : String
	{
		return LibraryManager.dirForIdentifier(self.uuid)
	}
	
	var userDirectory : String
	{
		return self.directory + "user.monkeymenu/"
	}
	
	var libraryFile : String
	{
			return self.userDirectory + "library.json"
	}
	
	var preferencesFile : String
	{
		return self.userDirectory + "preferences.plist"
	}
	
	var originalDirectory : String
	{
		return self.directory + "original.monkeymenu/"
	}
	lazy var item: CommanderItem? =
	{
		return CommanderItem(file: self.libraryFile)
	}()
	
	lazy var desc : String? =
	{
		if let desc = self.info["desc"] as? String
		{
			return desc
		}
		return nil
	}()
	
	init?( identifier: String )
	{
		let dir = LibraryManager.dirForIdentifier(uuid)
		if NSFileManager.defaultManager().fileExistsAtPath(dir)
		{
			self.identifier = identifier
			
			self.info["author"] = "Kyle C"
			self.info["url"] = "http://google.com"
			self.info["desc"] = "Lists a bunch of files and lets you perform actions on them.\n-Copy filepaths\n-Commit files\n-Open files\n-etc"
			
			self.info["identifier"] = ""
			self.info["version"] = ""
			
			self.info["min_commander_version"] = ""
			self.info["max_commander_version"] = ""
			
			super.init()
		} else {
			self.identifier = ""
			super.init()
			return nil
		}
	}
	
	var preferences : NSDictionary
	{
		set
		{
			newValue.writeToFile(self.preferencesFile, atomically: true)
		}
		get
		{
			let file = self.directory + "preferences.json"
			
			var preferences : [ String : AnyObject ] = [:]
			
			if NSFileManager.defaultManager().fileExistsAtPath(file)
			{
				let error = NSErrorPointer()
				if let dictionary = NSDictionary(contentsOfFile: file)
				{
					return dictionary
				}
			}
			
			return preferences
		}
	}
	
	var title : String
	{
		if let item = self.item
		{
			var title = item.name
			
			if let author = self.info["author"] as? String
			{
				title = "\(title) by \(author)"
			}
			
			return title
		}
		return "<Unnamed Menu>"
	}
}

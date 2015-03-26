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
	
	var directory : String
	{
		return LibraryManager.dirForUUID(self.uuid)
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
	
	init?( uuid: String )
	{
		let dir = LibraryManager.dirForUUID(uuid)
		if NSFileManager.defaultManager().fileExistsAtPath(dir)
		{
			self.uuid = uuid
			super.init()
		} else {
			self.uuid = ""
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
}

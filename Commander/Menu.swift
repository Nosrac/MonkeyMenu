//
//  Menu.swift
//  Monkey Menu
//
//  Created by Kyle Carson on 3/25/15.
//  Copyright (c) 2015 Kyle Carson. All rights reserved.
//

import Cocoa

class Menu
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
		} else {
			self.uuid = ""
			return nil
		}
	}
	
	
}

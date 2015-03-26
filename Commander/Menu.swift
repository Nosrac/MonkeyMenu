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
	
	var preferences : [ String : AnyObject ]
	{
		set
		{
			let file = self.directory + "preferences.json"
			
		}
		get
		{
			let file = self.directory + "preferences.json"
			
			var preferences : [ String : AnyObject ] = [:]
			
			if NSFileManager.defaultManager().fileExistsAtPath(file)
			{
				let error = NSErrorPointer()
				if let string = String(contentsOfFile: file, encoding: NSASCIIStringEncoding, error: error)
				{
					let json = JSON( string )
					if let dictionary = json.asDictionary
					{
						for (key, valJson) in dictionary
						{
							if let int = valJson.asInt
							{
								preferences[key] = int
							} else if let double = valJson.asDouble
							{
								preferences[key] = double
							} else if let string = valJson.asString
							{
								preferences[key] = string
							}
						}
					}
				}
			}
			
			return preferences
		}
	}
}

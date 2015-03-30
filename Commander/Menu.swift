//
//  Menu.swift
//  Monkey Menu
//
//  Created by Kyle Carson on 3/25/15.
//  Copyright (c) 2015 Kyle Carson. All rights reserved.
//

import Cocoa

struct MenuInfo
{
	let name : String
	let desc : String
	
	let author : String
	let url : NSURL
	
	let identifier : String
	
	let version : Double
	
	let min_version : Double?
	let max_version : Double?
}

class Menu : NSObject
{
	let info : MenuInfo
	
	var directory : String
	{
		return LibraryManager.dirForIdentifier(self.info.identifier)
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
	
	static func infoForMenuFile( file : String ) -> MenuInfo?
	{
		let infoFile = file + "/library.json"
		
		let error = NSErrorPointer()
		if let string = NSString( contentsOfFile: infoFile, encoding: NSUTF8StringEncoding, error: error) as? String,
			json = JSON( string: string ).asDictionary
		{
			let name = json["name"]?.asString
			let desc = json["desc"]?.asString
			
			let urlString = json["url"]?.asString
			let author = json["author"]?.asString
			
			let identifier = json["identifier"]?.asString
			let version = json["version"]?.asDouble
			
			let min_version = json["min_version"]?.asDouble
			let max_version = json["max_version"]?.asDouble
			
			if let name = name, urlString = urlString, desc = desc, identifier = identifier, version = version, author = author, url = NSURL(string: urlString)
			{
				return MenuInfo(name: name, desc: desc, author: author, url: url, identifier: identifier, version: version, min_version: min_version, max_version: max_version)
			}
		}
		
		return nil
	}
	
	static func errorForMenuFile( file: String ) -> String?
	{
		if !NSFileManager.defaultManager().fileExistsAtPath(file)
		{
			return "Menu file doesn't exist"
		} else if !file.endsWith(".monkeymenu")
		{
			return "File isn't a monkey menu"
		} else if !NSFileManager.defaultManager().fileExistsAtPath(file + "/library.json")
		{
			return "Menu doesn't contain library.json"
		} else if self.infoForMenuFile(file) == nil {
			return "Menu didn't contain correct fields.  Requires: name, url, desc, identifier, and version"
		}
		
		return nil
	}
	
	init?( identifier: String )
	{
		let dir = LibraryManager.dirForIdentifier(identifier)
		let file = dir + "/user.monkeymenu"
		
		let error = Menu.errorForMenuFile(file)
		if let info = Menu.infoForMenuFile(file)
			where error == nil
		{
			self.info = info
			super.init()
		} else {
			self.info = MenuInfo(name: "", desc: "", author: "", url: NSURL(string: "http://google.com")!, identifier: "", version: 0, min_version: nil, max_version: nil)
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
		return "\(self.info.name) by \(self.info.author)"
	}
}

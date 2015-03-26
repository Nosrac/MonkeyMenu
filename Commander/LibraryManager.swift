//
//  LibraryManager.swift
//  Commander
//
//  Created by Kyle Carson on 3/23/15.
//  Copyright (c) 2015 Kyle Carson. All rights reserved.
//

import Foundation
import Cocoa

class LibraryManager
{
	static var libraryWindows : [NSWindow] = []
	static var menus : [ Menu ] = []
	static func loadLibraries()
	{
		var items : [Menu] = []
		
		let error = NSErrorPointer()
		
		let contents = self.manager.contentsOfDirectoryAtPath(self.librariesDirectory, error: error)
		
		if let contents = contents
		{
			for uuid : String in contents as! [String]
			{
				if let menu = Menu(uuid: uuid)
				{
					menus.append(menu)
					self.openWindow(menu)
				}
			}
		}
		
		self.menus = items
	}
	
	static var window : NSWindow?
	
	static func open()
	{
		if let storyboard = NSStoryboard(name: "Library Manager", bundle: nil),
			controller = storyboard.instantiateInitialController() as? NSWindowController,
			window = controller.window
		{
			self.window = window
			window.makeKeyAndOrderFront(nil)
		}
	}
	
	static func createDirectory(file : String)
	{
		let error : NSErrorPointer = NSErrorPointer()
		
		self.manager.createDirectoryAtPath(file, withIntermediateDirectories: true, attributes: nil, error: error)
	}
	static var baseDirectory : String {
		let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.ApplicationSupportDirectory, .UserDomainMask, true)
		let appSupprt = paths.first! as! String
		
		let base = appSupprt + "/Monkey Menu/"
		
		self.createDirectory(base)
		
		return base
	}
	static var librariesDirectory : String {
		let libs = self.baseDirectory + "/Libraries/"
		self.createDirectory(libs)
		return libs
	}
	static func newDirectory() -> String
	{
		let uuid = NSUUID().UUIDString
		var dir = self.librariesDirectory + "/" + uuid + "/"
		
		self.createDirectory(dir);
		
		return dir
	}
	
	static func openWindow(menu : Menu)
	{
		if let storyboard = NSStoryboard(name: "Main", bundle: nil),
			windowController = storyboard.instantiateInitialController() as? NSWindowController,
			window = windowController.window,
			controller = window.contentViewController as? CommanderItemViewController,
			item = menu.item
		{
			self.window = window
			window.makeKeyAndOrderFront(nil)
			
			window.title = item.name
			controller.menuLibrary = menu
			
			self.libraryWindows.append( window )
		}
	}
	
	static var manager : NSFileManager
	{
		return NSFileManager.defaultManager()
	}
	
	static func checkMenuFile(file: String) -> Bool
	{
		var error : String?
		
		if !NSFileManager.defaultManager().fileExistsAtPath(file)
		{
			error = "Menu doesn't exist"
		}
		if !file.endsWith(".monkeymenu")
		{
			error = "Menu isn't a monkey menu"
		}
		if !NSFileManager.defaultManager().fileExistsAtPath(file + "/library.json")
		{
			error = "Menu doesn't contain library.json"
		}
		
		if let error = error
		{
			Log.error("Attempted to install menu \(file.lastPathComponent): \(error)")
			return false
		} else {
			return true
		}
	}
	
	static func installLibrary(file : String, openWindow: Bool = false)
	{
		if !self.checkMenuFile(file)
		{
			return
		}
		
		let uuid = NSUUID().UUIDString
		
		var dir = self.dirForUUID(uuid)
		
		if let menu = Menu(uuid:uuid)
		{
			var error = NSErrorPointer()
			
			self.manager.copyItemAtPath(file, toPath: menu.userDirectory, error: error)
			self.manager.copyItemAtPath(file, toPath: menu.originalDirectory, error: error)
			
			if openWindow
			{
				self.openWindow( menu )
			}
		}
	}
	
	static func tempDir() -> String
	{
		let uuid = NSUUID().UUIDString
		
		var dir = "/tmp/" + uuid + "/"
		
		self.createDirectory(dir)
		
		return dir
	}
	
	static func dirForUUID(uuid : String) -> String
	{
		let dir = self.librariesDirectory + uuid + "/"
		
		self.createDirectory(dir)
		
		return dir
	}
	
	
}
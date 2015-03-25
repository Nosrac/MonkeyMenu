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
	static var libraries : [ CommanderItem ] = []
	static func loadLibraries()
	{
		var items : [CommanderItem] = []
		
		let error = NSErrorPointer()
		
		let contents = self.manager.contentsOfDirectoryAtPath(self.librariesDirectory, error: error)
		
		if let contents = contents
		{
			for file : String in contents as! [String]
			{
				var itemFile = self.librariesDirectory + "/" + file + "/user/library.json"
				
				if self.manager.fileExistsAtPath(itemFile)
				{
					if let item = CommanderItem(file: itemFile)
					{
						items.append(item)
						self.openWindow(item)
					}
				}
			}
		}
		
		self.libraries = items
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
		
		let base = appSupprt + "/com.kyleacarson.Commander/"
		
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
		var dir = self.librariesDirectory + "/+" + uuid + "/"
		
		self.createDirectory(dir);
		
		return dir
	}
	
	static func openWindow(file : String)
	{
		if self.manager.fileExistsAtPath(file)
		{
			if let item = CommanderItem(file: file)
			{
				self.openWindow(item)
			}
		}
	}
	
	static func openWindow(item : CommanderItem)
	{
		if let storyboard = NSStoryboard(name: "Main", bundle: nil),
			windowController = storyboard.instantiateInitialController() as? NSWindowController,
			window = windowController.window,
			controller = window.contentViewController as? CommanderItemViewController
		{
			self.window = window
			window.makeKeyAndOrderFront(nil)
			
			window.title = item.name
			controller.pushItem( item )
			
			self.libraryWindows.append( window )
		}
	}
	
	static var manager : NSFileManager
	{
		return NSFileManager.defaultManager()
	}
	
	static func installLibrary(file : String) -> String?
	{
		if file.endsWith(".commander-library") && NSFileManager.defaultManager().fileExistsAtPath(file)
		{
			var dir = self.newDirectory()
			var userdir = dir + "/user/"
			
			var error = NSErrorPointer()
			self.manager.removeItemAtPath(userdir, error: error)
			
			var cli = CommandLine()
			cli.runCommand("/usr/bin/unzip", arguments: [file, "-d", userdir])
			
			if !self.manager.fileExistsAtPath(userdir)
			{
				Log.error("Failed to unzip library \(file)", category: nil)
				return nil
			}
			
			self.cleanInstalledLibrary(userdir)
			
			let libraryFile = userdir + "library.json"
			
			if !self.manager.fileExistsAtPath(libraryFile)
			{
				return nil;
			}
			
			self.manager.copyItemAtPath(file, toPath: dir + "/original.commander-library", error: error)
			
			return libraryFile
		}
		Log.error("Failed to open library \(file)", category: nil)
		return nil;
	}
	
	static func tempDir() -> String
	{
		var dir = "/tmp/" + NSUUID().UUIDString + "/"
		
		self.createDirectory(dir)
		
		return dir
	}
	
	static func cleanInstalledLibrary(userdir : String)
	{
		let error = NSErrorPointer()
		if let items = self.manager.contentsOfDirectoryAtPath(userdir, error: error)
		
		// Fix archives zipped by OS X
		where items.count == 2 && items.first! as! String == "__MACOSX"
		{
			let realContents = userdir + "/" + (items.last as! String)
			if let realItems = self.manager.contentsOfDirectoryAtPath(realContents, error: error)
			{
				var temp = self.tempDir()
				
				var cli = CommandLine()
				cli.runCommand("/bin/cp", arguments: ["-R", realContents + "/", temp])
				self.manager.removeItemAtPath(userdir, error: error)
				self.manager.copyItemAtPath(temp, toPath: userdir, error: error);
				self.manager.removeItemAtPath(temp, error: error)
			}
		}
	}
	
	
}
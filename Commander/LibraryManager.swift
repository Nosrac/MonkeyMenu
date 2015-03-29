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
		let error = NSErrorPointer()
		
		let contents = self.manager.contentsOfDirectoryAtPath(self.librariesDirectory, error: error)
		
		if let contents = contents
		{
			for identifier : String in contents as! [String]
			{
				if let menu = Menu(identifier: identifier)
				{
					self.addMenu(menu)
				}
			}
		}
	}
	
	static var window : NSWindow?
	
	static func open()
	{
		if self.window == nil
		{
			if let storyboard = NSStoryboard(name: "Library Manager", bundle: nil),
				controller = storyboard.instantiateInitialController() as? NSWindowController,
				window = controller.window
			{
				self.window = window
			}
		}
		
		if let window = self.window
		{
			window.makeKeyAndOrderFront(nil)
		}
	}
	
	static func createDirectory(file : String)
	{
		let error : NSErrorPointer = NSErrorPointer()
		
		self.manager.createDirectoryAtPath(file, withIntermediateDirectories: true, attributes: nil, error: error)
	}
	
	static var baseDirectory : String
	{
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
		if let error = Menu.errorForMenuFile(file)
		{
			Log.error("Attempted to install menu \(file.lastPathComponent): \(error)")

			return false
		}
		return true
	}
	
	static func installLibrary(file : String, openWindow: Bool = false)
	{
		if !self.checkMenuFile(file)
		{
			return
		}
		
		let identifier = NSUUID().UUIDString
		
		var dir = self.dirForIdentifier(identifier)
		self.createDirectory(dir)
		
		if let menu = Menu(identifier:identifier)
		{
			var error = NSErrorPointer()
			
			self.manager.copyItemAtPath(file, toPath: menu.userDirectory, error: error)
			self.manager.copyItemAtPath(file, toPath: menu.originalDirectory, error: error)
			
			if openWindow
			{
				self.openWindow( menu )
			}
			
			self.addMenu(menu)
		}
	}
	
	static func uninstallMenu( menu : Menu )
	{
		if let url = NSURL.fileURLWithPath( menu.directory)
		{
			let error = NSErrorPointer()
			if ( self.manager.trashItemAtURL(url, resultingItemURL: nil, error: error) )
			{
				self.menus.removeObject( menu )
				NSNotificationCenter.defaultCenter().postNotificationName(self.menusDidChangeEvent, object: nil)
			}
		}
	}
	
	static func dirForIdentifier(identifier : String) -> String
	{
		let dir = self.librariesDirectory + identifier + "/"
		
		return dir
	}
	
	static func openWindowMenu() -> NSMenu
	{
		let menu = NSMenu()
		
		for aMenu in self.menus
		{
			if let item = aMenu.item
			{
				let action = CapturedTargetAction
					{
						self.openWindow(aMenu)
				}
				let menuitem = NSMenuItem(title: "\(item.name) Menu", action: action.action, keyEquivalent: "")
				menuitem.target = action
				
				menu.addItem(menuitem)
			}
		}
		
		return menu
	}
	
	static let menusDidChangeEvent = "MenuDidChangeEvent"
	
	static func addMenu (menu : Menu)
	{
		self.menus.append( menu )
		
		NSNotificationCenter.defaultCenter().postNotificationName(self.menusDidChangeEvent, object: nil)
	}
	
}
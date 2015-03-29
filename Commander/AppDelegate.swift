//
//  AppDelegate.swift
//  Commander
//
//  Created by Kyle Carson on 12/21/14.
//  Copyright (c) 2014 Kyle Carson. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
	
	@IBOutlet var newWindowMenu : NSMenuItem?
	@IBOutlet var openMenusWindowMenu : NSMenuItem?

	func applicationDidFinishLaunching(aNotification: NSNotification) {
		
		
	}
	
	func watchMenuChanges()
	{
		let callback = CapturedTargetAction
			{
				self.newWindowMenu?.submenu = LibraryManager.openWindowMenu()
		}
		NSNotificationCenter.defaultCenter().addObserver(callback, selector: callback.action, name: LibraryManager.menusDidChangeEvent, object: nil)
	}
	
	func openLog()
	{
		Log.openLog()
	}
	
	func setupViewMenusMenu()
	{
		if let item = self.openMenusWindowMenu
		{
			let callback = CapturedTargetAction
			{
				LibraryManager.open()
			}
			
			item.target = callback
			item.action = callback.action
		}
	}
	
	var libraryManager : NSWindow?
	
	func applicationWillFinishLaunching(notification: NSNotification) {
		
		self.watchMenuChanges()
		self.setupViewMenusMenu()
		
		if let
			window : NSWindow = NSApplication.sharedApplication().windows.first as? NSWindow
		{
			window.close()
		}
		
		LibraryManager.loadLibraries()
		LibraryManager.open()
		
	}

	func applicationWillTerminate(aNotification: NSNotification) {
		// Insert code here to tear down your application
	}
	
	func application(sender: NSApplication, openFiles filenames: [AnyObject])
	{
		for file in filenames as! [String]
		{
			LibraryManager.installLibrary(file, openWindow: true)
		}
	}

}


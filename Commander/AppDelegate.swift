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

	func applicationDidFinishLaunching(aNotification: NSNotification) {
	}
	
	var libraryManager : NSWindow?
	
	func applicationWillFinishLaunching(notification: NSNotification) {

		LibraryManager.loadLibraries();
		
		LibraryManager.open()
		
		if let
			window : NSWindow = NSApplication.sharedApplication().windows.first as? NSWindow
		{
			window.close()
			

		}
	}

	func applicationWillTerminate(aNotification: NSNotification) {
		// Insert code here to tear down your application
	}



}


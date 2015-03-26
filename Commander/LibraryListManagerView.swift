//
//  LibraryListManager.swift
//  Commander
//
//  Created by Kyle Carson on 3/15/15.
//  Copyright (c) 2015 Kyle Carson. All rights reserved.
//

import Cocoa

class LibraryListManagerView: NSViewController, NSTableViewDelegate {

	@IBOutlet var addButton : NSButton?
	
    override func viewDidLoad() {
		super.viewDidLoad()
		
		if let button = self.addButton
		{
			button.target = self
			button.action = "openAddButtonMenu"
		}
    }
	func openAddButtonMenu()
	{
		if let button = self.addButton,
			window = self.view.window
		{
			self.addButtonMenu.popUpMenuPositioningItem(nil, atLocation: NSEvent.mouseLocation(), inView: nil)
		}
	}
	
	func openLibrary()
	{
		let open = OpenPanel()
		open.canChooseDirectories = false
		open.allowedFileTypes = [ ".commander-library" ]
		
		open.beginWithCompletionHandler { (button : Int) -> Void in
			if let file = open.URL?.absoluteString
				where button == NSFileHandlingPanelOKButton
			{
				LibraryManager.installLibrary(file, openWindow: true)
			}
		}
	}
	
	var addButtonMenu : NSMenu
	{
		let menu = NSMenu(title: "Test")
		
		let new = NSMenuItem(title: "New", action: "newLibrary", keyEquivalent: "n")
		new.target = self
		
		menu.addItem(new)
		
		let open = NSMenuItem(title: "Open…", action: "openLibrary", keyEquivalent: "o")
		open.target = self
		
		menu.addItem(open)
		
		return menu
	}
}

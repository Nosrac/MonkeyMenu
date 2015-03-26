//
//  LibraryListManager.swift
//  Commander
//
//  Created by Kyle Carson on 3/15/15.
//  Copyright (c) 2015 Kyle Carson. All rights reserved.
//

import Cocoa

class LibraryListManagerView: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
	
	@IBOutlet var addButton : NSButton?
	@IBOutlet var table : NSTableView?
	
    override func viewDidLoad() {
		super.viewDidLoad()
		
		if let button = self.addButton
		{
			button.target = self
			button.action = "openAddButtonMenu"
		}
		
		self.setupTable()
    }
	
	func setupTable()
	{
		let callback = CapturedTargetAction
		{
			self.table?.reloadData()
		}
		NSNotificationCenter.defaultCenter().addObserver(callback, selector: callback.action, name: LibraryManager.menusDidChangeEvent, object: nil)
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
	
	func numberOfRowsInTableView(tableView: NSTableView) -> Int
	{
		return LibraryManager.menus.count
	}
	
	func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject?
	{
		return LibraryManager.menus[row]
	}
	
	func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat
	{
		return 32.0
	}
}

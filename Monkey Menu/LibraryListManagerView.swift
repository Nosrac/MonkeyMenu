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
		if let table = self.table
		{
			let reloadCallback = CapturedTargetAction
			{
				table.reloadData()
			}
			NSNotificationCenter.defaultCenter().addObserver(reloadCallback, selector: reloadCallback.action, name: LibraryManager.menusDidChangeEvent, object: nil)
			
			table.doubleAction = "openClickedMenuInWindow"
			table.target = self
		}
	}
	
	func openClickedMenuInWindow ()
	{
		if let menu = self.menu(self.table!.clickedRow)
		{
			LibraryManager.openWindow(menu)
		}
	}
	var selectedMenu : Menu?
	{
		return self.menu(self.table!.selectedRow)
	}
	func menu(row: Int) -> Menu?
	{
		let menu : Menu?
		if row >= 0 && row < LibraryManager.menus.count
		{
			menu = LibraryManager.menus[ row ]
		} else {
			menu = nil
		}
		return menu;
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
		open.allowedFileTypes = [ "monkeymenu" ]
		
		open.beginWithCompletionHandler { (button : Int) -> Void in
			if let file = open.URL?.absoluteString
				where button == NSFileHandlingPanelOKButton
			{
				LibraryManager.installLibrary(file, openWindow: true)
			}
		}
	}
	
	static let selectedMenuChangedEvent = "selectedMenuChangedEvent"
	
	func manageMenu( menu : Menu? )
	{
		NSNotificationCenter.defaultCenter().postNotificationName(LibraryListManagerView.selectedMenuChangedEvent, object: menu)
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
		return self.menu(row)
	}
	
	func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat
	{
		return 32.0
	}
	
	func tableViewSelectionDidChange(notification: NSNotification)
	{
		self.manageMenu( self.selectedMenu )
	}
}

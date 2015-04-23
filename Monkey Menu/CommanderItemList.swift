//
//  CommaderItemList.swift
//  Commander
//
//  Created by Kyle Carson on 12/23/14.
//  Copyright (c) 2014 Kyle Carson. All rights reserved.
//

import Cocoa

class CommanderItemList: ViewController, NSTableViewDataSource, NSTableViewDelegate {
	
	@IBOutlet var table : CommanderItemListView?
	var itemViewController : CommanderItemViewController?
	
	var items : [CommanderItem] = []{
		didSet {
			Async.main
			{
				self.table?.reloadData()
				
				if self.items.count > 0
				{
					self.table?.selectRowIndexes(NSIndexSet(index: 0), byExtendingSelection: false)
				}
				return
			}
		}
	}
	var selectedItem : CommanderItem? {
		if let row = self.table?.selectedRow where row >= 0 && row < items.count
		{
			return items[ row ]
		}
		return nil
	}
	
	func selectNextItem ()
	{
		let row = self.table!.selectedRow + 1
		if row < items.count
		{
			self.table?.selectRowIndexes(NSIndexSet(index: row), byExtendingSelection: false);
		}
	}
	
	func selectPreviousItem ()
	{
		let row = self.table!.selectedRow - 1
		if row >= 0
		{
			self.table?.selectRowIndexes(NSIndexSet(index: row), byExtendingSelection: false);
		}
	}

    override func viewDidLoad()
	{
        super.viewDidLoad()
		
		if let table = self.table
		{
			table.setDataSource(self)
			table.setDelegate(self)
			table.list = self
			
			if let controller = self.itemViewController
			{
				table.target = controller
				table.doubleAction = "performDefaultAction"
			}
		}
    }
	
	func numberOfRowsInTableView(tableView: NSTableView) -> Int {
		return items.count
	}
	
	func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject?
	{
		return items[row]
	}
	
	func tableViewSelectionDidChange(notification: NSNotification) {
		if let item = self.selectedItem
		{
			self.table?.scrollRowToVisible( self.table!.selectedRow )
			if item.preloadChildren
			{
				item.getChildren({ (items) -> () in
					// Done preloading
				})
			}
		}
	}
	
	override func keyDown(theEvent: NSEvent)
	{
		if let callback = keyDownTriggered
		{
			callback(item: self.selectedItem, event: theEvent)
			return
		}
		
		super.keyDown(theEvent)
	}
	
	var keyDownTriggered : ( ( item : CommanderItem?, event: NSEvent ) -> () )?
	
	func menuForItem (item : CommanderItem) -> NSMenu
	{
		let menu = NSMenu()
		
//		let title = NSMenuItem(title: item.name, action: "blah", keyEquivalent: "")
//		menu.addItem( title )
		
		for action in item.actions
		{
			menu.addItem( self.menuItemForAction(action, item: item) )
		}
		return menu
	}
	
	func menuItemForAction ( action : CommanderAction, item : CommanderItem ) -> NSMenuItem
	{
		let target = CapturedTargetAction
		{
			self.itemViewController?.performItemAction(item, action: action)
		}
		
		if action.separator
		{
			return NSMenuItem.separatorItem()
		}
		
		let menuitem = NSMenuItem()
		menuitem.title = action.name
		menuitem.target = target
		menuitem.action = target.action
		menuitem.alternate = action.alternate
		
		if (action.childActions.count > 0)
		{
			let submenu = NSMenu()
			
			for subaction in action.childActions
			{
				submenu.addItem( self.menuItemForAction(subaction, item: item) )
			}
			
			menuitem.submenu = submenu
		}
		
		if let key = action.keystrokeKey()
		{
			menuitem.keyEquivalent = key
			menuitem.keyEquivalentModifierMask = action.keystrokeMask()
		}
		
		return menuitem
	}
}

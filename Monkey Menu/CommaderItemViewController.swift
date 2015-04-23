//
//  CommaderItemViewController.swift
//  Commander
//
//  Created by Kyle Carson on 12/23/14.
//  Copyright (c) 2014 Kyle Carson. All rights reserved.
//

let CommanderItemKeyDefaultAction : UInt16 = 36; // New Line
let CommanderItemKeyPopItem : UInt16 = 53 // Escape

import Cocoa

struct CommanderLibraryState
{
	let item : CommanderItem
	let search : String
}

class CommanderItemViewController: ViewController, NSTextFieldDelegate
{
	@IBOutlet var searchbar : CommanderSearchField?
	@IBOutlet var loadingIndicator : NSProgressIndicator?
	
	
	var menuLibrary : Menu?
	{
		didSet {
			if let menu = self.menuLibrary,
				item = menu.item
			{
				self.pushItem(item)
			}
		}
	}
	
	var loading : Int = 0 {
		didSet {
			loadingChanged()
		}
	}
	
	func loadingChanged()
	{
		if (loading > 0)
		{
			Async.main(after: 0.2) {
				if (self.loading > 0)
				{
					self.loadingIndicator?.startAnimation(self)
				}
			}
		} else {
			Async.main {
				self.loadingIndicator?.stopAnimation(self)
			}
		}
	}
	
	var itemList : CommanderItemList? {
		didSet {
			itemList?.keyDownTriggered = performItemAction
		}
	}
	
	var items : [CommanderItem]?
	var searchItems : [CommanderItem]? {
		didSet {
			self.updateValues()
		}
	}
	
	var item : CommanderItem? {
		didSet {
			items = nil
			searchItems = nil

			self.updateValues()
		}
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		if let searchbar = self.searchbar
		{
			searchbar.canceledOperation = popItem
			searchbar.target = self
			searchbar.action = "performDefaultAction"
		}
	}
	
	func selectedItem() -> CommanderItem?
	{
		return itemList?.selectedItem
	}
	
	override func controlTextDidChange(obj: NSNotification)
	{
		updateSearch()
	}
	
	var filterQueue : CommanderItemFilterQueue?
	
	func updateSearch()
	{
		if count(searchbar!.stringValue) == 0
		{
			searchItems = nil
			return
		}
		
		if filterQueue == nil
		{
			filterQueue = CommanderItemFilterQueue
			{
				(items) in
				
				self.searchItems = items
			}
		}
		
		if let queue = filterQueue
		{
			var filter = CommanderItemFilter(items: self.children(allowSearch: false))
			filter.search = searchbar!.stringValue
			
			queue.addFilter(filter)
		}
		
	}
	
	override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?)
	{
		if (segue.identifier == "list_embed")
		{
			itemList = segue.destinationController as? CommanderItemList
			itemList?.itemViewController = self
		}
	}
	
	func children( allowSearch : Bool = true) -> [ CommanderItem ]
	{
		if let searchItems = searchItems where allowSearch
		{
			return searchItems
		}
		if let items = items
		{
			return items
		}
		if let item = item
		{
			loading = loading + 1
			
			items = item.children
			
			loading = loading - 1
			
			return items!
		}
		
		return []
	}
	
	func updateValues()
	{
		itemList?.items = self.children()
	}
	
	func performItemAction (item : CommanderItem, action: CommanderAction )
	{
		let context = CommanderActionContext( item: item, itemViewController : self)
		action.run( context )
	}
	
	func performDefaultAction ()
	{
		if let item = self.selectedItem()
		{
			self.performDefaultAction(item)
		}
	}
	
	func performDefaultAction (item : CommanderItem )
	{
		if item.hasChildren()
		{
			pushItem( item )
		} else {
			if let action = item.primaryAction()
			{
				self.performItemAction(item, action: action)
			} else {
				Log.error("Item has no children or actions")
			}
		}
	}
	
	func masksMatch(code: NSEventModifierFlags, mask : Int) -> Bool
	{
		if code.rawValue & UInt(mask) == UInt(mask)
		{
			return true
		}
		return false
	}
	
	func control(control: NSControl, textView: NSTextView, doCommandBySelector commandSelector: Selector) -> Bool
	{
		if commandSelector == "moveUp:"
		{
			itemList?.selectPreviousItem()
			return true;
		}
		if commandSelector == "moveDown:"
		{
			itemList?.selectNextItem()
			return true;
		}
		
		return false
	}
	
	func performItemAction (item : CommanderItem?, event : NSEvent)
	{
		if loading > 0
		{
			return
		}
		
		if let item = item
		where event.keyCode == CommanderItemKeyDefaultAction
		{
			self.performDefaultAction(item)
			return
		} else if event.keyCode == CommanderItemKeyPopItem {
			popItem()
			return
		}
		
		if let item = item
		{
			for action in item.actions
			{
				if let keyCode = action.keystrokeKey(),
					chars = event.characters
				where keyCode.lowercaseString == chars.lowercaseString &&
					self.masksMatch(event.modifierFlags, mask: action.keystrokeMask())
				{
					self.performItemAction(item, action: action)
					return
				}
			}
		}
		
		// If not pressing command / control / function / alt let's assume they were typing in the search box
		if event.modifierFlags & NSEventModifierFlags.CommandKeyMask == NSEventModifierFlags.allZeros &&
		event.modifierFlags & NSEventModifierFlags.ControlKeyMask == NSEventModifierFlags.allZeros &&
		event.modifierFlags & NSEventModifierFlags.FunctionKeyMask == NSEventModifierFlags.allZeros &&
		event.modifierFlags & NSEventModifierFlags.AlternateKeyMask == NSEventModifierFlags.allZeros
		{
			if let searchbar = searchbar,
				characters = event.charactersIgnoringModifiers
			{
				searchbar.stringValue = searchbar.stringValue.stringByAppendingString(characters)
				searchbar.becomeFirstResponder()
				
				if let editor = self.view.window?.fieldEditor(false, forObject: searchbar)
				{
					editor.selectedRange = NSMakeRange(count(searchbar.stringValue), 0)
				}
			}
		}
	}
	
	var stateStack : [CommanderLibraryState] = []
	
	func pushItem ( anItem : CommanderItem )
	{
		if !anItem.hasChildren()
		{
			NSBeep();
			return;
		}
		loading = loading + 1
		
		let search = self.searchbar?.stringValue
		self.searchbar?.stringValue = ""
		
		anItem.getChildren {
			(children) in
			
			if let item = self.item,
				search = search
			{
				let state = CommanderLibraryState(item: item, search: search)
				
				self.stateStack.append( state )
			}
			
			self.item = anItem
			
			self.loading = self.loading - 1
		}
	}
	
	func popItem()
	{
		if let string = self.searchbar?.stringValue
			where string.length > 0
		{
			self.searchbar!.stringValue = ""
			updateSearch()
			return
		}
		
		if stateStack.count <= 0
		{
			NSBeep();
			return
		}
		
		let state = stateStack.removeLast()
		
		self.item = state.item
		self.searchbar?.stringValue = state.search
		updateSearch()
	}
    
}

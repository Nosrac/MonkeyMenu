//
//  MenuManager.swift
//  Monkey Menu
//
//  Created by Kyle Carson on 3/26/15.
//  Copyright (c) 2015 Kyle Carson. All rights reserved.
//

import Cocoa

class MenuManager: NSViewController
{
	var item : Menu?
	{
		didSet
		{
			if let item = item
			{
				self.view.hidden = false
				self.descTextView?.string = item.desc
				self.headerTextView?.stringValue = item.title
			} else {
				
				self.view.hidden = true
			}
			
		}
	}
	
	@IBOutlet var headerTextView : NSTextField?
	@IBOutlet var descTextView : NSTextView?

    override func viewDidLoad()
	{
		super.viewDidLoad()
		
		self.view.hidden = true
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "selectedMenuChanged:", name: LibraryListManagerView.selectedMenuChangedEvent, object: nil)
    }
	
	func selectedMenuChanged ( event : NSNotification )
	{
		self.item = event.object as? Menu
	}
	
	func openNewWindowSelector () -> Selector
	{
		return "openNewWindow"
	}
	
	func openNewWindow()
	{
		if let item = self.item
		{
			LibraryManager.openWindow(item)
		}
	}
    
}

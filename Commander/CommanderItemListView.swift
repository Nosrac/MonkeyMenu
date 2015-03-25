//
//  CommanderItemListView.swift
//  Commander
//
//  Created by Kyle Carson on 2/25/15.
//  Copyright (c) 2015 Kyle Carson. All rights reserved.
//

import Foundation
import Cocoa

class CommanderItemListView : NSTableView
{
	var list : CommanderItemList?
	
	override func menuForEvent(event: NSEvent) -> NSMenu?
	{
		let point = self.convertPoint( event.locationInWindow, fromView: nil )
		let row = self.rowAtPoint( point )
		
		if let list = list
			where row >= 0
		{
			let item = list.items[row]
			
			return list.menuForItem( item )
		}
		
		return nil
	}
	
	
}
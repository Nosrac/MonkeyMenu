//
//  CommanderSearchField.swift
//  Commander
//
//  Created by Kyle Carson on 12/29/14.
//  Copyright (c) 2014 Kyle Carson. All rights reserved.
//

import Cocoa

class CommanderSearchField: NSTextField {
	
	override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
    }
	
	var canceledOperation : ( () -> () )?
	
	override func cancelOperation(sender: AnyObject?) {
		if let operation = canceledOperation
		{
			operation()
		}
	}
}

//
//  CommanderItemViewBackground.swift
//  Commander
//
//  Created by Kyle Carson on 12/29/14.
//  Copyright (c) 2014 Kyle Carson. All rights reserved.
//

import Cocoa

@IBDesignable class CommanderItemViewBackground: NSView {
	
	@IBInspectable var backgroundColor: NSColor?

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
		
		if let background = self.backgroundColor
		{
			background.set()
			NSRectFill(self.bounds)
		}
		
    }
}

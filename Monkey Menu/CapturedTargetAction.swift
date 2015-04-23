//
//  CapturedTargetAction.swift
//  Commander
//
//  Created by Kyle Carson on 2/25/15.
//  Copyright (c) 2015 Kyle Carson. All rights reserved.
//

import Cocoa
import Foundation

class CapturedTargetAction : NSObject
{
	static var allTargetActions : [ CapturedTargetAction ] = [ ]
	
	let cb : () -> Void
	
	/* Contains the Selector to use as an action */
	let action : Selector = "runCallback"
	
	init ( callback : () -> Void )
	{
		self.cb = callback
		
		// Do this so we don't fall out of memory
		super.init()
		CapturedTargetAction.allTargetActions.append( self )
	}
	
	func runCallback()
	{
		self.cb()
	}
}
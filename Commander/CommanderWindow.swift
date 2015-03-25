//
//  CommanderWindow.swift
//  Commander
//
//  Created by Kyle Carson on 3/1/15.
//  Copyright (c) 2015 Kyle Carson. All rights reserved.
//

import Foundation
import Cocoa

class CommanderWindow : NSWindow
{
	override var canBecomeKeyWindow : Bool {
		get {
			return true
		}
	}
	override var canBecomeMainWindow : Bool {
		get {
			return true
		}
	}
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
}
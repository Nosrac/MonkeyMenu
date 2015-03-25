//
//  OpenPanel.swift
//  Monkey Menu
//
//  Created by Kyle Carson on 3/25/15.
//  Copyright (c) 2015 Kyle Carson. All rights reserved.
//

import Cocoa

class OpenPanel: NSOpenPanel {
	
	override func beginWithCompletionHandler(handler: (Int) -> Void)
	{
		let args = NSProcessInfo.processInfo().arguments
		
		println(args)
	
		if let executable = args.first as? String
		where executable.contains("Build/Products/Debug/Monkey Menu.app")
		{
			handler(NSFileHandlingPanelCancelButton)
		} else {
			super.beginWithCompletionHandler(handler)
		}
	}
}

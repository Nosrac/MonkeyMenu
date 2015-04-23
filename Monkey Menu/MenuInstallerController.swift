//
//  MenuInstallerController.swift
//  Monkey Menu
//
//  Created by Kyle Carson on 4/5/15.
//  Copyright (c) 2015 Kyle Carson. All rights reserved.
//

import Foundation
import Cocoa

class MenuInstallerController : NSViewController
{
	static var storyboards : [NSStoryboard] = Array()
	static var windows : [NSWindow] = []
	
	var installingMenu : Menu?
	
	static func installMenu( menu: Menu)
	{
		if let storyboard = NSStoryboard(name: "MenuInstaller", bundle: nil),
			controller = storyboard.instantiateInitialController() as? NSWindowController,
			window = controller.window
		{
			self.storyboards.append(storyboard)
			self.windows.append(window)
			window.becomeKeyWindow()
			window.becomeMainWindow()
			println(window.title)
		}
	}
//	var installingMenu : Menu
//	init?(menu: Menu)
//	{
//		self.installingMenu = menu
//		
//		
//	}
//	
//	required init?(coder: NSCoder)
//	{
//		
//	}
}
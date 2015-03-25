//
//  MenuMaker.swift
//  Monkey Menu
//
//  Created by Kyle Carson on 3/25/15.
//  Copyright (c) 2015 Kyle Carson. All rights reserved.
//

import Cocoa

class MenuMaker
{
	static func createMenu(skeleton: String)
	{
		if let wrapper = NSFileWrapper(path: skeleton)
		{
			let open = OpenPanel()
			open.beginWithCompletionHandler({ (button) -> Void in
				if button != NSFileHandlingPanelOKButton
				{
					return;
				}
				
				let error = NSErrorPointer()
				if let url = open.URL
				{
					wrapper.writeToURL(url, options: NSFileWrapperWritingOptions.allZeros, originalContentsURL: nil, error: error)
				}
			})
		}
	}
}

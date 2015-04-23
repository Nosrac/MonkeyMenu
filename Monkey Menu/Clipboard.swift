//
//  Clipboard.swift
//  Monkey Menu
//
//  Created by Kyle Carson on 4/5/15.
//  Copyright (c) 2015 Kyle Carson. All rights reserved.
//

import Foundation
import Cocoa

class Clipboard
{
	static let pasteAppleScriptCode = "tell application \"System Events\" to keystroke \"v\" using {command down}"
	
	static var copiedText : String?
	{
		let pasteboard = NSPasteboard.generalPasteboard()
		if let item = pasteboard.pasteboardItems?.first as? NSPasteboardItem,
			string = item.stringForType(NSPasteboardTypeString)
		{
			return string
		}
		
		return nil
	}
	
	static func copy(string: String)
	{
		let pasteboard = NSPasteboard.generalPasteboard()
		
		let item = NSPasteboardItem(pasteboardPropertyList: string, ofType: NSPasteboardTypeString)
		
		pasteboard.clearContents()
		pasteboard.writeObjects([ item ])
	}
	
	static func paste( string : String, inBackground: Bool = true )
	{
		if inBackground
		{
			NSApplication.sharedApplication().hide(self)
			NSApplication.sharedApplication().unhide(self)
		}
		
		let copiedString = self.copiedText
		
		self.copy(string)
		if let applescript = NSAppleScript(source: self.pasteAppleScriptCode)
		{
			var err : AutoreleasingUnsafeMutablePointer<NSDictionary?> = AutoreleasingUnsafeMutablePointer()
			applescript.executeAndReturnError(err)
		}
		
		if let text = copiedString
		{
			Async.userInteractive(after: 0.1)
			{
				
				self.copy(text)
			}
		}
		
	}
}
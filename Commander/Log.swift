//
//  ErrorHandler.swift
//  Commander
//
//  Created by Kyle Carson on 3/5/15.
//  Copyright (c) 2015 Kyle Carson. All rights reserved.
//

import Foundation
import Cocoa

enum LogEntryType
{
	case Error, Info, Warning, Success
}

struct LogEntry : Printable
{
	let text : String
	let type : LogEntryType
	let category : String?
	let timestamp : NSDate = NSDate()
	
	static let ItemChildrenCommandFailed = "ItemChildrenCommandFailed"
	
	var description: String
	{
		get {
			return "[\(timestamp)] \(text)"
		}
	}
}

class Log
{
	static func addEntry( text : String, type: LogEntryType, category : String? = nil )
	{
		let entry = LogEntry(text: text, type: type, category: category, timestamp: NSDate() )
		
		let text = entry.description + "\n"
		
		let error = NSErrorPointer()
		if let url = NSURL(fileURLWithPath: self.filepath, isDirectory: false),
			file = NSFileHandle(forWritingToURL: url, error: error),
			data = text.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
		{
			file.seekToEndOfFile()
			file.writeData(data)
		}
	}
	
	static func openLog()
	{
		NSWorkspace.sharedWorkspace().openFile( self.filepath )
	}
	
	static var filepath : String
	{
		let path = LibraryManager.baseDirectory + "log.log"
		let manager = NSFileManager.defaultManager()
		
		if !manager.fileExistsAtPath(path)
		{
			manager.createFileAtPath(path, contents: nil, attributes: nil)
		}
		
		return path
	}
	
	static func error(text: String, category: String? = nil)
	{
		self.addEntry(text, type: .Error, category: category)
	}
	
	static func info(text: String, category: String? = nil)
	{
		self.addEntry(text, type: .Info, category: category)
	}
	
	static func warning(text: String, category: String? = nil)
	{
		self.addEntry(text, type: .Warning, category: category)
	}
	
	static func success(text: String, category: String? = nil)
	{
		self.addEntry(text, type: .Success, category: category)
	}
}
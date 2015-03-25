//
//  ErrorHandler.swift
//  Commander
//
//  Created by Kyle Carson on 3/5/15.
//  Copyright (c) 2015 Kyle Carson. All rights reserved.
//

import Foundation

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
	static var entries : [ LogEntry ] = []
	
	static func addEntry( text : String, type: LogEntryType, category : String? = nil )
	{
		let entry = LogEntry(text: text, type: type, category: category, timestamp: NSDate() )
		println(entry)
		self.entries.append( entry )
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
//
//  CommandLine.swift
//  Commander
//
//  Created by Kyle Carson on 2/22/15.
//  Copyright (c) 2015 Kyle Carson. All rights reserved.
//

import Cocoa

class CommandLine
{
    func runCommandAsync( command : String, callback: ((String?) -> ())? = nil )
    {
        Async.background
        {
            let result = self.runCommand(command)
            
            if let cb = callback
            {
                cb(result)
            }
        }
    }
    
	var currentDirectory : String = "/"
	
	func runCommand( command : String ) -> String?
	{
		return self.runCommand("/bin/sh", arguments: [ "-c", command ])
	}
	
	func runCommand( launchPath : String, arguments : [String] ) -> String?
	{
		let task = NSTask()
		
		task.standardOutput = NSPipe()
		task.launchPath = launchPath
		task.currentDirectoryPath = self.currentDirectory
		task.arguments = arguments
		task.launch()
		
		let data = task.standardOutput.fileHandleForReading.readDataToEndOfFile()
		let output: String? = NSString(data: data, encoding: NSUTF8StringEncoding) as? String
		
		return output
	}
}
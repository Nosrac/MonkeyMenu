//
//  CommanderItemFilterQueue.swift
//  Commander
//
//  Created by Kyle Carson on 3/3/15.
//  Copyright (c) 2015 Kyle Carson. All rights reserved.
//

import Foundation
class CommanderItemFilterQueue
{
	private var filters : [ CommanderItemFilter ] = []
	private var minIndex : Int = 0
	
	let cb : ([CommanderItem]) -> ()
	
	init (cb : ([CommanderItem]) -> ())
	{
		self.cb = cb
	}
	
	func addFilter ( filter: CommanderItemFilter )
	{
		Async.main
		{
			let index = self.filters.count
			self.filters.append( filter )
			
			Async.background
			{
				
				self.returnItems(filter.filteredItems(), index: index)
			}
		}
	}
	
	func returnItems( items: [CommanderItem], index: Int )
	{
		Async.main
		{
			if index >= self.minIndex
			{
				self.minIndex = index
				self.cb(items)
				
				self.tryReset()
			}
		}
	}
	
	func tryReset()
	{
		if self.minIndex == ( self.filters.count - 1)
		{
			self.minIndex = 0
			self.filters = []
		}
	}
}
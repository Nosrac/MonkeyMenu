//
//  CommanderItemFilter.swift
//  Commander
//
//  Created by Kyle Carson on 12/23/14.
//  Copyright (c) 2014 Kyle Carson. All rights reserved.
//

import Cocoa
import Foundation

struct CommanderItemScore {
	let item : CommanderItem
	let score : Int
}

struct CommanderFilterCache
{
	let items : [ CommanderItem ]
	let search : String
	
	let filteredItems : [CommanderItem]
}

final class CommanderItemFilter
{
	let items : [ CommanderItem ]
	var search = "" {
		didSet {
			search = self.filterString(search)
		}
	}
	
	init(items someItems : [ CommanderItem ])
	{
		items = someItems
	}
	
	static var cachedItems : [CommanderFilterCache] = []
	
	func getCachedItems() -> ([ CommanderItem ], exactMatch : Bool)?
	{
		var caches = CommanderItemFilter.cachedItems.sorted({ (a, b) -> Bool in
			return count(a.search) > count(b.search)
		})
		
		for cache in caches
		{
			if cache.items != self.items
			{
				continue
			}
			
			if self.search == cache.search
			{
				return (cache.filteredItems, true)
			}
			
			if let range = self.search.rangeOfString(cache.search, options: NSStringCompareOptions.LiteralSearch)
			{
				return (cache.filteredItems, false)
			}
		}
		return nil
	}
	
	func filteredItems() -> [ CommanderItem ]
	{
		var scores : [CommanderItemScore] = []
		
		let searchItems : [CommanderItem]
		
		if let (cache, exact) = self.getCachedItems()
		{
			if exact
			{
				return cache
			}
			searchItems = cache
		} else {
			searchItems = self.items
		}
		
		for item in searchItems
		{
			if let score = self.score( item )
			{
				scores.append( score )
			}
		}
		
		scores.sort { (scoreA, scoreB) -> Bool in
			return scoreA.score < scoreB.score
		}
		
		var scoreList = scores.map({ (score) -> CommanderItem in
			return score.item
		})
		
		let cacheItem = CommanderFilterCache(items: self.items, search: self.search, filteredItems: scoreList)

		CommanderItemFilter.cachedItems.append(cacheItem )
		
		return scoreList
	}
	
	func score(item: CommanderItem) -> CommanderItemScore?
	{
		if let score = self.score(item.name)
		{
			return CommanderItemScore(item: item, score: score)
		}
		
		return nil
	}
	
	func score(string: String) -> Int? {
		var slice = filterString(string)
		
		let chars = Array(slice)
		var range = Range(start: chars.startIndex, end: chars.endIndex)
		
		var distance = 0
		
		for searchChar in self.search
		{
			let start = range.startIndex
			var multiplier = 1
			
			var keep = false
			for char in chars[range]
			{
				range.startIndex++
				if char == searchChar
				{
					keep = true
					
					let change = range.startIndex - start
					
					if change > 1
					{
						distance += change * 3
					} else {
						distance -= 1
					}
					break
				}
			}
			if !keep
			{
				return nil
			}
		}
		
		return distance
	}
	
	func filterString ( string : String ) -> String
	{
		let charSet = NSCharacterSet.alphanumericCharacterSet().invertedSet
		var components = string.lowercaseString.componentsSeparatedByCharactersInSet(charSet)
		
		var filteredString = ""
		
		for substr in components
		{
			filteredString += substr
		}
		return filteredString
	}
}

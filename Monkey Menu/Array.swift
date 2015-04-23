//
//  Array.swift
//  Monkey Menu
//
//  Created by Kyle Carson on 3/26/15.
//  Copyright (c) 2015 Kyle Carson. All rights reserved.
//

import Cocoa

extension Array {
	mutating func removeObject<U: Equatable>(object: U) {
		var index: Int?
		for (idx, objectToCompare) in enumerate(self) {
			if let to = objectToCompare as? U {
				if object == to {
					index = idx
				}
			}
		}
		
		if((index) != nil) {
			self.removeAtIndex(index!)
		}
	}
}

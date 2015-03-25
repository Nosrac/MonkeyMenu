//
//  String.swift
//  Commander
//
//  Created by Kyle Carson on 2/11/15.
//  Copyright (c) 2015 Kyle Carson. All rights reserved.
//

extension String {
	
	subscript (i: Int) -> Character {
		return self[advance(self.startIndex, i)]
	}
	
	subscript (i: Int) -> String {
		return String(self[i] as Character)
	}
	
	subscript (r: Range<Int>) -> String {
		return substringWithRange(Range(start: advance(startIndex, r.startIndex), end: advance(startIndex, r.endIndex)))
	}
	
	var length : Int {
		get {
			return count(self)
		}
	}
	
	func beginsWith (str: String) -> Bool {
		if let range = self.rangeOfString(str) {
			return range.startIndex == self.startIndex
		}
		return false
	}
	
	func endsWith (str: String) -> Bool {
		if let range = self.rangeOfString(str) {
			return range.endIndex == self.endIndex
		}
		return false
	}
}
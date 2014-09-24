//
//  KZStringExtensions.swift
//  SampleSDKSwift
//
//  Created by Nicolas Miyasato on 8/8/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

import Foundation

// Utilities.
extension String {
    func filterNumbers() -> String {
        var numbersOnly = ""
        let digits = NSCharacterSet.decimalDigitCharacterSet()
        
        for c in self.unicodeScalars {
            if digits.longCharacterIsMember(c.value) {
                let a = String(c)
                numbersOnly += String(c)
            }
        }
        return numbersOnly
    }
}

// XML related
extension String {
    func tag(tagName:String!) -> String! {
        let startTag = "<\(tagName) "
        let endTag = "</\(tagName)>"
        
        let datastring = NSString(string: self)
        let startRange : NSRange = datastring.rangeOfString(startTag)
        let endRange : NSRange = datastring.rangeOfString(endTag)
        
        let length = (endRange.location + countElements(endTag)) - startRange.location
        let range : NSRange = NSRange(location:startRange.location,length:length)
        let substring = datastring.substringWithRange(range)
        
        return substring

    }
}

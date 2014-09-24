//
//  KZNSDataExtensions.swift
//  SampleSDKSwift
//
//  Created by Nicolas Miyasato on 8/20/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

import Foundation

extension NSData {
    
    /// This method will extract the Assertion tag as a string.
    /// We need the entire string <Assertion.....> .... </Assertion>
    /// So using an NSXmlParser is way more complicated instead of doing this.
    func getAssertionContent() -> String! {

        let startTag = "<Assertion "
        let endTag = "</Assertion>"
        
        let datastring = NSString(data: self, encoding: NSUTF8StringEncoding)
        
        let startRange : NSRange = datastring.rangeOfString(startTag)
        let endRange : NSRange = datastring.rangeOfString(endTag)
        
        let length = (endRange.location + countElements(endTag)) - startRange.location
        let range : NSRange = NSRange(location:startRange.location,length:length)
        let substring = datastring.substringWithRange(range)
        
        return substring
    }
    
}
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
    
// Crypto
extension String {
    func md5() -> String! {
        let str = self.cStringUsingEncoding(NSUTF8StringEncoding)
        let strLen = CC_LONG(self.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.alloc(digestLen)
        
        CC_MD5(str!, strLen, result)
        
        var hash = NSMutableString()
        for i in 0..<digestLen {
            hash.appendFormat("%02x", result[i])
        }
        
        result.destroy()
        
        return String(format: hash)
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

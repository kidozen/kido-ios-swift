//
//  KZViewExtensions.swift
//  KidoZen
//
//  Created by Nicolas Miyasato on 12/5/14.
//  Copyright (c) 2014 KidoZen. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    public var frameX : CGFloat {
        get {
            return self.frame.origin.x
        }
        
        set(x) {
            var rect = self.frame
            rect.origin.x = x;
            self.frame = rect;

        }
    }
    
    
    public var frameY : CGFloat {
        get {
            return self.frame.origin.y
        }
        
        set(y) {
            var rect = self.frame
            rect.origin.y = y;
            self.frame = rect;
            
        }
    }
    
    public var frameWidth : CGFloat {
        get {
            return self.frame.size.width
        }
        
        set(newWidth) {
            var rect = self.frame
            rect.size.width = newWidth
            self.frame = rect

        }
    }
    
    public var frameHeight : CGFloat {
        get {
            return self.frame.size.height
        }
        
        set(newHeight) {
            var rect = self.frame
            rect.size.height = newHeight
            self.frame = rect
            
        }
    }
    
    
    public var frameSize : CGSize {
        get {
            return self.frame.size
        }
        
        set(newSize) {
            var rect = self.frame
            rect.size = newSize
            self.frame = rect
        }
    }
    
    
    public var frameOrigin : CGPoint {
        get {
            return self.frame.origin
        }
        
        set(newOrigin) {
            var rect = self.frame
            rect.origin = newOrigin
            self.frame = rect
        }
    }
    
    public var frameMaxX : CGFloat {
        get {
            return CGRectGetMaxX(self.frame)
        }
        
        set(frameMX) {
            self.frameWidth = max(frameMX - self.frameX, 0)
        }
    }
    
    public var frameMaxY : CGFloat {
        get {
            return CGRectGetMaxY(self.frame)
        }
        
        set(frameMY) {
            self.frameHeight = max(frameMY - self.frameY, 0)
        }
    }
    
    public var centerX : CGFloat {
        get {
            return self.center.x
        }
        
        set(newCenterX) {
            self.center = CGPointMake(newCenterX, self.center.y)
        }
    }
    
    public var centerY : CGFloat {
        get {
            return self.center.y
        }
        
        set(newCenterY) {
            self.center = CGPointMake(self.center.y, newCenterY)
        }
    }
    
    
    
}

//
//  UIColor+ex.swift
//  TangoBook
//
//  Created by Shusuke Unno on 2017/07/19.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    func intColor() -> UInt32 {
        var R : CGFloat = 0.0
        var G : CGFloat = 0.0
        var B : CGFloat = 0.0
        var A : CGFloat = 0.0
        
        self.getRed(&R, green: &G, blue: &B, alpha: &A)
        
        return (UInt32(A * 255.0) << 24) |
            (UInt32(R * 255.0) << 16) |
            (UInt32(G * 255.0) << 8) |
            UInt32(B * 255.0)
    }
}

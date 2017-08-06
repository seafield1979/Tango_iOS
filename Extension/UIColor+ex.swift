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
        
        // IntでオーバーフローするのでAlphaは除外
        return //(UInt32(A * 255.0) << 24) |
            (UInt32(R * 255.0) << 16) |
            (UInt32(G * 255.0) << 8) |
            UInt32(B * 255.0)
    }
    
    // １６進数の文字列にして返す
    func hexColor() -> String {
        return String(format: "%08x", self.intColor())
    }
    
    func alpha() -> CGFloat {
        var R : CGFloat = 0.0
        var G : CGFloat = 0.0
        var B : CGFloat = 0.0
        var A : CGFloat = 0.0
        self.getRed(&R, green: &G, blue: &B, alpha: &A)
        
        return A
    }
    
    /**
     * 文字列の色情報をUIColorに変換する
     * 例 #ff8000 -> UIColor(1.0, 0.5, 0.0)
     */
    static func hexColor(_ str: String) -> UIColor
    {
        if str.substring(to: str.index(str.startIndex, offsetBy: 1)) == "#"
        {
            let colStr = str.substring(from: str.index(str.startIndex, offsetBy: 1))
            if colStr.utf16.count == 6
            {
                let rStr = (colStr as NSString).substring(with: NSRange(location: 0, length: 2))
                let gStr = (colStr as NSString).substring(with: NSRange(location: 2, length: 2))
                let bStr = (colStr as NSString).substring(with: NSRange(location: 4, length: 2))
                let rHex = CGFloat(Int(rStr, radix: 16) ?? 0)
                let gHex = CGFloat(Int(gStr, radix: 16) ?? 0)
                let bHex = CGFloat(Int(bStr, radix: 16) ?? 0)
                return UIColor(red: rHex/255.0, green: gHex/255.0, blue: bHex/255.0, alpha: 1.0)
            }
        }
        return UIColor.white
    }
    
    // PixelDataに変換する
    func toPixelColor() -> PixelData {
        var R : CGFloat = 0.0
        var G : CGFloat = 0.0
        var B : CGFloat = 0.0
        var A : CGFloat = 0.0
        
        self.getRed(&R, green: &G, blue: &B, alpha: &A)
        
        return PixelData(a: UInt8(A * 255),
                         r: UInt8(R * 255),
                         g: UInt8(G * 255),
                         b: UInt8(B * 255))
    }
}

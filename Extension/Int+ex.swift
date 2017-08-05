//
//  Int+ex.swift
//  TangoBook
//
//  Created by Shusuke Unno on 2017/07/31.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import UIKit

extension Int {
    // UIColorに変換する
    // argb 32bit(r:8bit g:8bit b:8bit a:8bit)の色から UIColor を作成する
    public func toColor() -> UIColor {
//        let a = CGFloat((self >> 24) & 0xff) / 255.0
        let a : CGFloat = 1.0
        let r = CGFloat((self >> 16) & 0xff) / 255.0
        let g = CGFloat((self >> 8) & 0xff) / 255.0
        let b = CGFloat(self & 0xff) / 255.0
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}

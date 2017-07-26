//
//  CGRect+U.swift
//  UGui
//
//  Created by Shusuke Unno on 2017/07/13.
//  Copyright © 2017年 Shusuke Unno. All rights reserved.
//

import Foundation
import UIKit

// CGRect の origin.x origin.y size.width size.height に値を設定できるプロパティを追加
extension CGRect {
    var x : CGFloat {
        get {
            return self.origin.x
        }
        set(x){
            self.origin.x = x
        }
    }
    var y : CGFloat {
        get {
            return self.origin.y
        }
        set(y) {
            self.origin.y = y
        }
    }
    var width : CGFloat {
        get {
            return size.width
        }
        set(width) {
            self.size.width = width
        }
    }
    var height : CGFloat {
        get {
            return size.height
        }
        set(height) {
            self.size.height = height
        }
    }
    var left : CGFloat {
        get {
            return self.x
        }
    }
    
    var top : CGFloat {
        get {
            return self.y
        }
    }
    
    var right : CGFloat {
        get {
            return self.x + self.width
        }
    }
    
    var bottom : CGFloat {
        get {
            return self.y + self.height
        }
    }
    
    func centerX() -> CGFloat {
        return self.x + self.width / 2
    }
    func centerY() -> CGFloat {
        return self.y + self.height / 2
    }
    
    /**
     指定の点(x,y)が矩形内にあるかどうかを判定
     - parameter x: 点のx座標
     - parameter y: 点のy座標
     - returns: true:　矩形内 / false: 矩形外
     */
    func contains(x: CGFloat, y: CGFloat) -> Bool {
        if self.x <= x && x <= self.right &&
            self.y <= y && y <= self.bottom {
            return true
        }
        return false
    }
}

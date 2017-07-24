//
//  URect.swift
//  UGui
//  自前のRectクラス
//  Swiftの標準のRect(CGRect)はプロパティが x,y,width,height なので JavaのRectと互換性がない
//  Created by Shusuke Unno on 2017/07/08.
//  Copyright © 2017年 Shusuke Unno. All rights reserved.
//

import Foundation
import UIKit

class URect {
    var left : CGFloat
    var right : CGFloat
    var top : CGFloat
    var bottom : CGFloat
    
    convenience init() {
        self.init(0,0,0,0)
    }
    init(_ left:CGFloat, _ top:CGFloat, _ right: CGFloat, _ bottom: CGFloat) {
        self.left = left
        self.top = top
        self.right = right
        self.bottom = bottom
    }
    
    // CGRect形式に変換する
    // UDrawのメソッドは引数をCGRectで受け取るため、これで変換した物を渡す
    public func toCGRect() -> CGRect  {
        return CGRect(x: left, y: top, width: right - left, height: bottom - top)
    }
    
    /**
     * 重なっているかチェック
     * @param rect1
     * @param rect2
     * @return true:一部分でも重なっている / false:全く重なっていない
     */
    public static func intersect(rect1 : URect, rect2 : URect) -> Bool {
        if (rect1.right < rect2.left || rect1.left > rect2.right ||
            rect1.bottom < rect2.top || rect1.top > rect2.bottom )
        {
            return false
        }
        return true
    }
    
    /**
     指定の点が矩形内に含まれるかどうかを判定する
     - parameter x: 点のx座標
     - parameter y: 点のy座標
     - return true: 含まれている / false: 含まれていない
     */
    public func contains(x : CGFloat, y : CGFloat) -> Bool {
        return left < right && top < bottom
                && x >= left && x < right && y >= top && y < bottom
    }
    
}

//
//  UDrawableRect.swift
//  UGui
//
//  Created by Shusuke Unno on 2017/07/08.
//  Copyright © 2017年 Shusuke Unno. All rights reserved.
//

import Foundation
import UIKit

class UDrawableRect : UDrawable {
    
    /**
     * Constructor
     */
    override init(priority: Int, x: CGFloat, y: CGFloat, width : CGFloat, height : CGFloat)
    {
        super.init(priority:priority,x: x,y: y,width: width,height: height)
    }
    
    public static func createInstance(priority : Int, x : CGFloat, y : CGFloat, width : CGFloat, height: CGFloat, color : UIColor) -> UDrawableRect
    {
        let instance = UDrawableRect(priority:priority,x: x,y: y,width: width, height: height)
        instance.color = color
        return instance
    }
    
    /**
     * 描画処理
     * @param canvas
     * @param paint
     * @param offset 独自の座標系を持つオブジェクトをスクリーン座標系に変換するためのオフセット値
     */
    public func draw(offset: CGPoint) {
        UDraw.drawRect(rect: CGRect(x:offset.x, y:offset.y, width:offset.x + size.width, height: offset.y + size.height), width: 2.0, color: UIColor.red)
    }
    
    /**
     * タッチ処理
     * @param vt
     * @return
     */
    public func touchEvent(vt: ViewTouch, offset: CGPoint) -> Bool {
        return false
    }
    
}

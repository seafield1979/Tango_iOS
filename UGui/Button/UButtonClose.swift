//
//  UButtonClose.swift
//  UGui
//
//  閉じるボタン
//  Created by Shusuke Unno on 2017/07/08.
//  Copyright © 2017年 Shusuke Unno. All rights reserved.
//

import Foundation
import UIKit

public class UButtonClose : UButton {
    /**
     * Consts
     */
    public static let X_LINE_WIDTH : Int = 5
    public static let BUTTON_W : Int = 34
    private var closeImage : UIImage
    
    /**
     * Member Variables
     */
    private var radius : CGFloat = 0.0
    
    /**
     * Get/Set
     */
    
    /**
     * Constructor
     */
    public init(callbacks : UButtonCallbacks, type : UButtonType, id : Int,
                priority : Int,
                x : CGFloat, y : CGFloat, color : UIColor)
    {
        self.radius = UDpi.toPixel(UButtonClose.BUTTON_W / 2)
        self.closeImage = UResourceManager.getImageByName(ImageName.close)!

        super.init(callbacks: callbacks, type: type, id: id, priority: priority,
                   x: x, y: y,
                   width: UDpi.toPixel(UButtonClose.BUTTON_W),
                   height: UDpi.toPixel(UButtonClose.BUTTON_W),
                   color: color)
        
        self.updateRect()
    }
    
    /**
     * Methods
     */
    
    /**
     * 描画処理
     * @param canvas
     * @param paint
     * @param offset 独自の座標系を持つオブジェクトをスクリーン座標系に変換するためのオフセット値
     */
    override public func draw(_ offset : CGPoint?) {
        var _rect = CGRect(origin: rect!.origin, size: rect!.size)
        if offset != nil {
            _rect.x += offset!.x
            _rect.y += offset!.y
        }
        UDraw.drawImage(image: closeImage, rect: _rect)
    }
    
    /**
     * タッチ処理
     * @param vt
     * @param offset
     * @return
     */
    override public func touchEvent(vt : ViewTouch, offset : CGPoint?) -> Bool {
        var done = false
        var offset = offset         // 引数を書き換えられるようにvarで再定義
        if (offset == nil) {
            offset = CGPoint()
        }
        if (vt.isTouchUp) {
            if (isPressed) {
                isPressed = false
                done = true
            }
        }
        
        switch(vt.type) {
        case .None:
            break
        case .Touch:
            fallthrough
        case .Moving:
            if (self.contains(x: vt.touchX(offset: -offset!.x),
                         y: vt.touchY(offset: -offset!.y)))
            {
                isPressed = true
                done = true
            }
            break
        case .Click:
            fallthrough
        case .LongClick:
            isPressed = false
            if (contains(x: vt.touchX(offset: -offset!.x),
                         y: vt.touchY(offset: -offset!.y)))
            {
                if (buttonCallback != nil) {
                    _ = buttonCallback?.UButtonClicked(id: id, pressedOn: false)
                }
                done = true
            }
            break
        case .MoveEnd:
            
            break
        default:
            break
        }
        return done
    }
    
    /**
     * 指定の座標がボタンの円の中に含まれるかをチェック
     * @param x
     * @param y
     * @return
     */
    private func contains(x : CGFloat, y : CGFloat) -> Bool {
        // 中心からの距離で判定
        let dx = x - (pos.x + radius)
        let dy = y - (pos.y + radius)
        
        if (radius * radius >= dx * dx + dy * dy) {
            return true
        }
        return false
    }
}

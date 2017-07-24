//
//  UScrollWindow.swift
//  UGui
//
//  client領域をスワイプでスクロールできるWindow
//
//  Created by Shusuke Unno on 2017/07/08.
//  Copyright © 2017年 Shusuke Unno. All rights reserved.
//

import Foundation
import UIKit

public class UScrollWindow : UWindow {
    /**
     * Constructor
     */
    public init(parentView : TopView,
                callbacks : UWindowCallbacks?,
                priority : Int, x : CGFloat, y : CGFloat,
                width : CGFloat, height : CGFloat,
                color : UIColor,
                topBarH : CGFloat, frameW : CGFloat, frameH : CGFloat)
    {
        super.init(parentView: parentView, callbacks: callbacks, priority: priority,
                   x: x, y: y,
                   width: width, height: height,
                   bgColor: color,
                   topBarH: topBarH, frameW: frameW, frameH: frameH)
    }
    
    /**
     * Methods
     */
    public override func doAction() -> DoActionRet {
        return DoActionRet.None
    }
    
    public override func drawContent(offset : CGPoint?) {
        
    }
    
    override public func touchEvent(vt: ViewTouch, offset: CGPoint?) -> Bool {
        if super.touchEvent(vt: vt, offset: offset) {
            return true
        }
        // スクロール処理
        var isDraw : Bool = false
        if vt.type == TouchType.Moving {
            if contentSize.width > clientSize.width {
                if vt.moveX != 0 {
                    contentTop.x -= vt.moveX
                    if (contentTop.x < 0) {
                        contentTop.x = 0
                    }
                    if (contentTop.x + clientSize.width > contentSize.width) {
                        contentTop.x = contentSize.width - clientSize.width
                    }
                    mScrollBarH!.updateScroll(pos: contentTop.x)
                    isDraw = true
                }
            }
            if contentSize.height > clientSize.height {
                if vt.moveY != 0 {
                    contentTop.y -= vt.moveY
                    if contentTop.y < 0 {
                        contentTop.y = 0
                    }
                    if contentTop.y + clientSize.height > contentSize.height {
                        contentTop.y = contentSize.height - clientSize.height
                    }
                    
                    mScrollBarV!.updateScroll(pos: contentTop.y)
                    isDraw = true
                }
            }
        }
        return isDraw
    }
    
    /**
     * Callbacks
     */
}

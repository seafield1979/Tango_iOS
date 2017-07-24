//
//  UListItem.swift
//  UGui
//
//  Created by Shusuke Unno on 2017/07/08.
//  Copyright © 2017年 Shusuke Unno. All rights reserved.
//

import Foundation
import UIKit

/**
 * リストビューの項目のコールバック
 */
public protocol UListItemCallbacks {
    /**
     * 項目がクリックされた
     * @param item
     */
    func ListItemClicked(item : UListItem)
    
    /**
     * 項目のボタンがクリックされた
     */
    func ListItemButtonClicked(item : UListItem, buttonId : Int)
}


public class UListItem : UDrawable {
    /**
     * Constants
     */
    public static let TAG = "UListItem"
    
    /**
     * Member variables
     */
    var mListItemCallbacks : UListItemCallbacks? = nil
    var mIndex : Int = 0
    var isTouchable : Bool = false
    var isTouching : Bool = false
    var pressedColor : UIColor? = nil
    var mFrameW : CGFloat = 0         // 枠の幅
    var mFrameColor : UIColor?        // 枠の色
    
    /**
     * Get/Set
     */
    
    public func getIndex() -> Int {
        return mIndex
    }
    public func setIndex(_ index : Int) {
        mIndex = index
    }
    public func getMIndex() -> Int{
        return mIndex
    }
    public func setListItemCallbacks(_ callbacks : UListItemCallbacks?) {
        self.mListItemCallbacks = callbacks
    }
    
    /**
     * Constructor
     */
    public init(callbacks : UListItemCallbacks?, isTouchable : Bool,
                x : CGFloat, width : CGFloat, height : CGFloat,
                bgColor : UIColor?,
                frameW : CGFloat, frameColor : UIColor?)
    {
        // yはリスト追加時に更新されるので0
        super.init(priority: 0, x: x, y: 0, width: width, height: height)
        
        mListItemCallbacks = callbacks
        color = bgColor
        self.isTouchable = isTouchable
        mFrameW = frameW
        mFrameColor = frameColor
        
        rect = CGRect(x:0, y:0, width:width, height:height)
        
        if isTouchable && color != nil{
            // 押された時の色（暗くする)
            pressedColor = UColor.addBrightness(argb: color!, addY: -0.2)
        }
    }
    
    
    override public func touchUpEvent(vt : ViewTouch) -> Bool {
        if vt.isTouchUp {
            isTouching = false
        }
        return false
    }
    
    /**
     * タッチ処理
     * @param vt
     * @return true:再描画あり
     */
    public override func touchEvent(vt : ViewTouch, offset : CGPoint?) -> Bool{
        var isDraw = false
    
        switch(vt.type) {
        case .Touch:
            if (isTouchable) {
                var point = CGPoint(x: vt.touchX, y: vt.touchY)
                if offset != nil {
                    point.x -= offset!.x
                    point.y -= offset!.y
                }
                
                if rect!.contains( point ) {
                    isTouching = true
                    isDraw = true
                }
            }
        case .Click:
            if (isTouchable) {
                var point = CGPoint(x: vt.touchX, y: vt.touchY)
                if offset != nil {
                    point.x -= offset!.x
                    point.y -= offset!.y
                }
                if mListItemCallbacks != nil {
                    if rect!.contains(point) {
                        mListItemCallbacks!.ListItemClicked(item: self)
                    }
                    isDraw = true
                }
            }
        default:
            break
        }
        return isDraw
    }
    
    override public func draw(_ offset : CGPoint?) {
        // BG　タッチ中は色を変更
        var _color = color
        
        if isTouchable && isTouching {
            _color = pressedColor
        }
        
        var rect = CGRect(x: 0, y: 0,
                         width:size.width, height:size.height)
        if offset != nil {
            rect.x += offset!.x
            rect.y += offset!.y
        }
        
        if mFrameW > 0 && color != nil {
            UDraw.drawRectFill( rect: rect, color: _color!,
                                strokeWidth: mFrameW, strokeColor: mFrameColor )
        }
        else if color != nil {
            UDraw.drawRectFill( rect: rect, color: _color! )
        }
        else if mFrameW > 0 {
            UDraw.drawRect( rect: rect, width: mFrameW, color: mFrameColor! )
        }
    }
    
}

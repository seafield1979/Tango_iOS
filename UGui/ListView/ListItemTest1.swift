//
//  ListItemTest1.swift
//  UGui
//
//  Created by Shusuke Unno on 2017/07/17.
//  Copyright © 2017年 Shusuke Unno. All rights reserved.
//

import Foundation
import UIKit

public class ListItemTest1 : UListItem {
    /**
     * Constants
     */
    public static let ITEM_H = 50
    public static let TEXT_SIZE = 17
    
    // colors
    private static let TEXT_COLOR = UIColor.blue
    
    /**
     * Member variables
     */
    private var mText : String? = nil
    private var mTextSize : Int = 10
    
    /**
     * Constructor
     */
    public init(callbacks : UListItemCallbacks?,
                              text : String,
                              x : CGFloat, width : CGFloat, color : UIColor?)
    {
        super.init(callbacks: callbacks,
                   isTouchable: true,
                   x: x, width: width, height: UDpi.toPixel(ListItemTest1.ITEM_H),
                   bgColor: color, frameW: 2, frameColor: UIColor.black)
        self.color = color
        mText = text
        mTextSize = Int(UDpi.toPixel(ListItemTest1.TEXT_SIZE))
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
    override public func draw( _ offset : CGPoint? ) {
        var _pos = CGPoint(x: pos.x, y: pos.y)
        if offset != nil {
            _pos.x += offset!.x
            _pos.y += offset!.y
        }
        
        // BG
        let _rect = CGRect(x:_pos.x, y:_pos.y,
                           width: size.width, height: size.height)
        UDraw.drawRectFill(rect: _rect, color: color!,
                           strokeWidth: 4, strokeColor: UIColor.black)
        
        // text
        let text = mText
        UDraw.drawText(text: text!, alignment: UAlignment.Center, textSize: mTextSize,
                       x: _pos.x + size.width / 2, y: _pos.y + size.height / 2, color: ListItemTest1.TEXT_COLOR )
    }
    
    /**
     * このtouchEventは使用しない
     */
    public func touchEvent(vt : ViewTouch) -> Bool{
        return false
    }
    
    /**
     * 高さを返す
     */
    public func getHeight() -> Int{
        return ListItemTest1.ITEM_H
    }
}

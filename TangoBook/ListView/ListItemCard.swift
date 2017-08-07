//
//  ListItemCard.swift
//  TangoBook
//      ListViewに表示する単語カードアイテム
//  Created by Shusuke Unno on 2017/08/07.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import UIKit

public class ListItemCard : UListItem {
    /**
     * Enums
     */
    /**
     * Constants
     */
    public let TAG = "ListItemCard"

    private let TEXT_COLOR = UIColor.black
    private let BG_COLOR = UIColor.white
    private let ICON_W = 35

    private let MARGIN_H = 17
    private let MARGIN_V = 5

    private let FRAME_WIDTH = 2
    private let FRAME_COLOR = UIColor.black

    /**
     * Member variables
     */
    private var mPresetCard : PresetCard? = nil

    // Dpi計算済み
    private var itemH : CGFloat, iconW : CGFloat

    /**
     * Get/Set
     */


    /**
     * Constructor
     */
    public init( listItemCallbacks : UListItemCallbacks?,
                 card : PresetCard, width : CGFloat)
    {
        itemH = CGFloat(UDraw.getFontSize(FontSize.M)) * 3 + UDpi.toPixel(MARGIN_V) * 4
        iconW = UDpi.toPixel(ICON_W)
        mPresetCard = card
        
        super.init(callbacks : listItemCallbacks,
                   isTouchable : true,
                   x : 0, width : width, height : CGFloat(UDraw.getFontSize(FontSize.M)) * 3 + UDpi.toPixel(MARGIN_V) * 4,
                   bgColor : BG_COLOR, frameW : UDpi.toPixel(FRAME_WIDTH), frameColor : FRAME_COLOR)       
        
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
    public func draw( offset : CGPoint?) {
//        PointF _pos = new PointF(pos.x, pos.y);
//        if (offset != null) {
//            _pos.x += offset.x;
//            _pos.y += offset.y;
//        }
//
//        super.draw(canvas, paint, _pos);
//
//        float x = _pos.x + MARGIN_H;
//        float marginV = (itemH - UDraw.getFontSize(FontSize.M) * 2) / 3;
//        float y = _pos.y + marginV;
//        int fontSize = UDraw.getFontSize(FontSize.M);
//
//        // Icon image
//        UDraw.drawBitmap(canvas, paint, UResourceManager.getBitmapById(R.drawable.card), x,
//                _pos.y + (itemH - iconW) / 2,
//                iconW, iconW );
//        x += iconW + UDpi.toPixel(MARGIN_H);
//
//        // WordA
//        UDraw.drawTextOneLine(canvas, paint,
//                UResourceManager.getStringById(R.string.word_a) + ": " + mPresetCard.mWordA,
//                UAlignment.None, fontSize,
//                x, y, TEXT_COLOR);
//        y += fontSize + marginV;
//
//        // WordB
//        UDraw.drawTextOneLine(canvas, paint,
//                UResourceManager.getStringById(R.string.word_b) + ": " + mPresetCard.mWordB,
//                UAlignment.None, fontSize,
//                x, y, TEXT_COLOR);
    }
}

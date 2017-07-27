//
//  UIcon.swift
//  TangoBook
//      ゴミ箱アイコン
//      このアイコンにドラッグするとゴミ箱に入る
//  Created by Shusuke Unno on 2017/07/25.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import UIKit

/**
 * Created by shutaro on 2016/11/21.
 *
 */

public class IconTrash : IconContainer {
    /**
     * Consts
     */
    private let ICON_W = 40;
    private let ICON_H = 40;
    private let ICON_COLOR = UColor.makeColor(100,100,200)
    
    /**
     * Member Variables
     */
    
    // Dpi補正済みのサイズ
    private var iconW : CGFloat, iconH : CGFloat
    private var textSize : CGFloat = 0
    
    
    /**
     * Get/Set
     */
    
    public override func getTangoItem() -> TangoItem? {
        return nil
    }
    public override func getParentType() -> TangoParentType{
        return TangoParentType.Trash
    }
    public override func updateTitle(){}
    
    /**
     * Constructor
     */
    public init(parentWindow : UIconWindow , iconCallbacks : UIconCallbacks?) {
        iconW = UDpi.toPixel(ICON_W)
        iconH = UDpi.toPixel(ICON_H)
        
        // 自動整列するので座標は設定しない
        super.init( parentWindow: parentWindow, iconCallbacks: iconCallbacks,
                    type: IconType.Trash,
                    x: 0, y: 0, width: UDpi.toPixel(ICON_W), height: UDpi.toPixel(ICON_H));
        textSize = UDpi.toPixel(TEXT_SIZE)
        
        title = UResourceManager.getStringByName("trash")
        setColor(ICON_COLOR)
        
        // 中のアイコンを表示するためのSubWindow
        let windows = parentWindow.getWindows()
        subWindow = windows!.getSubWindow()
        
        image = UResourceManager.getImageWithColor( imageName: ImageName.trash, color: UColor.DarkBlue)
    }

    /**
     * Methods
     */
    
    /**
     * カードアイコンを描画
     * 長方形の中に単語のテキストを最大 DISP_TITLE_LEN 文字表示
     * @param canvas
     * @param paint
     * @param offset
     */
    public override func drawIcon(offset : CGPoint?) {
        
        var drawPos : CGPoint
        if offset != nil {
            drawPos = CGPoint(x: pos.x + offset!.x, y: pos.y + offset!.y);
        } else {
            drawPos = pos
        }
        
        var alpha : CGFloat = 1.0
        if isLongTouched || isTouched || isDroped {
            // 長押し、タッチ、ドロップ中はBGを表示
            UDraw.drawRoundRectFill(rect: CGRect(x: drawPos.x, y: drawPos.y, width: drawPos.x + iconW, height: drawPos.y + iconH),
                                     cornerR: UDpi.toPixel(10),
                                     color: touchedColor!, strokeWidth: 0, strokeColor: nil)
        } else if (isAnimating) {
            // 点滅
            let v1 = (CGFloat(animeFrame) / CGFloat(animeFrameMax)) * 180
            alpha = 1.0 -  sin(v1 * UUtil.RAD)
        } else {
            alpha = self.color!.alpha()
        }
        
        // icon
        // 領域の幅に合わせて伸縮
        UDraw.drawImageWithCrop(image: image!,
                                srcRect: CGRect(x: 0,y: 0, width: image!.getWidth(), height: image!.getHeight()),
                                dstRect: CGRect(x: drawPos.x, y: drawPos.y,
                                                width: iconW, height: iconH), alpha: alpha)
        
        // Text
        UDraw.drawText(text: title!, alignment: UAlignment.Center,
                       textSize: Int(UDpi.toPixel(TEXT_SIZE)),
                       x: drawPos.x + iconW / 2,
                       y: drawPos.y + iconH + UDpi.toPixel(TEXT_MARGIN),
                       color: UIColor.black)

    }
    
    /**
     * ドロップ可能かどうか
     * ドラッグ中のアイコンを他のアイコンの上に重ねたときにドロップ可能かを判定してアイコンの色を変えたりする
     * @param dstIcon
     * @return
     */
    public func canDrop( dstIcon : UIcon, dropX : CGFloat, dropY : CGFloat) -> Bool {
        return true
    }
    
    /**
     * アイコンの中に入れることができるか
     * @return
     */
    public func canDropIn( dstIcon : UIcon, dropX : CGFloat, dropY : CGFloat) -> Bool
    {
        return false
    }
    
    /**
     * ドロップ時の処理
     * @param dstIcon
     * @return 何かしら処理をした（再描画あり）
     */
    public func droped(dstIcon : UIcon, dropX : CGFloat, dropY : CGFloat) -> Bool{
        return true
    }
    
    /**
     * Newフラグ設定
     */
    public override func setNewFlag(newFlag : Bool) {
    }
}

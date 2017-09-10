//
//  UIcon.swift
//  TangoBook
//      ゴミ箱アイコン
//      このアイコンにドラッグするとゴミ箱に入る
//  Created by Shusuke Unno on 2017/07/25.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import SpriteKit

/**
 * Created by shutaro on 2016/11/21.
 *
 */

public class IconTrash : IconContainer {
    /**
     * Consts
     */
    private let ICON_W = 40
    private let ICON_H = 40
    private let FONT_SIZE_T = 12
    private let ICON_COLOR = UColor.makeColor(100,100,200)
    
    /**
     * Member Variables
     */
    
    // Dpi補正済みのサイズ
    private var iconW : CGFloat, iconH : CGFloat
    private var fontSize : CGFloat = 0
    
    
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
        fontSize = UDpi.toPixel(FONT_SIZE_T)
        
        setTitle( UResourceManager.getStringByName("trash") )
        titleView!.parentNode.position.y -= UDpi.toPixel(4)
        
        setColor(ICON_COLOR)
        
        // 中のアイコンを表示するためのSubWindow
        let windows = parentWindow.getWindows()
        subWindow = windows!.getSubWindow()
        
        image = UResourceManager.getImageWithColor( imageName: ImageName.trash, color: UColor.DarkBlue)
        
        if let _image = image {
            imageNode!.texture = SKTexture(image: _image)
        }
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
    public override func drawIcon() {
        
        var alpha : CGFloat = 1.0
        if isLongTouched || isTouched || isDroped {
            // 長押し、タッチ、ドロップ中はBGを表示
        } else if (isAnimating) {
            // 点滅
            let v1 = (CGFloat(animeFrame) / CGFloat(animeFrameMax)) * 180
            alpha = 1.0 -  sin(v1 * UUtil.RAD)
        } else {
            alpha = self.color.alpha()
        }
        
        parentNode.alpha = alpha
    }
    
    /**
     * ドロップ可能かどうか
     * ドラッグ中のアイコンを他のアイコンの上に重ねたときにドロップ可能かを判定してアイコンの色を変えたりする
     * @param dstIcon
     * @return
     */
    public override func canDrop( dstIcon : UIcon, x dropX : CGFloat, y dropY : CGFloat) -> Bool {
        return true
    }
    
    /**
     * アイコンの中に入れることができるか
     * @return
     */
    public override func canDropIn( dstIcon : UIcon, x dropX : CGFloat, y dropY : CGFloat) -> Bool
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
    public override func setNewFlag(isNew : Bool) {
    }
}

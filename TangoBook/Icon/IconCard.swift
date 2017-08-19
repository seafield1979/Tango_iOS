//
//  UIcon.swift
//  TangoBook
//      単語カードのアイコン
//  Created by Shusuke Unno on 2017/07/25.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import UIKit

public class IconCard : UIcon {
    /**
     * Consts
     */
    private let ICON_W = 40
    private let ICON_H = 40
    
    private let TOUCHED_COLOR = UColor.makeColor(100,200,100)
    
    /**
     * Member Variables
     */
    var card : TangoCard
    
    // Dpi補正済みのサイズ
    private var iconW, iconH : CGFloat
    
    /**
     * Get/Set
     */
    
    public override func getTangoItem() -> TangoItem {
        return card
    }
    
    /**
     * Constructor
     */
    
    convenience public init( card : TangoCard, parentWindow : UIconWindow, iconCallbacks : UIconCallbacks?)
    {
        self.init(card: card, parentWindow: parentWindow,iconCallbacks: iconCallbacks, x: 0, y: 0)
    }

    public init( card : TangoCard, parentWindow : UIconWindow, iconCallbacks : UIconCallbacks?, x : CGFloat, y : CGFloat)
    {
        self.card = card
        iconW = UDpi.toPixel(ICON_W)
        iconH = UDpi.toPixel(ICON_H)
        
        super.init(parentWindow: parentWindow, iconCallbacks: iconCallbacks,
                   type: IconType.Card,
                   x: x, y: y,
                   width: UDpi.toPixel(ICON_W), height: UDpi.toPixel(ICON_H))
        
        updateTitle()
        setColor(TOUCHED_COLOR)
        
        // アイコン画像の読み込み
        image = UResourceManager.getImageWithColor(imageName: ImageName.card,
                                                   color: UColor.makeColor(argb: UInt32(card.color)))
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
    override public func drawIcon( offset : CGPoint? ) {
        var drawPos : CGPoint
        if offset != nil {
            drawPos = CGPoint(x: pos.x + offset!.x, y: pos.y + offset!.y);
        } else {
            drawPos = pos
        }
        var alpha : CGFloat = 1.0
        
        if (isLongTouched || isTouched || isDroped) {
            // 長押し、タッチ、ドロップ中はBGを表示
            UDraw.drawRoundRectFill(rect: CGRect(x: drawPos.x, y: drawPos.y,
                                            width: iconW, height: iconH),
                                    cornerR: UDpi.toPixel(10),
                                    color: touchedColor!, strokeWidth: 0, strokeColor: nil)
        } else if (isAnimating) {
            // 点滅
            let v1 : CGFloat = (CGFloat(animeFrame) / CGFloat(animeFrameMax)) * 180
            alpha = 1.0 -  sin(v1 * UUtil.RAD)
        } else {
            alpha = self.color.alpha()
        }
        // icon
        // 領域の幅に合わせて伸縮
        UDraw.drawImageWithCrop(image: image!,
                                srcRect: CGRect(x: 0,y: 0, width: image!.getWidth(), height: image!.getHeight()),
                                dstRect: CGRect(x: drawPos.x, y: drawPos.y,
                                                width: iconW, height: iconH), alpha: alpha)
        // Text
        UDraw.drawText(text: title!, alignment: UAlignment.CenterX,
                       textSize: Int(UDpi.toPixel(TEXT_SIZE)),
                       x: drawPos.x + iconW / 2,
                       y: drawPos.y + iconH + UDpi.toPixel(TEXT_MARGIN),
                       color: UIColor.black)

        // New!
        if card.isNew {
            if newTextView == nil {
                createNewBadge()
            }
            newTextView!.draw( CGPoint(x: drawPos.x + iconW / 2, y:drawPos.y + iconW / 2))
        }
    }

    /**
     * タイトルに表示する文字列を更新
     */
    override public func updateTitle() {
        // 改行ありなら１行目のみ切り出す
        if card.wordA == nil {
            return
        }
        
        var str : String?
        var strs : [String]?
        var maxLen : Int
        
        if MySharedPref.getCardName() {
            // 日本語
            str = card.wordB
            maxLen = DISP_TITLE_LEN_J
        } else {
            str = card.wordA
            maxLen = DISP_TITLE_LEN
        }
        
        // ２行以上の文字列は１行目のみ表示
        if str != nil {
            strs = str!.components(separatedBy: "\n")
            if strs != nil && strs!.count > 0 {
                self.title = strs![0]
                
                // 文字数制限
                if self.title!.lengthOfBytes(using: String.Encoding.utf8) < maxLen {
                    self.title = strs![0]
                } else {
                    self.title = self.title!.substring(to: str!.index(str!.startIndex, offsetBy: maxLen))
                }

            }
        }
    }
    

    /**
     * ドロップ可能かどうか
     * ドラッグ中のアイコンを他のアイコンの上に重ねたときにドロップ可能かを判定してアイコンの色を変えたりする
     * @param dstIcon
     * @return
     */
    public override func canDrop( dstIcon : UIcon, x dropX : CGFloat, y dropY : CGFloat) -> Bool {
        // ドロップ座標がアイコンの中に含まれているかチェック
        if !dstIcon.checkDrop(x: dropX, y: dropY) {
            return false
        }
        
        return true
    }
    
    /**
     * アイコンの中に入れることができるか
     * @return
     */
    public override func canDropIn( dstIcon : UIcon, x dropX : CGFloat, y dropY : CGFloat) -> Bool
    {
        if dstIcon.getType() != IconType.Card {
            if dstIcon.checkDrop(x:dropX, y:dropY) {
                return true
            }
        }
        return false
    }
    
    /**
     * ドロップ時の処理
     * @param dstIcon
     * @return 何かしら処理をした（再描画あり）
     */
    public func droped(dstIcon : UIcon, dropX : CGFloat, dropY : CGFloat) -> Bool{
        // 全面的にドロップはできない
        if (!canDrop(dstIcon: dstIcon, x: dropX, y: dropY)){
            return false
        }
        return true
    }
    
    /**
     * Newフラグ設定
     */
    public override func setNewFlag(newFlag : Bool) {
        if card.isNew != newFlag {
            card.isNew = newFlag
            TangoCardDao.updateNewFlag(card: card, isNew: newFlag)
        }
    }
}

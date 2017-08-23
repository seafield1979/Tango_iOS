//
//  UIcon.swift
//  TangoBook
//      単語帳アイコン
//  Created by Shusuke Unno on 2017/07/25.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import SpriteKit

public class IconBook : IconContainer {
    
    /**
     * Constant
     */
    public static let TAG = "UIconRect"
    private let ICON_W = 40
    private let ICON_H = 40
    
    private let TEXT_SIZE2 = 14
    private let ICON_COLOR = UColor.makeColor(100,200,100)
    
    /**
     * Member variable
     */
    var book : TangoBook? = nil
    
    // Dpi補正済みのサイズ
    private var iconW : CGFloat, iconH : CGFloat
    private var textSize : Int
    
    /**
     * Get/Set
     */
    override public func getTangoItem() -> TangoItem {
        return book!
    }
    
    override public func getParentType() -> TangoParentType {
        return TangoParentType.Book
    }
    
    public func getItems() -> [TangoCard]? {
        let list = TangoItemPosDao.selectCardsByBookId(book!.id)
        return list
    }
    
    /**
     * Constructor
     */
    public init( book : TangoBook, parentWindow : UIconWindow, iconCallbacks : UIconCallbacks?, x: CGFloat, y: CGFloat)
    {
        iconW = UDpi.toPixel(ICON_W)
        iconH = UDpi.toPixel(ICON_H)
        textSize = Int(UDpi.toPixel(TEXT_SIZE2))
        
        super.init(parentWindow: parentWindow, iconCallbacks: iconCallbacks,
                   type: IconType.Book, x: x, y: y,
                   width: UDpi.toPixel(ICON_W), height: UDpi.toPixel(ICON_H))
        
        setColor(ICON_COLOR)
        self.book = book
        updateTitle()
        
        let windows = parentWindow.getWindows()
        subWindow = windows!.getSubWindow()
        
        let color = UColor.makeColor(argb: UInt32(book.getColor()))
        self.image = UResourceManager.getImageWithColor(imageName: ImageName.cards,
                                                        color: color)
        // アイコンの画像を設定
        if let _image = self.image {
            imageNode.texture = SKTexture(image: _image)
        }
    }

    /**
     * アイコンの描画
     * @param canvas
     * @param paint
     * @param offset
     */
    public override func drawIcon() {
        var alpha : CGFloat = 1.0
        if isLongTouched || isTouched  {
            // 長押し、タッチ、ドロップ中はBGを表示
            dragedBgNode.isHidden = false
        } else if  isDroped {
        } else if (isAnimating) {
            // 点滅
            let v1 : CGFloat = (CGFloat(animeFrame) / CGFloat(animeFrameMax)) * 180
            alpha = 1.0 -  sin(v1 * UUtil.RAD)
        } else {
            alpha = self.color.alpha()
        }
        parentNode.alpha = alpha
        
        // New!
        if book!.isNew {
            if newTextView == nil {
                createNewBadge()
            }
        }
    }

    /**
     * タイトルを更新する
     */
    public override func updateTitle() {
        let len = (book!.getName()!.characters.count < DISP_TITLE_LEN) ?
                book!.getName()!.characters.count :
                DISP_TITLE_LEN
        let text = book!.getName()!
        self.title = text.substring(to: text.index(text.startIndex, offsetBy: len))
        
        textNode.isHidden = (title!.characters.count == 0)
        
        textNode.text = title
    }
    
    /**
     * Newフラグ設定
     */
    public override func setNewFlag(newFlag : Bool) {
        if book!.isNew != newFlag {
            book!.setNewFlag(isNew: newFlag)
            TangoBookDao.updateNewFlag(book: book!, isNew: newFlag)
        }
    }

    
    /**
     * ドロップ可能かどうか
     * ドラッグ中のアイコンを他のアイコンの上に重ねたときにドロップ可能かを判定してアイコンの色を変えたりする
     * @param dstIcon
     * @return
     */
    public override func canDrop( dstIcon : UIcon, x dropX : CGFloat, y dropY : CGFloat) -> Bool {
        // ドロップ先のアイコンがサブWindowの中なら不可能
        if dstIcon.getParentWindow()!.getType() == WindowType.Sub {
            return false;
        }
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
    public override func canDropIn(dstIcon : UIcon, x dropX : CGFloat, y dropY : CGFloat) -> Bool {
        if dstIcon.getType() == IconType.Trash {
            if dstIcon.checkDrop(x: dropX, y: dropY) {
                return true
            }
        }
        return false
    }
    
    public override func click() {
        super.click()
    }
    
    public override func longClick() {
        super.longClick()
    }
    
    public override func moving() {
        super.moving()
    }
}

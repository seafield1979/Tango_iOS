//
//  UIcon.swift
//  TangoBook
//      単語帳アイコン
//  Created by Shusuke Unno on 2017/07/25.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import UIKit

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
    public init( book : TangoBook, parentWindow : UIconWindow, iconCallbacks : UIconCallbacks?)
    {
        iconW = UDpi.toPixel(ICON_W)
        iconH = UDpi.toPixel(ICON_H)
        textSize = Int(UDpi.toPixel(TEXT_SIZE2))
        
        super.init(parentWindow: parentWindow, iconCallbacks: iconCallbacks,
                   type: IconType.Book, x: 0, y: 0,
                   width: UDpi.toPixel(ICON_W), height: UDpi.toPixel(ICON_H))
        
        setColor(ICON_COLOR)
        self.book = book
        updateTitle()
        
        let windows = parentWindow.getWindows()
        subWindow = windows!.getSubWindow()
        
        let color = UColor.makeColor(argb: UInt32(book.getColor()))
        image = UResourceManager.getImageWithColor(imageName: ImageName.cards,
                                                   color: color)
    }

    /**
     * アイコンの描画
     * @param canvas
     * @param paint
     * @param offset
     */
    public override func drawIcon( offset : CGPoint? ) {
        var drawPos : CGPoint = pos
        if offset != nil {
            drawPos.x += offset!.x
            drawPos.y += offset!.y
        }
        
        var alpha : CGFloat = 1.0
        if isLongTouched || isTouched || isDroped {
            // 長押し、タッチ、ドロップ中はBGを表示
            UDraw.drawRoundRectFill(rect: CGRect(x: drawPos.x, y: drawPos.y, width: drawPos.x + iconW, height: drawPos.y + iconH),
                                     cornerR: UDpi.toPixel(10),
                                     color: touchedColor!,
                                     strokeWidth: 0, strokeColor: nil)
        } else if (isAnimating) {
            // 点滅
            let v1 : CGFloat = (CGFloat(animeFrame) / CGFloat(animeFrameMax)) * 180
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
        
        // New!
        if book!.isNew {
            if newTextView == nil {
                createNewBadge()
            }
            newTextView!.draw( CGPoint(x: drawPos.x + iconW / 2,
                                       y: drawPos.y + iconH - UDpi.toPixel(NEW_TEXT_SIZE)))

        }
    }

    /**
     * タイトルを更新する
     */
    public override func updateTitle() {
        let len = (book!.getName()!.lengthOfBytes(
            using: String.Encoding.utf8) < DISP_TITLE_LEN) ?
                book!.getName()!.lengthOfBytes(using: String.Encoding.utf8) :
                DISP_TITLE_LEN
        let text = book!.getName()!
        self.title = text.substring(to: text.index(text.startIndex, offsetBy: len))
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
//
//    
//    /**
//     * ドロップ可能かどうか
//     * ドラッグ中のアイコンを他のアイコンの上に重ねたときにドロップ可能かを判定してアイコンの色を変えたりする
//     * @param dstIcon
//     * @return
//     */
//    public boolean canDrop(UIcon dstIcon, float dropX, float dropY) {
//        // ドロップ先のアイコンがサブWindowの中なら不可能
//        if (dstIcon.getParentWindow().getType() == UIconWindow.WindowType.Sub) {
//            return false;
//        }
//        // ドロップ座標がアイコンの中に含まれているかチェック
//        if (!dstIcon.checkDrop(dropX, dropY)) return false;
//        
//        return true;
//    }
//    
//    /**
//     * アイコンの中に入れることができるか
//     * @return
//     */
//    public boolean canDropIn(UIcon dstIcon, float dropX, float dropY) {
//        if (dstIcon.getType() == IconType.Trash) {
//            if (dstIcon.checkDrop(dropX, dropY)) {
//                return true;
//            }
//        }
//        return false;
//    }
//    
//    @Override
//    public void click() {
//        super.click();
//    }
//    
//    @Override
//    public void longClick() {
//        super.longClick();
//    }
//    
//    @Override
//    public void moving() {
//        super.moving();
//    }
}

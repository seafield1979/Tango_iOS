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
    
    private let TEXT_SIZE = 14
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
    
    public func getItems() -> List<TangoCard>? {
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
        textSize = Int(UDpi.toPixel(TEXT_SIZE))
        
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
//
//    /**
//     * アイコンの描画
//     * @param canvas
//     * @param paint
//     * @param offset
//     */
//    public void drawIcon(Canvas canvas,Paint paint, PointF offset) {
//        PointF drawPos;
//        if (offset != null) {
//            drawPos = new PointF(pos.x + offset.x, pos.y + offset.y);
//        } else {
//            drawPos = pos;
//        }
//        
//        if (isLongTouched || isTouched || isDroped) {
//            // 長押し、タッチ、ドロップ中はBGを表示
//            UDraw.drawRoundRectFill(canvas, paint,
//                                    new RectF(drawPos.x, drawPos.y, drawPos.x + iconW, drawPos.y + iconH),
//                                    10, touchedColor, 0, 0);
//        } else if (isAnimating) {
//            // 点滅
//            double v1 = ((double)animeFrame / (double)animeFrameMax) * 180;
//            int alpha = (int)((1.0 -  Math.sin(v1 * UDrawable.RAD)) * 255);
//            paint.setColor((alpha << 24) | (color & 0xffffff));
//        } else {
//            paint.setColor(color);
//        }
//        // icon
//        // 領域の幅に合わせて伸縮
//        canvas.drawBitmap(image, new Rect(0,0,image.getWidth(), image.getHeight()),
//                          new Rect((int)drawPos.x, (int)drawPos.y,
//                                   (int)drawPos.x + iconW,(int)drawPos.y + iconH),
//                          paint);
//        
//        // Text
//        UDraw.drawTextOneLine(canvas, paint, title, UAlignment.CenterX, textSize,
//                              drawPos.x + iconW / 2, drawPos.y + iconH + UIcon.TEXT_MARGIN, Color.BLACK);
//        
//        // New!
//        if (book.isNewFlag()) {
//            if (newTextView == null) {
//                createNewBadge(canvas);
//            }
//            newTextView.draw(canvas, paint,
//                             new PointF(drawPos.x + iconW / 2, drawPos.y + iconH - UDpi.toPixel(UIcon.NEW_TEXT_SIZE)));
//        }
//    }
//    
//    /**
//     * タイトルを更新する
//     */
//    public void updateTitle() {
//        int len = (book.getName().length() < UIcon.DISP_TITLE_LEN) ? book.getName().length() :
//            UIcon.DISP_TITLE_LEN;
//        self.title = book.getName().substring(0, len);
//    }
//    
//    /**
//     * Newフラグ設定
//     */
//    public void setNewFlag(boolean newFlag) {
//        if (book.isNewFlag() != newFlag) {
//            book.setNewFlag(newFlag);
//            RealmManager.getBookDao().updateNewFlag(book, newFlag);
//        }
//    }
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

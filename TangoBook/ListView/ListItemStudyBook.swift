//
//  ListItemStudyBook.swift
//  TangoBook
//      学習する単語帳を選択するListViewのアイテム
//  Created by Shusuke Unno on 2017/08/07.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import UIKit

public class ListItemStudyBook : UListItem {
    /**
     * Enums
     */

    /**
     * Constants
     */
    public let TAG = "ListItemStudiedBook";

    private let TEXT_SIZE = 17
    private let TEXT_SIZE2 = 14
    private let TEXT_COLOR = UIColor.black
    private let ICON_W = 45;

    private let MARGIN_H = 17
    private let MARGIN_V = 5

    private let FRAME_WIDTH = 1
    private let FRAME_COLOR = UIColor.black

    /**
     * Member variables
     */
    private var mTextName : String? = nil
    private var mStudiedDate : String? = nil
    private var mCardCount : String? = nil
    private var mBook : TangoBook? = nil
    private var mIcon : UIImage? = nil

    // Dpi計算結果
    private var itemH : CGFloat = 0

    /**
     * Get/Set
     */
    public func getBook() -> TangoBook? {
        return mBook
    }

    /**
     * Constructor
     */
    public init(listItemCallbacks : UListItemCallbacks?,
                book : TangoBook, width : CGFloat, color : UIColor)
    {
        super.init(callbacks : listItemCallbacks,
                   isTouchable : true,
                   x : 0, width : width, height : UDpi.toPixel(TEXT_SIZE) * 3 + UDpi.toPixel(MARGIN_V)*4,
                   bgColor : color, frameW : UDpi.toPixel(FRAME_WIDTH), frameColor : FRAME_COLOR)
        mBook = book;
        itemH = UDpi.toPixel(TEXT_SIZE) * 3 + UDpi.toPixel(MARGIN_V) * 4

        // 単語帳名
        mTextName = UResourceManager.getStringByName("book_name2") + " : " + book.getName()!

        // 単語帳アイコン(色あり)
        mIcon = UResourceManager.getImageWithColor(imageName: ImageName.cards, color: book.getColor().toColor())

        // カード数 & 覚えていないカード数
        let count = TangoItemPosDao.countInParentType(
            parentType: TangoParentType.Book,
            parentId: book.getId())
        let ngCount = TangoItemPosDao.countCardInBook(
            bookId: book.getId(),
            countType: TangoItemPosDao.BookCountType.NG)

        mCardCount = UResourceManager.getStringByName("card_count") + ": " + count.description + "  " +
                UResourceManager.getStringByName("count_not_learned") + ": " + ngCount.description

        // 最終学習日
        let date = book.getLastStudiedTime()
        let dateStr = (date == nil) ? " --- " : UUtil.convDateFormat(date: date!, mode: ConvDateMode.DateTime)

        mStudiedDate = String(format: "学習日時 : %@", dateStr)
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
    public override func draw( _ offset : CGPoint? ) {
        var _pos = CGPoint(x: pos.x, y: pos.y)
        if offset != nil {
            _pos.x += offset!.x
            _pos.y += offset!.y
        }

        super.draw(_pos)

        var x = _pos.x + UDpi.toPixel(MARGIN_H)
        var y = _pos.y + UDpi.toPixel(MARGIN_V)
        let margin = UDpi.toPixel(TEXT_SIZE + MARGIN_V)

        // Icon image
        UDraw.drawImage( image : mIcon!, x : x, y : _pos.y + (itemH-UDpi.toPixel(ICON_W)) / 2,
                         width : UDpi.toPixel(ICON_W), height : UDpi.toPixel(ICON_W) );
        x += UDpi.toPixel(ICON_W + MARGIN_H);
        // Book名
        UDraw.drawText( text : mTextName!, alignment : UAlignment.None, textSize : Int(UDpi.toPixel(TEXT_SIZE)), x : x, y : y, color : UColor.makeColor(50,150,50))
        y += margin
        
        // 学習日時
        UDraw.drawText( text : mStudiedDate!, alignment : UAlignment.None, textSize : Int(UDpi.toPixel(TEXT_SIZE2)),
                        x : x, y : y, color : TEXT_COLOR)
        y += margin;

        // カード数
        UDraw.drawText( text : mCardCount!, alignment : UAlignment.None, textSize : Int(UDpi.toPixel(TEXT_SIZE2)), x : x, y : y, color : UColor.DarkGray)
    }

    /**
     *
     * @param vt
     * @return
     */
    public override func touchEvent( vt : ViewTouch, offset : CGPoint?) -> Bool {
        if super.touchEvent(vt: vt, offset: offset) {
            return true;
        }
        return false;
    }

    /**
     * UButtonCallbacks
     */
    public func UButtonClicked(id : Int, pressedOn : Bool) -> Bool {
        return false
    }
}


//
//  ListItemStudyBook.swift
//  TangoBook
//      学習する単語帳を選択するListViewのアイテム
//  Created by Shusuke Unno on 2017/08/07.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import SpriteKit

public class ListItemStudyBook : UListItem {
    /**
     * Enums
     */

    /**
     * Constants
     */
    public let TAG = "ListItemStudiedBook";

    private let FONT_SIZE = 17
    private let FONT_SIZE2 = 13
    private let TEXT_COLOR = UIColor.black
    private let ICON_W = 30

    private let MARGIN_H = 10
    private let MARGIN_V = 5

    private let FRAME_WIDTH = 1
    private let FRAME_COLOR = UIColor.black
    private let TITLE_COLOR : UIColor = UColor.makeColor(50,150,50)

    /**
     * Member variables
     */
    // SpriteKit Node
    private var iconNode : SKSpriteNode?
    
    private var mTextName : String? = nil
    private var mStudiedDate : String? = nil
    private var mCardCount : String? = nil
    private var mBook : TangoBook? = nil
    private var mIcon : UIImage? = nil
    
    private var mTitleView : UTextView?
    private var mDateView : UTextView?
    private var mInfoView : UTextView?
    

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
                book : TangoBook, width : CGFloat, bgColor : UIColor)
    {
        super.init(callbacks : listItemCallbacks,
                   isTouchable : true,
                   x : 0, width : width, height : UDpi.toPixel(FONT_SIZE) * 3 + UDpi.toPixel(MARGIN_V)*4,
                   bgColor : bgColor, frameW : UDpi.toPixel(FRAME_WIDTH), frameColor : FRAME_COLOR)
        mBook = book;
        itemH = UDpi.toPixel(FONT_SIZE) * 3 + UDpi.toPixel(MARGIN_V) * 4

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
        let dateStr : String? = (date == nil) ? " --- " : UUtil.convDateFormat(date: date!, mode: ConvDateMode.DateTime)

        mStudiedDate = String(format: "学習日時 : %@", dateStr!)
        
        initSKNode()
    }
    
    /**
     * SpriteKitノードを生成
     */
    public override func initSKNode() {
        var x = UDpi.toPixel(MARGIN_H)
        var y = UDpi.toPixel(MARGIN_V)
        let marginV = UDpi.toPixel(MARGIN_V)

        // 単語帳アイコン
        iconNode = SKSpriteNode(texture : SKTexture(image: mIcon!))
        iconNode!.position = CGPoint(x: x, y: (itemH - UDpi.toPixel(ICON_W)) / 2)
        iconNode!.anchorPoint = CGPoint(x:0, y:1)
        iconNode!.size = CGSize(width: UDpi.toPixel(ICON_W), height: UDpi.toPixel(ICON_W))
        parentNode.addChild2( iconNode! )
        
        x += UDpi.toPixel(ICON_W + MARGIN_H)
        
        // 単語帳の名前
        mTitleView = UTextView(text: mTextName!, fontSize: UDpi.toPixel(FONT_SIZE), priority: 1, alignment: .Left, createNode: true, isFit: true, isDrawBG: false, margin: 0, x: x, y: y, width: size.width - x - UDpi.toPixel(MARGIN_H), color: TITLE_COLOR, bgColor: nil)
        parentNode.addChild2( mTitleView!.parentNode )
        
        y += marginV + mTitleView!.getHeight()
        
        // 学習日時
        mDateView = UTextView(text: mStudiedDate!, fontSize: UDpi.toPixel(FONT_SIZE2), priority: 1, alignment: .Left, createNode: true, isFit: true, isDrawBG: false, margin: 0, x: x, y: y, width: size.width - x - UDpi.toPixel(MARGIN_H), color: TEXT_COLOR, bgColor: nil)
        parentNode.addChild2( mDateView!.parentNode )
        
        y += marginV + mDateView!.getHeight()
        
        // カード数
        mInfoView = UTextView(text: mCardCount!, fontSize: UDpi.toPixel(FONT_SIZE2), priority: 1, alignment: .Left, createNode: true, isFit: true, isDrawBG: false, margin: 0, x: x, y: y, width: size.width - x - UDpi.toPixel(MARGIN_H), color: UColor.DarkGray, bgColor: nil)
        parentNode.addChild2( mInfoView!.parentNode )
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
    public override func draw() {
        super.draw()
    }

    /**
     *
     * @param vt
     * @return
     */
    public override func touchEvent( vt : ViewTouch, offset : CGPoint?) -> Bool {
        if super.touchEvent(vt: vt, offset: offset) {
            return true
        }
        return false
    }

    /**
     * UButtonCallbacks
     */
    public func UButtonClicked(id : Int, pressedOn : Bool) -> Bool {
        return false
    }
}


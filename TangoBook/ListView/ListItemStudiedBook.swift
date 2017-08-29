//
//  ListItemStudiedBook.swift
//  TangoBook
//      単語帳の学習履歴ListView(ListViewStudyHistory)に表示する項目
//  Created by Shusuke Unno on 2017/08/07.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import SpriteKit

public enum ListItemStudiedBookType : Int {
    case Title
    case History     // 単語帳の学習履歴
}

public class ListItemStudiedBook : UListItem {
    // MARK: Constants
    private static let FONT_SIZE : Int = 17
    private static let FONT_SIZE2 : Int  = 14
    private static let MARGIN_H : Int  = 17
    private static let MARGIN_V : Int  = 5
    private static let TITLE_H : Int  = 27
    private let FRAME_WIDTH : Int  = 1
    private let FRAME_COLOR : UIColor = .black
    
    // MARK: Properties
    // SpriteKit Node
    private var titleNode : SKLabelNode!
    
    private var mType : ListItemStudiedBookType
    private var mTitle : String?          // 期間を表示する項目
    private var mTextDate : String?
    private var mTextName : String?
    private var mTextInfo : String?
    private var mBookHistory : TangoBookHistory?

    // MARK: Accessor
    public func getType() -> ListItemStudiedBookType {
        return mType
    }
    
    public func getBookHistory() -> TangoBookHistory {
        return mBookHistory!
    }
    
    // MARK: Initializer
    public init( listItemCallbacks : UListItemCallbacks?,
                 type : ListItemStudiedBookType, isTouchable : Bool,
                 history : TangoBookHistory?,
                 x : CGFloat, width : CGFloat, height : CGFloat, textColor : UIColor, bgColor : UIColor?)
    {
        mType = type
        mBookHistory = history
        
        super.init(callbacks : listItemCallbacks, isTouchable : isTouchable,
                   x : x, width : width, height : height,
                   bgColor : bgColor, frameW : UDpi.toPixel(FRAME_WIDTH), frameColor : FRAME_COLOR)
        pressedColor = UColor.addBrightness( argb: color, addY: -0.2)
        
    }

    // ListItemResultType.OKのインスタンスを生成する
    public static func createHistory(history : TangoBookHistory,
                                     width : CGFloat, textColor : UIColor, bgColor : UIColor) -> ListItemStudiedBook? {
        let instance : ListItemStudiedBook =
            ListItemStudiedBook(
                listItemCallbacks : nil, type : ListItemStudiedBookType.History,
                isTouchable : true, history : history,
                x : 0, width : width, height : UDpi.toPixel(ListItemStudiedBook.FONT_SIZE) * 3 + UDpi.toPixel(ListItemStudiedBook.MARGIN_V) * 4,
                textColor : textColor, bgColor : bgColor)
        
        var book : TangoBook? = TangoBookDao.selectById( id: history.bookId )
        if book == nil {
            // 削除されるなどして存在しない場合は表示しない
            return nil
        }
        
        instance.mTextDate = String(
            format: "学習日時: %@",
            UUtil.convDateFormat(date: history.studiedDateTime, mode: ConvDateMode.DateTime)!)
        
        instance.mTextName = UResourceManager.getStringByName("book") + ": " + book!
            .getName()!
        instance.mTextInfo = String(format: "OK:%d  NG:%d", history.okNum, history
            .ngNum)
        
        // SpriteKit Node
        // titleNode
        let x = UDpi.toPixel(ListItemStudiedBook.MARGIN_H)
        var y = UDpi.toPixel(ListItemStudiedBook.MARGIN_V)
        
        // BGや枠描画は親クラスのdrawメソッドで行う
        let fontSize : CGFloat = UDpi.toPixel(ListItemStudiedBook.FONT_SIZE)
        
        // 単語帳名
        var result = SKNodeUtil.createLabelNode(
            text: instance.mTextName!, fontSize: UDpi.toPixel(ListItemStudiedBook.FONT_SIZE),
            color: .black, alignment: .Left,
            pos: CGPoint(x: x, y: y))
        instance.parentNode.addChild2( result.node )
        
        y += result.size.height + UDpi.toPixel(MARGIN_V)
        
        // 学習日時
        result = SKNodeUtil.createLabelNode(
            text: instance.mTextDate!, fontSize: UDpi.toPixel(ListItemStudiedBook.FONT_SIZE2),
            color: .black, alignment: .Left,
            pos: CGPoint(x: x, y: y))
        
        instance.parentNode.addChild2( result.node )
        y += result.size.height + UDpi.toPixel(MARGIN_V)
        
        // OK/NG
        result = SKNodeUtil.createLabelNode(
            text: instance.mTextInfo!, fontSize: UDpi.toPixel(ListItemStudiedBook.FONT_SIZE2),
            color: .black, alignment: .Left,
            pos: CGPoint(x: x, y: y))
        
        instance.parentNode.addChild2( result.node )
        
        return instance
    }

    // ListItemResultType.Title のインスタンスを生成する
    public static func createTitle( text : String, width : CGFloat,
                                    textColor : UIColor , bgColor : UIColor?) -> ListItemStudiedBook?
    {
        let instance = ListItemStudiedBook(
            listItemCallbacks : nil, type : ListItemStudiedBookType.Title,
            isTouchable : false, history : nil,
            x : 0, width : width, height : UDpi.toPixel(ListItemStudiedBook.TITLE_H), textColor : textColor, bgColor : bgColor)
        instance.mTitle = text
        instance.mFrameW = 0
        
        // titleNode
        instance.titleNode = SKNodeUtil.createLabelNode(
            text: text, fontSize: UDpi.toPixel(ListItemStudiedBook.FONT_SIZE),
            color: .black, alignment: .Center,
            pos: CGPoint(x: instance.size.width / 2, y: instance.size.height / 2)).node
        
        instance.parentNode.addChild2(instance.titleNode)
        
        return instance
    }
    
    // MARK: Methods
    /**
     * 描画処理
     * @param offset 独自の座標系を持つオブジェクトをスクリーン座標系に変換するためのオフセット値
     */
    public override func draw() {
//        let _textColor : UIColor = .black
//        
//        var x = pos.x + UDpi.toPixel(ListItemStudiedBook.MARGIN_H)
//        var y = pos.y + UDpi.toPixel(ListItemStudiedBook.MARGIN_V)
//        
//        // BGや枠描画は親クラスのdrawメソッドで行う
//        super.draw()
//        
//        let fontSize : CGFloat = UDpi.toPixel(ListItemStudiedBook.FONT_SIZE)
//        
//        if mType == ListItemStudiedBookType.History {
//            // 履歴
            // Book名
//            UDraw.drawTextOneLine(canvas, paint, mTextName, UAlignment.None,
//                                  fontSize, x, y, _textColor);
//            y += fontSize + UDpi.toPixel(MARGIN_V);
//            
//            // 学習日時
//            UDraw.drawTextOneLine(canvas, paint, mTextDate, UAlignment.None,
//                                  UDpi.toPixel(FONT_SIZE2) , x, y, _textColor);
//            y += fontSize + UDpi.toPixel(MARGIN_V);
//            
//            // OK/NG数 正解率
//            UDraw.drawTextOneLine(canvas, paint, mTextInfo, UAlignment.None,
//                                  UDpi.toPixel(FONT_SIZE2), x, y, _textColor);
//        }
    }

    public override func touchEvent( vt : ViewTouch, offset : CGPoint?) -> Bool{
        if super.touchEvent(vt: vt, offset: offset) {
            return true
        }
        return false
    }
    
    /**
     * 高さを返す
     */
    public override func getHeight() -> CGFloat {
        return size.height
    }
    
    /**
     * UButtonCallbacks
     */
    public func UButtonClicked(id : Int, pressedOn : Bool) -> Bool{
        return false
    }
}

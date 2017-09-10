//
//  LIstItemResult.swift
//  TangoBook
//      学習結果ListView(ListViewResult)のアイテム
//  Created by Shusuke Unno on 2017/08/07.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import SpriteKit

public class ListItemResult : UListItem, UButtonCallbacks {
    
    // MARK: Enums
    public enum ListItemResultType : Int{
        case Title
        case OK
        case NG
    }

    // MARK: Constants
    public let TAG = "ListItemOption"

    private static let MAX_TEXT = 60

    private static let ButtonIdStar = 100100

    private static let PRIORITY_TEXT = 2
    private static let PRIORITY_BUTTON = 1
    
    // 座標系
    private static let TITLE_H = 27
    private static let CARD_H = 40
    private static let FONT_SIZE = 17
    private static let STAR_ICON_W = 34
    private let FRAME_WIDTH = 1
    private static let MARGIN_H = 10

    // color
    private let FRAME_COLOR : UIColor = .black

    // MARK: Properties
    
    private var mType : ListItemResultType
    private var mText : String?, mText2 : String?
    private var isOK : Bool = false
    private var mCard : TangoCard?
    private var mTextColor : UIColor
    private var mTitleView : UTextView?
    private var mStarButton : UButtonImage?
    private var mLearnedTextW : Int = 0        // "覚えた"のテキストの幅

    // MARK: Accessor
    public func getType() -> ListItemResultType {
        return mType
    }

    public func getCard() -> TangoCard? {
        return mCard
    }

    // MARK: Initializer
    public init(listItemCallbacks : UListItemCallbacks?,
                type : ListItemResultType, isTouchable : Bool, card : TangoCard?,
                x : CGFloat, width : CGFloat,  height : CGFloat,
                textColor : UIColor, bgColor : UIColor)
    {
        mType = type
        mTextColor = textColor
        mCard = card

        super.init( callbacks : listItemCallbacks, isTouchable : isTouchable, x : x, width : width, height : height, bgColor : bgColor, frameW : UDpi.toPixel(FRAME_WIDTH), frameColor : FRAME_COLOR )
    }
    
    /**
     * SpriteKitのノード作成
     */

    // ListItemResultType.Title のインスタンスを生成する
    public static func createTitle( isOK : Bool, width : CGFloat,
                                    textColor : UIColor, bgColor : UIColor ) -> ListItemResult?
    {
        let text = isOK ? "OK" : "NG"
        let instance = ListItemResult(
            listItemCallbacks : nil,
            type : ListItemResultType.Title, isTouchable : false,
            card : nil, x : 0, width : width, height: UDpi.toPixel(ListItemResult.TITLE_H),
            textColor : textColor, bgColor : bgColor )
        
        instance.isOK = isOK
        instance.mText = text
        
        // SpriteKit Node
        let fontSize = UDpi.toPixel(ListItemResult.FONT_SIZE)
        let node = SKNodeUtil.createLabelNode(text: text, fontSize: fontSize, color: .white, alignment: .Center, pos: CGPoint(x: instance.size.width / 2, y: instance.size.height / 2)).node
        instance.parentNode.addChild2(node)
        
        if isOK {
            // 「覚えた」のテキスト
            let node2 = SKNodeUtil.createLabelNode(text: UResourceManager.getStringByName("learned"), fontSize: fontSize, color: .white, alignment: .Right_CenterY, pos: CGPoint(x: instance.size.width - UDpi.toPixel(ListItemResult.MARGIN_H), y: instance.size.height / 2)).node
            instance.parentNode.addChild2(node2)
        }
        
        return instance
    }

    // ListItemResultType.OKのインスタンスを生成する
    // @param star 覚えたアイコン(Star)を表示するかどうか
    public static func createOK(
        card : TangoCard, studyMode : StudyMode,
        isEnglish : Bool, star : Bool,
        width : CGFloat, textColor : UIColor, bgColor : UIColor) -> ListItemResult
    {
        let instance : ListItemResult = ListItemResult(
            listItemCallbacks : nil, type : ListItemResultType.OK, isTouchable : true,
            card : card, x : 0, width : width, height: UDpi.toPixel(ListItemResult.CARD_H),
            textColor : textColor, bgColor : bgColor)

        instance.mText = ListItemResult.convString(isEnglish ? card.wordA : card.wordB)
        instance.mText2 = ListItemResult.convString(isEnglish ? card.wordB : card.wordA)
        
        // title node
        instance.mTitleView = UTextView(text: instance.mText!, fontSize: UDpi.toPixel(ListItemResult.FONT_SIZE), priority: ListItemResult.PRIORITY_TEXT, alignment: .Center, createNode: true, isFit: true, isDrawBG: false, margin: 0, x: instance.size.width / 2, y: instance.size.height / 2, width: instance.size.width - UDpi.toPixel(16), color: .black, bgColor: nil)
        instance.parentNode.addChild2( instance.mTitleView!.parentNode )
        
        // Starボタンを追加(On/Offあり)
        if star {
            let image = UResourceManager.getImageWithColor(
                imageName: ImageName.favorites, color: UColor.OrangeRed)
            let image2 = UResourceManager.getImageWithColor(
                imageName: ImageName.favorites2, color: UColor.OrangeRed)
            
            instance.mStarButton = UButtonImage(
                callbacks : instance as UButtonCallbacks, id : ListItemResult.ButtonIdStar, priority : PRIORITY_BUTTON,
                x : instance.size.width - UDpi.toPixel(50),
                y : (instance.size.height - UDpi.toPixel( ListItemResult.STAR_ICON_W ) ) / 2,
                width : UDpi.toPixel(ListItemResult.STAR_ICON_W),
                height : UDpi.toPixel(STAR_ICON_W),
                image : image!, pressedImage : nil)
            
            instance.mStarButton!.addState( image: image2!)
            instance.mStarButton!.setState(card.star ? 1 : 0)
            instance.parentNode.addChild2( instance.mStarButton!.parentNode )
        }
        return instance
    }

    // ListItemResultType.NGのインスタンスを生成する
    public static func createNG(
        card : TangoCard, studyMode : StudyMode, isEnglish : Bool,
        width : CGFloat, textColor : UIColor, bgColor : UIColor) -> ListItemResult
    {
        let instance = ListItemResult(
            listItemCallbacks : nil, type : ListItemResultType.NG,
            isTouchable : true, card : card, x : 0,
            width : width, height: UDpi.toPixel(ListItemResult.CARD_H),
            textColor : textColor, bgColor : bgColor)
        instance.mText = convString(isEnglish ? card.wordA : card.wordB)
        instance.mText2 = convString(isEnglish ? card.wordB : card.wordA)
        instance.size.height = UDpi.toPixel(ListItemResult.CARD_H)
        
        //SpriteKit Node1
        instance.mTitleView = UTextView(
            text: instance.mText!, fontSize: UDpi.toPixel(ListItemResult.FONT_SIZE), priority: ListItemResult.PRIORITY_TEXT, alignment: .Center, createNode: true, isFit: true, isDrawBG: false, margin: 0,
            x: instance.size.width / 2, y: instance.size.height / 2,
            width: instance.size.width - UDpi.toPixel(16), color: .black, bgColor: nil)
        
        instance.parentNode.addChild2( instance.mTitleView!.parentNode )
        
        return instance
    }

    // MARK: Methods
    public override func doAction() -> DoActionRet{
        if mStarButton != nil {
            return mStarButton!.doAction()
        }
        return .None
    }

    /**
     * 描画処理
     * @param canvas
     * @param paint
     * @param offset 独自の座標系を持つオブジェクトをスクリーン座標系に変換するためのオフセット値
     */
    public override func draw() {
        super.draw()

        switch mType {
        case .Title:
            break
        case .OK:
            fallthrough
        case .NG:
            let text = isTouching ? mText2 : mText
            if let _text = text {
                mTitleView!.setText( _text )
            }
        }

        if mStarButton != nil {
            mStarButton!.draw()
        }
    }

    /**
     *
     * @param vt
     * @return
     */
    public override func touchEvent( vt : ViewTouch, offset : CGPoint?) -> Bool{
        var offset = offset
        if offset == nil {
            offset = CGPoint()
        }
        // Starボタンのクリック処理
        if mStarButton != nil {
            var offset2 = pos
            offset2.x += offset!.x
            offset2.y += offset!.y
            
            if mStarButton!.touchEvent(vt: vt, offset: offset2) {
                return true
            }
        }

        var isDraw = false
        switch vt.type {
        case .Touch:
            if isTouchable {
                if rect.contains(x: vt.touchX - offset!.x, y: vt.touchY - offset!.y) {
                    isTouching = true
                    isDraw = true
                }
            }
            break
        default:
            break
        }

        return isDraw
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
        if id == ListItemResult.ButtonIdStar {
            let star = TangoCardDao.toggleStar(card: mCard!)

            // 表示アイコンを更新
            mStarButton!.setState(star ? 1 : 0)
            return true
        }
        return false
    }

    /**
     * 表示するためのテキストに変換（改行なし、最大文字数制限）
     * @param text
     * @return
     */
    private static func convString( _ text : String?) -> String? {
        if text == nil {
            return nil
        }
        // 改行を除去
        var _text = text!.replacingOccurrences(of: "\n", with: " ")
        
        // 最大文字数制限
        if _text.characters.count > MAX_TEXT {
            return _text.substring(to: _text.index( _text.startIndex, offsetBy: MAX_TEXT))
        }
        return _text
    }
}


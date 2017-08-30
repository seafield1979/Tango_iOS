//
//  ListItemOption.swift
//  TangoBook
//      オプションページのListViewに表示する項目
//  Created by Shusuke Unno on 2017/08/07.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import SpriteKit

public struct OptionInfo {
    var title : String
    var isTitle : Bool
    var color : UIColor
    var bgColor : UIColor
}

public enum OptionItems : Int, EnumEnumerable {
    case TitleEdit      // [単語帳編集]
    case ColorBook      // 新規追加の単語帳の色
    case ColorCard      // 新規追加のカードの色
    case CardTitle      // 編集ページで表示されるタイトルの種類(英語 or 日本語)
    case TitleStudy     // [学習]
    case StudyMode3     // ４択モードの不正解カード抽出範囲
    case StudyMode4     // 正解入力学習モードの文字並び順
    
    public func getItemInfo() -> OptionInfo {
        switch self {
        case .TitleEdit:    // [単語帳編集]
            return OptionInfo(title : "title_option_edit", isTitle : true, color : UIColor.black, bgColor : UColor.LightGreen)
            
        case .ColorBook:      // 新規追加の単語帳の色
            return OptionInfo(title : "option_color_book", isTitle : false, color : UIColor.black, bgColor : UIColor.white)
            
        case .ColorCard:      // 新規追加のカードの色
            return OptionInfo(title : "option_color_card", isTitle : false, color : UIColor.black, bgColor : UIColor.white)
            
        case .CardTitle:      // 編集ページで表示されるタイトルの種類(英語 or 日本語)
            return OptionInfo(title : "option_card_title", isTitle : false, color : UIColor.black, bgColor : UIColor.white)
            
        case .TitleStudy:     // [学習]
            return OptionInfo(title : "title_option_study", isTitle : true, color : UIColor.black, bgColor : UColor.LightRed)
            
        case .StudyMode3:     // ４択モードの不正解カード抽出範囲
            return OptionInfo(title : "option_mode3_1", isTitle : false, color : UIColor.black, bgColor : UIColor.white)
            
        case .StudyMode4:     // 正解入力学習モードの文字並び順
            return OptionInfo(title : "option_mode4_1", isTitle : false, color : UIColor.black, bgColor : UIColor.white)
        }
    }
    
    public static func getItems( mode : PageViewOptions.Mode ) -> [OptionItems]? {
        switch mode {
        case .All:
            return cases
        case .Edit:
            let items : [OptionItems] = [
                    TitleEdit, ColorBook, ColorCard, CardTitle]
            return items
        
        case .Study:
            let items : [OptionItems] = [ TitleStudy, StudyMode3, StudyMode4 ]
            return items
            
        }
    }
}

public class ListItemOption : UListItem {
    // MARK: Constants
    public let TAG = "ListItemOption"
    private let TITLE_H = 27
    private let FONT_SIZE = 17
    private let FRAME_WIDTH = 1
    private let FRAME_COLOR = UIColor.black
   
    // MARK: Properties
    // SpriteKit Node
    private var titleNode : SKLabelNode?
    private var colorNode : SKShapeNode?
    
    private var mItemType : OptionItems
    private var mTitle : String
    private var mColor : UIColor
    private var mBgColor : UIColor
    
    // MARK: Accessor
    public func setTitle( _ title : String) {
        mTitle = title
    }
    
    public func getColorNode() -> SKShapeNode {
        return colorNode!
    }

    public func getTitleNode() -> SKLabelNode {
        return titleNode!
    }
    
    // MARK: Initializer
    public init(listItemCallbacks : UListItemCallbacks?,
                itemType : OptionItems, title : String, isTitle : Bool, color : UIColor, bgColor : UIColor,
        x : CGFloat, width : CGFloat) {
        
        self.mItemType = itemType
        self.mTitle = title
        self.mColor = color
        self.mBgColor = bgColor
        
        var height : CGFloat
        switch mItemType {
        case .ColorBook:
            fallthrough
        case .ColorCard:
            height = UDpi.toPixel(50)
            
        case .CardTitle:
            fallthrough
        case .StudyMode3:
            fallthrough
        case .StudyMode4:
            height = UDpi.toPixel(67)
        default:
            height = UDpi.toPixel(40)
        }
        
        super.init(callbacks : listItemCallbacks, isTouchable : !isTitle,
                   x : x, width : width, height : height,
                   bgColor : bgColor, frameW : UDpi.toPixel(FRAME_WIDTH),
                   frameColor : FRAME_COLOR)
        
        initSKNode()
    }
    
    public override func initSKNode() {
        titleNode = SKNodeUtil.createLabelNode(text: mTitle, fontSize: UDpi.toPixel(FONT_SIZE), color: .black, alignment: .Center, pos: CGPoint(x: size.width / 2, y: size.height / 2)).node
        parentNode.addChild2( titleNode! )
        
        if mItemType == .ColorBook || mItemType == .ColorCard {
            let color = MySharedPref.readInt(
                (mItemType == .ColorBook) ?
                    MySharedPref.DefaultColorBookKey :
                    MySharedPref.DefaultColorCardKey)
            
            let _color = UColor.makeColor(argb: UInt32(color))
            let _pos = CGPoint(x: size.width - UDpi.toPixel(50),
                               y: UDpi.toPixel(50 / 2))
            let w = UDpi.toPixel(34)
            colorNode = SKNodeUtil.createRectNode(rect: CGRect(x: -w/2, y: -w/2, width: w, height: w), color: _color, pos: _pos, cornerR: 0)
            
            // 色が未設定なら非表示
//            if color == 0 {
//                colorNode!.isHidden = true
//            }
            parentNode.addChild2( colorNode! )
        }
    }
    
    /**
     * Methods
     */
    
    /**
     * 描画処理
     * @param offset 独自の座標系を持つオブジェクトをスクリーン座標系に変換するためのオフセット値
     */
    public override func draw() {
        super.draw()
    }
    
    /**
     * 高さを返す
     */
    public override func getHeight() -> CGFloat {
        return size.height
    }
}



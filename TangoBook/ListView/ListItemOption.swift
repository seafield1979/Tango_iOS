//
//  ListItemOption.swift
//  TangoBook
//      オプションページのListViewに表示する項目
//  Created by Shusuke Unno on 2017/08/07.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import UIKit
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
    case DefaultNameBook    // 新規追加単語帳の先頭文字列
    case DefaultNameCard    // 新規追加カードの先頭文字列
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
            
        case .DefaultNameBook:    // 新規追加単語帳の先頭文字列
            return OptionInfo(title : "option_default_name_book", isTitle : false, color : UIColor.black, bgColor : UIColor.white)
            
        case .DefaultNameCard:    // 新規追加カードの先頭文字列
            return OptionInfo(title : "option_default_name_card", isTitle : false, color : UIColor.black, bgColor : UIColor.white)
            
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
                    TitleEdit, ColorBook, ColorCard, CardTitle, DefaultNameBook,
                    DefaultNameCard]
            return items
        
        case .Study:
            let items : [OptionItems] = [ TitleStudy, StudyMode3, StudyMode4 ]
            return items
            
        }
    }
}

public class ListItemOption : UListItem {
    /**
     * Constants
     */
    public let TAG = "ListItemOption"
    private let TITLE_H = 27
    private let FONT_SIZE = 17
    private let FRAME_WIDTH = 1
    private let FRAME_COLOR = UIColor.black
    
    /**
     * Member variables
     */
    private var mItemType : OptionItems
    private var mTitle : String
    private var mColor : UIColor
    private var mBgColor : UIColor
    
    /**
     * Get/Set
     */
    public func setTitle( title : String) {
        mTitle = title
    }
    
    /**
     * Constructor
     */
    public init(listItemCallbacks : UListItemCallbacks?,
                itemType : OptionItems, title : String, isTitle : Bool, color : UIColor,bgColor : UIColor,
        x : CGFloat, width : CGFloat) {
        
        self.mItemType = itemType
        self.mTitle = title
        self.mColor = color
        self.mBgColor = bgColor
        
        super.init(callbacks : listItemCallbacks, isTouchable : !isTitle,
                   x : x, width : width, height : UDpi.toPixel(TITLE_H),
                   bgColor : bgColor, frameW : UDpi.toPixel(FRAME_WIDTH),
                   frameColor : FRAME_COLOR)
        
        switch mItemType {
        case .ColorBook:
            fallthrough
        case .ColorCard:
            size.height = UDpi.toPixel(50)
            
        case .CardTitle:
            fallthrough
        case .DefaultNameBook:
            fallthrough
        case .DefaultNameCard:
            fallthrough
        case .StudyMode3:
            fallthrough
        case .StudyMode4:
            size.height = UDpi.toPixel(67)
        default:
            size.height = UDpi.toPixel(40)
        }
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
//        PointF _pos = new PointF(pos.x, pos.y);
//        if (offset != null) {
//            _pos.x += offset.x;
//            _pos.y += offset.y;
//        }
//        
//        super.draw(canvas, paint, _pos);
//        
//        UDraw.drawText(canvas, mTitle, UAlignment.Center, UDpi.toPixel(FONT_SIZE),
//                       _pos.x + size.width / 2, _pos.y + size.height / 2, mColor);
//        
//        switch(mItemType) {
//        case ColorBook:
//        case ColorCard: {
//            int color = MySharedPref.readInt(
//                (mItemType == OptionItems.ColorBook) ?
//                    MySharedPref.DefaultColorBookKey :
//                    MySharedPref.DefaultColorCardKey);
//            if (color != 0) {
//                _pos.x += size.width - UDpi.toPixel(50);
//                _pos.y += UDpi.toPixel(7);
//                UDraw.drawRectFill(canvas, paint,
//                                   new Rect((int) _pos.x, (int) _pos.y,
//                                            (int) _pos.x + UDpi.toPixel(34),
//                                            (int) _pos.y + size.height - UDpi.toPixel(13)),
//                                   color, 0, 0);
//            }
//        }
//        break;
//        }
    }
    
    /**
     * 高さを返す
     */
    public override func getHeight() -> CGFloat {
        return size.height
    }
}



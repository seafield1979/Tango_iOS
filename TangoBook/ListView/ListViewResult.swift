//
//  ListViewResult.swift
//  TangoBook
//
//  Created by Shusuke Unno on 2017/08/07.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import UIKit


/**
 * Created by shutaro on 2016/12/11.
 *
 * リザルトページで表示するListView
 */

public class ListViewResult : UListView {

    /**
     * Enums
     */
    /**
     * Constants
     */
    private let TITLE_TEXT_COLOR = UIColor.white
    private let TITLE_OK_COLOR = UColor.makeColor(50,200,50)
    private let TITLE_NG_COLOR = UColor.makeColor(200,50,50)
    private let ITEM_BG_COLOR = UIColor.white
    private let ITEM_TEXT_COLOR = UIColor.black

    /**
     * Member variables
     */
    
    /**
     * Get/Set
     */
    
    /**
     * Constructor
     */
    // OKカードとNGカードが別で渡ってくるパターン(リザルトページ)
    // @param studyMode  学習モード false:英->日  true:日->英
    public init( topScene: TopScene, listItemCallbacks : UListItemCallbacks?,
                 okCards : List<TangoCard>, ngCards : List<TangoCard>,
                 studyMode : StudyMode, studyType : StudyType,
                 priority : Int, x : CGFloat, y : CGFloat, width : CGFloat,
                 height : CGFloat, color : UIColor)
    {
        super.init(topScene : topScene, windowCallbacks : nil, listItemCallbacks : listItemCallbacks, priority : priority,
                   x : x, y : y, width : width, height : height, bgColor : color)
        
        initItems(okCards : okCards, ngCards : ngCards, studyMode : studyMode, studyType : studyType, star : true)
        
    }

    // OKカードとNGカードが同じリストに入って渡ってくる
    // 履歴ページで表示する用途
    public init( topScene: TopScene, listItemCallbacks : UListItemCallbacks?,
                 studiedCards : List<TangoStudiedCard>,
                 studyMode : StudyMode, studyType : StudyType,
                 priority : Int, x : CGFloat, y : CGFloat, width : CGFloat, height : CGFloat, color : UIColor)
    {
        super.init(topScene : topScene, windowCallbacks : nil,
                   listItemCallbacks : listItemCallbacks, priority : priority,
                   x : x, y : y,
                   width : width, height : height, bgColor : color)
        
        let ngCards : [TangoCard]? = TangoCardDao.selectByStudiedCards(
            studiedCards: studiedCards.toArray(), ok: false, changeable: false)
        
        let okCards : [TangoCard]? = TangoCardDao.selectByStudiedCards(
            studiedCards : studiedCards.toArray(), ok: true, changeable: false)
        
        var _okCards : List<TangoCard> = (okCards == nil) ? List() : List(okCards!)
        var _ngCards : List<TangoCard> = (ngCards == nil) ? List() : List(ngCards!)
        
        initItems(okCards : _okCards, ngCards : _ngCards, studyMode : studyMode, studyType : studyType, star : true)
    }

    /**
     * Methods
     */
    public override func drawContent(offset: CGPoint?) {
        super.drawContent(offset: offset)
    }

    public override func doAction() -> DoActionRet{
        var ret : DoActionRet = .None
        ret = .Redraw
        for item in mItems {
            let _ret : DoActionRet = item!.doAction()
            switch _ret {
            case .Done:
                return .Done
            case .Redraw:
                ret = .Redraw
            default:
                break
            }
        }
        return ret
    }
    
    /**
     * アイテムを追加する
     * @param okCards
     * @param ngCards
     * @param studyMode 学習モード
     */
    private func initItems( okCards : List<TangoCard>, ngCards : List<TangoCard>,
                            studyMode : StudyMode, studyType : StudyType,
                            star : Bool) {
        var item : ListItemResult? = nil
        // NG
//        if (ngCards != null && ngCards.size() > 0) {
//            // Title
//            item = ListItemResult.createTitle(false, size.width, TITLE_TEXT_COLOR, TITLE_NG_COLOR);
//            add(item);
//            // Items
//            for (TangoCard card : ngCards) {
//                item = ListItemResult.createNG(card, studyMode, (studyType == StudyType.EtoJ),
//                                               size.width, ITEM_TEXT_COLOR, ITEM_BG_COLOR);
//                add(item);
//            }
//        }
//        
//        // OK
//        if (okCards != null && okCards.size() > 0) {
//            // Title
//            item = ListItemResult.createTitle(true, size.width, TITLE_TEXT_COLOR, TITLE_OK_COLOR);
//            add(item);
//            // Items
//            for (TangoCard card : okCards) {
//                item = ListItemResult.createOK(card, studyMode, (studyType == StudyType.EtoJ),
//                                               star, size.width,
//                                               ITEM_TEXT_COLOR,
//                                               ITEM_BG_COLOR);
//                add(item);
//            }
//        }
//        
//        updateWindow();
    }

    
    /**
     * for Debug
     */
    public override func addDummyItems(count : Int) {
        updateWindow()
    }
}

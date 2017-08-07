//
//  ListViewResult.swift
//  TangoBook
//
//  Created by Shusuke Unno on 2017/08/07.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import Foundation


/**
 * Created by shutaro on 2016/12/11.
 *
 * リザルトページで表示するListView
 */

//public class ListViewResult extends UListView implements UButtonCallbacks {
//    
//    /**
//     * Enums
//     */
//    /**
//     * Constants
//     */
//    private static final int TITLE_TEXT_COLOR = Color.WHITE;
//    private static final int TITLE_OK_COLOR = Color.rgb(50,200,50);
//    private static final int TITLE_NG_COLOR = Color.rgb(200,50,50);
//    private static final int ITEM_BG_COLOR = Color.WHITE;
//    private static final int ITEM_TEXT_COLOR = Color.BLACK;
//    
//    /**
//     * Member variables
//     */
//    
//    /**
//     * Get/Set
//     */
//    
//    /**
//     * Constructor
//     */
//    // OKカードとNGカードが別で渡ってくるパターン(リザルトページ)
//    // @param studyMode  学習モード false:英->日  true:日->英
//    public ListViewResult(UListItemCallbacks listItemCallbacks,
//    List<TangoCard> okCards, List<TangoCard> ngCards,
//    StudyMode studyMode, StudyType studyType,
//    int priority, float x, float y, int width, int
//    height, int color)
//    {
//        super(null, listItemCallbacks, priority, x, y, width, height, color);
//        
//        initItems(okCards, ngCards, studyMode, studyType, true);
//        
//    }
//    
//    // OKカードとNGカードが同じリストに入って渡ってくる
//    // 履歴ページで表示する用途
//    public ListViewResult( UListItemCallbacks listItemCallbacks,
//    List<TangoStudiedCard> studiedCards,
//    StudyMode studyMode, StudyType studyType,
//    int priority, float x, float y, int width, int
//    height, int color)
//    {
//        super(null, listItemCallbacks, priority, x, y, width, height, color);
//        
//        List<TangoCard> ngCards = RealmManager.getCardDao().selectByStudiedCards(studiedCards,
//        false, false);
//        List<TangoCard> okCards = RealmManager.getCardDao().selectByStudiedCards(studiedCards,
//        true, false);
//        initItems(okCards, ngCards, studyMode, studyType, true);
//    }
//    
//    /**
//     * Methods
//     */
//    public void drawContent(Canvas canvas, Paint paint, PointF offset) {
//        super.drawContent(canvas, paint, offset);
//    }
//    
//    public DoActionRet doAction() {
//        DoActionRet ret = DoActionRet.None;
//        for (UListItem item : mItems) {
//            DoActionRet _ret = item.doAction();
//            switch(_ret) {
//            case Done:
//                return DoActionRet.Done;
//            case Redraw:
//                ret = DoActionRet.Redraw;
//                break;
//            }
//        }
//        return ret;
//    }
//    
//    /**
//     * アイテムを追加する
//     * @param okCards
//     * @param ngCards
//     * @param studyMode 学習モード
//     */
//    private void initItems(List<TangoCard> okCards, List<TangoCard> ngCards,
//    StudyMode studyMode, StudyType studyType,
//    boolean star) {
//        ListItemResult item = null;
//        // NG
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
//    }
//    
//    
//    /**
//     * for Debug
//     */
//    public void addDummyItems(int count) {
//        
//        updateWindow();
//    }
//    
//    /**
//     * Callbacks
//     */
//}

//
//  ListViewStudyHistory.swift
//  TangoBook
//
//  Created by Shusuke Unno on 2017/08/07.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import Foundation

/**
 * Created by shutaro on 2016/12/14.
 *
 * 学習履歴ページで表示するリストビュー
 * 学習した単語帳の一覧を表示する
 */

public class ListViewStudyHistory : UListView {
//    /**
//     * Enums
//     */
//    /**
//     * Constants
//     */
//    
//    private static final int LIMIT = 100;
//    private static final int TITLE_TEXT_COLOR = UColor.BLACK;
//    private static final int TITLE_BG_COLOR = UColor.Green;
//    /**
//     * Member variables
//     */
//    private Date[] beforeDate = new Date[5];
//    
//    /**
//     * Get/Set
//     */
//    
//    /**
//     * Constructor
//     */
//    public ListViewStudyHistory(UListItemCallbacks listItemCallbacks,
//    int priority, float x, float y, int width, int
//    height, int color)
//    {
//        super(null, listItemCallbacks, priority, x, y, width, height, color);
//        
//        List<TangoBookHistory> histories = RealmManager.getBookHistoryDao().selectAllWithLimit
//        (true, LIMIT);
//        
//        boolean[] dispTitleFlags = new boolean[5];
//        int[] titleStringIds = {
//            R.string.time_area_1,
//            R.string.time_area_2,
//            R.string.time_area_3,
//            R.string.time_area_4,
//            R.string.time_area_5 };
//        
//        // add items
//        initTimeArea();
//        for (TangoBookHistory history : histories) {
//            int time = getTimeArea(history.getStudiedDateTime());
//            
//            ListItemStudiedBook title = null;
//            
//            // Title
//            // 各時間の先頭にタイトルを追加
//            if (dispTitleFlags[time - 1] == false) {
//                dispTitleFlags[time - 1] = true;
//                String text = UResourceManager.getStringById(titleStringIds[time - 1]);
//                title = ListItemStudiedBook.createTitle( text, size.width, TITLE_TEXT_COLOR, TITLE_BG_COLOR);
//                add(title);
//            }
//            
//            // 学習した単語帳
//            ListItemStudiedBook item = ListItemStudiedBook.createHistory( history,
//                                                                          width, Color.BLACK, Color.WHITE);
//            if (item != null) {
//                add(item);
//            }
//        }
//        
//        updateWindow();
//    }
//    
//    /**
//     * Methods
//     */
//    /**
//     * 現在の日時から指定の日数分前のDateを求める
//     */
//    private void initTimeArea() {
//        Date nowDate = new Date();
//        
//        Calendar cal = Calendar.getInstance();
//        cal.setTime(nowDate);
//        
//        // 1日前
//        cal.add(Calendar.DAY_OF_MONTH, -1);
//        beforeDate[0]= cal.getTime();
//        
//        // 2日前
//        cal.add(Calendar.DAY_OF_MONTH, -2);
//        beforeDate[1] = cal.getTime();
//        
//        // １週間前まで
//        cal.add(Calendar.DAY_OF_MONTH, -7);
//        beforeDate[2] = cal.getTime();
//        
//        // 1ヶ月前まで
//        cal.add(Calendar.DAY_OF_MONTH, -30);
//        beforeDate[3] = cal.getTime();
//        
//    }
//    /**
//     * 日時のタイプを取得する
//     * @param date  判定元の日時
//     * @return  1:1日前 / 2:2日前 / 3:１週間前 / 4:１ヶ月前 : 5:１ヶ月以上前
//     */
//    private int getTimeArea(Date date) {
//        Date nowDate = new Date();
//        
//        Calendar cal = Calendar.getInstance();
//        cal.setTime(nowDate);
//        
//        // 1日前まで
//        if (date.after(beforeDate[0])) {
//            // 今日(~24時間前)
//            return 1;
//        }
//        
//        // 2日前まで
//        if (date.before(beforeDate[0]) && date.after(beforeDate[1])) {
//            // 昨日(24時間前 ~ 48時間前)
//            return 2;
//        }
//        
//        // １週間前まで
//        if (date.before(beforeDate[1]) && date.after(beforeDate[2])) {
//            // 48時間前 ~ １週間前
//            return 3;
//        }
//        
//        // 1ヶ月前まで
//        if (date.before(beforeDate[2]) && date.after(beforeDate[3])) {
//            // 48時間前 ~ １週間前
//            return 4;
//        }
//        // 1ヶ月以上前
//        return 5;
//    }
//    
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
}

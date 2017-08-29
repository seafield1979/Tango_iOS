//
//  ListViewStudyHistory.swift
//  TangoBook
//
//  Created by Shusuke Unno on 2017/08/07.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import UIKit

/**
 * Created by shutaro on 2016/12/14.
 *
 * 学習履歴ページで表示するリストビュー
 * 学習した単語帳の一覧を表示する
 */

public class ListViewStudyHistory : UListView {
    // MARK: Constants
    private let LIMIT : Int = 100
    private let TITLE_TEXT_COLOR : UIColor = UIColor.black
    private let TITLE_BG_COLOR : UIColor = UColor.Green

    private var beforeDate : [Date] = Array(repeating: Date(), count: 5)
    
    // MARK: Accessor

    // MARK: Initializer
    public init(topScene: TopScene, listItemCallbacks : UListItemCallbacks?,
                priority : Int, x : CGFloat, y : CGFloat, width : CGFloat, height : CGFloat, color : UIColor?)
    {
        super.init(topScene : topScene, windowCallbacks : nil,
                   listItemCallbacks : listItemCallbacks, priority : priority,
                   x : x, y : y,
                   width : width, height : height,
                   bgColor : color)
        
        let histories : [TangoBookHistory] = TangoBookHistoryDao.selectAllWithLimit(reverse: true, limit: LIMIT)
        
        var dispTitleFlags : [Bool] = Array(repeating: false, count: 5)
        let titleStrings : [String] = [
            "time_area_1",
            "time_area_2",
            "time_area_3",
            "time_area_4",
            "time_area_5" ]
        
        // add items
        initTimeArea()
        for history in histories {
            var time : Int = getTimeArea(date: history.studiedDateTime!)
            
            var title : ListItemStudiedBook? = nil
            
            // Title
            // 各時間の先頭にタイトルを追加
            if dispTitleFlags[time - 1] == false {
                dispTitleFlags[time - 1] = true
                let text = UResourceManager.getStringByName( titleStrings[time - 1])
                title = ListItemStudiedBook.createTitle( text : text, width : size.width, textColor : TITLE_TEXT_COLOR, bgColor : TITLE_BG_COLOR)
                add(item: title!)
            }
            
            // 学習した単語帳
            let item : ListItemStudiedBook? = ListItemStudiedBook.createHistory(
                history : history, width : width, textColor : .black, bgColor : .white)
            if item != nil {
                add(item: item!)
            }
        }
        
        updateWindow()
    }

    // MARK: Methods
    /**
     * 現在の日時から指定の日数分前のDateを求める
     */
    private func initTimeArea() {
        let nowDate = Date()
        
        let cal : Calendar = Calendar(identifier: .gregorian)
        //cal.setTime(nowDate)
        
        // 1日前
        //cal.add(Calendar.DAY_OF_MONTH, -1);
        beforeDate[0] = cal.date(byAdding: .day, value: -1, to: cal.startOfDay(for: nowDate))!
        
        // 2日前
        beforeDate[1] = cal.date(byAdding: .day, value: -2, to: cal.startOfDay(for: nowDate))!
        
        // １週間前まで
        beforeDate[2] = cal.date(byAdding: .day, value: -7, to: cal.startOfDay(for: nowDate))!
        
        // 1ヶ月前まで
        beforeDate[3] = cal.date(byAdding: .month, value: -1, to: cal.startOfDay(for: nowDate))!
    }
    
    /**
     * 日時のタイプを取得する
     * @param date  判定元の日時
     * @return  1:1日前 / 2:2日前 / 3:１週間前 / 4:１ヶ月前 : 5:１ヶ月以上前
     */
    private func getTimeArea( date : Date? ) -> Int{
        if date == nil {
            return 5
        }
        
        var nowDate = Date()
        
        var cal = Calendar(identifier: .gregorian)
        
        // 1日前まで
        if date!.after(beforeDate[0]) {
            // 今日(~24時間前)
            return 1
        }
        
        // 2日前まで
        if date!.before(beforeDate[0]) && date!.after(beforeDate[1]) {
            // 昨日(24時間前 ~ 48時間前)
            return 2
        }
        
        // １週間前まで
        if date!.before(beforeDate[1]) && date!.after(beforeDate[2]) {
            // 48時間前 ~ １週間前
            return 3
        }
        
        // 1ヶ月前まで
        if date!.before(beforeDate[2]) && date!.after(beforeDate[3]) {
            // 48時間前 ~ １週間前
            return 4
        }
        // 1ヶ月以上前
        return 5
    }
}

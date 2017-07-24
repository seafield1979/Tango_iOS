//
//  UDrawManager.swift
//  UGui
//  描画システムの管理を行う
//  Created by Shusuke Unno on 2017/07/08.
//  Copyright © 2017年 Shusuke Unno. All rights reserved.
//

import Foundation
import UIKit


/**
 * デバッグ座標の１点の情報
 */
class DebugPoint {
    public var x : CGFloat = 0, y : CGFloat = 0
    public var color : UIColor = UIColor.clear
    public var drawText : Bool = false
    
    init(x : CGFloat, y : CGFloat, color : UIColor, drawText : Bool) {
        self.x = x
        self.y = y
        self.color = color
        self.drawText = drawText
    }
}

class UDrawManager {
    /**
     * Constants
     */
    public static let TAG : String = "UDrawManager"
    private static let DEFAULT_PAGE : Int = 1
    
    /**
     * Static variables
     */
    private static var singleton = UDrawManager()
    public static func getInstance() -> UDrawManager { return singleton }
    
    // デバッグ用のポイント描画
    private static var debugPoints : List<DebugPoint> = List()
    private static var debugPoints2 : RefDictionary<Int, DebugPoint> = RefDictionary()
    
    /**
     * Member variable
     */
    // タッチ中のDrawableオブジェクト
    // タッチを放すまで他のオブジェクトのタッチ処理はしない
    private var touchingObj : UDrawable? = nil
    
    // ページのリスト
    private var mPageList : RefDictionary<Int, RefDictionary<Int, DrawList>> = RefDictionary()
    
    // カレントページ
    private var mCurrentPage : Int = DEFAULT_PAGE
    
    private var removeRequest : List<UDrawable> = List();
    
    /**
     * Get/Set
     */
    public func getTouchingObj() -> UDrawable? {
        return touchingObj
    }
    
    public func setTouchingObj(_ touchingObj : UDrawable?) {
        self.touchingObj = touchingObj;
    }
    
    /**
     * 初期化
     * アクティビティが生成されるタイミングで呼ぶ
     */
    public func initialize() {
        mPageList.clear()
        
        // デフォルトのページを設定
        setCurrentPage(mCurrentPage)
    }
    
    public func initPage(page : Int) {
        let lists = mPageList[page]
        if lists != nil {
            lists!.removeAll()
        }
     }
     
     /**
     * ページを切り替える
     * @param page 切り替え先のページ 0ならデフォルトのページ
     */
    public func setCurrentPage(_ page : Int) {
        // 古いページの削除リクエストを処理する
        removeRequestedList();

        // ページリストが存在しないなら作成する
        if mPageList[page] == nil {
            let lists : RefDictionary<Int, DrawList> = RefDictionary()
            mPageList[page] = lists
        }
        self.mCurrentPage = page
    }
     
     /**
     * カレントページのリストを取得
     */
    private func getCurrentDrawLists() -> RefDictionary<Int, DrawList>?
    {
        return mPageList[mCurrentPage]
    }
     
     /**
     * 描画オブジェクトを追加
     * @param obj
     * @return
     */
    public func addWithNewPriority(obj: UDrawable, priority: Int) -> DrawList? {
        obj.drawPriority = priority
        return addDrawable(obj)
    }
    
    public func addDrawable(_ obj : UDrawable) -> DrawList? {
        // カレントページのリストを取得
        let lists : RefDictionary<Int, DrawList>? = getCurrentDrawLists()
        if lists == nil {
            return nil
        }

        // 挿入するリストを探す
        let _priority : Int = obj.getDrawPriority()
        var list : DrawList? = lists![_priority]
        if list == nil {
            // まだ存在していないのでリストを生成
            list = DrawList(priority: obj.getDrawPriority())
            lists![_priority] = list
        }
        list!.add(obj)
        obj.setDrawList(list!)
        return list!
    }
    
     /**
     * リストに登録済みの描画オブジェクトを削除
     * 削除要求をバッファに積んでおき、描画前に削除チェックを行う
     * @param obj
     * @return
     */
    public func removeDrawable(_ obj: UDrawable) {
        removeRequest.append(obj);
    }
     
    /**
     * 削除要求のリストの描画オブジェクトを削除する
     */
    private func removeRequestedList() {
        let lists = getCurrentDrawLists()
        if lists == nil {
            return
        }
        
        for obj in removeRequest {
            let _priority : Int = obj!.getDrawPriority()
            let list = lists![_priority]
            if list != nil {
                list!.remove(obj!)
            }
        }
        removeRequest.removeAll()
    }
     
     /**
     * 指定のプライオリティのオブジェクトを全て削除
     * @param priority
     */
    public func removeWithPriority(priority : Int) {
        let lists = getCurrentDrawLists()
        if let _lists  = lists {
            _lists.removeValue(forKey: priority)
        }
    }

    /**
     * すべての描画オブジェクトを削除する
     */
    public func removeAll() {
        // カレントページのリストを取得
        let lists : RefDictionary<Int, DrawList>? = getCurrentDrawLists()
        
        for list : DrawList in lists!.values {
            list.removeAll()
        }
    }

     
    /**
     * DrawListのプライオリティを変更する
     * @param list1  変更元のリスト
     * @param priority
     */
    public func setPriority(list1 : DrawList, priority : Int) {
        let lists = getCurrentDrawLists()
        
        if let _lists = lists {
            // 変更先のプライオリティーを持つリストを探す
            let list2 : DrawList? = _lists[priority]
            
            if list2 != nil {
                // すでに変更先のプライオリティーのリストがあるので交換
                let srcPriority = list1.priority
                _lists[priority] = list1
                _lists[srcPriority] = list2
            } else {
                _lists[priority] = list1
            }
        }
    }
    
     /**
     * 追加済みのオブジェクトのプライオリティーを変更する
     * @param obj
     * @param priority
     */
    public func setPriority(obj : UDrawable, priority : Int) {
        let lists = getCurrentDrawLists()
        
        if let _lists = lists {
            // 探す
            for pri in _lists.keys {
                let list : DrawList? = _lists[pri]
                if list!.contains(obj: obj) {
                    if pri == priority {
                        // すでに同じPriorityにいたら末尾に移動
                        list!.toLast(obj)
                    }
                    else {
                        list!.remove(obj)
                        _ = addDrawable(obj)
                        return
                    }
                }
            }
        }
    }
    
     /**
     * 配下の描画オブジェクトを全て描画する
     * @param canvas
     * @param paint
     * @return true:再描画あり / false:再描画なし
     */
     public func draw() -> Bool {
        var redraw = false;
        let lists = getCurrentDrawLists()
        
        if lists == nil {
            return false
        }
         
         // 削除要求のかかったオブジェクトを削除する
         removeRequestedList()
         
         for list in lists!.values {
             // 毎フレームの処理
             let ret = list.doAction()
             if ret == DoActionRet.Done {
                 redraw = true
                 break
             } else if (ret == DoActionRet.Redraw) {
                redraw = true;
             }
         }
         
        ULog.startCount(tag: UDrawManager.TAG)
        // 描画は手前(priorityが大きい)から順に行う
        for key in lists!.keys.sorted().reversed() {
            let list = lists![key]
            if list!.draw() {
               redraw = true
            }
        }
         
        ULog.showCount(tag: UDrawManager.TAG)
        
        UDrawManager.drawDebugPoint()
         
        return redraw;
    }
     
     /**
     * タッチイベント処理
     * 描画優先度の高い順に処理を行う
     * @param vt
     * @return true:再描画
     */
    public func touchEvent(_ vt : ViewTouch) -> Bool {
        let lists = getCurrentDrawLists()
        if lists == nil {
            return false
        }

        var isRedraw = false
        
        // 手前から順に処理したいので priority が低い順に操作する
        let sortedKeys = lists!.keys.sorted()
        
        for key in sortedKeys {
            let list = lists![key]
            if (list!.touchUpEvent(vt: vt) ) {
                // タッチアップイベントは全てのオブジェクトで処理する
                isRedraw = true
            }
        }

        for key in sortedKeys {
            let list = lists![key]
            
            if list!.touchEvent(vt: vt) {
                // その他のタッチイベントはtrueが返った時点で打ち切り
                return true
            }
        }
        return isRedraw
    }
    
    /**
     * デバッグ用の点を描画する
     */
     /**
     * 点の追加
     */
     // List
    public static func addDebugPoint(x : CGFloat, y : CGFloat, color : UIColor, drawText : Bool )
    {
        debugPoints.append(DebugPoint(x:x, y:y, color:color, drawText:drawText))
    }
     
    // Map
    public static func setDebugPoint(id: Int, x : CGFloat, y : CGFloat, color : UIColor, drawText : Bool)
    {
        debugPoints2[id] = DebugPoint(x: x, y: y, color: color, drawText: drawText)
    }
     
     /**
     * 全てクリア
     */
    public static func clearDebugPoint() {
        debugPoints.removeAll()
        debugPoints2.removeAll()
    }
     
    private static func drawDebugPoint() {
        for dp in debugPoints {
            if let _dp = dp {
                UDraw.drawLine(x1:_dp.x - 50, y1: _dp.y, x2: _dp.x + 50, y2: _dp.y, lineWidth: 3, color: _dp.color)
                UDraw.drawLine(x1: _dp.x, y1: _dp.y - 50, x2: _dp.x, y2: _dp.y + 50, lineWidth: 3, color: _dp.color)
            }
        }
         
        for dp in debugPoints2.values {
            UDraw.drawLine(x1: dp.x - 50, y1: dp.y,
                           x2: dp.x + 50, y2: dp.y,
                           lineWidth: 3, color: dp.color)
            UDraw.drawLine(x1: dp.x, y1: dp.y - 50,
                           x2: dp.x, y2: dp.y + 50,
                           lineWidth: 3, color: dp.color)
        }
    }
}

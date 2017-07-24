//
//  DrawList.swift
//  UGui
//      描画オブジェクトのリストを管理するクラス
//      プライオリティーやクリップ領域を持つ
//  Created by Shusuke Unno on 2017/07/08.
//  Copyright © 2017年 Shusuke Unno. All rights reserved.
//

import Foundation
import UIKit

class DrawList {
    // 描画範囲 この範囲外には描画しない
    public private(set) var priority : Int;
    private var list : List<UDrawable> = List()
    
    init(priority : Int) {
        self.priority = priority;
    }
    
    // Get/Set
    /**
     * リストに追加
     * すでにリストにあった場合は末尾に移動
     * @param obj
     */
    public func add(_ obj: UDrawable) {
        // これから追加しようとしているオブジェクトをリストから削除
        if list.count > 0 {
            for i in 0...list.count-1 {
                let _obj = list[i]
                if obj === _obj {
                    _ = list.remove(at: i)
                    break
                }
            }
        }
        // リストの末尾に追加
        list.append(obj);
    }
    
    // リストから削除
    public func remove(_ obj : UDrawable) {
        for i in 0...list.count-1 {
            let _obj = list[i]
            if obj === _obj {
                _ = list.remove(at: i)
                break
            }
        }
    }
    
    // すべてのリストを削除
    public func removeAll() {
        list.removeAll()
    }
    
    // 指定の描画オブジェクトを最後に移動
    public func toLast(_ obj : UDrawable) {
        // 追加時と同じ処理なので流用する
        add(obj)
    }
    
    /**
     * Is contain in list
     * リストに指定のオブジェクトが含まれるかをチェック
     * @param obj
     * @return
     */
    public func contains(obj : UDrawable) -> Bool {
        for _obj in list {
            if obj === _obj {
                return true
            }
        }
        return false
    }
    
    /**
     * リストの描画オブジェクトを描画する
     * @return true:再描画あり (まだアニメーション中のオブジェクトあり)
     */
    public func draw() -> Bool {
        // 分けるのが面倒なのでアニメーションと描画を同時に処理する
        var allDone = true
        
        for obj : UDrawable? in list {
            if obj!.animate() {
                allDone = false;
            }
            ULog.count(UDrawManager.TAG)
            let offset = obj!.getDrawOffset()
            obj!.draw(offset);
            drawId(rect: obj!.rect!, priority: priority);
        }
        return !allDone;
    }
    
    /**
     * 毎フレームの処理
     * @return
     */
    public func doAction() -> DoActionRet {
        var ret = DoActionRet.None;
        for obj : UDrawable? in list {
            let _ret : DoActionRet = obj!.doAction()
            switch(_ret) {
                case .Done:
                    return _ret;
                case .Redraw:
                    ret = _ret;
                    break
                default:
                    break
            }
        }
        return ret;
    }
    
    /**
     * プライオリティを表示する
     * @param canvas
     * @param paint
     */
    func drawId(rect : CGRect, priority : Int) {
        // idを表示
        if !UDebug.drawIconId {
            return
        }
        
        // todo
//        paint.setColor(Color.BLACK);
//        paint.setTextSize(30);
//        
//        String text = "" + priority;
//        Rect textRect = new Rect();
//        paint.getTextBounds(text, 0, text.length(), textRect);
//        
//        canvas.drawText("" + priority, rect.centerX() - textRect.width() / 2, rect.centerY() - textRect.height() / 2, paint);
//        
    }
    
    /**
     * タッチアップイベント処理
     * @param vt
     * @return
     */
    func touchUpEvent(vt : ViewTouch) -> Bool {
        var isRedraw : Bool = false
        
        for obj : UDrawable? in list {
            if obj!.touchUpEvent(vt: vt) {
                isRedraw = true
            }
        }
        return isRedraw
    }
    
    /**
     * タッチイベント処理
     * リストの末尾(手前に表示されている)から順に処理する
     * @param vt
     * @return true:再描画
     */
    func touchEvent(vt : ViewTouch) -> Bool {
        let manager = UDrawManager.getInstance()

        if vt.isTouchUp {
            manager.setTouchingObj(nil)
        }
        
        // タッチを放すまではタッチしたオブジェクトのみ処理する
        if (manager.getTouchingObj() != nil &&
            vt.type != TouchType.Touch)
        {
            if manager.getTouchingObj()?.touchEvent(vt:vt, offset: nil) == true {
                return true;
            }
            return false;
        }
    
        // 手前に表示されたものから処理したいのでリストを逆順で処理する
        for obj in list.reversed() {
            if obj?.isShow == false {
                continue
            }
            let offset = obj!.getDrawOffset()
            
            if obj!.touchEvent(vt:vt, offset:offset) {
                if vt.type == TouchType.Touch {
                    manager.setTouchingObj(obj)
                }
                return true;
            }
        }
        return false;
    }
}

//
//  UMenuBar.swift
//  UGui
//    メニューバー
//    メニューに表示する項目を管理する
//      抽象クラスなので、各アプリにあったメニューをサブクラスとして実装する
//  Created by Shusuke Unno on 2017/07/08.
//  Copyright © 2017年 Shusuke Unno. All rights reserved.
//

import Foundation
import UIKit

/**
 */
public class UMenuBar : UWindow {
    public static let TAG = "UMenuBar"
    public static let DRAW_PRIORITY = 90
    public static let MENU_BAR_H = 60
    static let MARGIN_L = 10
    static let MARGIN_H = 16
    static let MARGIN_TOP = 5
    
    
    var mMenuItemCallbacks : UMenuItemCallbacks? = nil
    var topItems : List<UMenuItem> = List()
    var items : List<UMenuItem> = List()
    var mDrawList : DrawList? = nil
    
    /**
     * Constructor
     */
    public init( parentView: TopView,
                callbacks : UMenuItemCallbacks?,
                 parentW : CGFloat, parentH : CGFloat,
                 bgColor : UIColor? )
    {
        super.init(parentView: parentView,
                   callbacks : nil,
                   priority: UMenuBar.DRAW_PRIORITY,
                   x:0, y:parentH - UDpi.toPixel(UMenuBar.MENU_BAR_H),
                   width: parentW, height: UDpi.toPixel(UMenuBar.MENU_BAR_H),
                   bgColor: bgColor,
                   topBarH: 0, frameW : 0, frameH : 0)
        mMenuItemCallbacks = callbacks
    }
    
    /**
     * Methods
     */
    /**
     * メニューバーを初期化
     */
    func initMenuBar() {
        // 抽象メソッド。サブクラスで実装する
    }
    
    func updateBGSize() {
        size.width = UDpi.toPixel(UMenuBar.MARGIN_L) + CGFloat(topItems.count) * UDpi.toPixel(UMenuItem.ITEM_W + UMenuBar.MARGIN_H)
    }
    
    /**
     * メニューのトップ項目を追加する
     * @param menuId
     * @param image
     */
    func addTopMenuItem(menuId : Int, image : UIImage) -> UMenuItem {
        let item = UMenuItem(menuBar: self, id: menuId, isTop: true, icon: image)
        item.mCallbacks = mMenuItemCallbacks
        item.isShow = true
        
        topItems.append(item)
        items.append(item)
        
        // 座標設定
        item.setPos(
            UDpi.toPixel(UMenuBar.MARGIN_H + UMenuItem.TOP_ITEM_W + UMenuBar.MARGIN_H * (topItems.count - 1)), UDpi.toPixel(UMenuBar.MARGIN_TOP))
        return item
    }
    
    /**
     * 子メニューを追加する
     * @param parent
     * @param menuId
     * @param image
     * @return
     */
    func addMenuItem(parent : UMenuItem, menuId : Int, image : UIImage) -> UMenuItem
    {
        let item = UMenuItem(menuBar: self,
                             id: menuId, isTop: false, icon: image)
        item.mCallbacks = mMenuItemCallbacks
        item.mParentItem = parent
        // 子要素は初期状態では非表示。オープン時に表示される
        item.isShow = false
        
        parent.addItem(child: item)
        
        items.append(item)
        return item
    }
    
    /**
     * メニューのアクション
     * メニューアイテムを含めて何かしらの処理を行う
     *
     * @return true:処理中 / false:完了
     */
    override public func doAction() -> DoActionRet {
        if !isShow {
            return DoActionRet.None
        }
        
        var ret = DoActionRet.None
        for item in topItems {
            let _ret = item!.doAction()
            switch(_ret) {
            case .Done:
                return _ret
            case .Redraw:
                ret = _ret
            default:
                break
            }
        }
        return ret
    }
    
    /**
     * タッチ処理を行う
     * 現状はクリック以外は受け付けない
     * メニューバー以下の項目(メニューの子要素も含めて全て)のクリック判定
     */
    override public func touchEvent(vt : ViewTouch, offset : CGPoint?) -> Bool {
        if (!isShow) {
            return false
        }
        
        var done = false
        let clickX = vt.touchX - pos.x
        let clickY = vt.touchY - pos.y
        
        // 渡されるクリック座標をメニューバーの座標系に変換
        for item in topItems {
            if item == nil {
                continue
            }
            
            if item!.checkTouch(vt: vt, touchX: clickX, touchY: clickY) {
                done = true
                // クリック時に後ろのアイテムに反応するのを防ぐ
                vt.isTouching = false
                
                if item!.isOpened {
                    // 他に開かれたメニューを閉じる
                    closeAllMenu(excludedItem : item!)
                }
                break
            }
            if done {
                break
            }
        }
        
        // メニューバーの領域をクリックしていたら、メニュー以外がクリックされるのを防ぐためにtrueを返す
        if !done {
            if 0 <= clickX && clickX <= size.width &&
                0 <= clickY && clickY <= size.height
            {
                // クリック時に後ろのアイテムに反応するのを防ぐ
                vt.isTouching = false
                return true
            }
        }
        return done
    }
    
    /**
     * メニューを閉じる
     * @param excludedItem 閉じるのを除外するアイテム
     */
    func closeAllMenu(excludedItem : UMenuItem) {
        for item in topItems {
            if item! === excludedItem {
                continue
            }
            item!.closeMenu()
        }
    }
    
    /**
     * メニュー項目の座標をスクリーン座標で取得する
     */
    public func getItemPos(itemId : Int) -> CGPoint {
        let item = items[itemId]
        
        let itemPos = item.getPos()
        return CGPoint(x: toScreenX(winX: itemPos.x),
                       y: toScreenY(winY: itemPos.y))
    }
    
    /*
     Drawableインターフェースメソッド
     */
    /**
     * 描画処理
     * @param canvas
     * @param paint
     */
    override public func drawContent(offset : CGPoint?) {
        if !isShow {
            return
        }
        
        // 背景描画
        // トップのアイテムから描画
        for item in topItems {
            if item != nil && item!.isShow {
                item!.draw(pos)
            }
        }
        return;
    }
    
    /**
     * アニメーション処理
     * onDrawからの描画処理で呼ばれる
     * @return true:アニメーション中
     */
    override public func animate() -> Bool {
        if (!isAnimating) {
            return false
        }
        var allFinished = true
        
        for item in topItems {
            if item!.animate() {
                allFinished = false
            }
        }
        if allFinished {
            isAnimating = false;
        }
        return !allFinished
    }
}

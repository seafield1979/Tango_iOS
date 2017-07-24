//
//  UListView.swift
//  UGui
//
//  Created by Shusuke Unno on 2017/07/08.
//  Copyright © 2017年 Shusuke Unno. All rights reserved.
//

import Foundation
import UIKit

/**
 * ListView
 * UListItemを縦に並べて表示する
 * 要素が領域に収まりきらない場合はスクロールバーでスクロールできるようになる
 */

public class UListView : UScrollWindow
{
    /**
     * Enums
     */
    /**
     * Constants
     */
    public static let MARGIN_V = 7
    
    /**
     * Member variables
     */
    var mItems : List<UListItem> = List()
    var mListItemCallbacks : UListItemCallbacks?
    var mClipRect : CGRect
    
    // リストの最後のアイテムの下端の座標
    var mBottomY : CGFloat = 0
    
    /**
     * Constructor
     */
    public init(parentView : TopView,
                windowCallbacks : UWindowCallbacks?,
                listItemCallbacks : UListItemCallbacks?,
                priority : Int,
                x : CGFloat, y : CGFloat,
                width : CGFloat, height : CGFloat, color : UIColor)
    {
        mListItemCallbacks = listItemCallbacks
        mClipRect = CGRect()
        
        super.init(parentView: parentView,
                   callbacks: windowCallbacks, priority:priority,
                    x: x, y: y,
                    width: width, height: height,
                    color: color,
                    topBarH: 0, frameW: 0, frameH: UDpi.toPixel(10))
        
    }
    
    /**
     * Methods
     */
    public func get(index : Int) -> UListItem {
        return mItems[index]
    }
    
    public func getItemNum() -> Int{
        return mItems.count
    }
    
    public func add(item : UListItem) {
        item.setPos( 0, mBottomY )
        item.setIndex( mItems.count )
        item.setListItemCallbacks( mListItemCallbacks )
        
        mItems.append(item)
        
        mBottomY += item.getHeight()
        mBottomY -= item.mFrameW / 2       // フレーム部分は重なってもOK
        
        contentSize.height = mBottomY
    }
    
    // 既存の項目を置き換える
//    public func update(oldItem : UListItem, newItem : UListItem) {
//        let index = mItems.indexOf(oldItem)
//        newItem.setPos(oldItem.getX(), oldItem.getY())
//        mItems.set(index, newItem)
//    }
    
    public func clear() {
        mItems.removeAll()
        mBottomY = 0
        setContentSize(width: 0, height: 0, update: true)
    }
    
    public func remove(index : Int) {
        if index == -1 {
            return
        }
        
        let item = mItems[index]
        var y = item.getY()
        _ = mItems.remove(at: index)
        // 削除したアイテム以降のアイテムのIndexと座標を詰める
        for i in index...mItems.count - 1 {
            let _item = mItems[i]
            _item.setIndex(i)
            _item.setY(y)
            y = _item.getBottom()
        }
        mBottomY = y
    }
    
    override public func doAction() -> DoActionRet {
        var ret = DoActionRet.None
        for item in mItems {
            let _ret = item!.doAction()
            switch (_ret) {
            case .Done:
                return DoActionRet.Done
            case .Redraw:
                ret = _ret
            default:
                break
            }
        }
        return ret
    }
    
    // ウィンドウの内部領域の描画
    override public func drawContent( offset : CGPoint? ) {
        var _pos = CGPoint(x: pos.x, y: pos.y)
        
        if offset != nil {
            _pos.x += offset!.x
            _pos.y += offset!.y
        }
        
        // クリッピングを設定        
        mClipRect = CGRect( x: _pos.x, y: _pos.y,
                            width: clientSize.width, height: clientSize.height)
        
        UIGraphicsGetCurrentContext()!.saveGState()
        UIGraphicsGetCurrentContext()!.clip(to: mClipRect)
        
        // アイテムを描画
        let _offset = CGPoint(x:_pos.x, y:_pos.y - contentTop.y)
        for item in mItems {
            if item!.getBottom() < contentTop.y {
                continue
            }
            
            item!.draw(_offset)
            
            if (item!.getY() + item!.getHeight() > contentTop.y + size.height) {
                // アイテムの下端が画面外にきたので以降のアイテムは表示されない
                break
            }
        }
        // クリッピングを解除
        UIGraphicsGetCurrentContext()!.restoreGState()
    }

    override public func touchEvent(vt : ViewTouch, offset : CGPoint?) -> Bool {
        var offset = offset
        if offset == nil {
            offset = CGPoint()
        }
        // 領域外なら何もしない
        let point = CGPoint(x: vt.touchX(offset: -pos.x - offset!.x),
                            y: vt.touchY(offset: -pos.y - offset!.y))
        if !getClientRect().contains(point) {
            return false
        }
        
        // アイテムのクリック判定処理
        let _offset = CGPoint(x:pos.x + offset!.x, y:pos.y - contentTop.y + offset!.y)
        var isDraw = false
        
        if (super.touchEvent(vt:vt, offset:offset)) {
            return true
        }
        
        for item in mItems {
            if item!.getBottom() < contentTop.y {
                continue
            }
            if item!.touchEvent(vt:vt, offset:_offset) {
                isDraw = true
            }
            if item!.getY() + item!.getHeight() > contentTop.y + clientSize.height {
                // アイテムの下端が画面外にきたので以降のアイテムは表示されない
                break
            }
        }
        
        return isDraw
    }
    
    override public func touchUpEvent(vt : ViewTouch) -> Bool {
        var isDraw = false
        if vt.isTouchUp {
            for item in mItems {
                item!.touchUpEvent(vt: vt)
                isDraw = true
            }
        }
        return isDraw
    }
    
    /**
     * for Debug
     */
    public func addDummyItems(count : Int) {
        for i in 0...19 {
            let item = ListItemTest1(callbacks: nil,
                                     text: "hoge",
                                     x: 0, width: size.width, color:UIColor.yellow)
            add(item: item)
        }
        updateWindow()
    }
}

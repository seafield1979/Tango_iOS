//
//  UScrollBar.swift
//  UGui
//
//  Created by Shusuke Unno on 2017/07/08.
//  Copyright © 2017年 Shusuke Unno. All rights reserved.
//

import Foundation
import UIKit

/**
 * スクロールバーの表示タイプ
 */
public enum ScrollBarShowType {
    case Show           // 必要なら表示
    case Show2          // 必要なら表示（自動で非表示になる）
    case ShowAllways    // 常に表示
}

/**
 * スクロールバーの配置場所
 */
public enum ScrollBarType {
    case Horizontal
    case Vertical
}


/**
 * 自前で描画するスクロールバー
 * タッチ操作あり
 *
 * 機能
 *  外部の値に連動してスクロール位置を画面に表示
 *  ドラッグしてスクロール
 *  バー以外の領域をタップしてスクロール
 *  指定のViewに張り付くように配置
 */
public class UScrollBar {
    /**
     * Constants
     */
    public static let TAG = "UScrollBar"
    
    private static let TOUCH_MARGIN = 40     // バーは細くてタッチしにくいので見た目よりもあたり判定を広くするためのマージンを設定する1
    
    // colors
    private static let BAR_COLOR = UColor.makeColor(160, 128,128,128)
    private static let SHOW_BAR_COLOR = UColor.makeColor(255, 255,128,0)
    private static let SHOW_BG_COLOR = UColor.makeColor(128,255,255,255)
    
    /**
     * Membar Variables
     */
    private var type : ScrollBarType = ScrollBarType.Vertical
    private var showType : ScrollBarShowType = ScrollBarShowType.Show
    private var _isShow : Bool = false
    
    public var pos = CGPoint()
    public var parentPos = CGPoint()
    public var bgColor : UIColor? = nil, barColor : UIColor? = nil
    private var isDraging : Bool = false
    
    // スクリーン座標系
    public var bgLength, bgWidth : CGFloat
    public var barPos : CGFloat        // バーの座標（縦ならy,横ならx)
    public var barLength : CGFloat = 0.0       // バーの長さ(縦バーなら高さ、横バーなら幅)
    
    // コンテンツ座標系
    public var contentLen : CGFloat       // コンテンツ領域のサイズ
    public var pageLen : CGFloat          // 表示画面のサイズ
    public var topPos : CGFloat         // スクロールの現在の位置
    
    var bgRect = CGRect()
    var barRect = CGRect()
    
    /**
     * Get/Set
     */
    
    public func setBgLength(bgLength : CGFloat) {
        self.bgLength = bgLength;
    }
    
    public func setBgColor(bgColor : UIColor?) {
        self.bgColor = bgColor
    }
    
    public func setBarColor(barColor : UIColor) {
        self.barColor = barColor
    }
    
    public func getTopPos() -> CGFloat {
        return topPos
    }
    
    private func updateBarLength() {
        if (pageLen >= contentLen) {
            // 表示領域よりコンテンツの領域が小さいので表示不要
            barLength = 0
            topPos = 0
            if (showType != ScrollBarShowType.ShowAllways) {
                _isShow = false
            }
        } else {
            barLength = self.bgLength *
                (CGFloat(pageLen) / (CGFloat(contentLen))
            )
            _isShow = true;
        }
    }
    
    public func getBgWidth() -> CGFloat {
        return bgWidth
    }
    
    public func setPageLen(pageLen : CGFloat) {
        self.pageLen = pageLen
    }
    
    public func isShow() -> Bool {
        if (_isShow && barLength > 0) {
            return true
        }
        return false
    }
    
    public func setShow(show : Bool) {
        self._isShow = show
    }
    
    /**
     * コンストラクタ
     * 指定のViewに張り付くタイプのスクロールバーを作成
     *
     * @param pageLen   1ページ分のコンテンツの長さ
     * @param contentLen  全体のコンテンツの長さ
     */
    public init(type : ScrollBarType, showType : ScrollBarShowType,
                parentPos : CGPoint, x : CGFloat, y : CGFloat,
                bgLength : CGFloat, bgWidth : CGFloat,
                pageLen : CGFloat, contentLen : CGFloat )
    {
        self.type = type
        self.showType = showType
        if (showType == ScrollBarShowType.ShowAllways) {
            _isShow = true
        }
        pos.x = x
        pos.y = y
        topPos = 0
        barPos = 0
        self.parentPos = parentPos
        self.bgWidth = bgWidth
        self.bgLength = bgLength
        self.contentLen = contentLen
        self.pageLen = pageLen
    
        updateBarLength()
 
        if (showType == ScrollBarShowType.Show2) {
            bgColor = UIColor.clear
            barColor = UScrollBar.BAR_COLOR
        } else {
            bgColor = UScrollBar.SHOW_BAR_COLOR
            barColor = UScrollBar.SHOW_BG_COLOR
        }
        
        updateSize()
    }
    
    /**
     * スクロールバーを表示する先のViewのサイズが変更された時の処理
     */
    public func updateSize() {
        updateBarLength()
        if (barPos + barLength > bgLength) {
            barPos = bgLength - barLength
        }
    }
    
    
    /**
     * 色を設定
     * @param bgColor  背景色
     * @param barColor バーの色
     */
    public func setColor(bgColor : UIColor?, barColor : UIColor?) {
        self.bgColor = bgColor
        self.barColor = barColor
    }
    
    /**
     * 領域がスクロールした時の処理
     * ※外部のスクロールを反映させる
     * @param pos
     */
    public func updateScroll(pos : CGFloat) {
        barPos = pos / contentLen * bgLength
        self.topPos = pos
    }
    
    public func updateBarPos() {
        barPos = topPos / contentLen * bgLength
    }
    
    /**
     * バーの座標からスクロール量を求める
     * updateScrollの逆バージョン
     */
    private func updateScrollByBarPos() {
        topPos = (barPos / bgLength) * contentLen
    }
    
    /**
     * コンテンツやViewのサイズが変更された時の処理
     */
    public func updateContent(contentSize : CGFloat) -> CGFloat {
        self.contentLen = contentSize
        
        updateBarLength()
        return topPos
    }
    
    public func draw(offset : CGPoint?) {
        if !_isShow {
            return
        }
    
        var baseX : CGFloat = pos.x + parentPos.x
        var baseY : CGFloat = pos.y + parentPos.y
        if offset != nil {
            baseX += offset!.x
            baseY += offset!.y
        }
        
        var _barLength : CGFloat = barLength
        var _barPos : CGFloat = barPos
        if (showType == ScrollBarShowType.ShowAllways) {
            _barLength = bgLength - 30;
            _barPos = 15;
        }
        if (type == ScrollBarType.Horizontal) {
            if bgColor != nil {
                bgRect.x = baseX
                bgRect.y = baseY
                bgRect.width = CGFloat(bgLength)
                bgRect.height = CGFloat(bgWidth)
            }
            
            barRect.x = baseX + CGFloat(_barPos)
            barRect.y = baseY + 10
            barRect.width = CGFloat(_barLength)
            barRect.height = CGFloat(bgWidth) - 20
        } else {
            if bgColor != nil {
                bgRect.x = baseX
                bgRect.y = baseY
                bgRect.width = CGFloat(bgWidth)
                bgRect.height = CGFloat(bgLength)
            }
            
            barRect.x = baseX + 10.0
            barRect.y = baseY + CGFloat(_barPos)
            barRect.width = CGFloat(bgWidth) - 20.0
            barRect.height = CGFloat(_barLength)
        }
        
        // 背景
        if (bgColor != nil) {
            UDraw.drawRectFill(rect: bgRect, color: bgColor!)
        }
        
        // バー
        if (barColor != nil) {
            UDraw.drawRectFill(rect: barRect, color: barColor!)
        }
    }
    
    
    /**
     * １画面分上（前）にスクロール
     */
    public func scrollUp() {
        topPos -= pageLen
        if (topPos < 0) {
            topPos = 0
        }
        updateBarPos()
    }
    
    /**
     * １画面分下（先）にスクロール
     */
    public func scrollDown() {
        topPos += pageLen;
        if (topPos + pageLen > contentLen) {
            topPos = contentLen - pageLen
        }
        updateBarPos()
    }
    
    /**
     * バーを移動
     * @param move 移動量
     */
    public func barMove(_ move : CGFloat) {
        barPos += move
        if (barPos < 0) {
            barPos = 0;
        }
        else if (barPos + barLength > bgLength) {
            barPos = bgLength - barLength
        }
        updateScrollByBarPos()
    }
    
    /**
     * タッチ系の処理
     * @param tv
     * @return
     */
    public func touchEvent(vt : ViewTouch, offset : CGPoint) -> Bool {
        switch(vt.type) {
        case .Touch:
            if touchDown(vt: vt, offset: offset) {
                return true
            }
        case .Moving:
            if touchMove(vt: vt) {
                return true
            }
        case .MoveEnd:
            _ = touchUp()
        default:
            break
        }
        return false
    }
    
    /**
     * スクロールバーのタッチ処理
     * @param vt
     * @return true:バーがスクロールした
     */
    private func touchDown(vt : ViewTouch, offset : CGPoint) -> Bool {
        // スペース部分をタッチしたら１画面分スクロール
        let ep = CGPoint(x: vt.touchX - offset.x, y: vt.touchY - offset.y)
        
        var rect = CGRect()
        
        if (type == ScrollBarType.Vertical) {
            let marginW = UDpi.toPixel(UScrollBar.TOUCH_MARGIN)
            rect = CGRect(x:pos.x - marginW,
                          y: pos.y,
                          width: bgWidth + marginW * 2, height: bgLength)
            
            if (rect.contains(ep)) {
                if (ep.y < barPos) {
                    // 上にスクロール
                    ULog.printMsg(UScrollBar.TAG,"Scroll Up")
                    scrollUp()
                    return true
                } else if (ep.y > pos.y + barPos + barLength) {
                    // 下にスクロール
                    ULog.printMsg(UScrollBar.TAG, "Scroll Down")
                    scrollDown()
                    return true
                } else {
                    // バー
                    ULog.printMsg(UScrollBar.TAG, "Drag Start")
                    isDraging = true
                    return true
                }
            }
        } else {
            rect = CGRect(x:pos.x,
                          y: pos.y - UDpi.toPixel(UScrollBar.TOUCH_MARGIN),
                          width: bgLength, height: bgWidth)
            
            if (rect.contains(ep)) {
                if ep.x < barPos {
                    // 上にスクロール
                    ULog.printMsg(UScrollBar.TAG, "Scroll Up")
                    scrollUp()
                    return true
                } else if ep.x > pos.x + barPos + barLength {
                    // 下にスクロール
                    ULog.printMsg(UScrollBar.TAG, "Scroll Down")
                    scrollDown()
                    return true
                } else {
                    // バー
                    ULog.printMsg(UScrollBar.TAG, "Drag Start")
                    isDraging = true
                    return true
                }
            }
        }
        return false
    }
    
    private func touchUp() -> Bool {
        ULog.printMsg(UScrollBar.TAG, "touchUp")
        isDraging = false
        
        return false
    }
    
    private func touchMove(vt : ViewTouch) -> Bool {
        if (isDraging) {
            let move : CGFloat = (type == ScrollBarType.Vertical) ? vt.moveY : vt.moveY
                barMove(move)
            return true
        }
        return false
    }
}

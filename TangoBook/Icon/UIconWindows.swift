//
//  UIcon.swift
//  TangoBook
//
//  複数のUIconWindowを管理する
//  Window間でアイコンのやり取りを行ったりするのに使用する
//  想定はメインWindowが１つにサブWindowが１つ
//
//  Created by Shusuke Unno on 2017/07/25.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import UIKit

public class UIconWindows : UWindowCallbacks {
   public enum DirectionType {
       case Landscape      // 横長
       case Portlait       // 縦長
   }
   
    /**
    * Consts
    */
   public static let TAG = "UIconWindows"
   public static let MOVING_FRAME = 12
   
   /**
    * Member Variables
    */
    private var windows : List<UIconWindow> = List()
    private var mainWindow : UIconWindow
    private var subWindow : UIconWindowSub
    private var size = CGSize()
    private var directionType = DirectionType.Portlait

    public static var publicInstance : UIconWindows? = nil

    /**
    * Get/Set
    */
    public func getMainWindow() -> UIconWindow? {
       return mainWindow
    }

    public func getSubWindow() -> UIconWindowSub {
       return subWindow
    }

    public func getWindows() -> List<UIconWindow>? {
       return windows
    }

    // デバッグ用のどこからでも参照できるインスタンス
    public static func getInstance() -> UIconWindows {
       return publicInstance!
    }

    /**
    * Constructor
    * インスタンスの生成はcreateInstanceを使用すること
    */
    private init(mainWindow : UIconWindow,
                 subWindow : UIconWindowSub,
                 screenW : CGFloat, screenH : CGFloat)
    {
        self.size = CGSize(width: screenW, height: screenH)
        self.directionType = (screenW > screenH) ? DirectionType.Landscape : DirectionType
        .Portlait
        self.mainWindow = mainWindow
        self.subWindow = subWindow
        
        self.windows.append(mainWindow)
        self.windows.append(subWindow)
        
        // 初期配置(HomeWindowで画面が占有されている)
        mainWindow.setPos(0, 0, convSKPos: true)
        mainWindow.setSize(screenW, screenH)
        if self.directionType == DirectionType.Landscape {
            subWindow.setPos(screenW, 0, convSKPos: true)
        } else {
            subWindow.setPos(0, screenH, convSKPos: true)
        }
    }

    public static func createInstance(mainWindow : UIconWindow,
                                      subWindow : UIconWindowSub,
                                      screenW : CGFloat, screenH : CGFloat) -> UIconWindows
    {
        let instance = UIconWindows(mainWindow: mainWindow,
                                    subWindow: subWindow,
                                    screenW : screenW, screenH : screenH)
        
        publicInstance = instance
        
        return instance
    }

    /**
     * Methods
     */
    
    /**
     * Windowを表示する
     * @param window
     * @param animation
     */
    public func showWindow( window: UIconWindow, animation : Bool) {
        window.isShow = true
        window.setAppearance(true)
        
        updateLayout(animation: animation)
    }
    
    /**
     * 指定のウィンドウを非表示にする
     * @param window
     */
    public func hideWindow(window : UIconWindow, animation : Bool) -> Bool{
        // すでに非表示なら何もしない
        if !window.getIsShow() || !window.isAppearance {
            return false
        }
        
        window.setAppearance(false)
        updateLayout(animation: animation)
        return true
    }
    
    /**
     * レイアウトを更新する
     * ウィンドウを追加、削除した場合に呼び出す
     */
    private func updateLayout(animation : Bool) {
        let showWindows : List<UIconWindow> = List()
        for _window in windows {
            if _window!.isAppearance {
                showWindows.append(_window!)
            }
        }
        if showWindows.count == 0 {
            return
        }
        
        // 各ウィンドウが同じサイズになるように並べる
        var width : CGFloat
        var height : CGFloat
        if directionType == DirectionType.Landscape {
            width = size.width / CGFloat(showWindows.count)
            height = size.height
        } else {
            width = size.width
            height = size.height / CGFloat(showWindows.count)
        }
        
        // 座標を設定する
        if animation {
            // Main
            mainWindow.setPos(0, 0, convSKPos: true)
            mainWindow.startMovingSize(dstW: width, dstH: height, frame: UIconWindows.MOVING_FRAME)
            
            // Sub
            if subWindow.isAppearance {
                // appear
                if directionType == DirectionType.Landscape {
                    subWindow.setPos(size.width, 0, convSKPos: true)
                    subWindow.startMoving(dstX: width, dstY: 0,
                                          dstW: width, dstH: height,
                                          frame: UIconWindows.MOVING_FRAME)
                } else {
                    subWindow.setPos(0, size.height, convSKPos: true)
                    subWindow.startMoving(dstX: 0, dstY: height,
                                          dstW: width, dstH: height,
                                          frame: UIconWindows.MOVING_FRAME)
                }
            } else {
                // disappear
                if (directionType == DirectionType.Landscape) {
                    subWindow.startMoving(dstX: size.width, dstY: 0,
                                          dstW: 0, dstH: height,
                                          frame: UIconWindows.MOVING_FRAME);
                } else {
                    subWindow.startMoving(dstX: 0, dstY: size.height,
                                          dstW: width, dstH: 0,
                                          frame: UIconWindows.MOVING_FRAME);
                }
            }
        } else {
            var x : CGFloat = 0, y : CGFloat = 0
            for _window in showWindows {
                _window!.setPos(x, y, convSKPos: true)
                _window!.setSize(width, height)
                if directionType == DirectionType.Landscape {
                    x += width
                } else {
                    y += height
                }
            }
        }
    }
    
    /**
     * 全てのウィンドウのカードの表示を更新する
     */
    public func resetCardTitle() {
        for window in windows {
            let icons : List<UIcon>? = window!.getIcons()
            
            if icons == nil {
                continue
            }
            for icon in icons! {
                icon?.updateTitle()
            }
        }
    }
    
    /**
     * 全てのアイコンのドロップ状態をクリアする
     */
    public func clearDroped() {
        for window in windows {
            let icons : List<UIcon>? = window!.getIcons()
            
            if icons == nil {
                continue
            }
            for icon in icons! {
                icon?.isDroped = false
            }
        }
    }
    
    /**
     * 全てのアイコンの情報を表示する for Debug
     */
    public func showAllIconsInfo() {
        for window in windows {
            let icons : List<UIcon>? = window!.getIcons()
            var pos = 1
            if icons == nil {
                continue
            }
            for icon in icons! {
                ULog.printMsg(UIconWindows.TAG,
                              String(format:
                              "pos:%d iconType:%d iconId:%d itemPos:%d mTitle:%@", pos, icon!.getType().rawValue,icon!.getTangoItem()!.getId(),icon!.getTangoItem()!.getPos(), icon!.getTitle()!))
                pos += 1
            }
        }
    }
    
    
    /**
     * UWindowCallbacks
     */
    public func windowClose( window : UWindow ) {
        // Windowを閉じる
        for _window in windows {
            if window === _window! {
                _ = hideWindow(window: _window!, animation: true)
                break
            }
        }
    }
}

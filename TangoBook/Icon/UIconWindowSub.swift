//
//  UIcon.swift
//  TangoBook
//
//  Sub Windowのクラス
//  単語帳編集ページで表示されるコンテナアイコンの中を表示するためのウィンドウ
//
//  Created by Shusuke Unno on 2017/07/25.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import UIKit

// コールバック
public protocol UIconWindowSubCallbacks {
    /**
     サブウィンドウに対するアクションが呼ばれた
     - parameter actionId: 押されたボタンのID
     - parameter icon: 押されたアクションアイコン
     */
    func IconWindowSubAction( actionId : SubWindowActionId, icon : UIcon?)
}

/**
 * Enum
 */
public enum SubWindowActionId : Int , EnumEnumerable{
    case Close
    case Edit
    case Copy
    case Delete
//    case Export
    case Cleanup
}

public class UIconWindowSub : UIconWindow {
    // button id
    private static let buttonIdClose = 299
    private static let buttonIdEdit = 300
    private static let buttonIdCopy = 301
    private static let buttonIdDelete = 302
    private static let buttonIdCleanup = 303
//    private static let buttonIdExport = 304
    
    // ウィンドウの下に表示されるアクションボタンの情報
    public struct ActionInfo {
        var imageName : ImageName
        var buttonId : Int
        var title : String
        var color : UIColor
        
        init(imageName: ImageName, buttonId : Int, title : String, color : UIColor) {
            self.imageName = imageName
            self.buttonId = buttonId
            self.title = UResourceManager.getStringByName(title)
            self.color = color
        }
    }
    
    private static let bookIds : [SubWindowActionId] = [.Close, .Edit, .Copy]
    private static let trashIds : [SubWindowActionId] = [.Close, .Cleanup]
    
    /**
     * Consts
     */
    private static let MARGIN_H = 17
    private static let MARGIN_V = 7
    private static let MARGIN_V2 = 17
    
    /**
     * Member variables
     */
    // 親のアイコン
    private var mParentIcon : UIcon?
    
    // SubWindowの上に表示するアイコンボタン
    private var mBookButtons : UIconWindowButtons?
    private var mTrashButtons : UIconWindowButtons?
    
    // コールバック用のインターフェース
    private var mIconWindowSubCallback : UIconWindowSubCallbacks? = nil
    
    /**
     * Get/Set
     */
    public func setParentIcon(icon : UIcon) {
        mParentIcon = icon
    }
    public func getParentIcon() -> UIcon? {
        return mParentIcon
    }
    
    private func getButtons() -> UIconWindowButtons {
        return (getParentType() == TangoParentType.Book) ? mBookButtons! : mTrashButtons!
        
    }

    /**
     * Constructor
     */
    public init( topScene: TopScene,
                 windowCallbacks : UWindowCallbacks?,
                 iconCallbacks : UIconCallbacks?,
                 iconWindowSubCallbacks : UIconWindowSubCallbacks?,
                 isHome : Bool, dir : WindowDir,
                 width : CGFloat, height : CGFloat, bgColor : UIColor)
    {
        super.init(topScene: topScene,
                   windowCallbacks: windowCallbacks,
                   iconCallbacks: iconCallbacks,
                   isHome: isHome, dir: dir, width: width, height: height,
                   bgColor: bgColor)
        
        mIconWindowSubCallback = iconWindowSubCallbacks
        // 閉じるボタンは表示しない
        closeIcon = nil
    }

    /**
     * Create class instance
     * It doesn't allow to create multi Home windows.
     * @return
     */
//    public static func createInstance(
//        topScene : TopView,
//        windowCallbacks : UWindowCallbacks?,
//        iconCallbacks : UIconCallbacks?,
//        iconWindowSubCallbacks : UIconWindowSubCallbacks?,
//        isHome : Bool, dir : WindowDir,
//        width : CGFloat, height : CGFloat, bgColor : UIColor) -> UIconWindowSub
//    {
//        let instance = UIconWindowSub(
//            topScene: topScene,
//            windowCallbacks : windowCallbacks, iconCallbacks: iconCallbacks,
//            iconWindowSubCallbacks: iconWindowSubCallbacks,
//            isHome: isHome, dir: dir, width: width, height: height,
//            bgColor: bgColor)
//        
//        return instance
//    }

    /**
     * Methods
     */
    public override func initialize() {
        super.initialize()
        
        // アイコンボタンの初期化
        
        // Bookを開いたときのアイコンを初期化
        mBookButtons = UIconWindowButtons(callbacks: self,
                                          priority: DrawPriority.SubWindowIcon.rawValue, x: 0, y: 0)
        for id in UIconWindowSub.bookIds {
            mBookButtons?.addButton(id: id)
        }
        mBookButtons!.initSKNode()
        mBookButtons!.parentNode.isHidden = true
        self.parentNode.addChild2(mBookButtons!.parentNode)

        // ゴミ箱を開いたときのアイコンを初期化
        mTrashButtons = UIconWindowButtons(callbacks: self,
                                          priority: DrawPriority.SubWindowIcon.rawValue, x: 0, y: 0)
        for id in UIconWindowSub.trashIds {
            mTrashButtons!.addButton(id: id)
        }
        mTrashButtons!.initSKNode()
        mTrashButtons!.parentNode.isHidden = true
        self.parentNode.addChild2(mTrashButtons!.parentNode)
    }
    
    /**
     * サブウィンドウに表示するアクションボタンを設定する
     */
    public func setActionButtons(_ type : TangoParentType) {
        mBookButtons!.parentNode.isHidden = true
        mTrashButtons!.parentNode.isHidden = true
        
        if type == .Book {
            mBookButtons!.isShow = true
            mTrashButtons!.isShow = false
        } else if type == .Trash {
            mBookButtons!.isShow = false
            mTrashButtons!.isShow = true
        }
    }
    
    /**
     アクションボタンの情報を取得する
     - parameter id: 情報を取得するアクションボタンのID
     - returns: アクションボタンの情報
     */
    static func getActionInfo(id : SubWindowActionId) -> ActionInfo {
        switch id {
        case .Close:
            return ActionInfo(imageName: ImageName.close, buttonId: buttonIdClose,
                              title : "close", color : UColor.DarkRed)
        case .Edit:
            return ActionInfo(imageName: ImageName.edit, buttonId: buttonIdEdit,
                              title : "edit", color : UColor.DarkGreen)
        case .Copy:
            return ActionInfo(imageName: ImageName.copy, buttonId: buttonIdCopy,
                              title : "copy", color : UColor.DarkGreen)
        case .Delete:
            return ActionInfo(imageName: ImageName.trash, buttonId: buttonIdDelete,
                              title : "trash", color : UColor.DarkGreen)
//        case .Export:
//            return ActionInfo(imageName: ImageName.export, buttonId: buttonIdExport,
//                              title : "export", color : UColor.DarkGreen)
        case .Cleanup:
            return ActionInfo(imageName: ImageName.trash2, buttonId: buttonIdCleanup,
                              title : "clean_up", color : UColor.DarkGreen)
        }
    }
    /**
     * 毎フレーム行う処理
     * @return true:再描画を行う(まだ処理が終わっていない)
     */
    override public func doAction() -> DoActionRet {
        var ret = DoActionRet.None
        
        var _ret = super.doAction()
        switch _ret {
        case .Done:
            return ret
        case .Redraw:
            ret = _ret
        default:
            break
        }
        
        _ret = getButtons().doAction()
        switch _ret {
        case .Done:
            return _ret
        case .Redraw:
            ret = _ret
        default:
            break
        }
        return ret
    }

    /**
     * タッチ処理
     * @param vt
     * @return trueならViewを再描画
     */
    override public func touchEvent( vt : ViewTouch, offset : CGPoint?) -> Bool {
        if !isShow {
            return false
        }
        if state == WindowState.icon_moving {
            return false
        }
        
        // アイコンのタッチ処理
        let buttons = getButtons()
        var offset2 = CGPoint(x: pos.x, y: pos.y + buttons.pos.y)
        if offset != nil {
            offset2.x += offset!.x
            offset2.y += offset!.y
        }

        if buttons.touchEvent(vt: vt, offset: offset2) {
            return true
        }
        
        return super.touchEvent(vt: vt, offset: offset)
    }
    
    /**
     * 描画処理
     * UIconManagerに登録されたIconを描画する
     * @param canvas
     * @param paint
     * @return trueなら描画継続
     */
    public override func drawContent( offset : CGPoint? )
    {
        super.drawContent(offset: offset)
        
        // アクションボタンの表示
        // 非表示時、移動時は表示しない
        let buttons : UIconWindowButtons = getButtons()
        let y = size.height - buttons.size.height
        buttons.pos = CGPoint(x: 0, y: y)
        buttons.parentNode.isHidden = !(isShow && !isMoving)
        buttons.parentNode.position = CGPoint( x: 0, y: y).convToSK()
        
        buttons.draw()
    }

    /**
     * UButtonCallbacks
     */
    public override func UButtonClicked(id : Int, pressedOn : Bool) -> Bool {
        switch id {
        case UIconWindowSub.buttonIdClose:
            if mIconWindowSubCallback != nil {
                mIconWindowSubCallback!.IconWindowSubAction(actionId: SubWindowActionId.Close, icon: nil)
            }
        case UIconWindowSub.buttonIdEdit:
            if mIconWindowSubCallback != nil && mParentIcon != nil {
                mIconWindowSubCallback!.IconWindowSubAction(actionId:SubWindowActionId.Edit, icon: mParentIcon!)
            }
        case UIconWindowSub.buttonIdCopy:
            if (mIconWindowSubCallback != nil && mParentIcon != nil ) {
                mIconWindowSubCallback!.IconWindowSubAction(actionId:SubWindowActionId.Copy, icon: mParentIcon!)
            }
//        case UIconWindowSub.buttonIdExport:
//            if (mIconWindowSubCallback != nil && mParentIcon != nil ) {
//                mIconWindowSubCallback!.IconWindowSubAction(actionId:SubWindowActionId.Export, icon: mParentIcon!)
//            }
        case UIconWindowSub.buttonIdDelete:
            if (mIconWindowSubCallback != nil && mParentIcon != nil ) {
                mIconWindowSubCallback!.IconWindowSubAction(actionId: SubWindowActionId.Delete, icon: mParentIcon)
            }
        case UIconWindowSub.buttonIdCleanup:
            if (mIconWindowSubCallback != nil) {
                mIconWindowSubCallback!.IconWindowSubAction(actionId: SubWindowActionId.Cleanup, icon: nil)
            }
        default:
            break
        }
        if (super.UButtonClicked(id: id, pressedOn: pressedOn)) {
            return true
        }
        return false
    }
    
}

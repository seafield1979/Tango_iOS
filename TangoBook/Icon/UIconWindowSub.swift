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
    case Export
    case Cleanup
}

public class UIconWindowSub : UIconWindow {
    // button id
    private static let buttonIdClose = 299
    private static let buttonIdEdit = 300
    private static let buttonIdCopy = 301
    private static let buttonIdDelete = 302
    private static let buttonIdCleanup = 303
    private static let buttonIdExport = 304
    
    // color
    private static let ICON_BG_COLOR = UColor.LightYellow

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
    
    private static let bookIds : [SubWindowActionId] = [.Close, .Edit, .Copy, .Export]
    private static let trashIds : [SubWindowActionId] = [.Close, .Cleanup]
    
    /**
     * Consts
     */
    private static let MARGIN_H = 17
    private static let MARGIN_V = 7
    private static let MARGIN_V2 = 17
    private static let ICON_TEXT_SIZE = 10
    private static let ACTION_ICON_W = 34
    
    /**
     * Member variables
     */
    // 親のアイコン
    private var mParentIcon : UIcon?
    
    // SubWindowの上に表示するアイコンボタン
    private var mBookButtons : [UButtonImage] = []
    private var mTrashButtons : [UButtonImage] = []

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
    
    private func getButtons() -> [UButtonImage] {
        return (getParentType() == TangoParentType.Book) ? mBookButtons : mTrashButtons;
        
    }

    /**
     * Constructor
     */
    public init( parentView: TopView,
                 windowCallbacks : UWindowCallbacks?,
                 iconCallbacks : UIconCallbacks?,
                 iconWindowSubCallbacks : UIconWindowSubCallbacks?,
                 isHome : Bool, dir : WindowDir,
                 width : CGFloat, height : CGFloat, bgColor : UIColor)
    {
        super.init(parentView: parentView,
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
//        parentView : TopView,
//        windowCallbacks : UWindowCallbacks?,
//        iconCallbacks : UIconCallbacks?,
//        iconWindowSubCallbacks : UIconWindowSubCallbacks?,
//        isHome : Bool, dir : WindowDir,
//        width : CGFloat, height : CGFloat, bgColor : UIColor) -> UIconWindowSub
//    {
//        let instance = UIconWindowSub(
//            parentView: parentView,
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
        let marginH = UDpi.toPixel(UIconWindowSub.MARGIN_H)
        var x = marginH
        let y = UDpi.toPixel(-UIconWindowSub.ACTION_ICON_W - UIconWindowSub.MARGIN_V2)
        
        // Bookを開いたときのアイコンを初期化
        var i : Int = 0
        for id in UIconWindowSub.bookIds {
            let info = UIconWindowSub.getActionInfo(id: id)
            let button = createActionButton(info: info, x: x, y: y)
            mBookButtons.append(button)
            
            x += UDpi.toPixel(UIconWindowSub.ACTION_ICON_W + UIconWindowSub.MARGIN_H);
            i += 1
        }

        // ゴミ箱を開いたときのアイコンを初期化
        x = marginH
        i = 0
        for id in UIconWindowSub.trashIds {
            let info = UIconWindowSub.getActionInfo(id: id)
            let button = createActionButton(info: info, x: x, y: y)
            mTrashButtons.append(button)
            
            x += UDpi.toPixel(UIconWindowSub.ACTION_ICON_W + UIconWindowSub.MARGIN_H);
            i += 1
        }
    }
    
    /**
     ウィンドウの下に表示するアクションボタンを生成する
     */
    func createActionButton(info : ActionInfo, x: CGFloat, y: CGFloat) -> UButtonImage {
        let image = UResourceManager.getImageWithColor(imageName: info.imageName, color: info.color)!
        
        let button = UButtonImage.createButton(
            callbacks: self,
            id: info.buttonId, priority: 0, x: x, y: y,
            width: UDpi.toPixel(UIconWindowSub.ACTION_ICON_W),
            height: UDpi.toPixel(UIconWindowSub.ACTION_ICON_W),
            image: image,
            pressedImage: nil)
        
        button.setTitle(title: info.title,
                        size: Int(UDpi.toPixel(UIconWindowSub.ICON_TEXT_SIZE)),
                        color: UIColor.black)
        return button

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
        case .Export:
            return ActionInfo(imageName: ImageName.export, buttonId: buttonIdExport,
                              title : "export", color : UColor.DarkGreen)
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
        
        for button in getButtons() {
            _ret = button.doAction()
            switch _ret {
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
        var offset2 = CGPoint(x: pos.x, y: pos.y + size.height)
        if offset != nil {
            offset2.x += offset!.x
            offset2.y += offset!.y
        }
        
        for button in getButtons() {
            if button.touchEvent(vt: vt, offset: offset2) {
                return true
            }
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
        
        if isMoving {
            return
        }
        
        let marginH = UDpi.toPixel(UIconWindowSub.MARGIN_H)
        
        // アイコンの背景
        let buttons : [UButtonImage] = getButtons()
        
        let width = CGFloat(buttons.count) * (UDpi.toPixel(UIconWindowSub.ACTION_ICON_W) + marginH) + marginH
        let height = UDpi.toPixel(UIconWindowSub.ACTION_ICON_W + UIconWindowSub.MARGIN_V + UIconWindowSub.MARGIN_V2)
        let x = pos.x
        let y = pos.y + size.height + UDpi.toPixel( -UIconWindowSub.MARGIN_V2 - UIconWindowSub.MARGIN_V - UIconWindowSub.ACTION_ICON_W);
        
        // BG
        UDraw.drawRoundRectFill(rect: CGRect(x:x, y:y, width:width, height:height),
                                cornerR: UDpi.toPixel(10), color:UIconWindowSub.ICON_BG_COLOR,
                                strokeWidth: 0, strokeColor: nil)
        
        // アイコンの描画
        let _pos = CGPoint(x: pos.x, y: pos.y + size.height)
        for button in buttons {
            button.draw(_pos)
        }
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
        case UIconWindowSub.buttonIdExport:
            if (mIconWindowSubCallback != nil && mParentIcon != nil ) {
                mIconWindowSubCallback!.IconWindowSubAction(actionId:SubWindowActionId.Export, icon: mParentIcon!)
            }
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

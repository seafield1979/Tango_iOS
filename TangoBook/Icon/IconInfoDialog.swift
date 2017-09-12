//
//  IconInfoDialog.swift
//  TangoBook
//
//  Created by Shusuke Unno on 2017/07/29.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import UIKit


/**
* ダイアログに表示する項目
*/
struct IconInfoItem {
    public var title : UTextView? = nil
    public var body : UTextView? = nil
}

 /**
  * アイコン情報ダイアログのアクションアイコン
  * これらのアイコンをタップするとアイコンに応じた処理を行う
  */
public struct ActionIconInfo {
    var id : ActionIconId
    var imageName : ImageName
    var titleName : String
}

public enum ActionIconId : Int, EnumEnumerable{
    case Open
    case Edit
    case MoveToTrash
    case Copy
    case Favorite
    case CleanUp
    case OpenTrash
    case Return
    case Delete
    case Study
    
    public func getInfo() -> ActionIconInfo {
        switch self {
        case .Open:
            return ActionIconInfo(id: self, imageName: ImageName.open, titleName: "open")
        case .Edit:
            return ActionIconInfo(id: self, imageName: ImageName.edit, titleName: "edit")
        case .MoveToTrash:
            return ActionIconInfo(id: self, imageName: ImageName.trash, titleName: "trash")
        case .Copy:
            return ActionIconInfo(id: self, imageName: ImageName.copy, titleName: "copy")
        case .Favorite:
            return ActionIconInfo(id: self, imageName: ImageName.favorites, titleName: "learned")
        case .CleanUp:
            return ActionIconInfo(id: self, imageName: ImageName.trash2, titleName: "clean_up")
        case .OpenTrash:
            return ActionIconInfo(id: self, imageName: ImageName.trash2, titleName: "open")
        case .Return:
            return ActionIconInfo(id: self, imageName: ImageName.return1, titleName: "return_to_home")
        case .Delete:
            return ActionIconInfo(id: self, imageName: ImageName.trash2, titleName: "delete")
        case .Study:
            return ActionIconInfo(id: self, imageName: ImageName.play, titleName: "study")
        }
    }
}



 /**
  * アイコンをクリックしたときに表示されるダイアログ
  * 抽象クラス
  */
public class IconInfoDialog : UWindow {
    
    /**
     * Consts
     */
    let FRAME_WIDTH = 2
    let FRAME_COLOR = UColor.makeColor(120,120,120)
    let TOP_ITEM_Y = 10

    let MARGIN_H = 17
    let MARGIN_V = 14
    let MARGIN_V_S = 6
    let DLG_MARGIN = 15
    let FRAME_W = 3
    
    /**
     * Member Variables
     */
    weak var mIconInfoCallbacks : IconInfoDialogCallbacks? = nil

    // ダイアログに情報を表示元のアイコン
    var mIcon : UIcon

    /**
     * Get/Set
     */
    public func getmIcon() -> UIcon {
        return mIcon
    }

    /**
     * Constructor
     */
    public init( topScene : TopScene,
                                iconInfoCallbacks : IconInfoDialogCallbacks?,
                                windowCallbacks : UWindowCallbacks?,
                                icon : UIcon,
                                x : CGFloat, y : CGFloat,
                                bgColor : UIColor?)
    {
        mIconInfoCallbacks = iconInfoCallbacks
        mIcon = icon
        
        // width, height はinit内で計算するのでここでは0を設定
        super.init(topScene: topScene,
                   callbacks: windowCallbacks,
                   priority : DrawPriority.Dialog.rawValue,
                   createNode: false, cropping: false,
                   x : x, y : y, width : 0, height : 0,
                   bgColor : bgColor,
                   topBarH: 0, frameW: 0, frameH: 0, cornerRadius: UDpi.toPixel(10))
        
        parentNode.zPosition = CGFloat(DrawPriority.Dialog.rawValue)
        
        frameColor = .darkGray
        frameSize = CGSize(width: UDpi.toPixel(FRAME_W),
                           height: UDpi.toPixel(FRAME_W))
    }


     /**
      * Methods
      */
    
    // Card
    public static func getCardIcons() -> List<ActionIconInfo> {
        let list : List<ActionIconInfo> = List()
        list.append(ActionIconId.Edit.getInfo())
        list.append(ActionIconId.Copy.getInfo())
        list.append(ActionIconId.MoveToTrash.getInfo())
        list.append(ActionIconId.Favorite.getInfo())
        return list
    }
    
    // Book Study
    public static func getBookStudyIcons() -> List<ActionIconInfo> {
        let list : List<ActionIconInfo> = List()
        list.append(ActionIconId.Study.getInfo())
        list.append(ActionIconId.Open.getInfo())
        return list
    }
    
    // Trash
    public static func getTrashIcons() -> List<ActionIconInfo> {
        let list : List<ActionIconInfo> = List()
        list.append(ActionIconId.OpenTrash.getInfo())
        list.append(ActionIconId.CleanUp.getInfo())
        return list
    }
    
    // in Trash
    public static func getInTrashIcons() -> List<ActionIconInfo> {
        let list : List<ActionIconInfo>  = List()
        list.append(ActionIconId.Return.getInfo())
        list.append(ActionIconId.Delete.getInfo())
        return list
    }

    public override func touchEvent( vt : ViewTouch, offset : CGPoint?) -> Bool{
        if super.touchEvent(vt: vt, offset: offset) {
            return true
        }
        
        // ダイアログ範囲外をタッチしたら閉じる
        if vt.type == .Touch {
            if !rect.contains( CGPoint(x: vt.touchX, y: vt.touchY)) {
                closeWindow()
                return true
            }
        }

        return false
    }
}

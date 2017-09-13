//
//  MenuBarTangoEdit.swift
//  TangoBook
//
//  Created by Shusuke Unno on 2017/07/29.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import UIKit

/**
 * Created by shutaro on 2016/12/06.
 *
 * 単語帳編集ページで表示するメニューバー
 */

public class MenuBarTangoEdit : UMenuBar {
    // MARK: Enums
    public enum MenuItemType {
        case Top
        case Child
        case State
    }

    struct MenuItemInfo {
        var id : MenuItemId
        var type : MenuItemType
        var imageName : ImageName
        var stringName : String
        var color : UIColor?
        var forDebug : Bool
    }
    
    // メニューのID、画像ID、Topかどうかのフラグ
    public enum MenuItemId : Int, EnumEnumerable {
        case AddTop
        case AddCard
        case AddBook
        case AddDummyCard
        case AddDummyBook
        case AddPresetBook
    }

    // MARK: Constants
    private let TEXT_COLOR = UIColor.white
    private let TEXT_BG_COLOR = UColor.makeColor(192,0,0,0)
    private let ICON_COLOR = UIColor.black
    
    // MARK: Properties
    var itemInfos : [MenuItemInfo] = []

    // MARK: Initializer
    public init( topScene: TopScene, callbackClass : UMenuItemCallbacks,
                 parentW : CGFloat, parentH : CGFloat, bgColor : UIColor?)
    {
        super.init (topScene: topScene, callbacks: callbackClass, parentW: parentW, parentH: parentH, bgColor: bgColor)
        
        // 画面右端に寄せる
        pos.x = parentW - UDpi.toPixel(UMenuItem.ITEM_W + UMenuBar.MARGIN_H)
        parentNode.position = pos

        itemInfos.append( MenuItemInfo(id: MenuItemId.AddTop, type: MenuItemType.Top, imageName: ImageName.add2, stringName: "", color: nil, forDebug: false))
        
        itemInfos.append( MenuItemInfo(id: MenuItemId.AddCard, type: MenuItemType.Child, imageName: ImageName.card, stringName: "add_card", color: ICON_COLOR, forDebug: false))
        
        itemInfos.append( MenuItemInfo(id: MenuItemId.AddBook, type: MenuItemType.Child, imageName: ImageName.cards, stringName: "add_book", color: ICON_COLOR, forDebug: false))
        
        itemInfos.append( MenuItemInfo(id: MenuItemId.AddDummyBook, type: MenuItemType.Child, imageName: ImageName.number_1, stringName: "add_dummy_card", color: ICON_COLOR, forDebug: true))
        
        itemInfos.append(MenuItemInfo(id: MenuItemId.AddDummyBook, type: MenuItemType.Child, imageName: ImageName.number_2, stringName: "add_dummy_book", color: ICON_COLOR, forDebug: true))
        
        itemInfos.append( MenuItemInfo(id: MenuItemId.AddPresetBook, type: MenuItemType.Child, imageName: ImageName.cards, stringName: "add_preset", color: ICON_COLOR, forDebug: false))
    }

    /**
     * メニューバーを生成する
     * @param topScene
     * @param callbackClass
     * @param parentW     親Viewのwidth
     * @param parentH    親Viewのheight
     * @param bgColor
     * @return
     */
    public static func createInstance(topScene : TopScene,
                                      callbackClass : UMenuItemCallbacks,
                                      parentW : CGFloat, parentH : CGFloat,
                                      bgColor : UIColor?) -> MenuBarTangoEdit
    {
        let instance = MenuBarTangoEdit( topScene: topScene,
                                         callbackClass: callbackClass,
                                         parentW: parentW, parentH: parentH,
                                         bgColor: bgColor)
        instance.initMenuBar()
        return instance
    }
    
    deinit {
        if UDebug.isDebug {
            print("MenuBarTangoEdit.deinit")
        }
    }

    /**
     * メニューバーを初期化
     * バーに表示する項目を追加する
     */
    override func initMenuBar() {
        var item : UMenuItem? = nil
        var itemTop : UMenuItem? = nil
        
        // add menu items
        for itemInfo in itemInfos {
            if itemInfo.forDebug {
                continue
            }
            
            let image : UIImage
            if let color = itemInfo.color {
                image = UResourceManager.getImageWithColor(imageName: itemInfo.imageName, color: color)!
            } else {
                image = UResourceManager.getImageByName(itemInfo.imageName)!
            }
            
            switch itemInfo.type {
            case .Top:
                itemTop = addTopMenuItem(menuId: itemInfo.id.rawValue, image: image)
                item = itemTop
                
            case .Child:
                item = addMenuItem(parent: itemTop!, menuId: itemInfo.id.rawValue, image:image)
                
                // アイコンの左側に表示
                item!.addTitle(title: UResourceManager.getStringByName(itemInfo.stringName),
                               alignment: UAlignment.Right_CenterY,
                               x: UDpi.toPixel(-8), y: item!.getHeight() / 2, color: TEXT_COLOR, bgColor: TEXT_BG_COLOR)
                
            case .State:
                item!.addState(icon: image)
            }
        }
        self.addToDrawManager()
        updateBGSize()
    }
    
    /**
     * ソフトウェアキーボードの戻るボタンの処理
     * @return
     */
    public override func onBackKeyDown() -> Bool {
        // トップメニューが開いていたら閉じる
        for item in topItems {
            if item!.isOpened {
                item!.closeMenu()
                return true
            }
        }
        return false
    }
}

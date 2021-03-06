//
//  MenuBarTest1.swift
//  UGui
//
//  Created by Shusuke Unno on 2017/07/17.
//  Copyright © 2017年 Shusuke Unno. All rights reserved.
//

import Foundation
import UIKit

public class MenuBarTest1 : UMenuBar {
    /**
     * Enums
     */
    
    // メニューをタッチした時に返されるID
    public enum MenuItemId : Int {
        case DebugTop
        case Debug1
        case Debug2
        case Debug3
    }
    
    /**
     * Constructor
     */
    public init(topScene : TopScene, callbacks : UMenuItemCallbacks,
                parentW : CGFloat, parentH : CGFloat, bgColor : UIColor? )
    {
        super.init(topScene: topScene, callbacks: callbacks,
                   parentW: parentW, parentH: parentH,
                   bgColor: bgColor)
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
    public static func createInstance(
        topScene : TopScene, callbacks : UMenuItemCallbacks,
        parentW : CGFloat, parentH : CGFloat, bgColor : UIColor?) -> MenuBarTest1
    {
        let instance = MenuBarTest1(
            topScene: topScene, callbacks : callbacks,
            parentW: parentW, parentH: parentH, bgColor: bgColor)
        
        instance.initMenuBar()
        return instance
    }
    
    /**
     * Methods
     */
    override func initMenuBar() {
        var item : UMenuItem? = nil
        
        // Add
        let image = UResourceManager.getImageByName(ImageName.debug)
        let image2 = UResourceManager.getImageByName(ImageName.debug)
        // Debug
        item = addTopMenuItem( menuId: MenuItemId.DebugTop.rawValue, image: image! )
        _ = addMenuItem(parent: item!, menuId: MenuItemId.Debug1.rawValue, image: image2!)
        _ = addMenuItem(parent: item!, menuId: MenuItemId.Debug2.rawValue, image: image2!)
        _ = addMenuItem(parent: item!, menuId: MenuItemId.Debug3.rawValue, image: image2!)
        
        self.addToDrawManager()
        
        updateBGSize()
    }
}

//
//  ListItemBackup.swift
//  TangoBook
//      ListViewBackup に表示される項目
//  Created by Shusuke Unno on 2017/08/30.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import SpriteKit

public class ListItemBackup : UListItem {
    // MARK: Constants
    // layout
    private let ITEM_H2 : Int = 117
    private let MARGIN_H : Int = 10
    private let MARGIN_V : Int = 7
    private let FRAME_WIDTH : Int = 1
    private let FONT_SIZE : Int = 17
    private let FONT_SIZE_S : Int = 13
    
    private let FRAME_COLOR = UIColor.black
    private let FONT_COLOR = UIColor.black
    
    // MARK: Properties
    private var titleNode : SKLabelNode?
    private var textNode : SKLabelNode?
    
    private var mTitle : String?          // タイトル
    private var mText : String?           // バックアップ情報
    private var mBackup : BackupFile?

    // MARK: Accessor
    public func setText( text : String? ) {
        mText = text
    }
    
    public func getBackup() -> BackupFile? {
        return mBackup
    }
    
    // MARK: Initializer
    
    public init( listItemCallbacks : UListItemCallbacks,
                 backup: BackupFile,
                 x : CGFloat, width : CGFloat)
    {
        super.init( callbacks : listItemCallbacks, isTouchable : true,
                    x : x, width : width, height : UDpi.toPixel(ITEM_H2),
                    bgColor : UIColor.white, frameW : UDpi.toPixel(FRAME_WIDTH),
                    frameColor : FRAME_COLOR)
        
        mBackup = backup;
        
        // 自動バックアップと手動バックアップでタイトルの文字列が異なる
        if (backup.isAutoBackup()) {
            mTitle = UResourceManager.getStringByName("backup_auto")
        } else {
            mTitle = UResourceManager.getStringByName("backup") + String(format: "%02d", backup.getId())
        }
        
        // mText
        if backup.isEnabled() {
            mText = String( format: "%@\n%@ : %d\n%@ : %d",
                UUtil.convDateFormat(date: backup.getDateTime(), mode: ConvDateMode.DateTime)!,
                UResourceManager.getStringByName("card_count"),
                backup.getCardNum(),
                UResourceManager.getStringByName("book_count"),
                backup.getBookNum())
        
        } else {
            mText = UResourceManager.getStringByName("empty")
        }
        
        initSKNode()
    }
    
    public override func initSKNode() {
        if let n = titleNode {
            n.removeFromParent()
        }
        if let n = textNode {
            n.removeFromParent()
        }
        
        // title
        titleNode = SKNodeUtil.createLabelNode(
            text: mTitle!, fontSize: UDpi.toPixel(FONT_SIZE_S), color: UColor.DarkBlue,
            alignment: .Left,
            pos: CGPoint(x:UDpi.toPixel(MARGIN_H), y: UDpi.toPixel(MARGIN_V))).node
        parentNode.addChild2(titleNode!)
        
        // text
        textNode = SKNodeUtil.createLabelNode(
            text: mText!, fontSize: UDpi.toPixel(FONT_SIZE), color: FONT_COLOR,
            alignment: .Center,
            pos: CGPoint(x: size.width / 2,
                         y: size.height / 2)).node
        parentNode.addChild2(textNode!)
    }
    
    // MARK: Methods
    /**
     * 描画処理
     * @param canvas
     * @param paint
     * @param offset 独自の座標系を持つオブジェクトをスクリーン座標系に変換するためのオフセット値
     */
    public override func draw() {
        super.draw()
    }
}


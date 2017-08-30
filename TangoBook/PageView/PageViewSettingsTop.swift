//
//  PageViewBackup.swift
//  TangoBook
//      設定ページトップ
//  Created by Shusuke Unno on 2017/07/24.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import UIKit

public class PageViewSettingsTop : UPageView, UButtonCallbacks {
    /**
     * Enums
     */
    // MARK: Enums
    enum ButtonId : Int, EnumEnumerable {
        case Option = 0
        case Backup
        case Restore
    }
    
    // タイトル画面で表示するボタンの情報
    public struct ButtonTInfo {
        var id : ButtonId
        var textName : String
        var textColor : UIColor
        var lineColor : UIColor
        var bgColor : UIColor
        var imageName : ImageName
        
        func getTitle() -> String {
            return UResourceManager.getStringByName(textName)
        }
    }
    
    private static let COLOR1 = UColor.makeColor(153,204,255)
    
    public var buttonInfo : [ButtonTInfo] = [
        ButtonTInfo(id : ButtonId.Option,
                    textName: "title_options",
                    textColor: UColor.DarkBlue,
                    lineColor: UColor.DarkBlue,
                    bgColor: PageViewSettingsTop.COLOR1,
                    imageName: ImageName.settings_1 ),
        ButtonTInfo(id : ButtonId.Backup,
                    textName: "backup",
                    textColor: UColor.DarkBlue,
                    lineColor: UColor.DarkBlue,
                    bgColor: PageViewSettingsTop.COLOR1,
                    imageName: ImageName.backup ),
        ButtonTInfo(id : ButtonId.Restore,
                    textName: "restore",
                    textColor: UColor.DarkBlue,
                    lineColor: UColor.DarkBlue,
                    bgColor: PageViewSettingsTop.COLOR1,
                    imageName: ImageName.restore )
    ]

    /**
     * Constants
     */
    // MARK: Constants
    public static let TAG = "PageViewSettingsTop"

    // MARK: Properties
    private let DRAW_PRIORITY : Int = 100
    private let BUTTON2_H : Int  = 67
    private let TEXT_SIZE : Int  = 17
    private let IMAGE_W : Int  = 35

    // button ids
    private let ButtonIdContactOK : Int = 100

    private let TEXT_COLOR : UIColor = .black

    /**
     * Member variables
     */
    // Buttons
    private var mButtons : [UButtonText] = []

    
    /**
     * Constructor
     */
    public init( topScene : TopScene, title : String) {
        super.init( topScene: topScene, pageId: PageIdMain.Settings.rawValue, title: title)
    }
    
    /**
     * Methods
     */
    
    override func onShow() {
    }
    
    override func onHide() {
        super.onHide();
    }
    
    /**
     * 描画処理
     * サブクラスのdrawでこのメソッドを最初に呼び出す
     * @param canvas
     * @param paint
     * @return
     */
    override func draw() -> Bool {
        if isFirst {
            isFirst = false
            initDrawables()
        }
        return false
    }
    
    /**
     * タッチ処理
     * @param vt
     * @return
     */
    public func touchEvent(vt : ViewTouch) -> Bool {
        
        return false
    }
    
    /**
     * そのページで表示される描画オブジェクトを初期化する
     */
    public override func initDrawables() {
        UDrawManager.getInstance().initialize()

        let width : CGFloat = mTopScene.getWidth()
        
        let x : CGFloat = UDpi.toPixel(UPageView.MARGIN_H)
        var y : CGFloat = UDpi.toPixel(UPageView.MARGIN_V)

        let buttonW : CGFloat = width - UDpi.toPixel(UPageView.MARGIN_H) * 2
        let buttonH : CGFloat = UDpi.toPixel(BUTTON2_H)

        for i in 0 ..< buttonInfo.count {
            let info = buttonInfo[i]

            let button = UButtonText(
                callbacks : self, type : UButtonType.Press, id : info.id.rawValue,
                priority : DRAW_PRIORITY, text : info.getTitle(),
                createNode : true, x : x, y : y,
                width : buttonW, height : buttonH, fontSize : UDpi.toPixel(TEXT_SIZE),
                textColor : info.textColor, bgColor : info.bgColor)
            
            let image : UIImage = UResourceManager.getImageWithColor(
                imageName: info.imageName, color: info.lineColor)!
            
            button.setImage( image: image,
                                  imageSize: CGSize(width: UDpi.toPixel(IMAGE_W), height: UDpi.toPixel(IMAGE_W)),
                                  initNode: true)
            
            // 表示座標を少し調整
            button.setImageAlignment( UAlignment.Center )
            button.setImageOffset( x: UDpi.toPixel(-IMAGE_W - 50), y: 0 )
            button.setTextOffset( x: UDpi.toPixel(UPageView.MARGIN_H) / 2, y: 0 )

            button.addToDrawManager()
            mButtons.append( button )

            y += buttonH + UDpi.toPixel(UPageView.MARGIN_V)
        }
    }

    
    /**
     * ソフトウェアキーの戻るボタンを押したときの処理
     * @return
     */
    public override func onBackKeyDown() -> Bool {
        return false
    }
    
    // MARK: Callbacks
    /**
     * UButtonCallbacks
     */
    /**
     * ボタンがクリックされた時の処理
     * @param id  button id
     * @param pressedOn  押された状態かどうか(On/Off)
     * @return
     */
    public func UButtonClicked( id : Int, pressedOn : Bool ) -> Bool {
        let buttonId = ButtonId.toEnum(id)
        switch buttonId {
            case .Option:
                // オプション設定ページに移動
                _ = PageViewManagerMain.getInstance().stackPage( pageId: PageIdMain.Options.rawValue)
            
            case .Backup:
                // バックアップページに遷移
                _ = PageViewManagerMain.getInstance().stackPage( pageId: PageIdMain.BackupDB.rawValue)
            
            case .Restore:
                // バックアップページに遷移
                _ = PageViewManagerMain.getInstance().stackPage( pageId: PageIdMain.RestoreDB.rawValue)
        }
        return false;
    }
}

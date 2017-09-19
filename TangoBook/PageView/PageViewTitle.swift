//
//  PageViewTitle.swift
//  TangoBook
//    タイトルページ。ここから各種ページに遷移する
//  Created by Shusuke Unno on 2017/07/24.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import UIKit

public class PageViewTitle : UPageView, UButtonCallbacks {
    // MARK: Enums
    enum TitleButtonId : Int, EnumEnumerable {
        case Edit = 0
        case Study
        case History
        case Settings
        case Help
        case Debug
    }

    
    // タイトル画面で表示するボタンの情報
    public struct ButtonTInfo {
        var id : TitleButtonId
        var textName : String
        var textColor : UIColor
        var lineColor : UIColor
        var bgColor : UIColor
        var imageName : ImageName
        
        func getTitle() -> String {
            return UResourceManager.getStringByName(textName)
        }
    }

    public var buttonInfo : [ButtonTInfo] = [
        ButtonTInfo(id: TitleButtonId.Edit,
                    textName: "title_edit",
                    textColor: UColor.DarkGreen,
                    lineColor: UColor.DarkGreen,
                    bgColor: UColor.makeColor(100, 200, 100),
                    imageName: ImageName.edit ),
        ButtonTInfo(id: TitleButtonId.Study,
                    textName: "title_study",
                    textColor: UIColor.white,
                    lineColor: UIColor.white,
                    bgColor: UColor.makeColor(200,100,100),
                    imageName: ImageName.study ),
        ButtonTInfo(id: TitleButtonId.History,
                    textName: "title_history",
                    textColor: UColor.DarkYellow,
                    lineColor: UColor.DarkYellow,
                    bgColor: UColor.Yellow,
                    imageName: ImageName.history ),
        ButtonTInfo(id: TitleButtonId.Settings,
                    textName: "title_settings",
                    textColor: UColor.DarkBlue,
                    lineColor: UColor.DarkBlue,
                    bgColor: UColor.makeColor(153,204,255),
                    imageName: ImageName.settings_1 ),
        ButtonTInfo(id: TitleButtonId.Help,
                    textName: "title_help",
                    textColor: UIColor.white,
                    lineColor: UColor.DarkOrange,
                    bgColor: UColor.makeColor(255,178,102),
                    imageName: ImageName.question2 ),
        ButtonTInfo(id: TitleButtonId.Debug,
                    textName: "title_debug",
                    textColor: UIColor.white,
                    lineColor: UColor.DarkGray,
                    bgColor: UColor.makeColor(200,100,100),
                    imageName: ImageName.debug ),
        ]

    // MARK: Constants
    public static let TAG = "PageViewTitle"
    private static let DRAW_PRIORITY = 100

    private static let BUTTON_H = 65
    private static let ZOOM_BUTTON_W = 40
    internal static let MARGIN_H2 = 18
    internal static let MARGIN_V2 = 10

    private static let FONT_SIZE = 17
    private static let IMAGE_W = 35

    // button Ids
    private let ButtonIdZoomIn = 100
    private let ButtonIdZoomOut = 101

    // MARK: Properties
    private var mToast : UToast?
    
     // Title
    private var mTitleText : UTextView?

    // Buttons
    private var mButtons : [UButtonText] = []

    // MARK: Initializer
    public init(topScene : TopScene, title : String) {
        super.init(topScene: topScene, pageId: PageIdMain.Title.rawValue, title: title)
        
    }

    // MARK: Methods
     override public func onShow() {

     }

     override public func onHide() {
         super.onHide()
        
        mToast = nil
        mTitleText = nil
        mButtons.removeAll()
     }

     /**
     * そのページで表示される描画オブジェクトを初期化する
     */
     public override func initDrawables() {
        clearPageObject()
        
        let width = self.mTopScene.getWidth()

        var buttonType : UButtonType? = nil

        // 描画オブジェクトクリア
        UDrawManager.getInstance().initialize()

        // ボタンの配置
        // 横向きなら３列、縦向きなら３列
        let columnNum = 2

        // 単語帳作成＆学習ボタンは正方形
        var buttonW : CGFloat = (width - CGFloat(columnNum + 1) * UDpi.toPixel(PageViewTitle.MARGIN_H2)) / CGFloat(columnNum)

        buttonType = UButtonType.Press;

        // ズームボタン + -
        var zoomButtonW = UDpi.toPixel(PageViewTitle.ZOOM_BUTTON_W)
        if zoomButtonW < CGFloat(PageViewTitle.ZOOM_BUTTON_W) {
            zoomButtonW = CGFloat(PageViewTitle.ZOOM_BUTTON_W)
        }
        // +ボタン
        var buttonImage = UResourceManager.getImageWithColor(imageName: ImageName.zoom_in, color: UIColor.orange)
        var button = UButtonImage( callbacks: self,
                                  id: ButtonIdZoomIn,
                                  priority: PageViewTitle.DRAW_PRIORITY,
                                  x: width - zoomButtonW * 2 - UDpi.toPixel(20),
                                  y: UDpi.toPixel(10),
                                  width: zoomButtonW, height: zoomButtonW,
                                  image: buttonImage!, pressedImage: nil)
        button.addToDrawManager()
        
        // -ボタン
        buttonImage = UResourceManager.getImageWithColor(imageName: ImageName.zoom_out, color: UIColor.orange)
        button = UButtonImage(callbacks: self,
                              id: ButtonIdZoomOut,
                              priority: PageViewTitle.DRAW_PRIORITY,
                              x:width - zoomButtonW - UDpi.toPixel(10),
                              y: UDpi.toPixel(10),
                              width: zoomButtonW, height: zoomButtonW,
                              image: buttonImage!,
                              pressedImage: nil)
        button.addToDrawManager()

        var x = UDpi.toPixel(PageViewTitle.MARGIN_H2)
        var y = UDpi.toPixel(PageViewTitle.MARGIN_V2 + 10) + zoomButtonW

        // 上２つのボタンを生成
        for i in 0...1 {
            // 作成するボタン情報
            let info = buttonInfo[i]
            
            let button = UButtonText(
                callbacks: self,
                type: buttonType!,
                id: info.id.rawValue,
                priority: PageViewTitle.DRAW_PRIORITY,
                text: info.getTitle(), createNode: true,
                x: x, y: y,
                width: buttonW, height: buttonW,
                fontSize: UDpi.toPixel(PageViewTitle.FONT_SIZE),
                textColor: info.textColor, bgColor: info.bgColor)
            mButtons.append(button)
                
            let image = UResourceManager.getImageWithColor(imageName: info.imageName, color: info.lineColor)
            
            button.setImage(image: image!,
                                 imageSize: CGSize(width: UDpi.toPixel(PageViewTitle.IMAGE_W), height: UDpi.toPixel(PageViewTitle.IMAGE_W)),
                                 initNode: true)
            button.addToDrawManager()

            // 表示座標を少し調整
            button.setImageAlignment(UAlignment.Center)
            button.setImageOffset(x: 0, y: UDpi.toPixel(-20))
            button.setTextOffset(x: 0, y: UDpi.toPixel(16))

            x += buttonW + UDpi.toPixel(PageViewTitle.MARGIN_H2)
        }
        y += buttonW + UDpi.toPixel(PageViewTitle.MARGIN_V2)

        // 下の段は横長ボタン
        buttonW = width - UDpi.toPixel(PageViewTitle.MARGIN_H2) * 2
        let buttonH = UDpi.toPixel(PageViewTitle.BUTTON_H)
        x = UDpi.toPixel(PageViewTitle.MARGIN_H2)
        
        for i in 2..<buttonInfo.count {
            // デバッグモードがONの場合のみDebugを表示
            let info = buttonInfo[i]

            if i == TitleButtonId.Debug.rawValue {
                if !UDebug.isDebug {
                    continue
                }
            }

            let button = UButtonText(callbacks: self,
                                     type: buttonType!,
                                     id: info.id.rawValue,
                                     priority: PageViewTitle.DRAW_PRIORITY,
                                     text: info.getTitle(),
                                     createNode : true,
                                     x: x, y: y,
                                     width: buttonW, height: buttonH,
                                     fontSize: UDpi.toPixel(PageViewTitle.FONT_SIZE),
                                     textColor: info.textColor,
                                     bgColor: info.bgColor)
            mButtons.append(button)
            
            let image = UResourceManager.getImageWithColor(
                imageName: info.imageName, color: info.lineColor)
            
            button.setImage(
                image: image!,
                imageSize: CGSize(width: UDpi.toPixel(PageViewTitle.IMAGE_W),
                        height: UDpi.toPixel(PageViewTitle.IMAGE_W)),
                initNode: true)
            button.addToDrawManager()

            // 表示座標を少し調整
            button.setImageAlignment(UAlignment.Center);
            button.setImageOffset(x: UDpi.toPixel(-PageViewTitle.IMAGE_W - 20 - PageViewTitle.MARGIN_H2 / 2), y: 0)
            button.setTextOffset(x: UDpi.toPixel(PageViewTitle.MARGIN_H2) / 2, y: 0)

            y += buttonH + UDpi.toPixel(PageViewTitle.MARGIN_V2)
        }
     }
    
    /**
     * ページの全オブジェクトをクリアする
     */
    private func clearPageObject() {
        UDrawManager.getInstance().removeAll()
        mTopScene.removeAllChildren()

        mToast = nil
        mTitleText = nil
        mButtons.removeAll()
    }

     /**
     * ソフトウェアキーの戻るボタンを押したときの処理
     * @return
     */
     override public func onBackKeyDown() -> Bool {
         return false
     }

    // MARK: Callbacks
     /**
     * UButtonCallbacks
     */
    // ボタンがクリックされた時の処理
    public func UButtonClicked(id : Int, pressedOn : Bool) -> Bool {
        if  id < TitleButtonId.count  {

            let buttonId = TitleButtonId.toEnum(id)
            switch (buttonId) {
            case .Edit:
                _ = PageViewManagerMain.getInstance().stackPage(pageId: PageIdMain.Edit.rawValue)
            
            case .Study:
                _ = PageViewManagerMain.getInstance().stackPage(pageId: PageIdMain.StudyBookSelect.rawValue)
            
            case .History:
                _ = PageViewManagerMain.getInstance().stackPage(pageId: PageIdMain.History.rawValue)
            
            case .Settings:
                _ = PageViewManagerMain.getInstance().stackPage(pageId: PageIdMain.Settings.rawValue)
            
            case .Help:
                let viewController = HelpViewController(
                    nibName: "HelpViewController",
                    bundle: nil)
                
                mTopScene.parentVC!.navigationController?.pushViewController(viewController, animated: true)
                break
            case .Debug:
                _ = PageViewManagerMain.getInstance().stackPage(pageId: PageIdMain.Debug.rawValue)
            
            }
        } else {
            // ズームボタン
            switch (id) {
                case ButtonIdZoomOut:
                    UDpi.scaleDown()
                    initDrawables()
                    showScaleToast()
                    
                    break
                case ButtonIdZoomIn:
                    UDpi.scaleUp()
                    initDrawables()
                    showScaleToast()
                    break
            default:
                break
            }
        }
        return false;
    }

    /**
     * スケール変更時のToastを表示する
     */
    private func showScaleToast() {
         if let toast = mToast {
             toast.cancel()
         }
        mToast = UToast.makeText( text: UDpi.getScaleText(), duration: 2.0)
        mToast!.show()
    }
    
    private func testPageView() {
        let manager = PageViewManagerMain.getInstance()
        
        var page1 : UPageView? = PageViewDebug(topScene: mTopScene, title: "page1")
        manager.stackPage(pageView: page1!)
        page1 = nil
        
        var page2 : UPageView? = PageViewDebug(topScene: mTopScene, title: "page2")
        manager.stackPage(pageView: page2!)
        page2 = nil
        
        _ = manager.popPage()
        
        var page3 : UPageView? = PageViewDebug(topScene: mTopScene, title: "page3")
        manager.stackPage(pageView: page3!)
        page3 = nil
        
        manager.popPage()
        manager.popPage()
    }
}


//
//  PageViewTitle.swift
//  TangoBook
//    タイトルページ。ここから各種ページに遷移する
//  Created by Shusuke Unno on 2017/07/24.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import UIKit

public class PageViewTitle : UPageView, UButtonCallbacks {
    /**
     Enums
     */
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
        ButtonTInfo(textName: "title_edit",
                    textColor: UColor.DarkGreen,
                    lineColor: UColor.DarkGreen,
                    bgColor: UColor.makeColor(100, 200, 100),
                    imageName: ImageName.edit ),
        ButtonTInfo(textName: "title_study",
                    textColor: UIColor.white,
                    lineColor: UIColor.white,
                    bgColor: UColor.makeColor(200,100,100),
                    imageName: ImageName.study ),
        ButtonTInfo(textName: "title_history",
                    textColor: UColor.DarkYellow,
                    lineColor: UColor.DarkYellow,
                    bgColor: UColor.Yellow,
                    imageName: ImageName.history ),
        ButtonTInfo(textName: "title_settings",
                    textColor: UColor.DarkBlue,
                    lineColor: UColor.DarkBlue,
                    bgColor: UColor.makeColor(153,204,255),
                    imageName: ImageName.settings_1 ),
        ButtonTInfo(textName: "title_help",
                    textColor: UIColor.white,
                    lineColor: UColor.DarkOrange,
                    bgColor: UColor.makeColor(255,178,102),
                    imageName: ImageName.study ),
        ButtonTInfo(textName: "title_debug",
                    textColor: UIColor.white,
                    lineColor: UColor.DarkGray,
                    bgColor: UColor.makeColor(200,100,100),
                    imageName: ImageName.debug )
        ]

    /**
     * Constants
     */
    public static let TAG = "PageViewTitle"
    private static let DRAW_PRIORITY = 100

    private static let BUTTON_H = 65
    private static let ZOOM_BUTTON_W = 40
    internal static let MARGIN_H2 = 18
    internal static let MARGIN_V2 = 10

    private static let TEXT_SIZE = 17
    private static let IMAGE_W = 35

    // button Ids
    private static let ButtonIdZoomIn = 100
    private static let ButtonIdZoomOut = 101

     /**
     * Member variables
     */
//     private Toast mToast
    
     // Title
    private var mTitleText : UTextView? = nil

    // Buttons
    private var mButtons : [UButtonText] = []

     /**
     * Constructor
     */
    public override init(parentView : TopView, title : String) {
        super.init(parentView: parentView, title: title)
        
    }

     /**
     * Methods
     */

     override public func onShow() {

     }

     override public func onHide() {
         super.onHide()
     }

     /**
     * そのページで表示される描画オブジェクトを初期化する
     */
     public override func initDrawables() {
        let width = self.mTopView.getWidth()

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
        var button = UButtonImage.createButton( callbacks: self,
                                  id: PageViewTitle.ButtonIdZoomIn,
                                  priority: PageViewTitle.DRAW_PRIORITY,
                                  x: width - zoomButtonW * 2 - UDpi.toPixel(20),
                                  y: UDpi.toPixel(10),
                                  width: zoomButtonW, height: zoomButtonW,
                                  image: buttonImage, pressedImage: nil)
        button.addToDrawManager()
        
        // -ボタン
        buttonImage = UResourceManager.getImageWithColor(imageName: ImageName.zoom_out, color: UIColor.orange)
        button = UButtonImage.createButton(callbacks: self,
                              id: PageViewTitle.ButtonIdZoomOut,
                              priority: PageViewTitle.DRAW_PRIORITY,
                              x:width - zoomButtonW - UDpi.toPixel(10),
                              y: UDpi.toPixel(10),
                              width: zoomButtonW, height: zoomButtonW,
                              image: buttonImage,
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
                id: i,
                priority: PageViewTitle.DRAW_PRIORITY,
                text: info.getTitle(),
                x: x, y: y,
                width: buttonW, height: buttonW,
                textSize: Int(UDpi.toPixel(PageViewTitle.TEXT_SIZE)),
                textColor: info.textColor, color: info.bgColor)
            
            mButtons.append(button)
                
            let image = UResourceManager.getImageWithColor(imageName: info.imageName, color: info.lineColor)
            
            button.setImage(image: image,
                                 imageSize: CGSize(width: UDpi.toPixel(PageViewTitle.IMAGE_W), height: UDpi.toPixel(PageViewTitle.IMAGE_W)))
            _ = UDrawManager.getInstance().addDrawable(button)

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
                                     id: i,
                                     priority: PageViewTitle.DRAW_PRIORITY,
                                     text: info.getTitle(),
                                     x: x, y: y,
                                     width: buttonW, height: buttonH,
                                     textSize: Int(UDpi.toPixel(PageViewTitle.TEXT_SIZE)),
                                     textColor: info.textColor,
                                     color: info.bgColor)
            mButtons.append(button)
            
            let image = UResourceManager.getImageWithColor(
                imageName: info.imageName, color: info.lineColor)
            
            button.setImage(
                image: image,
                imageSize: CGSize(width: UDpi.toPixel(PageViewTitle.IMAGE_W),
                        height: UDpi.toPixel(PageViewTitle.IMAGE_W)))
            _ = UDrawManager.getInstance().addDrawable(button);

            // 表示座標を少し調整
            button.setImageAlignment(UAlignment.Center);
            button.setImageOffset(x: UDpi.toPixel(-PageViewTitle.IMAGE_W - 20 - PageViewTitle.MARGIN_H2 / 2), y: 0)
            button.setTextOffset(x: UDpi.toPixel(PageViewTitle.MARGIN_H2) / 2, y: 0)

            y += buttonH + UDpi.toPixel(PageViewTitle.MARGIN_V2)
        }
     }

     /**
     * ソフトウェアキーの戻るボタンを押したときの処理
     * @return
     */
     override public func onBackKeyDown() -> Bool {
         return false
     }

     /**
     * Callbacks
     */

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
//                    MainActivity.getInstance().showHelpTopPage()
                    break
                case .Debug:
                    _ = PageViewManagerMain.getInstance().stackPage(pageId: PageIdMain.Debug.rawValue)
                
            }
        } else {
            // ズームボタン
            switch (id) {
                case PageViewTitle.ButtonIdZoomOut:
                    UDpi.scaleDown()
                    initDrawables()
                    mTopView.invalidate()
                    showScaleToast()
                    break
                case PageViewTitle.ButtonIdZoomIn:
                    UDpi.scaleUp()
                    initDrawables()
                    mTopView.invalidate()
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
//         if (mToast != null) {
//             mToast.cancel();
//         }
//         mToast = Toast.makeText(mContext, UDpi.getScaleText(), Toast.LENGTH_LONG);
//         mToast.show();
     }
 }


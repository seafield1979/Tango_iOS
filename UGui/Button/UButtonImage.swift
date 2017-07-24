//
//  UButtonImage.swift
//  UGui
//
//  Created by Shusuke Unno on 2017/07/08.
//  Copyright © 2017年 Shusuke Unno. All rights reserved.
//

import Foundation
import UIKit

/**
 * 画像を表示するボタン
 * 画像の下にテキストを表示することも可能
 */

public class UButtonImage : UButton {
    /**
     * Consts
     */
    public static let TEXT_MARGIN : Int = 4
    
    private static let TEXT_SIZE : Int = 10
    
    /**
     * Member Variables
     */
    var images : List<UIImage> = List()    // 画像
    var pressedImage : UIImage? = nil      // タッチ時の画像
    var disabledImage : UIImage? = nil     // disable時の画像
    var title : String? = nil             // 画像の下に表示するテキスト
    var titleSize : Int = 0
    var titleColor : UIColor = UIColor()
    var stateId : Int = 0          // 現在の状態
    var stateMax : Int = 0         // 状態の最大値 addState で増える
    
    private var mTextTitle : UTextView? = nil
    
    /**
     * Get/Set
     */
    public func setEnabled(enabled : Bool) {
        self.enabled = enabled
        if (!enabled) {
            if (disabledImage == nil && images.count > 0) {
                disabledImage = UUtil.convToGrayImage(image: images[0])
            }
        }
    }
    
    public func setImage(_ image : UIImage?) {
        if (image != nil) {
            self.images.append(image!)
        }
    }
    public func setPressedImage(_ image : UIImage?) {
        if (image != nil) {
            pressedImage = image
        }
    }
    
    /**
     * Constructor
     */
    public init(callbacks : UButtonCallbacks?,
                             id : Int , priority : Int,
                             x : CGFloat, y : CGFloat,
                             width : CGFloat, height : CGFloat,
                             imageName : ImageName?, pressedImageName : ImageName? )
    {
        super.init(callbacks: callbacks, type: UButtonType.BGColor,
                   id: id, priority: priority,
                   x: x, y: y, width: width, height: height,
                   color: UColor.Blue)
        
        if imageName != nil {
            images.append(UResourceManager.getImageByName(imageName!)!)
        }
        
        if pressedImage != nil {
            self.pressedImage = UResourceManager.getImageByName(pressedImageName!)
        } else {
            pressedColor = UColor.LightPink;
        }
        stateId = 0;
        stateMax = 1;
    }
    
    // 画像ボタン
    public static func createButton(callbacks : UButtonCallbacks?,
                                    id : Int, priority : Int,
                                    x : CGFloat, y : CGFloat,
                                    width : CGFloat, height : CGFloat,
                                    imageName : ImageName?,
                                    pressedImageName : ImageName?) -> UButtonImage
    {
        let button = UButtonImage(callbacks: callbacks, id: id, priority: priority,
                                  x: x, y: y, width: width, height: height,
                                  imageName: imageName,
                                  pressedImageName: pressedImageName)
        return button
    }
    
    // 画像ボタン
    public static func createButton(callbacks : UButtonCallbacks?,
                                    id : Int, priority : Int,
                                    x : CGFloat, y : CGFloat,
                                    width : CGFloat, height : CGFloat,
                                    image : UIImage?, pressedImage : UIImage?) -> UButtonImage
    {
        let button = UButtonImage(callbacks: callbacks,
                                  id: id, priority: priority,
                                  x:x, y:y,
                                  width: width, height: height,
                                  imageName: nil, pressedImageName: nil)
        button.setImage(image)
        button.setPressedImage(pressedImage)
        return button
    }
    
    /**
     * Methods
     */
    /**
     * ボタンの下に表示するタイトルを設定する
     * @param title
     * @param titleSize
     * @param titleColor
     */
    public func setTitle(title: String, titleSize : Int, titleColor : UIColor) {
        self.title = title
        self.titleSize = titleSize
        self.titleColor = titleColor
    }
    
    /**
     * 状態を追加する
     * @param imageId 追加した状態の場合に表示する画像
     */
    public func addState(imageName : ImageName) {
        images.append(UResourceManager.getImageByName(imageName)!)
        stateMax += 1
    }
    public func addState(image : UIImage) {
        images.append(image)
        stateMax += 1
    }
    
    /**
     * テキストを追加する
     */
    public func addTitle(title : String, alignment: UAlignment,
                         x : CGFloat, y : CGFloat,
                         color : UIColor, bgColor : UIColor?)
    {
        mTextTitle = UTextView.createInstance(text: title,
                                              textSize:Int(UDpi.toPixel(UButtonImage.TEXT_SIZE)),
                                              priority: 0, alignment: alignment,
                                              multiLine:false, isDrawBG: true,
                                              x:x, y:y,
                                              width:0,
                                              color: color, bgColor: bgColor)
        mTextTitle?.setMargin(10, 10)
    }
    
    /**
     * 次の状態にすすむ
     */
    public func setNextState() -> Int {
        if (stateMax >= 2) {
            stateId = (stateId + 1) % stateMax
        }
        return stateId
    }
    
    public func setState(state : Int) {
        if (stateMax > state) {
            stateId = state;
        }
    }
    
    private func getNextStateId() -> Int {
        if (stateMax >= 2) {
            return (stateId + 1) % stateMax
        }
        return 0
    }
    
    /**
     * UDrawable
     */
    /**
     * 描画処理
     * @param canvas
     * @param paint
     * @param offset 独自の座標系を持つオブジェクトをスクリーン座標系に変換するためのオフセット値
     */
    public override func draw(_ offset : CGPoint?) {
        var _image : UIImage? = nil
        
        var _pos = CGPoint(x: pos.x, y: pos.y)
        if (offset != nil) {
            _pos.x += offset!.x
            _pos.y += offset!.y
        }
        
        if !enabled {
            _image = disabledImage
        } else {
            _image = images[stateId]
        }
        let _rect = CGRect(x:_pos.x, y:_pos.y,
                           width: size.width,
                           height: size.height)
        if (isPressed) {
            if pressedImage != nil {
                _image = pressedImage
            } else {
                // BGの矩形を配置
                UDraw.drawRoundRectFill( rect: CGRect(x:_rect.x - 10,
                                                y: _rect.y - 10,
                                                width: _rect.width + 10,
                                                height: _rect.height + 10),
                                         cornerR: 10.0, color: pressedColor,
                                         strokeWidth: 0, strokeColor: nil)
            }
        }
        
        // 領域の幅に合わせて伸縮
        UDraw.drawImage(image: _image!, rect: _rect)
        
        if UDebug.drawRectLine {
            self.drawRectLine(offset: offset, color: UIColor.yellow)
        }
        
        // 下にテキストを表示
        if title != nil {
            UDraw.drawText(text: title!, alignment: UAlignment.CenterX,
                           textSize: titleSize,
                           x:_rect.centerX(),
                           y:_rect.bottom + UDpi.toPixel(UButtonImage.TEXT_MARGIN),
                           color: titleColor)
        }
    }
}

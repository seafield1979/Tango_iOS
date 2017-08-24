//
//  UImageView.swift
//  UGui
//      画像を表示するオブジェクト
//      状態別に複数の画像を表示させることができる
//  Created by Shusuke Unno on 2017/07/08.
//  Copyright © 2017年 Shusuke Unno. All rights reserved.
//

import UIKit

/**
 * Created by shutaro on 2016/12/13.
 *
 */

public class UImageView : UDrawable {
    /**
     * Consts
     */
    public let TAG = "UImageView"
    private let TEXT_MARGIN = 10
    
    /**
     * Member variables
     */
    
    var images : List<UIImage> = List()    // 画像
    var mTitle : String? = nil             // 画像の下に表示するテキスト
    var mTitleSize : CGFloat = 0
    var mTitleColor : UIColor? = nil
    var mStateId : Int = 0          // 現在の状態
    var mStateMax : Int = 0         // 状態の最大値 addState で増える
    
    
    /**
     * Get/Set
     */
    public func setTitle( text : String?, size : CGFloat, color : UIColor?) {
        mTitle = text
        mTitleSize = size
        mTitleColor = color
    }
    
    /**
     * Constructor
     */
    public init(priority : Int, imageName : ImageName, x : CGFloat, y : CGFloat, width : CGFloat, height : CGFloat,
                color : UIColor?)
    {
        super.init( priority: priority, x: x, y: y, width: width, height: height)
        
        let image = UResourceManager.getImageWithColor(
            imageName: imageName, color: color)
        
        self.images.append(image!)
        mStateId = 0
        mStateMax = 1
    }
    
    
    /**
     * 描画処理
     * @param canvas
     * @param paint
     * @param offset 独自の座標系を持つオブジェクトをスクリーン座標系に変換するためのオフセット値
     */
    public override func draw() {
        var _image : UIImage
        
        let _pos = CGPoint(x: pos.x, y: pos.y)
//        if offset != nil {
//            _pos.x += offset!.x
//            _pos.y += offset!.y
//        }
        
        _image = images[mStateId]
        let _rect = CGRect(x: _pos.x, y: _pos.y,
                           width: size.width, height: size.height)
        
        // 領域の幅に合わせて伸縮
        UDraw.drawImage(image: _image, rect: _rect)
        
        // 下にテキストを表示
        if mTitle != nil && mTitleColor != nil {
            UDraw.drawText( text : mTitle!, alignment : UAlignment.CenterX,
                            fontSize : mTitleSize,
                            x : _rect.centerX(), y : _rect.bottom + UDpi.toPixel(TEXT_MARGIN), color : mTitleColor!)
        }
    }
    
    /**
     * 状態を追加する
     * @param imageId 追加した状態の場合に表示する画像
     */
    public func addState( imageName : ImageName ) {
        images.append( UResourceManager.getImageByName(imageName)!)
        
        mStateMax += 1
    }
    
    /**
     * 次の状態にすすむ
     */
    public func setNextState() -> Int {
        if mStateMax >= 2 {
            mStateId = (mStateId + 1) % mStateMax
        }
        return mStateId
    }
    
    public func setState( state : Int) {
        if mStateMax > state {
            mStateId = state
        }
    }
    
    private func getNextStateId() -> Int{
        if mStateMax >= 2 {
            return (mStateId + 1) % mStateMax
        }
        return 0
    }
    
}

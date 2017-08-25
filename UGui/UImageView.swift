//
//  UImageView.swift
//  UGui
//      画像を表示するオブジェクト
//      状態別に複数の画像を表示させることができる
//  Created by Shusuke Unno on 2017/07/08.
//  Copyright © 2017年 Shusuke Unno. All rights reserved.
//

import SpriteKit

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
    // SpriteKit Node
    var imageNode : SKSpriteNode?
    var titleNode : SKLabelNode?
    
    var images : List<UIImage> = List()    // 画像
    var mTitle : String? = nil             // 画像の下に表示するテキスト
    var mFontSize : CGFloat = 0
    var mTitleColor : UIColor? = nil
    var mStateId : Int = 0          // 現在の状態
    var mStateMax : Int = 0         // 状態の最大値 addState で増える
    
    
    /**
     * Get/Set
     */
    public func setTitle( text : String?, size : CGFloat, color : UIColor?) {
        mTitle = text
        mFontSize = size
        mTitleColor = color
    }
    
    /**
     * Constructor
     */
    public init(priority : Int, imageName : ImageName, initNode: Bool,
                x : CGFloat, y : CGFloat, width : CGFloat, height : CGFloat,
                color : UIColor?)
    {
        super.init( priority: priority, x: x, y: y, width: width, height: height)
        
        parentNode.position = CGPoint(x: x, y: y)
        let image = UResourceManager.getImageWithColor(
            imageName: imageName, color: color)
        
        self.images.append(image!)
        mStateId = 0
        mStateMax = 1
        
        if initNode {
            initSKNode()
        }
    }
    
    /**
     * SpriteKitのノード生成
     */
    public override func initSKNode() {
        if images.count > 0 {
            let texture = SKTexture(image: images[0])
            imageNode = SKSpriteNode(texture: texture)
            imageNode!.size = size
            imageNode?.anchorPoint = CGPoint(x:0, y:1)
            parentNode.addChild2( imageNode! )

            if let title = mTitle {
                titleNode = SKNodeUtil.createLabelNode(
                    text: title, fontSize: mFontSize,
                    color: mTitleColor!, alignment: .CenterX,
                    pos: CGPoint(x: imageNode!.frame.size.width / 2, y: imageNode!.frame.size.height + UDpi.toPixel(0)))
            }
            parentNode.addChild2( titleNode! )
        }
    }
    
    /**
     * 描画処理
     * @param canvas
     * @param paint
     * @param offset 独自の座標系を持つオブジェクトをスクリーン座標系に変換するためのオフセット値
     */
    public override func draw() {
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
            
            imageNode!.texture = SKTexture(image: images[mStateId])
        }
        return mStateId
    }
    
    public func setState( state : Int) {
        if mStateMax > state {
            mStateId = state
            
            imageNode!.texture = SKTexture(image: images[mStateId])
        }
    }
    
    private func getNextStateId() -> Int{
        if mStateMax >= 2 {
            return (mStateId + 1) % mStateMax
        }
        return 0
    }
    
}

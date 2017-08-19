//
//  SKNodeUtil.swift
//  SK_UGui
//    SpriteKitのノード関連の便利機能クラス
//  Created by Shusuke Unno on 2017/08/11.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import SpriteKit

public class SKNodeUtil {
    
    
    /**
     線のShapeNodeを作成する
     */
    public static func createLineNode( p1 : CGPoint, p2 : CGPoint, color : SKColor, lineWidth : CGFloat) -> SKShapeNode
    {
        let scene = TopScene.getInstance()
        var points = [ scene.convertPoint(fromView: p1),
                       scene.convertPoint(fromView: p2) ]
        let node = SKShapeNode(points: &points, count: points.count)
        node.strokeColor = color
        node.lineWidth = lineWidth
        
        return node
    }
    
    /**
     三角形のShapeNodeを作成する
     */
    public static func createTriangleNode(length : CGFloat, angle: CGFloat, color : SKColor) -> SKShapeNode {
        // 始点から終点までの４点を指定
        let rad = CGFloat.pi / 180
        var points = [CGPoint(x:cos((-30 + angle) * rad) * length,
                              y: sin((-30 + angle) * rad) * length),
                      CGPoint(x:cos((90 + angle) * rad) * length,
                              y: sin((90 + angle) * rad) * length),
                      CGPoint(x: cos((210 + angle) * rad) * length,
                              y: sin((210 + angle) * rad) * length),
                      CGPoint(x: cos((-30 + angle) * rad) * length,
                              y: sin((-30 + angle) * rad) * length)]
        let node = SKShapeNode(points: &points, count: points.count)
        node.fillColor = color
        node.strokeColor = .clear
        return node
    }
    
    /**
     * 四角形のノードを作成する
     * 引数の座標系はUIKitなので、内部でSpriteKit座標系に変換する
     */
    public static func createRectNode(rect : CGRect, color : SKColor, pos : CGPoint, cornerR : CGFloat) -> SKShapeNode
    {
        let n = SKShapeNode(rect : rect.convToSK(), cornerRadius: cornerR)
        n.fillColor = color
        n.strokeColor = .clear
        n.position = pos
        
        return n
    }
    
    /**
     ＋のSKNodeを作成する
     */
    public static func createCrossPoint( pos : CGPoint, length : CGFloat, lineWidth : CGFloat, color : SKColor) -> SKNode
    {
        let scene = TopScene.getInstance()
        
        // ２本の線の親
        let parentNode = SKNode()
        parentNode.position = scene.convertPoint(fromView: pos)
        parentNode.zPosition = 1000.0
        
        // line1
        var points = [ CGPoint(x: -length / 2, y:0),
                       CGPoint(x: length / 2, y:0) ]
        
        let line1 = SKShapeNode(points: &points, count: points.count)
        line1.strokeColor = color
        line1.lineWidth = lineWidth
        parentNode.addChild(line1)

        // line2 
        points = [ CGPoint(x: 0, y: -length / 2),
                    CGPoint(x: 0, y: length / 2) ]
        
        let line2 = SKShapeNode(points: &points, count: points.count)
        line2.strokeColor = color
        line2.lineWidth = lineWidth
        parentNode.addChild(line2)
        
        return parentNode
    }
    
    
    // MARK : Label系
    
    public static func createLabelNode( text : String, textSize: CGFloat, color : SKColor, alignment : UAlignment, offset: CGPoint?) -> SKLabelNode
    {
        let n = SKLabelNode(text: text)
        n.fontColor = color
        n.fontSize = textSize
        n.fontName = "HiraKakuProN-W6"
        if offset != nil {
            n.position = offset!.convToSK()
        }
        
        switch alignment {
        case .None:
            n.horizontalAlignmentMode = .left
            n.verticalAlignmentMode = .top
        case .CenterX:
            n.horizontalAlignmentMode = .center
            n.verticalAlignmentMode = .top
        case .CenterY:
            n.horizontalAlignmentMode = .left
            n.verticalAlignmentMode = .center
        case .Center:
            n.horizontalAlignmentMode = .center
            n.verticalAlignmentMode = .center
        case .Left:
            n.horizontalAlignmentMode = .left
            n.verticalAlignmentMode = .top
        case .Right:
            n.horizontalAlignmentMode = .right
            n.verticalAlignmentMode = .top
        case .Right_CenterY:
            n.horizontalAlignmentMode = .right
            n.verticalAlignmentMode = .center
        }
        
        return n
    }
}

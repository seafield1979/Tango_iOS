//
//  SKNodeUtil.swift
//  SK_UGui
//    SpriteKitのノード関連の便利機能クラス
//  Created by Shusuke Unno on 2017/08/11.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import SpriteKit

public class SKNodeUtil {
    
    static private let fontName = "HiraKakuProN-W3"
    
    // CrossShapeの種類
    public enum CrossType {
        case Type1      // ＋
        case Type2      // ×
    }
    
    // MARK Constants
    private static let FONT_MARGIN_V = 6        // 複数行のラベルの各行のマージン
    
    // MARK: Methods
    /**
     線のShapeNodeを作成する
     */
    public static func createLineNode( p1 : CGPoint, p2 : CGPoint, color : SKColor, lineWidth : CGFloat) -> SKShapeNode
    {
        var points = [ p1.convToSK(),
                       p2.convToSK() ]
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
     * 円形のノードを作成する
     */
    public static func createCircleNode( pos : CGPoint, radius : CGFloat, lineWidth : CGFloat, color : UIColor) -> SKShapeNode
    {
        let n = SKShapeNode(circleOfRadius: radius)
        n.position = pos
        n.strokeColor = color
        n.lineWidth = lineWidth
        
        return n
    }
    
    /**
     * ２つの線の交差(＋、×）のSKNodeを作成する
     */
    public static func createCrossPoint( type: CrossType, pos : CGPoint, length : CGFloat, lineWidth : CGFloat, color : SKColor, zPos : CGFloat) -> SKShapeNode
    {
        var points1 : [CGPoint]
        var points2 : [CGPoint]
        if type == .Type1 {
            // line1
            points1 = [ CGPoint(x: -length / 2, y:0),
                           CGPoint(x: length / 2, y:0) ]
            // line2
            points2 = [ CGPoint(x: 0, y: -length / 2),
                       CGPoint(x: 0, y: length / 2) ]
        } else {
            let rad = CGFloat.pi / 180
            
            // line1
            points1 = [ CGPoint(x: cos(135 * rad) * length, y: sin(135 * rad) * length),
                        CGPoint(x: cos(-45 * rad) * length, y: sin(-45 * rad) * length) ]
            // line2
            points2 = [ CGPoint(x: cos(45 * rad) * length, y: sin(45 * rad) * length),
                        CGPoint(x: cos(225 * rad) * length, y: sin(225 * rad) * length) ]
        }
        
        let line1 = SKShapeNode(points: &points1, count: points1.count)
        line1.strokeColor = color
        line1.lineWidth = lineWidth
        line1.zPosition = zPos
        line1.position = pos
        
        let line2 = SKShapeNode(points: &points2, count: points2.count)
        line2.strokeColor = color
        line2.lineWidth = lineWidth
        line1.addChild(line2)
        
        return line1
    }
    
    
    // MARK : Label系
    public static func createLabelNode( text : String, fontSize: CGFloat, color :SKColor, alignment : UAlignment, pos: CGPoint?) -> (node: SKLabelNode, size: CGSize)
    {
        if text.contains("\n") {
            // 複数行
            return SKNodeUtil.createMultiLineLabelNode(text: text, fontSize: fontSize, color: color, alignment: alignment, pos: pos)
        } else {
            // 一行
            return SKNodeUtil.createOneLineLabelNode(text: text, fontSize: fontSize, color: color, alignment: alignment, pos: pos)
        }
    }
    
    /**
     * 改行なしのラベルを作成
     */
    public static func createOneLineLabelNode( text : String, fontSize: CGFloat, color : SKColor, alignment : UAlignment, pos: CGPoint?) -> (node: SKLabelNode, size: CGSize)
    {
        let n = SKLabelNode(text: text)
        n.fontColor = color
        n.fontSize = fontSize
        n.fontName = SKNodeUtil.fontName
        if pos != nil {
            n.position = pos!
        }
        
        n.setAlignment( alignment )
        
        return (n, n.frame.size)
    }
    
    /**
     改行ありのラベルを作成
     */
    static func createMultiLineLabelNode(text: String, fontSize: CGFloat, color : SKColor, alignment : UAlignment, pos: CGPoint?) -> (node: SKLabelNode, size: CGSize)
    {
        let subStrings:[String] = text.components(separatedBy:"\n")
        let margin = UDpi.toPixel(FONT_MARGIN_V)
        var labelOutPut = SKLabelNode()
        var subStringNumber:Int = 0
        var maxWidth : CGFloat = 0
        
        for subString in subStrings {
            let labelTemp = SKLabelNode(fontNamed: SKNodeUtil.fontName)
            labelTemp.text = subString
            labelTemp.setAlignment(alignment)
            labelTemp.fontColor = color
            labelTemp.fontSize = fontSize
            if labelTemp.frame.size.width > maxWidth {
                maxWidth = labelTemp.frame.size.width
            }
            
            let y : CGFloat = CGFloat(subStringNumber) * (fontSize + margin)
            
            if subStringNumber == 0 {
                if pos != nil {
                    labelTemp.position = pos!
                }
                labelOutPut = labelTemp
            } else {
                labelTemp.position = CGPoint(x: 0, y: -y)
                labelOutPut.addChild(labelTemp)
            }
            
            subStringNumber += 1
        }
        
        // アライメントによる座標補正
        if alignment == .CenterY || alignment == .Center || alignment == .Right_CenterY {
            let centerY = (CGFloat(subStringNumber) * fontSize) / 2
            labelOutPut.position.y -= (centerY - fontSize / 2)
        } else if alignment == .Bottom || alignment == .CenterX_Bottom || alignment == .Right_Bottom
        {
            let centerY = (CGFloat(subStringNumber) * fontSize) / 2
            labelOutPut.position.y -= (centerY - fontSize)
        }
        
        return (labelOutPut, CGSize(width: maxWidth,
                                    height: CGFloat(subStringNumber) * fontSize + CGFloat(subStringNumber - 1) * margin))
    }
    
    
    /**
     * 画像ノード(SKSpriteNode)を作成
     */
    public static func createSpriteNode(imageNamed imageName: ImageName, width: CGFloat, height: CGFloat) -> SKSpriteNode
    {
        let n = SKSpriteNode(imageNamed: imageName.rawValue)
        n.size = CGSize(width: width, height: height)
        n.anchorPoint = CGPoint(x:0, y:1)
        return n
    }
    
    /**
     * 画像ノード(SKSpriteNode)を作成  UIImage版
     */
    public static func createSpriteNode(image: UIImage, width: CGFloat, height: CGFloat, x: CGFloat, y: CGFloat ) -> SKSpriteNode
    {
        let texture = SKTexture(image: image)
        let n = SKSpriteNode(texture: texture)
        n.size = CGSize(width: width, height: height)
        n.position = CGPoint(x: x, y: y)
        n.anchorPoint = CGPoint(x:0, y:1)
        return n
    }

}

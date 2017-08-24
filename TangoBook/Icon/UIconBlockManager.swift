//
//  UIcon.swift
//  TangoBook
//
//  Created by Shusuke Unno on 2017/07/25.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import UIKit


 /**
  * アイコンを内包するRectを管理するクラス
  * 配下のアイコンが全て収まる大きなRectを求めておき、
  * まずはこの大きなRectと判定を行い、重なっていた場合にのみ個々のアイコンと判定する
  */
public class UIconsBlockManager {
    public static let TAG = "UIconsBlockManager"
    var blockList : List<IconsBlock> = List()
    var icons : List<UIcon>? = nil

     /**
      * インスタンスを取得
      * @param icons
      * @return
      */
    public static func createInstance( icons : List<UIcon>) -> UIconsBlockManager {
        let instance = UIconsBlockManager()
        instance.icons = icons
        return instance
    }

     /**
      * アイコンリストを設定する
      * アイコンリストはアニメーションが終わって座標が確定した時点で行う
      */
    public func setIcons( icons : List<UIcon>) {
         self.icons = icons
         update()
     }

     /**
      * IconsBlockのリストを作成する
      */
     public func update() {
        if icons == nil {
            return
        }
        blockList.removeAll()
        
        var block : IconsBlock? = nil
        for icon in icons! {
            if block == nil {
                block = IconsBlock()
            }

            if block!.add(icon: icon!) {
                // ブロックがいっぱいになったのでRectを更新してから次のブロックを作成する
                block!.updateRect()
                blockList.append(block!)
                // 次のアイコンがあるとも限らないのでここでからにしておく
                block = nil
            }
        }

        if block != nil {
            block!.updateRect()
            blockList.append(block!)
        }
    }

     /**
      * 指定座標に重なるアイコンを取得する
      * @param pos
      * @return
      */
    public func getOverlapedIcon(pos : CGPoint, exceptIcons : List<UIcon>) -> UIcon? {
         for block in blockList {
            let icon = block!.getOverlapedIcon(pos: pos, exceptIcons: exceptIcons)
            if icon != nil {
                 return icon
             }
         }
         return nil
     }

//     private void showLog() {
//         // debug
//         for (IconsBlock block : blockList) {
//             Rect _rect = block.getRect();
//             ULog.print(TAG, "count:" + block.getIcons().size() + " L:" + _rect.left + " R:" + _rect
//                     .right +
//                     " " +
//                     "U:" +
//                     _rect.top + " D:" + _rect.bottom);
//         }
//     }

//     /**
//      * IconsBlockの矩形を描画 for Debug
//      * @param canvas
//      * @param paint
//      */
//     public void draw(Canvas canvas, Paint paint, PointF toScreenPos) {
//         for (IconsBlock block : blockList) {
//             block.draw(canvas, paint, toScreenPos);
//         }
//     }
 }

 /**
  * １ブロックのクラス
  */
class IconsBlock {
    private let BLOCK_ICON_MAX = 8

    private var icons : List<UIcon> = List()
    private var rect = CGRect()
    private var color = UIColor.black

    // Get/Set
    public func getRect() -> CGRect {
        return rect
    }

    public func getIcons() -> List<UIcon> {
        return icons
    }

    /**
     * アイコンをブロックに追加する
     * @param icon
     * @return true:リストがいっぱい
     */
    public func add(icon : UIcon) -> Bool {
        icons.append(icon)
        if icons.count >= BLOCK_ICON_MAX {
            return true
        }
        return false
    }

    /**
     * ブロックの矩形を更新
     */
    public func updateRect() {
        rect.x = 1000000
        rect.y = 1000000
        
        for icon in icons {
            if icon!.getX() < rect.left {
                rect.x = icon!.getX()
            }
            if icon!.getRight() > rect.right {
                rect.width = icon!.getRight() - rect.x
            }
            if icon!.getY() < rect.top {
                rect.y = icon!.getY()
            }
            if icon!.getBottom() > rect.bottom {
                rect.height = icon!.getBottom() - rect.y
            }
        }
    }

    /**
     * ブロックとの重なり判定
     * ブロックと重なっていたら個々のアイコンとも判定を行う
     * @param pos
     * @param exceptIcons
     * @return nil:重なるアイコンなし
     */
    public func getOverlapedIcon(pos : CGPoint, exceptIcons : List<UIcon>) -> UIcon? {

        if rect.contains(x: pos.x, y: pos.y) {
            for icon in icons {
                if exceptIcons.contains(icon!) {
                    continue
                }

                ULog.count(UIconsBlockManager.TAG)
                if icon!.getRect().contains(x: pos.x, y: pos.y) {
                    return icon
                }
            }
        }
        return nil
    }

    /**
     * 矩形を描画(for Debug)
     * @param canvas
     * @param paint
     */
    public func draw( toScreenPos : CGPoint ) {
        
//        let _rect = CGRect(x: rect.left + toScreenPos.x,
//                          y: rect.top + toScreenPos.y,
//                          width: rect.width,
//                          height: rect.height)
//        UDraw.drawRect(rect: _rect, width: 2, color: color)
    }
}

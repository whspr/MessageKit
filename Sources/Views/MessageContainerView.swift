/*
 MIT License

 Copyright (c) 2017-2018 MessageKit

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

import UIKit

open class MessageContainerView: UIImageView {

    // MARK: - Properties

    private let imageMask = UIImageView()

    
    open var isBubble: Bool = false
    open var isForwarded: Bool = false
    open var ForwardIncome: Bool = false
    open var forwardedOffset: CGFloat = 0
    
    open var style: MessageStyle = .none {
        didSet {
            applyMessageStyle()
        }
    }

    open override var frame: CGRect {
        didSet {
            sizeMaskToView()
        }
    }
    
    open var isSelected: Bool = false

    // MARK: - Methods

    
    
    private func sizeMaskToView() {
        switch style {
        case .none, .custom:
            break
        case .bubble, .bubbleTail, .bubbleOutline, .bubbleTailOutline:
            imageMask.frame = bounds
        }
        switch style {
        case .bubble:
            self.isBubble = true
        default:
            self.isBubble = false
        }
        if self.isForwarded {
            if backgroundColor != .white {
                if self.isBubble {
                    superview?.layer.addShadowBubble(.left(CGRect(x: frame.minX + 8, y: frame.minY, width: frame.width - 8, height: frame.height)))
                } else {
                    superview?.layer.addShadowTail(.left(CGRect(x: frame.minX + 8, y: frame.minY, width: frame.width - 8, height: frame.height)))
                }
            } else {
                if self.isBubble {
                    superview?.layer.addShadowBubble(.right(CGRect(x: frame.minX, y: frame.minY, width: frame.width - 8, height: frame.height + 1)))
                } else {
                    superview?.layer.addShadowTail(.right(CGRect(x: frame.minX, y: frame.minY, width: frame.width - 8, height: frame.height + 1)))
                }
            }
        } else {
            if backgroundColor != .white {
                if self.isBubble {
                    superview?.layer.addShadowBubble(.left(CGRect(x: frame.minX + 8, y: frame.minY, width: frame.width - 8, height: frame.height)))
                } else {
                    superview?.layer.addShadowTail(.left(CGRect(x: frame.minX + 8, y: frame.minY, width: frame.width - 8, height: frame.height)))
                }
            } else {
                if self.isBubble {
                    superview?.layer.addShadowBubble(.right(CGRect(x: frame.minX, y: frame.minY, width: frame.width - 8, height: frame.height + 1)))
                } else {
                    superview?.layer.addShadowTail(.right(CGRect(x: frame.minX, y: frame.minY, width: frame.width - 8, height: frame.height + 1)))
                }
            }
        }
    }

    private func applyMessageStyle() {
        
        self.clipsToBounds = true
        switch style {
        case .bubble, .bubbleTail:
            imageMask.image = style.image
            sizeMaskToView()
            mask = imageMask
            image = nil
        case .bubbleOutline(let color):
            let bubbleStyle: MessageStyle = .bubble(.bottomRight)
            imageMask.image = bubbleStyle.image
            sizeMaskToView()
            mask = imageMask
            image = style.image?.withRenderingMode(.alwaysTemplate)
            tintColor = color
        case .bubbleTailOutline(let color, let tail, let corner):
            let bubbleStyle: MessageStyle = .bubbleTail(tail, corner)
            imageMask.image = bubbleStyle.image
            sizeMaskToView()
            mask = imageMask
            image = style.image?.withRenderingMode(.alwaysTemplate)
            tintColor = color
        case .none:
            mask = nil
            image = nil
            tintColor = nil
        case .custom(let configurationClosure):
            mask = nil
            image = nil
            tintColor = nil
            configurationClosure(self)
        }
    }
}


fileprivate extension CALayer {
    
    enum ShadowDirection {
        case left(CGRect)
        case right(CGRect)
    }
    //
    //    1 _______ 8
    //   2 /       \ 7
    //     |       |
    //   3 |       | 6
    //  4 /________/ 5
    //
    
    func addShadowTail(_ direction: ShadowDirection) {
        var path: CGMutablePath
        self.masksToBounds = true
        self.shadowOffset = .zero
        self.shadowOpacity = 0.2
        self.shadowRadius = 0.2
        self.shadowColor = UIColor.black.cgColor
        switch direction {
        case .left(let rect):
            path = CGMutablePath()
            let points: [CGPoint] = [
                CGPoint(x: rect.minX + 6, y: rect.minY),//1
                CGPoint(x: rect.minX, y: rect.minY + 6),//2
                CGPoint(x: rect.minX, y: rect.maxY - 8),//3
                CGPoint(x: rect.minX - 8, y: rect.maxY + 0.5),//4
                CGPoint(x: rect.maxX - 6, y: rect.maxY + 0.5),//5
                CGPoint(x: rect.maxX, y: rect.maxY - 6),//6
                CGPoint(x: rect.maxX, y: rect.minY + 6),//7
                CGPoint(x: rect.maxX - 6, y: rect.minY)//8
            ]
            path.addLines(between: points)
            path.closeSubpath()
        case .right(let rect):
            path = CGMutablePath()
            let points: [CGPoint] = [
                CGPoint(x: rect.minX + 6, y: rect.minY),//1
                CGPoint(x: rect.minX, y: rect.minY + 6),//2
                CGPoint(x: rect.minX, y: rect.maxY - 6), //3
                CGPoint(x: rect.minX + 6, y: rect.maxY - 0.5), //4
                CGPoint(x: rect.maxX + 9, y: rect.maxY - 0.5),//5
                CGPoint(x: rect.maxX, y: rect.maxY - 9),//6
                CGPoint(x: rect.maxX, y: rect.minY + 6),//7
                CGPoint(x: rect.maxX - 6, y: rect.minY)//8
            ]
            path.addLines(between: points)
            path.closeSubpath()
        }
        self.shadowPath = path
    }
    
    func addShadowBubble(_ direction: ShadowDirection) {
        var path: CGMutablePath
        self.masksToBounds = true
        self.shadowOffset = .zero
        self.shadowOpacity = 0.2
        self.shadowRadius = 0.2
        self.shadowColor = UIColor.black.cgColor
        switch direction {
        case .left(let rect):
            path = CGMutablePath()
            let points: [CGPoint] = [
                CGPoint(x: rect.minX + 6, y: rect.minY),//1
                CGPoint(x: rect.minX, y: rect.minY + 6),//2
                CGPoint(x: rect.minX, y: rect.maxY - 6),//3
                CGPoint(x: rect.minX + 6, y: rect.maxY + 0.5),//4
                CGPoint(x: rect.maxX - 6, y: rect.maxY + 0.5),//5
                CGPoint(x: rect.maxX, y: rect.maxY - 6),//6
                CGPoint(x: rect.maxX, y: rect.minY + 6),//7
                CGPoint(x: rect.maxX - 6, y: rect.minY)//8
            ]
            path.addLines(between: points)
            path.closeSubpath()
        case .right(let rect):
            path = CGMutablePath()
            let points: [CGPoint] = [
                CGPoint(x: rect.minX + 6, y: rect.minY),//1
                CGPoint(x: rect.minX, y: rect.minY + 6),//2
                CGPoint(x: rect.minX, y: rect.maxY - 6), //3
                CGPoint(x: rect.minX + 6, y: rect.maxY - 0.5), //4
                CGPoint(x: rect.maxX - 6, y: rect.maxY - 0.5),//5
                CGPoint(x: rect.maxX, y: rect.maxY - 6),//6
                CGPoint(x: rect.maxX, y: rect.minY + 6),//7
                CGPoint(x: rect.maxX - 6, y: rect.minY)//8
            ]
            path.addLines(between: points)
            path.closeSubpath()
        }
        self.shadowPath = path
    }
}

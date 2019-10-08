//
//  FallingCounterLabel.swift
//  TextPaths
//
//  Copyright © 2017 The Pirate Cat. All rights reserved.
//

import UIKit
import TextPaths

public class NumberPaths {
    
    public var font: UIFont
    
    public var alignment: NSTextAlignment
    
    public var textPath: TextPath
    
    public var unicodeMap: [UnicodeScalar:TextPathGlyph]
    
    public init?(WithFont font: UIFont, alignment: NSTextAlignment) {
        self.font = font
        self.alignment = alignment
        
        let par = NSMutableParagraphStyle()
        par.alignment = self.alignment
        
        let numbersString = NSMutableAttributedString(string: "0123456789", attributes: [
            NSAttributedString.Key.font: self.font
            ])
        
        let compositionSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        guard let textPath = numbersString.getTextPath(InBounds: compositionSize) else {
            return nil
        }

        var paths = [UnicodeScalar:TextPathGlyph]()
        let unicodes = numbersString.string.unicodeScalars
        textPath.frames[0].enumerateGlyphs({ _, glyph in
            let unicode = unicodes[glyph.index]
            paths[unicode] = glyph
        })
        
        self.textPath = textPath
        self.unicodeMap = paths
    }
}

public class FallingCounterLabel {
    private struct TextDropInfo {
        var charPath: TextPathGlyph
        var modified: Bool
        init(charPath: TextPathGlyph, modified: Bool) {
            self.charPath = charPath
            self.modified = modified
        }
    }
    
    public weak var label: UILabel? {
        didSet {
            if let label = label {
                label.layer.borderColor = UIColor.black.cgColor
                label.layer.borderWidth = 1                
            }
        }
    }
    
    public var numberPaths: NumberPaths?
    
    var layers = [CAShapeLayer]()
 
    var fieldLength = 2
    
    var duration = CGFloat(0.6)
    
    public var value = -1 {
        didSet {
            update(Animated: (oldValue != -1) && (oldValue != value))
        }
    }
    
    public init(WithLabel label: UILabel) {
        self.label = label
    }
    
    func update(Animated animated: Bool) {
        guard let numberPaths = numberPaths else {
            return
        }
        
        guard let label = label else {
            return
        }
        let attributes = [
            NSAttributedString.Key.font: numberPaths.font
        ]
        let formatString = String(format: "%%.0%dd", fieldLength)
        let numbersString = NSMutableAttributedString(string: String(format: formatString, value), attributes: attributes)
        
        if animated {
            let lastText = label.attributedText
            let transition = CATransition()
            transition.duration = 0.3
            transition.type = CATransitionType.fade
            label.layer.add(transition, forKey: "attributedText")
            label.attributedText = numbersString
        
            drop(FromText:lastText!, toText:numbersString)
        } else {
            label.attributedText = numbersString
        }
    }
    
    func drop(FromText fromText: NSAttributedString, toText: NSAttributedString) {
        for layer in layers {
            layer.removeFromSuperlayer();
        }

        guard let label = label, let numberPaths = numberPaths else {
            return
        }

        var paths = [TextDropInfo]()
        var pathBounds = CGRect.zero
        var fromItr = fromText.string.unicodeScalars.makeIterator()
        var toItr = toText.string.unicodeScalars.makeIterator()
        while let fromScalar = fromItr.next(), let toScalar = toItr.next() {
            guard let charPath = numberPaths.unicodeMap[fromScalar] else {
                return
            }
            
            pathBounds.size = CGSize(width: pathBounds.width + charPath.advance.width,
                                     height:  max(pathBounds.height, charPath.path.boundingBoxOfPath.height))
            let info = TextDropInfo(charPath: charPath, modified: true)
            paths.append(info)
        }
                
        var i = 0, j = 0
        
        var frameOffset = label.bounds.origin
        frameOffset.x += (label.bounds.width - pathBounds.width) * 0.5
        frameOffset.y += (label.bounds.height - pathBounds.height) * 0.5
        
        let delays = [1.0, 0.0, 1.5, 4.5, 0.0, 0,0, 0,0, 0,0]
        var delay = 0.4
        
        func d2r(_ value: CGFloat) -> CGFloat {
            return value / 180.0 * CGFloat(Float.pi)
        }
        
        var advance = CGFloat(0.0)
        var index = 0
        for info in paths {
            let charPath = info.charPath
            let path = CAShapeLayer()
            let bounds = charPath.path.boundingBox
            
            func CT(_ transforms: CATransform3D...) -> CATransform3D {
                var T = CATransform3DMakeTranslation(bounds.width*0.5, bounds.height*0.5, 0.0)
                for transform in transforms {
                    T = CATransform3DConcat(transform, T)
                }
                T = CATransform3DTranslate(T, -bounds.width*0.5, -bounds.height*0.5, 0.0)
                return T
            }
            
            if info.modified {
                path.path = charPath.path
                path.anchorPoint = CGPoint(x: 0.0, y: 0.0)
                path.position = CGPoint(x: frameOffset.x + advance, y: frameOffset.y)
                path.bounds = CGRect(origin: .zero, size: bounds.size)
                path.fillColor = label.textColor.cgColor
                path.transform = CATransform3DIdentity
                path.opacity = 1.0
                label.layer.addSublayer(path)
                
                let scaleAnim = CABasicAnimation(keyPath: "transform")
                scaleAnim.fromValue = CATransform3DIdentity
                scaleAnim.toValue = CT(CATransform3DMakeScale(2.0, 2.0, 1.0))
                
                var alfa = 20.0 + (5.0 - CGFloat(arc4random_uniform(100))/10.0)
                if arc4random_uniform(100)<50 {
                    alfa *= -1.0
                }
                
                let shakeAnim = CAKeyframeAnimation(keyPath: "transform")
                shakeAnim.values = [
                    CT(CATransform3DMakeRotation(d2r(0), 0, 0, 1), CATransform3DMakeScale(1.0, 1.0, 1)),
                    CT(CATransform3DMakeRotation(d2r(0), 0, 0, 1), CATransform3DMakeScale(1.05, 1.05, 1)),
                    CT(CATransform3DMakeRotation(d2r(-alfa), 0, 0, 1), CATransform3DMakeScale(0.8, 0.8, 1)),
                    CT(CATransform3DMakeRotation(d2r(+alfa), 0, 0, 1), CATransform3DMakeScale(0.6, 0.6, 1)),
                    CT(CATransform3DMakeRotation(d2r(0), 0, 0, 1), CATransform3DMakeScale(0.4, 0.4, 1))
                ]
                shakeAnim.keyTimes = [0.0, 0.05, 0.25, 0.5, 0.75]
                shakeAnim.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
                
                let flyAnim = CABasicAnimation(keyPath: "position.y")
                flyAnim.isAdditive = true
                flyAnim.fromValue = 0.1
                flyAnim.toValue = (2.0 + 2.5 * CGFloat(arc4random_uniform(100))/100.0) * bounds.height
                flyAnim.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
                
                let opacityAnim = CABasicAnimation(keyPath: "opacity")
                opacityAnim.duration = CFTimeInterval(duration)
                opacityAnim.beginTime = 0.2
                opacityAnim.fromValue = 1.0
                opacityAnim.toValue = 0.0
                
                let groupAnim = CAAnimationGroup()
                groupAnim.beginTime = CACurrentMediaTime()
                groupAnim.duration = CFTimeInterval(duration) + 0.2
                groupAnim.animations = [scaleAnim, shakeAnim, flyAnim, opacityAnim]
                groupAnim.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
                groupAnim.fillMode = CAMediaTimingFillMode.forwards
                groupAnim.isRemovedOnCompletion = false
                
                path.removeAllAnimations()
                path.add(groupAnim, forKey: "animation")
                layers.append(path)
            }
            
            advance += charPath.advance.width
            index += 1
        }
    }
    
}

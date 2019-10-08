//
//  ViewController.swift
//  FlyingText
//
//  Created by Mateusz Malczak on 08/10/2019.
//

import UIKit
import TextPaths

class ViewController: UIViewController {
    
    @IBOutlet weak var label: UILabel!
    
    var textPath: TextPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let attributedString = createSlogoText()
        let bounds = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textPath = attributedString.getTextPath(InBounds: bounds,
                                                withAttributes: true,
                                                withPath: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        slogoFlyin()
    }
    
    func createSlogoText() -> NSAttributedString {
        let slogo = "what if\ntoday\nwas your\nlast day?"
        let slogoLines = slogo.uppercased().components(separatedBy: .newlines)
        
        let lineColors = [
            UIColor.blue
        ]
        let lineFonts = [
            UIFont.systemFont(ofSize: 22, weight: .light),
            UIFont.systemFont(ofSize: 42, weight: .ultraLight)
        ]
        
        let attrStr = NSMutableAttributedString()
        let para = NSMutableParagraphStyle()
        para.alignment = .center
        for (index, lineText) in slogoLines.enumerated() {
            let color = lineColors[index % lineColors.count]
            let font = lineFonts[index % lineFonts.count]
            let lineAttrs = [
                NSAttributedString.Key.foregroundColor: color,
                NSAttributedString.Key.font: font,
                NSAttributedString.Key.paragraphStyle: para
            ]
            let text = "\n\(lineText)"
            let attrLineStr = NSAttributedString(string: text, attributes: lineAttrs)
            attrStr.append(attrLineStr)
        }
        
        attrStr.append(NSAttributedString(string: "\n\n\n\nToday will never happen again,\nmake the most of it!", attributes: [
            NSAttributedString.Key.foregroundColor: lineColors[0],
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .ultraLight),
            NSAttributedString.Key.paragraphStyle: para
        ]))
        
        return NSAttributedString(attributedString: attrStr)
    }
    
    func slogoFlyin() {
        guard let textPath = textPath else {
            return
        }
        
        // clean-up
        view
            .layer
            .sublayers?
            .compactMap({ $0 as? CAShapeLayer})
            .reversed()
            .forEach { $0.removeFromSuperlayer() }
        
        let frameOffset = CGPoint(x: (view.frame.width - textPath.composedBounds.width) * 0.5,
                                  y: (view.frame.height - textPath.composedBounds.height) * 0.5)
        
        let duration = 0.2
        var i = 0, j = 0
        let delays = [0.5, 0.0, 1.0, 1.5]
        var delay = 0.2
        var time = delay
        
        var lastAnimation: CAAnimation? = nil
        
        for line in textPath.frames[0].lines {
            line.enumerateGlyphs { [unowned self] _, charPath in
                let path = CAShapeLayer()
                let bounds = charPath.path.boundingBox
                
                var T = CATransform3DMakeTranslation(bounds.width*0.5, bounds.height*0.5, 0.0)
                T = CATransform3DScale(T, 4.0, 4.0, 1.0)
                T = CATransform3DTranslate(T, -bounds.width*0.5, -bounds.height*0.5, 0.0)
                
                let color = (charPath.attributes?[NSAttributedString.Key.foregroundColor] as? UIColor) ?? UIColor.black
                path.path = charPath.path
                path.anchorPoint = CGPoint(x: 0.0, y: 0.0)
                path.position = CGPoint(x: frameOffset.x + charPath.position.x, y: frameOffset.y + charPath.position.y)
                path.bounds = CGRect(origin: .zero, size: bounds.size)
                path.fillColor = color.cgColor
                path.transform = T
                path.opacity = 0.0
                self.view.layer.addSublayer(path)
                
                let scaleAnim = CABasicAnimation(keyPath: "transform")
                scaleAnim.fromValue = T
                scaleAnim.toValue = CATransform3DIdentity
                let opacityAnim = CABasicAnimation(keyPath: "opacity")
                opacityAnim.fromValue = 0.0
                opacityAnim.toValue = 1.0
                let groupAnim = CAAnimationGroup()
                groupAnim.beginTime = CACurrentMediaTime() + (duration * 0.3) * Double(j) + delay
                groupAnim.duration = duration
                groupAnim.animations = [scaleAnim, opacityAnim]
                groupAnim.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
                groupAnim.fillMode = CAMediaTimingFillMode.forwards
                groupAnim.isRemovedOnCompletion = false
                
                path.removeAllAnimations()
                path.add(groupAnim, forKey: "animation")
                self.view.layer.addSublayer(path)
                
                lastAnimation = opacityAnim
                
                j += 1
                time += duration * 0.62
            }
            delay += (i < delays.count) ? delays[i] : 0
            i += 1
        }
        
        if let anim = lastAnimation {
            anim.delegate = self
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.seconds(Int(round(time))), execute: { [unowned self] in
//            self.dismiss(animated: true, completion: nil)
            self.slogoFlyin()
        })
    }
    
}

extension ViewController: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        anim.delegate = nil
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.seconds(1), execute: { [unowned self] in
            // replay
            self.slogoFlyin()
        })
    }
}

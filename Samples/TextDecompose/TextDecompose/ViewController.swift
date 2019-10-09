//
//  ViewController.swift
//  TextDecompose
//
//  Created by Mateusz Malczak on 09/10/2019.
//

import UIKit
import TextPaths

class ViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var container: UIView!
    
    var drawLineBounds = true
    
    var drawTextLineBounds = true
    
    var drawGlyphsBounds = true
    
    @IBAction func switchLineLeading(_ sender: UISwitch) {
        drawLineBounds = !drawLineBounds
        decomposeText()
    }
    
    @IBAction func switchLineText(_ sender: UISwitch) {
        drawTextLineBounds = !drawTextLineBounds
        decomposeText()
    }
    
    @IBAction func switchGlyphs(_ sender: UISwitch) {
        drawGlyphsBounds = !drawGlyphsBounds
        decomposeText()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        decomposeText()
    }
    
    func decomposeText() {
        let hardcodedTextViewMargins: CGFloat = 12
        let bounds = CGSize(width: textView.frame.width - hardcodedTextViewMargins,
                            height: CGFloat.greatestFiniteMagnitude)
        guard let textPaths = textView.attributedText.getTextPath(InBounds: bounds,
                                                                  withAttributes: true,
                                                                  withPath: true) else {
                                                                    return
        }
        
        let textBounds = textPaths.composedBounds
        
        let offset = CGPoint(
            x: textBounds.width < container.bounds.width ? (container.bounds.width - textBounds.width) * 0.5 : 0,
            y: textBounds.height < container.bounds.height ? (container.bounds.height - textBounds.height) * 0.5 : 0
        )
        
        let layer = container.layer
        
        // cleanup
        layer
            .sublayers?
            .reversed()
            .forEach { $0.removeFromSuperlayer() }
        
        let container = CAShapeLayer()
        container.bounds = textBounds
        container.anchorPoint = .zero
        container.position = offset
        layer.addSublayer(container);
        
        // draw composed text path
        let textShape = CAShapeLayer()
        textShape.anchorPoint = .zero
        textShape.bounds = textBounds
        textShape.path = textPaths.composedPath!
        textShape.fillColor = UIColor.darkText.cgColor
        container.addSublayer(textShape)
        
        for frame in textPaths.frames {
            container.addSublayer(rect(frame.path.boundingBoxOfPath, .red))
            
            var lineOffsetY: CGFloat = 0.0
            
            for line in frame.lines {
                let lineBounds = line.lineBounds
                let textBounds = line.textBounds
                                
                if drawLineBounds {
                    let shape = rect(lineBounds, .blue)
                    shape.position = CGPoint(x: lineBounds.origin.x,
                                             y: lineOffsetY)
                    container.addSublayer(shape)
                }

                if drawTextLineBounds {
                    let textShape = rect(textBounds, .purple)
                    textShape.position = CGPoint(x: lineBounds.origin.x + textBounds.origin.x,
                                                 y: lineOffsetY + lineBounds.origin.x)
                    container.addSublayer(textShape)
                }
                
                if drawGlyphsBounds {
                    line.enumerateGlyphs { (_, glyph) in
                        let glyphBounds = glyph.path.boundingBoxOfPath
                        let bounds = CGRect(origin: glyph.position, size: glyphBounds.size)
                        let shape = rect(bounds, .green)
                        shape.position = CGPoint(x: glyph.position.x,
                                                 y: glyph.position.y)
                        container.addSublayer(shape)
                    }
                }

                // move to next line (we keep line bounds in own coordinate space)
                lineOffsetY = lineOffsetY + lineBounds.height
            }            
        }
        
    }
    
    func rect(_ rect: CGRect, _ color: UIColor) -> CAShapeLayer {
        let shape = CAShapeLayer()
        let bounds = CGRect(origin: .zero, size: rect.size)
        let origin = rect.origin
        shape.bounds = bounds
        shape.strokeColor = color.cgColor
        shape.fillColor = nil
        shape.anchorPoint = .zero
        shape.path = UIBezierPath(rect: bounds).cgPath
        shape.position = origin
        return shape
    }
}

//
//  NSAttributedString.swift
//  TextPaths
//
//  Created by Mateusz Malczak on 21/01/17.
//  Copyright © 2017 The Pirate Cat. All rights reserved.
//

import UIKit
import CoreGraphics

typealias TextPathAttributes = [String:Any]

/**
 Class represents single character representation - glyph
 */
public class TextPathGlyph {
    public typealias Index = String.UnicodeScalarView.Index
    
    /// Character index in source string unicode view
    public fileprivate(set) var index: Index
    
    /// Glyph path defined in glyph coordinates
    public fileprivate(set) var path: CGPath
    
    /// Glyph path position (top left corner) in line space
    public fileprivate(set) var position: CGPoint
    
    /// Glyph line advance
    public fileprivate(set) var advance = CGSize.zero
    
    /// Glyph origin offset (x component is a glyph origin offset, y component is an offset to baseline)
    public fileprivate(set) var originOffset = CGPoint.zero
    
    /// Glyph line run index
    fileprivate var lineRun: Int = 0
    
    /// Glyph line
    fileprivate weak var line: TextPathLine?
    
    /// Get glyph attributes as defined in source string
    public var attributes: [String:Any]? {
        return line?.attributes(ForGlyph: self)
    }
    
    init(index: Index, path: CGPath, position: CGPoint){
        self.index = index
        self.path = path
        self.position = position
    }
}

/**
 Single text line representation
 */
public class TextPathLine {
    
    /// Line index
    public fileprivate(set) var index: Int
    
    /**
        Line typographic bounds based on line ascent / descent
     
        Rectangle is based on typographic line properties (ie. ascent, descent)
     */
    public fileprivate(set) var lineBounds = CGRect.zero
    
    /**
        Line path bounds based on text path
     
        Rectangle defined by _textBounds_ is smaller than _lineBounds_ and is based only o text bounds
     */
    public fileprivate(set) var textBounds = CGRect.zero
    
    /// Line leading
    public fileprivate(set) var leading = CGFloat(0.0)
    
    /// Line ascent
    public fileprivate(set) var ascent = CGFloat(0.0)
    
    /// Line descent
    public fileprivate(set) var descent = CGFloat(0.0)
    
    /**
        Line effective descent is calculated based on lineRuns typographic properties,
        in most cases is equal to _descent_.  In some rare cases this rect is smaller that _descent_ property.
        
        ## Example ##
        ````
        let str = NSMutableAttributedString(string: "First line".uppercased(), attributes: [
            NSFontAttributeName: UIFont.systemFont(ofSize: 22, weight: UIFontWeightUltraLight)
        ])
        str.append(NSAttributedString(string: "\nSecond line".uppercased(), attributes: [
            NSFontAttributeName: UIFont.systemFont(ofSize: 64, weight: UIFontWeightMedium)
        ]))
        ````
        In second line much larger font is used, it also applied to the 'line break' (\n)
        character. As a result typographic size of the first line is different that one used by TextKit to draw text
        in text components (UILabel, UITextView).
        In this case _effectiveDescent_ of the first line is smaller that _descent_ measured by CoreText, because it is calculated
        only based on visible characters (ie. not including '\n' metrics)
     */
    public fileprivate(set) var effectiveDescent = CGFloat(0.0)
    
    /// Line effective ascent (read more above)
    public fileprivate(set) var effectiveAscent = CGFloat(0.0)
    
    /// Line glyph to attributes mapping
    fileprivate var attributes: [TextPathAttributes]?
    
    /// Collection of all glyphs in line
    fileprivate var glyphs = [TextPathGlyph]()
    
    init(index: Int) {
        self.index = index
    }
    
    /**
     Enumerates over all glyphs in line
     - Parameter callback: Called for each glyph in line
     - Parameter line: Current text line
     - Parameter glyph: Current glyph
     */
    public func enumerateGlyphs(_ callback:(_ line: TextPathLine, _ glyph: TextPathGlyph) -> ()) {
        for glyph in glyphs {
            callback(self, glyph)
        }
    }
    
    /**
     Get attributes for a line glyph
     - Parameter glyph: Glyph in line
     - Returns: Glyph attributes
     */
    fileprivate func attributes(ForGlyph glyph: TextPathGlyph) -> [String:Any]? {
        if let attributes = attributes {
            return attributes[glyph.lineRun]
        }
        return nil
    }
}

/**
 Text frame representation. This can represent a simple text rectangle (eq. UITextView text content),
 as well as a complex frame defined by CGPath
 */
public class TextPathFrame {
    
    /// Frame shape path (eq. textfield bounds rect)
    public fileprivate(set) var path: CGPath
    
    /// Text frame lines
    public fileprivate(set) var lines = [TextPathLine]()
    
    init(path: CGPath) {
        self.path = path
    }
    
    /**
     Enumerates over all glyphs in text frame
     - Parameter callback: Called for each glyph in text frame
     - Parameter line: Current text line
     - Parameter glyph: Current glyph
     */
    public func enumerateGlyphs(_ callback: @escaping(_ line: TextPathLine, _ glyph: TextPathGlyph) -> ()) {
        for line in lines {
            line.enumerateGlyphs(callback)
        }
    }
}

/**
 Text path represents a CGPath representation of text frame, glyphs and typographic properties
 */
public class TextPath {
    
    /// Attributed text used to generate text path
    public fileprivate(set) var attributedString: NSAttributedString
    
    /// Text path composed for input text
    public fileprivate(set) var composedPath: CGPath?
    
    /// Composed text path bounding box
    public fileprivate(set) var composedBounds: CGRect
    
    /// text frames
    public fileprivate(set) var frames = [TextPathFrame]()
    
    init(text: NSAttributedString, path: CGPath? = nil) {
        self.attributedString = text
        self.composedPath = path
        self.composedBounds = path?.boundingBoxOfPath ?? CGRect.zero
    }
}

public extension NSAttributedString {
    
    /**
        Creates a text path and a collection of text lines and 
        glyphs with additional typographic informations (ie. ascent, descent, bounds)
     
        - Parameter bounds: text bounding box
        - Parameter withAttributes: if _true_ glyph attributes are included in returned TextPath
        - Parameter withPath: if _true_ a composed text path is included
        - Returns: created text path or NULL if failed
     */
    public func getTextPath(InBounds bounds:CGSize, withAttributes: Bool = false, withPath: Bool = true) -> TextPath? {
        let clearText = self.string
        if clearText.isEmpty {
            return nil
        }
        
        let defaultAttributes = [
            NSFontAttributeName: UIFont.systemFont(ofSize: UIFont.systemFontSize),
            NSForegroundColorAttributeName: UIColor.black
        ]

        var lineIndex = 0
        let unicodeScalars = clearText.unicodeScalars
        var unicodeIndex = unicodeScalars.startIndex

        let frameSetter = CTFramesetterCreateWithAttributedString(self)
        let textRange = CFRangeMake(0, self.length)
        let frameSize = CTFramesetterSuggestFrameSizeWithConstraints(frameSetter, textRange, nil, bounds, nil)
        let framePath = UIBezierPath(rect: CGRect(origin: .zero, size: frameSize)).cgPath
        let frame = CTFramesetterCreateFrame(frameSetter, textRange, framePath, nil)
        
        let tpFrame = TextPathFrame(path: framePath)
        let frames = [tpFrame]
        
        // 0. fetch all lines / glyphs + text path
        let ignoredCharsSet = CharacterSet.whitespacesAndNewlines
        let path = CGMutablePath()
        
        if let lines = CTFrameGetLines(frame) as? [CTLine] {
            var linesShift = CGFloat(0)
            var origins = [CGPoint](repeating: CGPoint.zero, count: lines.count)
            CTFrameGetLineOrigins(frame, CFRangeMake(0, lines.count), &origins)
            var originItr = origins.makeIterator()

            for line in lines {
                let lineOrigin = originItr.next() ?? CGPoint.zero
                let tpLine = TextPathLine(index: lineIndex)

                tpLine.lineBounds = CTLineGetBoundsWithOptions(line, .excludeTypographicLeading)
                tpLine.textBounds = CTLineGetBoundsWithOptions(line, .useGlyphPathBounds)
                
                let _ = CTLineGetTypographicBounds(line, &tpLine.ascent, &tpLine.descent, &tpLine.leading)
                
                if let lineRuns = CTLineGetGlyphRuns(line) as? [CTRun] {
                    if withAttributes {
                        tpLine.attributes = [TextPathAttributes](repeating:defaultAttributes, count: lineRuns.count)
                    }
                    
                    var effectiveDescent = CGFloat(0)
                    var effectiveAscent = CGFloat(0)

                    var lineRunIndex = 0
                    for lineRun in lineRuns {
                        let glyphsCount = CTRunGetGlyphCount(lineRun)
                        if glyphsCount == 0 {
                            continue
                        }

                        let attributes = (CTRunGetAttributes(lineRun) as? TextPathAttributes) ?? defaultAttributes
                        let font = (attributes[NSFontAttributeName] as? UIFont) ?? (defaultAttributes[NSFontAttributeName] as! UIFont)
                        
                        if withAttributes {
                            tpLine.attributes![lineRunIndex] = attributes
                        }

                        var rt_ascent = CGFloat(0.0)
                        var rt_descent = CGFloat(0.0)
                        var rt_leading = CGFloat(0.0)
                        let _ = CTRunGetTypographicBounds(lineRun, CFRangeMake(0, glyphsCount), &rt_ascent, &rt_descent, &rt_leading)
                        
                        let lineRunInfo = (CTRunGetGlyphsPtr(lineRun), CTRunGetPositionsPtr(lineRun), CTRunGetAdvancesPtr(lineRun))
                        switch( lineRunInfo ) {
                        case let (glyphsPtr?,  positionsPtr?, advancesPtr?):
                            var glyphPtr = glyphsPtr
                            var positionPtr = positionsPtr
                            var advancePtr = advancesPtr
                            
                            for _ in 0..<glyphsCount {
                                let glyphUnicodeIndex = unicodeIndex
                                unicodeIndex = unicodeScalars.index(after: unicodeIndex)
                                
                                if(!ignoredCharsSet.contains(unicodeScalars[glyphUnicodeIndex])) {
                                    effectiveAscent = max(effectiveAscent, abs(rt_ascent))
                                    effectiveDescent = max(effectiveDescent, abs(rt_descent))
                                    
                                    let glyph = glyphPtr.pointee
                                    let position = positionPtr.pointee
                                    
                                    var T = CGAffineTransform(scaleX: 1, y: 1)
                                    let ctFont = font as CTFont
                                    if let glyphPath = CTFontCreatePathForGlyph(ctFont, glyph, &T) {
                                        let pathBounds = glyphPath.boundingBoxOfPath
                                        var pathOffset = CGAffineTransform(translationX: -pathBounds.origin.x, y: -pathBounds.origin.y)
                                        let glyphPathRel = glyphPath.copy(using: &pathOffset) ?? glyphPath
                                        let originOffset = CGPoint(x: -pathBounds.origin.x, y: pathBounds.origin.y)
                                        let offset = CGPoint(x: lineOrigin.x + position.x + pathBounds.origin.x,
                                                             y: lineOrigin.y + position.y + pathBounds.origin.y)
                                        
                                        let tpGlyph = TextPathGlyph(index: glyphUnicodeIndex, path: glyphPathRel, position: offset)
                                        tpGlyph.lineRun = lineRunIndex
                                        tpGlyph.advance = advancePtr.pointee
                                        tpGlyph.originOffset = originOffset
                                        
                                        tpGlyph.line = tpLine
                                        tpLine.glyphs.append(tpGlyph)
                                    }
                                }
                                glyphPtr = glyphPtr.successor()
                                positionPtr = positionPtr.successor()
                                advancePtr = advancePtr.successor()
                            }
                            break;
                        default:
                            return nil
                        }
                    
                        lineRunIndex += 1
                    }
                    
                    if tpLine.glyphs.count != 0 {
                        tpLine.effectiveAscent = effectiveAscent
                        tpLine.effectiveDescent = effectiveDescent
                        for tpGlyph in tpLine.glyphs {
                            let position = tpGlyph.position
                            let offset = CGPoint(x: position.x, y: position.y + (tpLine.ascent - tpLine.effectiveAscent) + linesShift)
                            let T = CGAffineTransform(translationX: offset.x, y: offset.y)
                            path.addPath(tpGlyph.path, transform: T)
                            tpGlyph.position = offset
                        }
                        
                        tpFrame.lines.append(tpLine)
                        lineIndex += 1
                    }
                    
                    
                    linesShift += (tpLine.ascent + tpLine.descent) - (effectiveAscent + effectiveDescent)
                }
            }
        }
        
        var finalPath = path as CGPath
        var pathBounds = CGRect.zero
        var matrix = CGAffineTransform.identity
        
        // 1. move path to (0,0) (and glyphs)
        pathBounds = path.boundingBoxOfPath
        matrix = CGAffineTransform(translationX: -pathBounds.origin.x, y: -pathBounds.origin.y)
        if let copyPath = path.copy(using: &matrix) {
            finalPath = copyPath
            
            for tpFrame in frames {
                tpFrame.enumerateGlyphs { _, glyph in
                    glyph.position = glyph.position.applying(matrix)
                }
            }
        }
        
        // 2. flip path (and glyphs)
        pathBounds = path.boundingBoxOfPath
        matrix = CGAffineTransform(scaleX: 1, y: -1)
        matrix = matrix.translatedBy(x: 0, y: -pathBounds.size.height)
        if let copyPath = path.copy(using: &matrix) {
            finalPath = copyPath
            
            for tpFrame in frames {
                tpFrame.enumerateGlyphs { _, glyph in
                    let glyphPath = glyph.path
                    let glyphBounds = glyphPath.boundingBoxOfPath
                    let glyphHeight = glyphBounds.size.height
                    var flipMatrix = CGAffineTransform(scaleX: 1, y: -1)
                    flipMatrix = flipMatrix.translatedBy(x: 0, y: -glyphHeight)
                    if let copyPath = glyphPath.copy(using: &flipMatrix) {
                        glyph.path = copyPath
                        let position = glyph.position.applying(matrix).applying(CGAffineTransform(translationX: 0, y: -glyphHeight))
                        glyph.position = position
                    }
                }
            }
        }
        
        let tp = TextPath(text: self, path: withPath ? finalPath : nil)
        tp.composedBounds = finalPath.boundingBoxOfPath
        tp.frames.append(contentsOf: frames)
        return tp
    }
}

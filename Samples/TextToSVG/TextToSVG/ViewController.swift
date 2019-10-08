//
//  ViewController.swift
//  TextToSVG
//
//  Created by Mateusz Malczak on 08/10/2019.
//

import UIKit
import WebKit
import TextPaths

class ViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var svgTextView: UITextView!
    
    @IBOutlet weak var webView: WKWebView!
    
    @IBAction func switchChanged(_ control: UISegmentedControl) {
        webView.isHidden = control.selectedSegmentIndex == 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getSVG()
    }
    
    func getSVG() {
        let hardcodedTextViewMargins: CGFloat = 12
        
        if let attributedText = textView.attributedText {
            let bounds = CGSize(width: textView.frame.width - hardcodedTextViewMargins,
                                height: CGFloat.greatestFiniteMagnitude)
            let textPath = attributedText.getTextPath(InBounds: bounds,
                                                      withAttributes: false,
                                                      withPath: true)
            if let composedPath = textPath?.composedPath, let composedBounds = textPath?.composedBounds {
                
                let svg_path = svg(fromPath: composedPath)
                
                let svg = """
                    <svg width="100%" height="auto" viewBox="0 0 \(composedBounds.width) \(composedBounds.height)" xmlns="http://www.w3.org/2000/svg">
                        <!-- Created with TextPaths - https://github.com/malczak/TextPaths -->
                      <path id="textPath" d="\(svg_path)" stroke-width="none" fill="#000"></path>
                    </svg>
                """
                
                svgTextView.text = svg
                
                let html = """
                    <html lang="en">
                        <head>
                            <title>TextPaths</title>
                            <meta name="viewport" content="width=device-width,initial-scale=1.0">
                        </head>
                        <body>
                            <h1>SVG Preview</h1><p>Text below is a SVG path</p>
                            <div>\(svg)</div>
                        </body>
                    </html>
                """
                
                webView.loadHTMLString(html, baseURL: nil)
            }
        }
    }
    
    func svg(fromPath path: CGPath) -> String {
        var data = Data()
        path.apply(info: &data) { userData, elementPtr in
            var data = userData!.assumingMemoryBound(to: Data.self).pointee
            let element = elementPtr.pointee
            switch element.type {
            case .moveToPoint:
                let point = element.points.pointee
                data.append(String(format: "M%.2f,%.2f", point.x, point.y).data(using: .utf8)!)
                break;
            case .addLineToPoint:
                let point = element.points.pointee
                data.append(String(format: "L%.2f,%.2f", point.x, point.y).data(using: .utf8)!)
                break;
            case .addQuadCurveToPoint:
                let ctrl = element.points.pointee
                let point = element.points.advanced(by: 1).pointee
                
                data.append(String(format: "Q%.2f,%.2f,%.2f,%.2f", ctrl.x, ctrl.y, point.x, point.y).data(using: .utf8)!)
                break
            case .addCurveToPoint:
                let ctrl1 = element.points.pointee
                let ctrl2 = element.points.advanced(by: 1).pointee
                let point = element.points.advanced(by: 2).pointee
                data.append(String(format: "C%.2f,%.2f,%.2f,%.2f,%.2f,%.2f", ctrl1.x, ctrl1.y, ctrl2.x, ctrl2.y, point.x, point.y).data(using: .utf8)!)
                break
            case .closeSubpath:
                data.append("Z".data(using: .utf8)!)
                break
            @unknown default:
                break
            }
            userData!.assumingMemoryBound(to: Data.self).pointee = data
        }
        
        return String(bytes: data, encoding: .utf8)!
    }
    
}

extension ViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        getSVG()
    }
}

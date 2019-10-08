//
//  ViewController.swift
//  FallingLabel
//
//  Created by Mateusz Malczak on 08/10/2019.
//

import UIKit

fileprivate struct Consts {
    static let fonts: [UIFont] = [
        UIFont(name: "AmericanTypewriter-Light", size: 44)!,
        UIFont(name: "BradleyHandITCTT-Bold", size: 44)!,
        UIFont.systemFont(ofSize: 120, weight: .regular),
        UIFont.systemFont(ofSize: 60, weight: .ultraLight),
        UIFont(name: "Zapfino", size: 33)!,
        UIFont.systemFont(ofSize: 40, weight: .bold),
    ]
}

class ViewController: UIViewController {
    
    @IBOutlet weak var label: UILabel!
    
    var counterDisplay: FallingCounterLabel?
    
    var timer: Timer?
    
    var currentFontIndex: Int = 0
    
    var index: Int = 0
    

    override func viewDidLoad() {
        super.viewDidLoad()
            
        let counter = FallingCounterLabel(WithLabel: label)
        counter.duration = 0.8
        counter.value = 0
        self.counterDisplay = counter
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setFont()
        startTimer()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        stopTimer()
        super.viewDidDisappear(animated)
    }
    
    func setFont(){
        guard let counter = counterDisplay else {
            return
        }
        
        counter.numberPaths = NumberPaths(WithFont: Consts.fonts[currentFontIndex],
                                          alignment: .center)

    }
    
    func startTimer() {
        stopTimer()
        index = 0
        let timer = Timer.scheduledTimer(timeInterval: 1.0,
                                         target: self,
                                         selector: #selector(onTimer),
                                         userInfo: nil,
                                         repeats: true)
        self.timer = timer
    }
    
    func stopTimer() {
        if let timer = timer {
            timer.invalidate()
        }
        timer = nil
    }

    @objc func onTimer(_ t: Any) {
        guard let counter = counterDisplay else {
            return
        }
        let value = counter.value
        counter.value = value + 1
        
        index += 1;
        if (index % 10) == 0 {
            currentFontIndex = (currentFontIndex + 1) % Consts.fonts.count
            setFont()
        }
    }

}


//
//  GeneralController.swift
//  PutDownMyMac
//
//  Created by Jun Zheng on 2019/7/2.
//  Copyright © 2019 Jun Zheng. All rights reserved.
//

import Cocoa

class GeneralController: NSViewController {
    @IBOutlet weak var volumeSlider: NSSlider!
    let userdefault = UserDefaults.standard
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    override func viewWillAppear() {
        volumeSlider.floatValue = userdefault.float(forKey: "alartVolume")
    }
    
    @IBAction func volumeChange(_ sender: NSSlider) {
        userdefault.set(Float(sender.floatValue), forKey: "alartVolume")
        print(sender.floatValue)
    }
    
}

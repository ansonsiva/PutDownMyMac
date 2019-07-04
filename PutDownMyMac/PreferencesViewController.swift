//
//  PreferencesViewController.swift
//  PutDownMyMac
//
//  Created by Jun Zheng on 2019/7/2.
//  Copyright © 2019 Jun Zheng. All rights reserved.
//

import Cocoa

class PreferencesViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
    }
    
    override func viewDidAppear() {
        let window = self.view.window
        window?.styleMask.remove(.resizable)
    }
    
    override func viewWillAppear() {
        let window = self.view.window
        window?.makeKeyAndOrderFront(self)
    }
}

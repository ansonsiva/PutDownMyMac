//
//  WhiteListController.swift
//  PutDownMyMac
//
//  Created by Jun Zheng on 2019/7/2.
//  Copyright © 2019 Jun Zheng. All rights reserved.
//

import Cocoa
import CoreWLAN

class WhiteListController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        let wifiName = CWWiFiClient.shared().interface()!.ssid()!
        print(wifiName)
        
    }
    
}

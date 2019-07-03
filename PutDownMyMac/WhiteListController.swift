//
//  WhiteListController.swift
//  PutDownMyMac
//
//  Created by Jun Zheng on 2019/7/2.
//  Copyright © 2019 Jun Zheng. All rights reserved.
//

import Cocoa
import CoreWLAN
import AVFoundation

class WhiteListController: NSViewController {

    
    @IBOutlet weak var wifiNameLabel: NSTextField!
    @IBOutlet weak var addButton: NSButton!
    @IBOutlet weak var tableView: NSTableView!
    
    let userdefault = UserDefaults.standard
    var currentWifi = CWWiFiClient.shared().interface()?.ssid()
    var wifiList = [String]()


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        if let wifiLabel = currentWifi {
            wifiNameLabel.stringValue = "Current Wifi is \"\(wifiLabel)\""}
        else{
            wifiNameLabel.stringValue = "Not connect to wifi yet"
        }
        
        //添加右键菜单
        let menu = NSMenu()
        menu.autoenablesItems = false
        menu.addItem(NSMenuItem(title: "Delete", action: #selector(tableViewDeleteItemClicked(_:)), keyEquivalent: ""))
        tableView.menu = menu
        
        wifiList = userdefault.stringArray(forKey: "wifiLists") ?? ["No wifi in white list now"]
    }
    
    
    
    
    
    @IBAction func addWifiPressed(_ sender: Any) {
        if let wifiToAdd = currentWifi {
            if wifiToAdd != "no wifi"{
                wifiList.append(wifiToAdd)
                userdefault.set(wifiList, forKey: "wifiLists")
                tableView.reloadData()
            }
        }else{
            
        }
    }
    
    
}

extension WhiteListController:NSTableViewDelegate,NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return wifiList.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let vw = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as? NSTableCellView else {return nil}
        
            vw.textField?.stringValue = wifiList[row]
        return vw
    }
    
    @objc private func tableViewDeleteItemClicked(_ sender: AnyObject) {
        
        guard tableView.clickedRow >= 0 else { return }
        
        wifiList.remove(at: tableView.clickedRow)
        userdefault.set(wifiList, forKey: "wifiLists")
        tableView.reloadData()
    }
}

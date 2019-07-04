//
//  AppDelegate.swift
//  PutDownMyMac
//
//  Created by Jun Zheng on 2019/6/27.
//  Copyright © 2019 Jun Zheng. All rights reserved.
//

import Cocoa
import IOKit.pwr_mgt
import IOKit.ps
import AVFoundation
import CoreWLAN
import AudioToolbox


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    var intervalTimer:Timer?
    var player: AVAudioPlayer?
    let icon = NSImage(named: "record")
    var isAlertOn = false
    var mainVolume:Float = 0.5
    let userdefault = UserDefaults.standard
    var currentWifi = CWWiFiClient.shared().interface()?.ssid() ?? "no wifi"
    var wifiList = [String]()
    
    

    enum batteryStatus {
        case battery
        case ac
    }
    
    @IBOutlet weak var AlertButton: NSMenuItem!
    @IBOutlet weak var PreferencesButton: NSMenuItem!
    @IBOutlet weak var QuitButton: NSMenuItem!
    @IBOutlet weak var AlertMenu: NSMenu!
    
    @IBAction func AlertToggle(_ sender: Any) {
        
        if getPowerStatus() == .ac {
            isAlertOn.toggle()
            noSleep()
            setAlert(AlertState: isAlertOn)
            
 
        }else{
            if !isAlertOn {
                let _ = showAlertPopWindow(question: "Please plug in the AC", text: "Plug in the AC to use the alert")
            }
        }
        
        
    }
    
    
    
    @IBAction func QuitPressed(_ sender: Any) {
        NSApplication.shared.terminate(self)
    }
    
    
    fileprivate func setAlert(AlertState isAlertOn:Bool){
        AlertButton.title = isAlertOn ? "Alert Off":"Alert On"
        statusItem.button?.image = NSImage.init(named: isAlertOn ? "recording":"record")
        if isAlertOn {
            intervalTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(showAlert), userInfo: nil, repeats: true)
        }else{
            intervalTimer?.invalidate()
        }
    }
    
    fileprivate func getPowerStatus() -> batteryStatus {
        let remainingSeconds: CFTimeInterval = IOPSGetTimeRemainingEstimate()
        switch remainingSeconds {
        case -2.0:
            return batteryStatus.ac
        default:
            return batteryStatus.battery
        }
    }
    
    //禁止休眠
    fileprivate func noSleep() {
        var assertionID: IOPMAssertionID = 0
        var sleepDisabled = false
        
        func disableScreenSleep(reason: String = "Disabling Screen Sleep") {
            sleepDisabled =  IOPMAssertionCreateWithName(kIOPMAssertionTypeNoDisplaySleep as CFString, IOPMAssertionLevel(kIOPMAssertionLevelOn), reason as CFString, &assertionID) == kIOReturnSuccess
        }
        
        func  enableScreenSleep() {
            IOPMAssertionRelease(assertionID)
            sleepDisabled = false
        }
    }
    
    
    
    
    
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        AlertButton.title = "Alert On"
        icon?.isTemplate = true
        statusItem.button?.image = icon
        statusItem.menu = AlertMenu
        userdefault.register(defaults: ["wifiLists" : [String]()])
        userdefault.register(defaults: ["alartVolume" : Float()])
        
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
    }
    
    
    @objc func showAlert(){
        wifiList = userdefault.stringArray(forKey: "wifiLists") ?? [""]
        if getPowerStatus() == .battery && !wifiList.contains(currentWifi) {
            print("your mac is lost")
            soundPlay()
        } 
    }
    
    
    fileprivate func soundPlay() {
        let url = URL(fileURLWithPath: Bundle.main.path(forResource: "alarm", ofType: "wav")!)
        mainVolume = userdefault.float(forKey: "alartVolume")
        do {
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: nil)
        } catch _{
            return
        }
//        player?.setVolume(mainVolume,fadeDuration: 0)
        player?.volume = mainVolume
        player?.play()
        
//        sleep(3)
    }
    
    fileprivate func showAlertPopWindow(question: String, text: String) -> Bool {
        let myPopup: NSAlert = NSAlert()
        myPopup.messageText = question
        myPopup.informativeText = text
        myPopup.alertStyle = NSAlert.Style.warning
        myPopup.addButton(withTitle: "好的")
        return myPopup.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn
    }
    
    
    
}



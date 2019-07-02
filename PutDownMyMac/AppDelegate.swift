//
//  AppDelegate.swift
//  PutDownMyMac
//
//  Created by Jun Zheng on 2019/6/27.
//  Copyright © 2019 Jun Zheng. All rights reserved.
//

import Cocoa
import IOKit
import IOKit.pwr_mgt
import IOKit.ps
import AVFoundation
import AudioToolbox
import CoreAudio


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    var intervalTimer:Timer?
    var player: AVAudioPlayer?
    let icon = NSImage(named: "record")
    var isAlertOn = false
    var originVolume = Float32(0.5)
    var mainVolume = Float32(0.0)
    
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
    
    @IBAction func PreferencesPressed(_ sender: Any) {
        
    }
    
    
    @IBAction func QuitPressed(_ sender: Any) {
        setAudioVolume(volume: originVolume)
        NSApplication.shared.terminate(self)
    }
    
    
    fileprivate func setAlert(AlertState isAlertOn:Bool){
        AlertButton.title = isAlertOn ? "Alert Off":"Alert On"
        statusItem.button?.image = NSImage.init(named: isAlertOn ? "recording":"record")
        if isAlertOn {
            
            intervalTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(showAlert), userInfo: nil, repeats: true)
            
        }else{
            intervalTimer?.invalidate()
            if mainVolume != Float32(1.0){
                setAudioVolume(volume: originVolume)
            }
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
    
    fileprivate func setAudioVolume(volume:Float32) {
        //获取音频设备
        
        var defaultOutputDeviceID = AudioDeviceID(0)
        var defaultOutputDeviceIDSize = UInt32(MemoryLayout.size(ofValue: defaultOutputDeviceID))
        
        var getDefaultOutputDevicePropertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultOutputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMaster))
        
        AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject),&getDefaultOutputDevicePropertyAddress,
                                   0,nil,&defaultOutputDeviceIDSize,&defaultOutputDeviceID)
        
        
        mainVolume = volume
        var volumeSize = UInt32(MemoryLayout.size(ofValue: volume))
        
        var volumePropertyAddress = AudioObjectPropertyAddress(mSelector:kAudioHardwareServiceDeviceProperty_VirtualMasterVolume,mScope: kAudioDevicePropertyScopeOutput,mElement: kAudioObjectPropertyElementMaster)
        //获取原音量
        AudioObjectGetPropertyData(defaultOutputDeviceID, &volumePropertyAddress, 0, nil, &volumeSize, &originVolume)
        //设置主音量
        AudioObjectSetPropertyData(defaultOutputDeviceID,&volumePropertyAddress,0,nil,volumeSize,&mainVolume)
    }
    
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
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        setAudioVolume(volume: originVolume)
    }
    
    
    @objc func showAlert(){
        if getPowerStatus() == .battery {
            setAudioVolume(volume: 1.0)
            print("your mac is lost")
            soundPlay()
        }
        
    }
    
    fileprivate func soundPlay() {
        
        let url = URL(fileURLWithPath: Bundle.main.path(forResource: "alarm", ofType: "wav")!)
        do {
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: nil)
            player?.volume = 1
        } catch _{
            return
        }
        player?.play()
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



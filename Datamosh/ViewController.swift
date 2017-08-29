//
//  ViewController.swift
//  Datamosh
//
//  Created by fairy-slipper on 8/27/17.
//  Copyright © 2017 fairy-slipper. All rights reserved.
//

import Cocoa
import Foundation
import AVFoundation

class ViewController: NSViewController {
    
    var openPanel : NSOpenPanel?
    var savePanel : NSSavePanel?
    var player: VideoPlayer?
    var playerLayer : AVPlayerLayer?
    var tracker : Slider?
    var timeScale : CMTimeScale?
    
    var playButton : NSButton?
    var glitchButton : NSButton?
    var resetButton : NSButton?
    
    var payLoad : NSTextField?
    var startSlider : NSSlider?
    var endSlider : NSSlider?
    var glitchSlider : NSSlider?
    var startText : NSText?
    var endText : NSText?
    var intensityText : NSText?
    var timeMeter : NSText?
    
    var hoverText : HoverText?
    
    var origUrl : NSURL?
    var videoData : NSMutableData?
    
    var timer : Timer?
    
    func create() {
        
        self.view.layer?.backgroundColor = CGColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        
        self.openPanel = NSOpenPanel()
        self.openPanel?.canChooseFiles = true
        
        self.savePanel = NSSavePanel()
        self.savePanel?.allowedFileTypes = Array(arrayLiteral: "mp4", "aiv")
        
        let buttonItems: [String] = ["mp4 (*.mp4)", "aiv (*.aiv)"]
        let accessoryView = NSView(frame: NSMakeRect(0.0, 0.0, 200, 32.0))
        let popupButton = NSPopUpButton(frame:NSMakeRect(50.0, 2, 140, 22.0));
        popupButton.addItems(withTitles: buttonItems)
        popupButton.action = #selector(setFormat)
        accessoryView.addSubview(popupButton)
        
        self.savePanel?.accessoryView = accessoryView
        
        let playButtonRect = CGRect(x: 110, y: 10, width: 100, height: 50)
        self.playButton =  NSButton(frame: playButtonRect)
        self.playButton?.title = "Play"
        self.playButton?.target = self
        self.playButton?.action = #selector(ViewController.playVideo)
        self.view.addSubview(self.playButton!)
        
        let glitchButtonRect = CGRect(x: 220, y: 10, width: 100, height: 50)
        self.glitchButton =  NSButton(frame: glitchButtonRect)
        self.glitchButton?.title = "Glitch"
        self.glitchButton?.target = self
        self.glitchButton?.action = #selector(ViewController.glitch)
        self.view.addSubview(self.glitchButton!)
        
        let resetButtonRect = CGRect(x: 330, y: 10, width: 100, height: 50)
        self.resetButton =  NSButton(frame: resetButtonRect)
        self.resetButton?.title = "Reset"
        self.resetButton?.target = self
        self.resetButton?.action = #selector(ViewController.reset)
        self.view.addSubview(self.resetButton!)
        
        self.timeMeter = NSText(frame: NSMakeRect(0, 25, 90, 25))
        self.timeMeter?.string = "00.00/00.00"
        self.timeMeter?.isEditable = false
        self.timeMeter?.alignment = NSTextAlignment.right
        self.timeMeter?.textColor = NSColor.white
        self.timeMeter?.backgroundColor = NSColor(cgColor: (self.view.layer?.backgroundColor)!)
        self.view.addSubview(self.timeMeter!)
        
        self.tracker = Slider(frame: NSMakeRect(0, 75, self.view.frame.width-5, 30))
        self.tracker?.delegate = self
        self.tracker?.target = self
        self.tracker?.action = #selector(trackerDrag)
        self.view.addSubview(self.tracker!)
        
        self.payLoad = NSTextField(frame: NSMakeRect(440, 10, 100, 50))
        self.payLoad?.isEditable = true
        self.payLoad?.stringValue = "000001"
        self.view.addSubview(self.payLoad!)
        
        self.startText = NSText(frame: NSMakeRect(550, 50, 90, 25))
        self.startText?.string = "Start"
        self.startText?.isEditable = false
        self.startText?.alignment = NSTextAlignment.right
        self.startText?.textColor = NSColor.white
        self.startText?.backgroundColor = NSColor(cgColor: (self.view.layer?.backgroundColor)!)
        self.view.addSubview(self.startText!)
        
        self.startSlider = NSSlider(frame: NSMakeRect(650, 55, self.view.frame.width-700, 25))
        self.startSlider?.maxValue = 100.0
        self.startSlider?.doubleValue = 5.0
        self.startSlider?.target = self
        self.startSlider?.action = #selector(startSliderValueChanged)
        
        self.endText = NSText(frame: NSMakeRect(550, 25, 90, 25))
        self.endText?.string = "End"
        self.endText?.isEditable = false
        self.endText?.alignment = NSTextAlignment.right
        self.endText?.textColor = NSColor.white
        self.endText?.backgroundColor = NSColor(cgColor: (self.view.layer?.backgroundColor)!)
        self.view.addSubview(self.endText!)
        
        self.endSlider = NSSlider(frame: NSMakeRect(650, 30, self.view.frame.width-700, 25))
        self.endSlider?.maxValue = 100.0
        self.endSlider?.doubleValue = 95.0
        self.endSlider?.target = self
        self.endSlider?.action = #selector(endSliderValueChanged)
        
        self.intensityText = NSText(frame: NSMakeRect(550, 0, 90, 25))
        self.intensityText?.string = "Intensity"
        self.intensityText?.isEditable = false
        self.intensityText?.alignment = NSTextAlignment.right
        self.intensityText?.textColor = NSColor.white
        self.intensityText?.backgroundColor = NSColor(cgColor: (self.view.layer?.backgroundColor)!)
        self.view.addSubview(self.intensityText!)
        
        self.glitchSlider = NSSlider(frame: NSMakeRect(650, 5, self.view.frame.width-700, 25))
        self.glitchSlider?.maxValue = 999999.0
        self.glitchSlider?.doubleValue = 900000.0
        self.glitchSlider?.target = self
        self.glitchSlider?.action = #selector(glitchSliderValueChanged)
        
        self.hoverText = HoverText(frame: NSMakeRect(self.view.frame.width/2.0 - 175, self.view.frame.height/2.0 - 50, 350, 100))
        self.hoverText?.alphaValue = 0.0
        self.hoverText?.font = NSFont(name: "Arial", size: 82)
        self.hoverText?.backgroundColor = NSColor.black
        self.hoverText?.textColor = NSColor.white
        self.hoverText?.alignment = NSTextAlignment.center
        self.hoverText?.isEditable = false
        self.hoverText?.layer?.zPosition = 1;
        self.hoverText?.updateLayer()
        self.view.addSubview(self.hoverText!)
        
        self.view.addSubview(self.startSlider!)
        self.view.addSubview(self.endSlider!)
        self.view.addSubview(self.glitchSlider!)
        
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    func quit() {
        exit(0)
    }
    
    func setFormat(sender: Any) {
        let button = sender as! NSPopUpButton
        let selectedItemIndex = button.indexOfSelectedItem
        let name = self.savePanel?.nameFieldStringValue
        let trimmedName = name?.substring(to: (name?.characters.index(of: "."))!)
        var ext = String()
        if(selectedItemIndex == 0) {
            ext = "mp4"
        } else if(selectedItemIndex == 1) {
            ext = "aiv"
        }
        
        self.savePanel?.nameFieldStringValue = trimmedName!
        self.savePanel?.allowedFileTypes = Array(arrayLiteral: ext)
    }
    
    func loadFile() {
        self.openPanel?.runModal()
        if (openPanel?.url != nil) {
            self.videoData = NSMutableData(contentsOf: (openPanel?.url)!)
            let newItem = AVPlayerItem(url: (openPanel?.url)!)
            self.player = nil
            self.playerLayer = nil
            self.player = VideoPlayer(playerItem: newItem)
            self.player?.currentItem?.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: nil)
            self.origUrl = openPanel?.url as NSURL?
            self.playerLayer = AVPlayerLayer(player: player)
            self.playerLayer?.frame = NSMakeRect(0, 100, self.view.frame.width, self.view.frame.height-100)
            self.playerLayer?.backgroundColor = CGColor.init(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
            self.playerLayer?.videoGravity = AVLayerVideoGravityResizeAspect
            self.view.layer?.addSublayer(self.playerLayer!)
            self.hoverText?.removeFromSuperview()
            self.view.addSubview(self.hoverText!)
        }
    }
    
    func saveFile() {
        self.savePanel?.runModal()
        FileManager.default.createFile(atPath: (self.savePanel?.url?.path)!, contents: self.videoData as Data?, attributes: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if(self.player?.currentItem?.status.rawValue == AVPlayerStatus.readyToPlay.rawValue){
            self.tracker?.maxValue = CMTimeGetSeconds((self.player?.currentItem?.duration)!)
            self.tracker?.doubleValue = 0.0
            self.timeScale = self.player?.currentTime().timescale
            self.timeMeter?.string = "00.00/" + String(CMTimeGetSeconds((self.player?.currentItem?.duration)!))
        }
    }
    
    func glitch() {
        
        if(self.origUrl != nil) {
            
            self.hoverText?.string = "Glitching"
            self.hoverText?.alphaValue = 1.0
            
            DispatchQueue.global(qos: .userInitiated).async {
                if (self.player?.rate != 0.0) {
                    self.player?.pause()
                    self.playButton?.title = "Play"
                    self.timer?.invalidate()
                }
                
                var array: [UInt8] = Array((self.payLoad?.stringValue.utf8)!)
                for j in 0..<array.count {
                    array[j] -= 48;
                    array[j] = UInt8(abs(Int(array[j])))
                }
                let start = self.startSlider?.doubleValue
                let end = self.endSlider?.doubleValue
                
                
//                        let videoData = self.videoData?.subdata(with: NSMakeRange(0, (self.videoData?.length)!)) //glitch v2
//                        var newArray = [UInt8](videoData!)
//                
//                        for i in Int(Double(newArray.count)*(start!/100.0))..<Int(Double(newArray.count)*(end!/100.0)) {
//                            if (newArray[i] == 0x0 && newArray[i+1] == 0x0 && newArray[i+2] == 0x1) {
//                                newArray[i+5000] = 0x0
//                                newArray[i+7000] = 0x0
//                                newArray[i+10000] = 0x0
//                                newArray[i+12000] = 0x0
//                                newArray[i+14000] = 0x0
//                                newArray[i+16000] = 0x0
//                                newArray[i+20000] = 0x0
//                            }
//                        }
//                        self.videoData?.replaceBytes(in: NSRange(location: 0, length: newArray.count), withBytes: newArray)
                
                for i in Int(Double((self.videoData?.length)!)*(start!/100.0))..<Int(Double((self.videoData?.length)!)*(end!/100.0)) {
                    if (i%(1000000 - (self.glitchSlider?.integerValue)!)) == 0 {
                        for j in 0..<array.count {
                            self.videoData?.replaceBytes(in: NSRange(location: i+j, length: 1), withBytes: &array[j])
                        }
                    }
                }
                
                self.videoData?.write(to: (URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp.mp4") as NSURL) as URL, atomically: true)
                let newItem = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp.mp4") as NSURL
                self.player = nil
                self.playerLayer = nil
                self.player = VideoPlayer(url: newItem as URL)
                self.player?.currentItem?.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: nil)
                self.playerLayer = AVPlayerLayer(player: self.player)
                self.playerLayer?.frame = NSMakeRect(0, 100, self.view.frame.width, self.view.frame.height-100)
                self.playerLayer?.backgroundColor = CGColor.init(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
                self.playerLayer?.videoGravity = AVLayerVideoGravityResizeAspect
                self.view.layer?.addSublayer(self.playerLayer!)
                self.hoverText?.alphaValue = 0.0
                self.hoverText?.removeFromSuperview()
                self.view.addSubview(self.hoverText!)
            }
        }
    }
    
    func reset() {
        if(self.origUrl != nil) {
            if (player?.rate != 0.0) {
                self.player?.pause()
                self.playButton?.title = "Play"
                self.timer?.invalidate()
            }
            self.player = nil
            self.playerLayer = nil
            self.player = VideoPlayer(url: self.origUrl! as URL)
            self.player?.currentItem?.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: nil)
            self.playerLayer = AVPlayerLayer(player: player)
            self.playerLayer?.frame = NSMakeRect(0, 100, self.view.frame.width, self.view.frame.height-100)
            self.playerLayer?.backgroundColor = CGColor.init(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
            self.playerLayer?.videoGravity = AVLayerVideoGravityResizeAspect
            self.view.layer?.addSublayer(self.playerLayer!)
            self.hoverText?.removeFromSuperview()
            self.view.addSubview(self.hoverText!)
        }
    }
    
    func playVideo() {
        if (player?.rate != 0.0) {
            self.player?.pause()
            self.playButton?.title = "Play"
            self.timer?.invalidate()
        } else {
            self.player?.play()
            self.playButton?.title = "Pause"
            self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(ViewController.update), userInfo: nil, repeats: true)
        }
    }
    
    func update() {
        self.tracker?.doubleValue = Double(CMTimeGetSeconds((self.player?.currentTime())!))
        self.timeMeter?.string = String(round(100*CMTimeGetSeconds((self.player?.currentTime())!))/100) + "/" + String(round(100*CMTimeGetSeconds((self.player?.currentItem?.duration)!))/100)
    }
    
    func startSliderValueChanged() {
        self.hoverText?.alphaValue = 1.0
        self.hoverText?.fade()
        self.hoverText?.string = String(round(100*(self.startSlider?.doubleValue)!)/100) + " %"
        if((self.startSlider?.doubleValue)! > (self.endSlider?.doubleValue)!) {
            self.endSlider?.doubleValue = (self.startSlider?.doubleValue)!
        }
    }
    
    func endSliderValueChanged() {
        self.hoverText?.alphaValue = 1.0
        self.hoverText?.fade()
        self.hoverText?.string = String(round(100*(self.endSlider?.doubleValue)!)/100) + " %"
        if((self.startSlider?.doubleValue)! > (self.endSlider?.doubleValue)!) {
            self.startSlider?.doubleValue = (self.endSlider?.doubleValue)!
        }
    }
    
    func glitchSliderValueChanged() {
        self.hoverText?.alphaValue = 1.0
        self.hoverText?.fade()
        self.hoverText?.string = String(round(10000*(self.glitchSlider?.doubleValue)! / 999999.0)/100) + " %"
    }
    
    func trackerDrag() {
        self.player?.seek(to:CMTime(seconds: (self.tracker?.doubleValue)!, preferredTimescale: self.timeScale!))
    }
    
    func resize() {
        self.tracker?.frame = NSMakeRect(0, 75, self.view.frame.width-5, 30)
        self.startSlider?.frame = NSMakeRect(650, 55, self.view.frame.width-700, 25)
        self.endSlider?.frame = NSMakeRect(650, 30, self.view.frame.width-700, 25)
        self.playerLayer?.frame = NSMakeRect(0, 100, self.view.frame.width, self.view.frame.height-100)
        self.glitchSlider?.frame = NSMakeRect(650, 5, self.view.frame.width-700, 25)
        self.hoverText?.frame = NSMakeRect(self.view.frame.width/2.0 - 175, self.view.frame.height/2.0 - 50, 350, 100)
    }
    
}

extension ViewController: SliderDelegate {
    func sliderTouchUp(_ sender: Slider) {
        self.player?.seek(to:CMTime(seconds: (self.tracker?.doubleValue)!, preferredTimescale: self.timeScale!))
        if (self.player?.timeControlStatus.rawValue == AVPlayerTimeControlStatus.playing.rawValue) {
            self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(ViewController.update), userInfo: nil, repeats: true)
        }
        NSLog("MOUSE UP")
    }
    func sliderTouchDown(_ sender: Slider) {
        if (self.player?.timeControlStatus.rawValue == AVPlayerTimeControlStatus.playing.rawValue) {
            self.timer?.invalidate()
        }
        NSLog("MOUSE DOWN")
    }
}

extension String {
    // charAt(at:) returns a character at an integer (zero-based) position.
    // example:
    // let str = "hello"
    // var second = str.charAt(at: 1)
    //  -> "e"
    func charAt(at: Int) -> Character {
        let charIndex = self.index(self.startIndex, offsetBy: at)
        return self[charIndex]
    }
}

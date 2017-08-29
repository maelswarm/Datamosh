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
    
    var origUrl : NSURL?
    var videoData : NSMutableData?
    
    var timer : Timer?
    
    override func viewWillAppear() {
        super.viewDidLoad()
        
        self.view.layer?.backgroundColor = CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        self.openPanel = NSOpenPanel()
        self.openPanel?.canChooseFiles = true
        
        self.savePanel = NSSavePanel()
        self.savePanel?.allowedFileTypes = Array(arrayLiteral: "mp4", "mkv", "aiv")
        
        let buttonItems: [String] = ["mp4 (*.mp4)", "mkv (*.mkv)", "aiv (*.aiv)"]
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
        self.intensityText?.backgroundColor = NSColor(cgColor: (self.view.layer?.backgroundColor)!)
        self.view.addSubview(self.intensityText!)
        
        self.glitchSlider = NSSlider(frame: NSMakeRect(650, 5, self.view.frame.width-700, 25))
        self.glitchSlider?.maxValue = 1000000
        self.glitchSlider?.doubleValue = 900000.0
        
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
            ext = "mkv"
        } else if(selectedItemIndex == 2) {
            ext = "aiv"
        }
        
        self.savePanel?.nameFieldStringValue = trimmedName!
        self.savePanel?.allowedFileTypes = Array(arrayLiteral: ext)
    }
    
    func loadFile() {
        self.openPanel?.runModal()
        self.videoData = NSMutableData(contentsOf: (openPanel?.url)!)
        let newItem = AVPlayerItem(url: (openPanel?.url)!)
        self.player = VideoPlayer(playerItem: newItem)
        self.player?.currentItem?.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: nil)
        self.origUrl = openPanel?.url as NSURL?
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = NSMakeRect(0, 100, self.view.frame.width, self.view.frame.height-100)
        playerLayer.backgroundColor = CGColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspect
        self.view.layer?.addSublayer(playerLayer)
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
        
        var array: [UInt8] = Array((self.payLoad?.stringValue.utf8)!)
        for j in 0..<array.count {
            array[j] -= 48;
            array[j] = UInt8(abs(Int(array[j])))
        }
        let start = self.startSlider?.doubleValue
        let end = self.endSlider?.doubleValue

//        
//        let subdata1 = self.videoData?.subdata(with: NSMakeRange(1000000, 9000000))
//        self.videoData?.replaceBytes(in: NSRange(location: 1000000, length: 8000000), withBytes: (subdata1 as! NSData).bytes)
        for i in Int(Double((self.videoData?.length)!)*(start!/100.0))..<Int(Double((self.videoData?.length)!)*(end!/100.0)) {
            if (i%(1000000 - (self.glitchSlider?.integerValue)!)) == 0 {
                for j in 0..<array.count {
                    self.videoData?.replaceBytes(in: NSRange(location: i, length: 1), withBytes: &array[j])
                }
            }
        }
        
        self.videoData?.write(to: (URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp.mp4") as NSURL) as URL, atomically: true)
        let newItem = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp.mp4") as NSURL
        self.player = VideoPlayer(url: newItem as URL)
        self.player?.currentItem?.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: nil)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = NSMakeRect(0, 100, self.view.frame.width, self.view.frame.height-100)
        playerLayer.backgroundColor = CGColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspect
        self.view.layer?.addSublayer(playerLayer)
    }
    
    func reset() {
        self.player = VideoPlayer(url: self.origUrl! as URL)
        self.player?.currentItem?.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: nil)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = NSMakeRect(0, 100, self.view.frame.width, self.view.frame.height-100)
        playerLayer.backgroundColor = CGColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspect
        self.view.layer?.addSublayer(playerLayer)
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
        if((self.startSlider?.doubleValue)! > (self.endSlider?.doubleValue)!) {
            self.endSlider?.doubleValue = (self.startSlider?.doubleValue)!
        }
    }
    
    func endSliderValueChanged() {
        if((self.startSlider?.doubleValue)! > (self.endSlider?.doubleValue)!) {
            self.startSlider?.doubleValue = (self.endSlider?.doubleValue)!
        }
    }
    
    func trackerDrag() {
        self.player?.seek(to:CMTime(seconds: (self.tracker?.doubleValue)!, preferredTimescale: self.timeScale!))
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

//
//  Slider.swift
//  Datamosh
//
//  Created by fairy-slipper on 8/27/17.
//  Copyright © 2017 fairy-slipper. All rights reserved.
//

import Cocoa

protocol SliderDelegate: class {
    func sliderTouchUp(_ sender: Slider)
    func sliderTouchDown(_ sender: Slider)
}

class Slider: NSSlider {
    
    weak var delegate:SliderDelegate?
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func mouseDown(with event: NSEvent) {
        self.delegate?.sliderTouchDown(self);
        super.mouseDown(with: event)
        self.mouseUp(with: event)
    }
    override func mouseUp(with event: NSEvent) {
        self.delegate?.sliderTouchUp(self);
    }
}

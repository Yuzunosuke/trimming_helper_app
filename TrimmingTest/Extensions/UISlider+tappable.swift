//
//  UISlider+tappable.swift
//  TrimmingTest
//
//  Created by 堺雄之介 on 2019/05/05.
//  Copyright © 2019 Yunosuke Sakai. All rights reserved.
//

import Foundation
import UIKit

extension UISlider {
    
    // スライダーのThumb以外をタップしても調節が可能になる
    override open func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        return true
    }
}

//
//  UIImage+SafeCiImage.swift
//  TrimmingTest
//
//  Created by 堺雄之介 on 2019/05/28.
//  Copyright © 2019 Yunosuke Sakai. All rights reserved.
//

import Foundation
import UIKit


extension UIImage {
    var safeCiImage: CIImage? {
        return self.ciImage ?? CIImage(image: self)
    }
    
    var safeCgImage: CGImage? {
        if let cgImge = self.cgImage {
            return cgImge
        }
        if let ciImage = safeCiImage {
            let context = CIContext(options: nil)
            return context.createCGImage(ciImage, from: ciImage.extent)
        }
        return nil
    }
}

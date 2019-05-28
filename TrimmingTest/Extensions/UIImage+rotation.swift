//
//  UIImage+rotation.swift
//  TrimmingTest
//
//  Created by 堺雄之介 on 2019/05/05.
//  Copyright © 2019 Yunosuke Sakai. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    
    func rotatedAndCropped(angle: CGFloat) -> UIImage? {
        guard let ciImage = safeCiImage else {
            return nil
        }
        
        let rotatedImage = ciImage.applyingFilter("CIStraightenFilter", parameters: [kCIInputAngleKey: -angle])
        return UIImage(ciImage: rotatedImage)
    }
    
    
    func rotated(angle: CGFloat, flipVertical: Bool = false, flipHorizontal: Bool = false) -> UIImage? {
        guard let ciImage = safeCiImage else {
            return nil
        }
        
        guard let filter = CIFilter(name: "CIAffineTransform") else {
            return nil
        }
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setDefaults()
        
        let newAngle = angle * CGFloat(-1)
        
        var transform = CATransform3DIdentity
        transform = CATransform3DRotate(transform, CGFloat(newAngle), 0, 0, 1)
        transform = CATransform3DRotate(transform, (flipVertical ? 1.0 : 0) * CGFloat.pi, 0, 1, 0)
        transform = CATransform3DRotate(transform, (flipHorizontal ? 1.0 : 0) * CGFloat.pi, 1, 0, 0)
        
        let affineTransform = CATransform3DGetAffineTransform(transform)
        
        filter.setValue(NSValue(cgAffineTransform: affineTransform), forKey: kCIInputTransformKey)
        
        guard let outputImage = filter.outputImage else {
            return nil
        }
        let context = CIContext(options: [CIContextOption.useSoftwareRenderer: true])
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage)
    }
 
    
}

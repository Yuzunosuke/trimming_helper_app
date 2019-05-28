//
//  UIImage+Trimming.swift
//  TrimmingTest
//
//  Created by 堺雄之介 on 2019/03/27.
//  Copyright © 2019 Yunosuke Sakai. All rights reserved.
//

import UIKit

extension UIImage {
    
    func trimming(to trimmingRect : CGRect , zoomedInOutScale: CGFloat) -> UIImage? {
        var opaque = false
        
        if let cgImage = cgImage {
            switch cgImage.alphaInfo {
            case .noneSkipLast, .noneSkipFirst:
                opaque = true
            default:
                break
            }
        }
        
        
//        let size = CGSize(width: trimmingRect.size.width, height: trimmingRect.size.height)
//
//        UIGraphicsBeginImageContextWithOptions(size, opaque, scale)
        
        
        
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: trimmingRect.size.width/zoomedInOutScale,
                                                      height: trimmingRect.size.height/zoomedInOutScale),
                                               opaque,
                                               scale)
        draw(at: CGPoint(x: -trimmingRect.origin.x/zoomedInOutScale, y: -trimmingRect.origin.y/zoomedInOutScale))
        let trimmedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return trimmedImage
    }
}

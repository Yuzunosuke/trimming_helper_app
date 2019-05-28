//
//  File.swift
//  TrimmingTest
//
//  Created by 堺雄之介 on 2019/04/05.
//  Copyright © 2019 Yunosuke Sakai. All rights reserved.
//

import AVFoundation
import Photos

class PhotoCaptureProcessor: NSObject {
    private(set) var requestedPhotoSettings: AVCapturePhotoSettings
    
    private let willCapturePhotoAnimation: () -> Void
    
    private var completionHandler: (PhotoCaptureProcessor) -> Void
    
    private var trimmingAreaView: UIView
    
    private var imageView: UIView
    
//    private let livePhotoCaptureHandler: (Bool) -> Void
    
    lazy var context = CIContext()
    
    private var photoData: Data?
    
//    private var livePhotoCompanionMovieURL: URL?
    
//    private var portraitEffectsMatteData: Data?
    
    init(with requestedPhotoSettings: AVCapturePhotoSettings,
         willCapturePhotoAnimation: @escaping () -> Void,
         completionHandler: @escaping (PhotoCaptureProcessor) -> Void,
         trimmingAreaView: UIView,
         imageView: UIView) {
        
        self.requestedPhotoSettings = requestedPhotoSettings
        self.willCapturePhotoAnimation = willCapturePhotoAnimation
        self.completionHandler = completionHandler
        self.trimmingAreaView = trimmingAreaView
        self.imageView = imageView
    }
    
    private func didFinish() {
        completionHandler(self)
    }
}


extension PhotoCaptureProcessor: AVCapturePhotoCaptureDelegate {
    
    /// - Tag: WillCapturePhoto
    func photoOutput(_ output: AVCapturePhotoOutput, willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        willCapturePhotoAnimation()
    }
    
    /// - Tag: DidFinishProcessingPhoto
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        if let error = error {
            print("Error capturing photo: \(error)")
        } else {
            photoData = photo.fileDataRepresentation()
            
            let image = UIImage(data: photoData!)
//            let appDelegate = UIApplication.shared.delegate as! AppDelegate
//            appDelegate.photoLibraryImage = image
            
            // 以下のトリミングうまくいかない
            // zoomedInOutScaleの値がうまくいかない？
            // もしくはpreviewLayerのサイズが合ってないかも？
            let screenWidth = imageView.frame.width * 10 / 9

            let cropRect: CGRect = CGRect(x: trimmingAreaView.frame.origin.x - imageView.frame.origin.x,
                                          y: trimmingAreaView.frame.origin.y - imageView.frame.origin.y,
                                          width: trimmingAreaView.frame.width,
                                          height: trimmingAreaView.frame.height)

            print("### cropの範囲", cropRect)
            print("### gridViewの範囲", trimmingAreaView.frame)

            if let trimmedImage = image?.trimming(to: cropRect, zoomedInOutScale: screenWidth / image!.size.width)  {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.photoLibraryImage = trimmedImage
            }
        }
    }
        
        // ポートレートモードの処理が入る
    
    
    /// - Tag: DidfinishRecordingLive
    // 省略
    
    /// - Tag: DidFinishProccessingLive
    // 省略
    
    /// - Tag: DidFinishCapture
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {
        didFinish()
    }
}

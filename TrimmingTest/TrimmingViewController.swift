//
//  TrimmingViewController.swift
//  TrimmingTest
//
//  Created by 堺雄之介 on 2019/03/26.
//  Copyright © 2019 Yunosuke Sakai. All rights reserved.
//

import UIKit
import Foundation

class TrimmingViewController: UIViewController {
    
    
    // MARK: Property
    
    var image: UIImage!
    let gridView = UIImageView()
    var imageView = UIImageView()
    var scaleZoomedInOut: CGFloat = 1.0
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    
    
    // MARK: override function
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
        configureNavigationBar()
        createGridView()
        
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        image = appDelegate.photoLibraryImage
//        createImageView(sourceImage: image)
        
        setUpPinchInOut()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        image = appDelegate.photoLibraryImage
        createImageView(sourceImage: image)
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let aTouch: UITouch = touches.first!
        
        let location = aTouch.location(in: gridView)
        
        let previousLocation = aTouch.previousLocation(in: gridView)
        
        let deltaX = location.x - previousLocation.x
        let deltaY = location.y - previousLocation.y
        
        imageView.frame.origin.x += deltaX
        imageView.frame.origin.y += deltaY
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        moveImageViewToFillBlank()
        
    }
    
    
    
    // MARK: private function
    
    // Viewそのものの設定
    private func configureView() {
        view.backgroundColor = UIColor(red: 23/255, green: 23/255, blue: 23/255, alpha: 1)
    }
    
    
    // NavigationBarの設定
    private func configureNavigationBar() {
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 23/255, green: 23/255, blue: 23/255, alpha: 1)
        self.navigationController?.navigationBar.tintColor = UIColor(red: 233/255, green: 119/255, blue: 113/255, alpha: 1)
        self.navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor(red: 190/255, green: 190/255, blue: 190/255, alpha: 1)
        ]
    }
    
    
    // gridViewの作成
    private func createGridView() {
        gridView.image = UIImage(named: "goldenSpiral")
        
        view.addSubview(gridView)
        
        gridView.translatesAutoresizingMaskIntoConstraints = false
        gridView.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        gridView.heightAnchor.constraint(equalToConstant: view.frame.width / 1.618).isActive = true
        gridView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        gridView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    
    // ImageViewの作成
    private func createImageView(sourceImage: UIImage) {
        
        imageView = UIImageView(image: sourceImage)
        
        let imageWidth = sourceImage.size.width
        let imageHeight = sourceImage.size.height
        let screenWidth = view.frame.width
        let screenHeight = view.frame.height
        
        if scaleZoomedInOut == 1.0 {
            if imageWidth > screenWidth {
                scaleZoomedInOut = screenWidth / imageWidth
            }
        }
        
        let frame: CGRect = CGRect(x: 0, y: 0, width: scaleZoomedInOut * imageWidth, height: scaleZoomedInOut * imageHeight)
        
        imageView.frame = frame
        imageView.center = CGPoint(x: screenWidth / 2, y: screenHeight / 2)
        
        view.addSubview(imageView)
        view.sendSubviewToBack(imageView)
        
    }
    
    
    // 切り取る範囲と座標を決める
    private func makeTrimmingRect(targetImageView: UIImageView, trimmingAreaView: UIView) -> CGRect?{
        
        var width = CGFloat()
        var height = CGFloat()
        var trimmingX = CGFloat()
        var trimmingY = CGFloat()
        
        let deltaX = targetImageView.frame.origin.x
        let deltaY = targetImageView.frame.origin.y
        
        // trimmingRectの大きさを決定
        width = trimmingAreaView.frame.size.width
        height = trimmingAreaView.frame.size.height

        //trimmingRectの座標を決定
        trimmingX = -deltaX
        trimmingY = trimmingAreaView.frame.origin.y - deltaY
        
        return CGRect(x: trimmingX, y: trimmingY, width: width, height: height)
    }
    
    
    private func setUpPinchInOut() {
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchAction(gesture:)))
        pinchGesture.delegate = self as? UIGestureRecognizerDelegate
        
        self.gridView.isUserInteractionEnabled = true
        self.gridView.isMultipleTouchEnabled = true
        
        self.gridView.addGestureRecognizer(pinchGesture)
    }
    
    
    private func updateImageView(){
        imageView.removeFromSuperview()
        createImageView(sourceImage: image)
    }
    
    
    // gridView内に空白がある時にそれをなくすためにimageViewを動かす
    private func moveImageViewToFillBlank() {
        // 上が余ってる時
        if self.imageView.frame.origin.y - self.gridView.frame.origin.y > 0 {
            UIView.animate(withDuration: 0.3) {
                self.imageView.frame.origin.y = self.gridView.frame.origin.y
            }
        }
        
        // 左が余ってる時
        if self.imageView.frame.origin.x - self.gridView.frame.origin.x > 0 {
            UIView.animate(withDuration: 0.3) {
                self.imageView.frame.origin.x = self.gridView.frame.origin.x
            }
        }
        
        // 下が余ってる時
        if self.gridView.frame.origin.y + self.gridView.frame.height - self.imageView.frame.maxY > 0 {
            UIView.animate(withDuration: 0.3) {
                self.imageView.frame.origin.y += self.gridView.frame.maxY - self.imageView.frame.maxY
            }
        }
        
        // 右が余ってる時
        if self.gridView.frame.width - self.imageView.frame.maxX > 0 {
            UIView.animate(withDuration: 0.3) {
                self.imageView.frame.origin.x += self.gridView.frame.maxX - self.imageView.frame.maxX
            }
        }
    }
    
    
    // MARK: Action
    
    @IBAction func savePhotoButton(_ sender: UIBarButtonItem) {
        if let trimmingRect = makeTrimmingRect(targetImageView: imageView, trimmingAreaView: gridView) {
            image = image.trimming(to: trimmingRect, zoomedInOutScale: scaleZoomedInOut)

            
            let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "previewNavigationContoller") as! UINavigationController
            let vc = nextVC.topViewController as! PreviewViewController
            vc.imageView.image = image
            self.present(nextVC, animated: true)
            imageView.removeFromSuperview()
        }
    }
    
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    
    var pinchCenter: CGPoint!
    var touchPoint1: CGPoint!
    var touchPoint2: CGPoint!
    let maxScale: CGFloat = 1
    var imageCenterWhenPinchStarted: CGPoint!
    
    @objc func pinchAction(gesture: UIPinchGestureRecognizer) {
        
        if gesture.state == .began {
            // ピンチを開始したときの画像の中心点を保存しておく
            imageCenterWhenPinchStarted = imageView.center
            touchPoint1 = gesture.location(ofTouch: 0, in: self.view)
            touchPoint2 = gesture.location(ofTouch: 1, in: self.view)
            
            // 指の中間点を求めて保存しておく
            // UIGestureRecognizerState.Changedで毎回求めた場合、ピンチ状態で片方の指だけ動かしたときに中心点がずれておかしな位置でズームされるため
            pinchCenter = CGPoint(x: (touchPoint1.x + touchPoint2.x) / 2, y: (touchPoint1.y + touchPoint2.y) / 2)
            
        } else if gesture.state == .changed {
            // ピンチジェスチャー・変更中
            var pinchScale :  CGFloat// ピンチを開始してからの拡大率。差分ではない
            if gesture.scale > 1 {
                pinchScale = 1 + gesture.scale/100
            }else{
                pinchScale = gesture.scale
            }
            if pinchScale * self.imageView.frame.width < gridView.frame.width {
                pinchScale = gridView.frame.width / self.imageView.frame.width
            }
            scaleZoomedInOut *= pinchScale
            
            // ピンチした位置を中心としてズーム（イン/アウト）するように、画像の中心位置をずらす
            let newCenter = CGPoint(x: imageCenterWhenPinchStarted.x - ((pinchCenter.x - imageCenterWhenPinchStarted.x) * pinchScale - (pinchCenter.x - imageCenterWhenPinchStarted.x)),
                                    y: imageCenterWhenPinchStarted.y - ((pinchCenter.y - imageCenterWhenPinchStarted.y) * pinchScale - (pinchCenter.y - imageCenterWhenPinchStarted.y)))
            self.imageView.frame.size = CGSize(width: pinchScale * self.imageView.frame.width, height: pinchScale * self.imageView.frame.height)
            imageView.center = newCenter
            
        } else if gesture.state == .ended {
            moveImageViewToFillBlank()
        }
        
    }
    
    
}

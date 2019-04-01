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
    @IBOutlet weak var gridCollectionView: UICollectionView!
    var iconNameArray = ["goldenSpiral", "goldenSpiralReverse", "goldenGrid", "3divisionGrid", "goldenDiagonal", "centerGrid", "diagonalGrid"]
    var iconImageNameArray = ["goldenSpiralIcon", "goldenSpiralReverseIcon", "goldenGridIcon", "3divisionGridIcon", "goldenDiagonalIcon", "centerGridIcon", "diagonalGridIcon"]
    var iconImageArray = [UIImage]()
    var selectedIconName = "goldenSpiral"
    var gridViewConstraints: [NSLayoutConstraint] = []
    var gridViewAngle = 0 {
        didSet {
            if gridViewAngle == 360 {
                gridViewAngle = 0
            }
        }
    }
    
    
    
    // MARK: override function
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureNavigationBar()
        createGridView(imageName: iconNameArray[0])
        configureCollectionView()
        configureIconArray()
        
        setUpPinchInOut()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        // AppDelegateからイメージをとりImageViewに入れる
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        image = appDelegate.photoLibraryImage
        createImageView(sourceImage: image)
    }
    
    
    // 画面をタッチするとその間写真が動かせる
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let aTouch: UITouch = touches.first!
        
        let location = aTouch.location(in: gridView)
        
        let previousLocation = aTouch.previousLocation(in: gridView)
        
        let deltaX = location.x - previousLocation.x
        let deltaY = location.y - previousLocation.y
        
        imageView.frame.origin.x += deltaX
        imageView.frame.origin.y += deltaY
    }
    
    
    // 画面へのタッチを終えると画像の位置判定を行い、必要なら空白を埋める動きをする
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        moveImageViewToFillBlank()
    }
    
    
    
    // MARK: private function
    
    // NavigationBarの設定
    private func configureNavigationBar() {
        self.navigationController?.navigationBar.tintColor = UIColor(red: 233/255, green: 119/255, blue: 113/255, alpha: 1)
        self.navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 1)
        ]
    }
    
    
    // gridViewの作成
    private func createGridView(imageName: String) {
        
        var gridImageName = ""
        if gridViewAngle == 0 {
            gridImageName = imageName
        } else {
            gridImageName = imageName + String(gridViewAngle)
        }
        
        gridView.image = UIImage(named: gridImageName)
        
        view.addSubview(gridView)
        
        gridView.translatesAutoresizingMaskIntoConstraints = false
        configureGridViewConstraints()
        
        gridView.contentMode = .scaleAspectFit
    }
    
    
    // gridViewの制約の設定
    private func configureGridViewConstraints() {
        NSLayoutConstraint.deactivate(gridViewConstraints)
        gridViewConstraints.removeAll()
        
        if gridViewAngle == 0 || gridViewAngle == 180 {
            gridViewConstraints = [
                gridView.heightAnchor.constraint(equalToConstant: view.frame.width * 0.9 / 1.5),
                gridView.widthAnchor.constraint(equalToConstant: view.frame.width * 0.9)
            ]
        }
        
        if gridViewAngle == 90 || gridViewAngle == 270 {
            gridViewConstraints = [
                gridView.heightAnchor.constraint(equalToConstant: view.frame.width * 0.9 * 1.5),
                gridView.widthAnchor.constraint(equalToConstant: view.frame.width * 0.9)
            ]
        }
        
        gridViewConstraints.append(gridView.centerXAnchor.constraint(equalTo: view.centerXAnchor))
        gridViewConstraints.append(gridView.centerYAnchor.constraint(equalTo: view.centerYAnchor))
        
        NSLayoutConstraint.activate(gridViewConstraints)
    }
    
    
    // gridViewの更新
    private func updateGridView(iconName: String){
        gridView.removeFromSuperview()
        createGridView(imageName: iconName)
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
    
    
    // ImageViewの更新
    private func updateImageView(){
        imageView.removeFromSuperview()
        createImageView(sourceImage: image)
    }
    
    
    // gridViewのアイコンを表示するcollectionViewの設定
    private func configureCollectionView() {
        gridCollectionView.register(GridCollectionViewCell.self, forCellWithReuseIdentifier: "GridCollectionViewCell")
        
        gridCollectionView.delegate = self
        gridCollectionView.dataSource = self
        
        gridCollectionView.backgroundColor = UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 1)
        
        view.bringSubviewToFront(gridCollectionView)
        
        gridCollectionView.translatesAutoresizingMaskIntoConstraints = false
        gridCollectionView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        gridCollectionView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        gridCollectionView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        gridCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
    
    
    // gridのアイコンの画像を格納する配列の設定
    private func configureIconArray() {
        for iconName in iconImageNameArray {
            guard let gridImage = UIImage(named: iconName) else { return }
            iconImageArray.append(gridImage)
        }
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
        trimmingX = trimmingAreaView.frame.origin.x - deltaX
        trimmingY = trimmingAreaView.frame.origin.y - deltaY
        
        return CGRect(x: trimmingX, y: trimmingY, width: width, height: height)
    }
    
    
    // ピンチジェスチャーの設定
    private func setUpPinchInOut() {
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchAction(gesture:)))
        pinchGesture.delegate = self as? UIGestureRecognizerDelegate
        
        self.gridView.isUserInteractionEnabled = true
        self.gridView.isMultipleTouchEnabled = true
        
        self.gridView.addGestureRecognizer(pinchGesture)
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
        if self.gridView.frame.origin.x + self.gridView.frame.width - self.imageView.frame.maxX > 0 {
            UIView.animate(withDuration: 0.3) {
                self.imageView.frame.origin.x += self.gridView.frame.maxX - self.imageView.frame.maxX
            }
        }
    }
    
    
    // MARK: Action
    
    // Trimボタンが押されたらトリミングした画像をPreviewViewControllerに送る
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
    
    
    // cancelボタンの動き
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



extension TrimmingViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return iconImageNameArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GridCollectionViewCell", for: indexPath) as! GridCollectionViewCell
        
        cell.configureConstraints()
        cell.iconImageView.image = iconImageArray[indexPath.item]
        
        return cell
    }
    
    
}


extension TrimmingViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if selectedIconName == iconNameArray[indexPath.item] {  // 複数回同じアイコンをタップした時
            gridViewAngle += 90
            updateGridView(iconName: selectedIconName)
        } else {
            selectedIconName = iconNameArray[indexPath.item]
            updateGridView(iconName: selectedIconName)
        }

    }
    
}

//
//  CameraViewController.swift
//  TrimmingTest
//
//  Created by 堺雄之介 on 2019/03/27.
//  Copyright © 2019 Yunosuke Sakai. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {
    
    
    // MARK: property
    
    var captureSession = AVCaptureSession()
    var mainCamera: AVCaptureDevice?
    var innerCamera: AVCaptureDevice?
    var currentDevice: AVCaptureDevice?
    var photoOutput: AVCapturePhotoOutput?
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    
    @IBOutlet weak var shutterButton: UIButton!
    
    @IBOutlet weak var gridCollectionView: UICollectionView!
    
    var iconNameArray = ["goldenSpiral", "goldenSpiralReverse", "goldenGrid", "3divisionGrid", "goldenDiagonal", "centerGrid", "diagonalGrid"]
    var iconImageNameArray = ["goldenSpiralIcon", "goldenSpiralReverseIcon", "goldenGridIcon", "3divisionGridIcon", "goldenDiagonalIcon", "centerGridIcon", "diagonalGridIcon"]
    var iconImageArray = [UIImage]()
    var selectedIconName = "goldenSpiral"
    
    let gridView = UIImageView()
    var gridViewAngle = 90 {
        didSet {
            if gridViewAngle == 450 {
                gridViewAngle = 90
            }
        }
    }
    
    
    // MARK: override function
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCaptureSession()
        setupCameraDevice()
        setupInputOutput()
        setupPreviewLayer()
        
        captureSession.startRunning()
        
        configureNavigationBar()
        configureShutterButton()
        configureCollectionView()
        configureIconArray()
        createGridView(imageName: iconNameArray[0])
        
        
        let action = #selector(orientationChanged(_:))
        let center = NotificationCenter.default
        let name = UIDevice.orientationDidChangeNotification
        center.addObserver(self, selector: action, name: name, object: nil)

    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK: private function
    
    private func setupCaptureSession() {
        captureSession.sessionPreset = .photo
    }
    
    
    private func setupCameraDevice() {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera],
                                                                      mediaType: .video,
                                                                      position: AVCaptureDevice.Position.unspecified)
        
        let devices = deviceDiscoverySession.devices
        
        for device in devices {
            if device.position == .back {
                mainCamera = device
            } else if device.position == .front {
                innerCamera = device
            }
        }
        
        currentDevice = mainCamera
    }
    
    
    private func setupInputOutput() {
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentDevice!)
            
            if captureSession.canAddInput(captureDeviceInput) {
                captureSession.addInput(captureDeviceInput)
            }
            
            photoOutput = AVCapturePhotoOutput()
            
            photoOutput!.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])], completionHandler: nil)
            
            if captureSession.canAddOutput(photoOutput!) {
                captureSession.addOutput(photoOutput!)
            }
            
        } catch {
            print(error)
        }
    }
    
    
    private func setupPreviewLayer() {
        self.cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        self.cameraPreviewLayer?.frame = CGRect(x: 0, y: 0, width: view.frame.width * 0.9, height: view.frame.width * 0.9 * 1.5).with(center: CGPoint(x: self.view.center.x, y: self.view.center.y))
        self.view.layer.insertSublayer(self.cameraPreviewLayer!, at: 0)
        
    }
    
    
    private func configureNavigationBar() {
        self.navigationController?.navigationBar.tintColor = UIColor(red: 233/255, green: 119/255, blue: 113/255, alpha: 1)
        self.navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 1)
        ]
    }
    
    
    private func configureShutterButton() {
        shutterButton.clipsToBounds = true
        shutterButton.layer.borderColor = UIColor(red: 23/255, green: 23/255, blue: 23/255, alpha: 1).cgColor
        shutterButton.layer.borderWidth = 3
        shutterButton.layer.cornerRadius = 30
        
        shutterButton.translatesAutoresizingMaskIntoConstraints = false
        shutterButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        shutterButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        shutterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        shutterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8).isActive = true
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
        gridCollectionView.leftAnchor.constraint(equalTo: shutterButton.rightAnchor, constant: 8).isActive = true
        gridCollectionView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -view.frame.width * 0.05).isActive = true
        gridCollectionView.bottomAnchor.constraint(equalTo: shutterButton.bottomAnchor).isActive = true
//        gridCollectionView.layer.borderColor = UIColor(red: 23/255, green: 23/255, blue: 23/255, alpha: 1).cgColor
//        gridCollectionView.layer.borderWidth = 1
    }
    
    
    private func configureIconArray() {
        for iconName in iconImageNameArray {
            guard let gridImage = UIImage(named: iconName) else { return }
            iconImageArray.append(gridImage)
        }
    }
    
    
    // gridViewの作成
    private func createGridView(imageName: String) {

        let gridImageName = imageName + String(gridViewAngle)
        
        gridView.image = UIImage(named: gridImageName)
        
        view.addSubview(gridView)
        
        gridView.translatesAutoresizingMaskIntoConstraints = false
        gridView.widthAnchor.constraint(equalToConstant: view.frame.width * 0.9).isActive = true
        gridView.heightAnchor.constraint(equalToConstant: view.frame.width * 0.9 * 1.5).isActive = true
        gridView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        gridView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        gridView.contentMode = .scaleAspectFit
    }
    
    
    // gridViewの更新
    private func updateGridView(iconName: String){
        gridView.removeFromSuperview()
        createGridView(imageName: iconName)
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
    
    
    
    // MARK: Action
    
    @IBAction func shutterButtonTapped(_ sender: UIButton) {
        let settings = AVCapturePhotoSettings()
        
        settings.isAutoStillImageStabilizationEnabled = true
        
        self.photoOutput?.capturePhoto(with: settings, delegate: self as AVCapturePhotoCaptureDelegate)
    }
    
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @objc func orientationChanged(_ notification: Notification) {
        print("### changed")
        let device = UIDevice.current
        if device.orientation.isLandscape {
            self.cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.landscapeLeft
        } else {
            self.cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        }
    }
    

}



extension CameraViewController: AVCapturePhotoCaptureDelegate {
    
    // 撮影完了時に呼ばれる処理
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation() {
            let image = UIImage(data: imageData)
//            var trimmedImage = UIImage()
            
            // うまくいかない
//            let imageViewScale = view.frame.height / gridView.frame.height
            
            let cropRect: CGRect = CGRect(x: gridView.frame.origin.x - cameraPreviewLayer!.frame.origin.x,
                                          y: gridView.frame.origin.y - cameraPreviewLayer!.frame.origin.y,
                                          width: gridView.frame.width,
                                          height: gridView.frame.height)
            
            print("### cropの範囲", cropRect)
            print("### gridViewの範囲", gridView.frame)
            
//            if let trimmedImage = image?.cgImage?.cropping(to: cropRect) {
//
//                print("### ", trimmedImage)
//                let appDelegate = UIApplication.shared.delegate as! AppDelegate
//                appDelegate.photoLibraryImage = UIImage(cgImage: trimmedImage, scale: 1.0, orientation: image!.imageOrientation)
//
//                let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "trimmingNavigationContoller") as! UINavigationController
//                self.present(nextVC, animated: true)
//            }
            
            if let trimmedImage = image?.trimming(to: cropRect, zoomedInOutScale: 1.0) {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.photoLibraryImage = trimmedImage
                
                let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "trimmingNavigationContoller") as! UINavigationController
                self.present(nextVC, animated: true)
            }
            
            
            // ここまで
            
            
            // これならうまく行くけど比率はおかしい
//            let appDelegate = UIApplication.shared.delegate as! AppDelegate
//            appDelegate.photoLibraryImage = image
//
//            let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "trimmingNavigationContoller") as! UINavigationController
//            self.present(nextVC, animated: true)

        }
    }
    
}


extension CameraViewController: UICollectionViewDataSource {
    
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


extension CameraViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
     
        if selectedIconName == iconNameArray[indexPath.item] {  // 複数回同じアイコンをタップした時
            gridViewAngle += 180
            updateGridView(iconName: selectedIconName)
        } else {
            selectedIconName = iconNameArray[indexPath.item]
            updateGridView(iconName: selectedIconName)
        }
        
    }
    
}

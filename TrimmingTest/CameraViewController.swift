//
//  CameraViewController.swift
//  TrimmingTest
//
//  Created by 堺雄之介 on 2019/04/05.
//  Copyright © 2019 Yunosuke Sakai. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class CameraViewController: UIViewController {
    
    
    // MARK: View Controller Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        shutterButton.isEnabled = false
        
        previewView.session = session
        
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            break
        case .notDetermined:
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: .video) { (granted) in
                if !granted {
                    self.setupResult = .notAuthorized
                }
                self.sessionQueue.resume()
            }
        default:
            setupResult = .notAuthorized
        }
        
        sessionQueue.async {
            self.configureSession()
        }
        
        configureNavigationBar()
        configureShutterButton()
        configureCollectionView()
        configureIconArray()
        createGridView(imageName: iconNameArray[0])
        configurePreviewView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        sessionQueue.async {
            
            switch self.setupResult {
            case .success:
                self.addObservers()
                self.session.startRunning()
                self.isSessionRunning = self.session.isRunning
                
            case .notAuthorized:
                DispatchQueue.main.async {
                    let changePrivacySetting = "AppNAME doesn't have permission to use the camera, please change privacy settings"
                    let message = NSLocalizedString(changePrivacySetting, comment: "カメラアクセスを拒否した時のアラートメッセージ")
                    let alertController = UIAlertController(title: "アプリ名", message: message, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK button"),
                                                            style: .cancel,
                                                            handler: nil))
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("Settings", comment: "button to open settings"),
                                                            style: .default,
                                                            handler: { _ in
                                                                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!,
                                                                                          options: [:],
                                                                                          completionHandler: nil)
                    }))
                    
                    self.present(alertController, animated: true, completion: nil)
                }
                
            case .configurationFailed:
                DispatchQueue.main.async {
                    let alertMsg = "Alert message when something goes wrong during capture session configuration"
                    let message = NSLocalizedString("Unable to capture media", comment: alertMsg)
                    let alertController = UIAlertController(title: "アプリ名", message: message, preferredStyle: .alert)
                    
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK button"),
                                                            style: .cancel,
                                                            handler: nil))
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            }
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        sessionQueue.async {
            if self.setupResult == .success {
                self.session.stopRunning()
                self.isSessionRunning = self.session.isRunning
                self.removeObservers()
            }
        }
        
        super.viewWillDisappear(animated)
    }
    
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
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
    
    private func configurePreviewView() {
        previewView.translatesAutoresizingMaskIntoConstraints = false
        previewView.widthAnchor.constraint(equalToConstant: view.frame.width * 0.9).isActive = true
        previewView.heightAnchor.constraint(equalToConstant: view.frame.width * 0.9 * 1.5).isActive = true
        previewView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        previewView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        previewView.videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
    }
    
    
    let gridView = UIImageView()
    var gridViewAngle = 90 {
        didSet {
            if gridViewAngle == 450 {
                gridViewAngle = 90
            }
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

    
    
    
    @IBOutlet weak var gridCollectionView: UICollectionView!
    var iconNameArray = ["goldenSpiral", "goldenSpiralReverse", "goldenGrid", "3divisionGrid", "goldenDiagonal", "centerGrid", "diagonalGrid"]
    var iconImageNameArray = ["goldenSpiralIcon", "goldenSpiralReverseIcon", "goldenGridIcon", "3divisionGridIcon", "goldenDiagonalIcon", "centerGridIcon", "diagonalGridIcon"]
    var iconImageArray = [UIImage]()
    var selectedIconName = "goldenSpiral"
    
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
    
    
    // MARK: session management
    
    private enum SessionSetupResult {
        case success
        case notAuthorized
        case configurationFailed
    }
    
    private let session = AVCaptureSession()
    private var isSessionRunning = false
    
    private let sessionQueue = DispatchQueue(label: "session queue")
    
    private var setupResult: SessionSetupResult = .success
    
    @objc dynamic var videoDeviceInput: AVCaptureDeviceInput!
    
    @IBOutlet private weak var previewView: PreviewView!
    
    
    private func configureSession() {
        
        if setupResult != .success {
            return
        }
        
        session.beginConfiguration()
        
        session.sessionPreset = .photo
        
        // Add video input
        do {
            var defaultVideoDevice: AVCaptureDevice?
            
            // デュアルカメラが利用可能であればそれを使う
            if let dualCameraDevice = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
                defaultVideoDevice = dualCameraDevice
            } else if let backCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
                // デュアルカメラが利用可能でなければ普通のカメラ
                defaultVideoDevice = backCameraDevice
            } else if let frontCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
                // 背面カメラが利用可能でなければインカメ
                defaultVideoDevice = frontCameraDevice
            }
            
            // 使えるカメラがなければセッションの設定失敗
            guard let videoDevice = defaultVideoDevice else {
                print("default video device is unavailable")
                
                setupResult = .configurationFailed
                session.commitConfiguration()
                return
            }
            let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
            
            
            if session.canAddInput(videoDeviceInput) {
                session.addInput(videoDeviceInput)
                self.videoDeviceInput = videoDeviceInput
                
                DispatchQueue.main.async {
                    let statusBarOrientation = UIApplication.shared.statusBarOrientation
                    var initialVideoOrientation: AVCaptureVideoOrientation = .portrait
                    
                    if statusBarOrientation != .unknown {
                        if let videoOrientation = AVCaptureVideoOrientation(interfaceOrientation: statusBarOrientation) {
                            initialVideoOrientation = videoOrientation
                        }
                    }
                    
                    self.previewView.videoPreviewLayer.connection?.videoOrientation = initialVideoOrientation
                }
            } else {
                print("Couldn't add video device input to the session.")
                
                setupResult = .configurationFailed
                session.commitConfiguration()
                return
            }
            
        } catch {
            print("couldn't create video device input: \(error)")
            
            setupResult = .configurationFailed
            session.commitConfiguration()
            return
        }
        
        
        // Add photo output
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
            
            photoOutput.isHighResolutionCaptureEnabled = true
            
            // Livephoto、被写界深度コントロールは保留（ボタン配置考えてないし、すくなくともライブフォトはアプリ自体に不要）
            photoOutput.isLivePhotoCaptureEnabled = false
            photoOutput.isDepthDataDeliveryEnabled = false
            photoOutput.isPortraitEffectsMatteDeliveryEnabled = false
        } else {
            print("Couldn't add photo output to the session")
            
            setupResult = .configurationFailed
            session.commitConfiguration()
            return
        }
        
        session.commitConfiguration()
        
    }
    
    
    
    
    // MARK: Capturing Photos
    
    private let photoOutput = AVCapturePhotoOutput()
    
    private var inProgressPhotoCaptureDelegates = [Int64: PhotoCaptureProcessor]()
    
    @IBOutlet weak var shutterButton: UIButton!
    
    /// - Tag: CapturePhoto
    @IBAction func capturePhoto(_ sender: UIButton) {
        
        // session queueに入る前にmain queueでpreview layerのorientationを取得する
        let videoPreviewLayerOrientation = previewView.videoPreviewLayer.connection?.videoOrientation
        
        sessionQueue.async {
            
            if let photoOutputConnection = self.photoOutput.connection(with: .video) {
                photoOutputConnection.videoOrientation = videoPreviewLayerOrientation!
            }
            
            let photoSettings = AVCapturePhotoSettings()
            
            // HEIFがサポートされているならば使用
//            if self.photoOutput.availablePhotoCodecTypes.contains(.hevc) {
//                photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecKey.hevc])
//            }
            
            // オートフラッシュの有効化
            if self.videoDeviceInput.device.isFlashAvailable {
                photoSettings.flashMode = .auto
            }
            
            // HDR写真の有効化
            photoSettings.isHighResolutionPhotoEnabled = true
            
            
            if !photoSettings.__availablePreviewPhotoPixelFormatTypes.isEmpty {
                photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: photoSettings.__availablePreviewPhotoPixelFormatTypes.first!]
            }
            
            // ライブフォト、深度調整、ポートレートモードの設定が入る
            // 省略
            
            let photoCaptureProcessor = PhotoCaptureProcessor(with: photoSettings, willCapturePhotoAnimation: {
                // Flash the screen to signal that camera took a photo
                DispatchQueue.main.async {
                    self.previewView.videoPreviewLayer.opacity = 0
                    UIView.animate(withDuration: 0.25, animations: {
                        self.previewView.videoPreviewLayer.opacity = 1
                    })
                }
            }, completionHandler: { photoCaptureProcessor in
                
                DispatchQueue.main.async {
                    let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "trimmingNavigationContoller") as! UINavigationController
                    self.present(nextVC, animated: true)
                }
                
                self.sessionQueue.async {
                    self.inProgressPhotoCaptureDelegates[photoCaptureProcessor.requestedPhotoSettings.uniqueID] = nil
                }
            }, trimmingAreaView: self.gridView, imageView: self.previewView
            )
            
            self.inProgressPhotoCaptureDelegates[photoCaptureProcessor.requestedPhotoSettings.uniqueID] = photoCaptureProcessor
            self.photoOutput.capturePhoto(with: photoSettings, delegate: photoCaptureProcessor)
        }

    }
    
    
    
    // MARK: KVO and Notifications
    
    private var keyValueObservations = [NSKeyValueObservation]()
    
    /// - Tag: ObserveInterruption
    private func addObservers() {
        let keyValueObservation = session.observe(\.isRunning, options: .new) { (_, change) in
            guard let isSessionRunning = change.newValue else { return }
            // ライブフォト、深度調整、ポートレートモードの設定が入る→省略
            
            DispatchQueue.main.async {
                self.shutterButton.isEnabled = isSessionRunning
            }
        }
        keyValueObservations.append(keyValueObservation)
        
//        let systemPressuereStateObservation = observe(\.videoDeviceInput.device.systemPressureState, options: .new) { (_, change) in
//            guard let systemPressureState = change.newValue else { return }
//            self.setRecommendedFrameRateRangeForPressureState(systemPressureState: systemPressureState)
//        }
//        keyValueObservations.append(contentsOf: systemPressuereStateObservation)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(subjectAreaDidChange),
                                               name: .AVCaptureDeviceSubjectAreaDidChange,
                                               object: videoDeviceInput.device)
        
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(sessionRuntimeError),
//                                               name: .AVCaptureSessionRuntimeError,
//                                               object: session)
//
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(sessionWasInterrupted),
//                                               name: .AVCaptureSessionWasInterrupted,
//                                               object: session)
//
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(sessionInterruptionEnded),
//                                               name: .AVCaptureSessionInterruptionEnded,
//                                               object: session)
    }
    
    
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self)
        
        for keyValueObservation in keyValueObservations {
            keyValueObservation.invalidate()
        }
        keyValueObservations.removeAll()
    }
    
    
    @objc
    func subjectAreaDidChange(notification: NSNotification) {
        let devicePoint = CGPoint(x: 0.5, y: 0.5)
        
        focus(with: .continuousAutoFocus, exposureMode: .continuousAutoExposure, at: devicePoint, monitorSubjectAreaChange: false)
    }
    

    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction private func focusAndExposeTap(_ gestureRecognizer: UITapGestureRecognizer) {
        let devicePoint = previewView.videoPreviewLayer.captureDevicePointConverted(fromLayerPoint: gestureRecognizer.location(in: gestureRecognizer.view))
        focus(with: .autoFocus, exposureMode: .autoExpose, at: devicePoint, monitorSubjectAreaChange: true)
    }
    
    private func focus(with focusMode: AVCaptureDevice.FocusMode,
                       exposureMode: AVCaptureDevice.ExposureMode,
                       at devicePoint: CGPoint,
                       monitorSubjectAreaChange: Bool) {
        
        sessionQueue.async {
            let device = self.videoDeviceInput.device
            
            do {
                try device.lockForConfiguration()
                
                if device.isFocusPointOfInterestSupported && device.isFocusModeSupported(focusMode) {
                    device.focusPointOfInterest = devicePoint
                    device.focusMode = focusMode
                }
                
                if device.isExposurePointOfInterestSupported && device.isExposureModeSupported(exposureMode) {
                    device.exposurePointOfInterest = devicePoint
                    device.exposureMode = exposureMode
                }
                
                device.isSubjectAreaChangeMonitoringEnabled = monitorSubjectAreaChange
                device.unlockForConfiguration()
                
            } catch {
                print("coudln't lock device for configuration: \(error)")
            }
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

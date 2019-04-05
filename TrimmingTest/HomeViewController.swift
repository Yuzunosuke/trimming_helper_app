//
//  ViewController.swift
//  TrimmingTest
//
//  Created by 堺雄之介 on 2019/03/26.
//  Copyright © 2019 Yunosuke Sakai. All rights reserved.
//

import UIKit
import Photos

class HomeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: property
    
    @IBOutlet weak var callPhotoLibraryButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.setNeedsStatusBarAppearanceUpdate()
        configureNavigationBar()
        configureCallPhotoLibraryButton()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //    MARK: private function
    
    private func configureCallPhotoLibraryButton() {
        callPhotoLibraryButton.translatesAutoresizingMaskIntoConstraints = false
        callPhotoLibraryButton.widthAnchor.constraint(equalToConstant: view.frame.width / 3).isActive = true
        callPhotoLibraryButton.heightAnchor.constraint(equalToConstant: view.frame.width / 3).isActive = true
        callPhotoLibraryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        callPhotoLibraryButton.bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: -16).isActive = true
        
        callPhotoLibraryButton.layer.borderColor = UIColor.white.cgColor
    }
    
    private func configureCameraButton() {
        cameraButton.translatesAutoresizingMaskIntoConstraints = false
        cameraButton.widthAnchor.constraint(equalToConstant: view.frame.width / 3).isActive = true
        cameraButton.heightAnchor.constraint(equalToConstant: view.frame.width / 3).isActive = true
        cameraButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        cameraButton.topAnchor.constraint(equalTo: view.centerYAnchor, constant: 16).isActive = true
        
        cameraButton.layer.borderColor = UIColor.white.cgColor
    }
    
    private func configureNavigationBar() {
        self.navigationController?.navigationBar.tintColor = UIColor(red: 233/255, green: 119/255, blue: 113/255, alpha: 1)
        self.navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 1)
        ]
    }
    
    
    private func callPhotoLibrary() {
        requestPhotoAuthorizationOn()
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) {
            
            let picker = UIImagePickerController()
            picker.modalPresentationStyle = UIModalPresentationStyle.popover
            picker.delegate = self
            picker.navigationBar.tintColor = UIColor(red: 233/255, green: 119/255, blue: 113/255, alpha: 1)
            picker.sourceType = UIImagePickerController.SourceType.photoLibrary
            
            self.present(picker, animated: true, completion: nil)
        }
    }
    
    private func requestPhotoAuthorizationOn() {
        let status = PHPhotoLibrary.authorizationStatus()
        if status == PHAuthorizationStatus.denied {
            let alert = UIAlertController(title: "写真へのアクセスを許可",
                                          message: "写真へのアクセスを許可する必要があります。設定を変更しますか？",
                                          preferredStyle: .alert)
            
            let allowAction = UIAlertAction(title: "OK", style: .default) { (_) -> Void in
                guard let _ = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
            }
            
            let cancelAction = UIAlertAction(title: "NO", style: .cancel) { (_) in
                // なにもしない
            }
            
            alert.addAction(allowAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true)
        }
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.photoLibraryImage = pickedImage
        }
        
        let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "trimmingNavigationContoller") as! UINavigationController
//        picker.present(nextVC, animated: true)
        dismiss(animated: true, completion: nil)
        present(nextVC, animated: true)
        
    }
    
    
    // MARK: Action

    @IBAction func callPhotoLibraryButtonTapped(_ sender: UIButton) {
        callPhotoLibrary()
    }

}


//
//  PreviewViewController.swift
//  TrimmingTest
//
//  Created by 堺雄之介 on 2019/03/27.
//  Copyright © 2019 Yunosuke Sakai. All rights reserved.
//

import UIKit

class PhotoPreviewViewController: UIViewController {
    
    // MARK: property
    
    let imageView = UIImageView()

    
    // MARK: override function

    override func viewDidLoad() {
        super.viewDidLoad()

        configureNavigationBar()
        createImageView()
        imageView.contentMode = .scaleAspectFit
        
//        let count = (self.navigationController?.viewControllers.count)! - 1
//        let previousVC = self.navigationController?.viewControllers[count]
//
//        let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "CameraNavigationController") as! UINavigationController
//        let cameraVc = nextVC.topViewController as! CameraViewController
//
//        if previousVC == cameraVc {
//            let appDelegate = UIApplication.shared.delegate as! AppDelegate
//            imageView.image = appDelegate.photoLibraryImage
//        }
    }
    
    
    
    // MARK: private function

    // NavigationBarの設定
    private func configureNavigationBar() {
        self.navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 1)
        ]
    }
    
    
    // imageViewの設定
    private func createImageView() {
        view.addSubview(imageView)
        
        imageView.contentMode = .scaleAspectFill
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: view.frame.width * 0.9).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: view.frame.width * 0.9 * 1.5).isActive = true
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    
    
    // MARK: Action
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        guard let image = imageView.image else { return }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        
        let alert = UIAlertController(title: "保存されました", message: "", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default){ (_) in
            NotificationCenter.default.post(name: .notifyName, object: nil)
        }
        alert.addAction(okButton)
        self.present(alert, animated: true)
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
}

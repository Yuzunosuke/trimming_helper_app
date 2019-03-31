//
//  PreviewViewController.swift
//  TrimmingTest
//
//  Created by 堺雄之介 on 2019/03/27.
//  Copyright © 2019 Yunosuke Sakai. All rights reserved.
//

import UIKit

class PreviewViewController: UIViewController {
    
    // MARK: property
    
    let imageView = UIImageView()

    
    // MARK: override function

    override func viewDidLoad() {
        super.viewDidLoad()

        configureNavigationBar()
        createImageView()
        imageView.contentMode = .scaleAspectFit
    }
    
    
    
    // MARK: private function

    // NavigationBarの設定
    private func configureNavigationBar() {
        self.navigationController?.navigationBar.tintColor = UIColor(red: 233/255, green: 119/255, blue: 113/255, alpha: 1)
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
//            self.dismiss(animated: true, completion: nil)
            NotificationCenter.default.post(name: .notifyName, object: nil)
        }
        alert.addAction(okButton)
        self.present(alert, animated: true)
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
}

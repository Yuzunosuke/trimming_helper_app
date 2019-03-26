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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: override function

    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
        configureNavigationBar()
        createImageView()
    }
    
    
    
    // MARK: private function
    
    // Viewそのものの設定
    private func configureView() {
        view.backgroundColor = UIColor(red: 23/255, green: 23/255, blue: 23/255, alpha: 1)
    }
    
    
    // NavigationBarの設定
    private func configureNavigationBar() {
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 23/255, green: 23/255, blue: 23/255, alpha: 1)
        self.navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor(red: 190/255, green: 190/255, blue: 190/255, alpha: 1)
        ]
    }
    
    
    // imageViewの設定
    private func createImageView() {
        view.addSubview(imageView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: view.frame.width / 1.618).isActive = true
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    
    
    // MARK: Action
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        guard let image = imageView.image else { return }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        
        let alert = UIAlertController(title: "保存されました", message: "", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default){ (_) in
            self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(okButton)
        self.present(alert, animated: true)
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
}

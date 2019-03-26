//
//  MyNavigationController.swift
//  TrimmingTest
//
//  Created by 堺雄之介 on 2019/03/27.
//  Copyright © 2019 Yunosuke Sakai. All rights reserved.
//

import UIKit

class MyNavigationController: UINavigationController {
    
    override var childForStatusBarStyle: UIViewController? {
        return self.visibleViewController
    }
    
    override var childForStatusBarHidden: UIViewController? {
        return self.visibleViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

}

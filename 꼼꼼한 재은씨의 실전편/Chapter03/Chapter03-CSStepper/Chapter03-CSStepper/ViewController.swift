//
//  ViewController.swift
//  Chapter03-CSStepper
//
//  Created by Choi SeungHyuk on 2020/10/10.
//  Copyright © 2020 test. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let stepper = CSStepper()
        
        stepper.frame = CGRect(x: 30, y: 100, width: 130, height: 30)
        
        
        
        self.view.addSubview(stepper)
        
       
    }


}


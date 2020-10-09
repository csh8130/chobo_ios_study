//
//  ViewController.swift
//  Chapter03-Alert
//
//  Created by Choi SeungHyuk on 2020/10/09.
//  Copyright © 2020 test. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaultAlertBtn = UIButton(type: .system)
        defaultAlertBtn.frame = CGRect(x: 0, y: 100, width: 100, height: 30)
        defaultAlertBtn.center.x = self.view.frame.width / 2
        defaultAlertBtn.setTitle("기본 알림창", for: .normal)
        defaultAlertBtn.addTarget(self, action: #selector(defaultAlert(_:)), for: .touchUpInside)
        self.view.addSubview(defaultAlertBtn)
    }

    @objc func defaultAlert(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        //let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        //let okAction = UIAlertAction(title: "Ok", style: .default)
        
        //alert.addAction(cancelAction)
//        alert.addAction(okAction)
        
        let v = UIViewController()
        v.view.backgroundColor = .red
        
        alert.setValue(v, forKey: "contentViewController")
        
        self.present(alert, animated: false)
    }
}


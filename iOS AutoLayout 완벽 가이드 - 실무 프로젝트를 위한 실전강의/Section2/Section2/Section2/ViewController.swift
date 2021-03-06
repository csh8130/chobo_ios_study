//
//  ViewController.swift
//  Section2
//
//  Created by Choi SeungHyuk on 2021/03/03.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var btn1: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resultLabel.layer.cornerRadius = 50
//        resultLabel.layer.masksToBounds = true
        resultLabel.clipsToBounds = true
        print(btn1.bounds.width)
    }

    override func viewDidAppear(_ animated: Bool) {
        print(btn1.bounds.width)
        btn1.layer.cornerRadius = btn1.bounds.width / 2
    }
}


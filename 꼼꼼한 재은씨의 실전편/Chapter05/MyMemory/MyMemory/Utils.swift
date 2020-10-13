//
//  Utils.swift
//  MyMemory
//
//  Created by Choi SeungHyuk on 2020/10/13.
//  Copyright © 2020 test. All rights reserved.
//

import UIKit
extension UIViewController {
    var tutorialSB: UIStoryboard {
        return UIStoryboard(name: "Tutorial", bundle: Bundle.main)
    }
    func instanceTutorialVC(name: String) -> UIViewController? {
        return self.tutorialSB.instantiateViewController(withIdentifier: name)
    }
}

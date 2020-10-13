//
//  TutorialMasterVC.swift
//  MyMemory
//
//  Created by Choi SeungHyuk on 2020/10/13.
//  Copyright © 2020 test. All rights reserved.
//

import UIKit

class TutorialMasterVC: UIViewController, UIPageViewControllerDataSource {
    
    var pageVC: UIPageViewController!
    
    var contentTitles = ["STEP 1", "STEP 2", "STEP 3", "STEP 4"]
    var contentImages = ["Page0", "Page1", "Page2", "Page3"]
    
    func getContentVC(atIndex idx: Int) -> UIViewController? {
        guard self.contentTitles.count >= idx && self.contentTitles.count > 0 else {
            return nil
        }
        
        guard let cvc = self.instanceTutorialVC(name: "ContentsVC") as? TutorialContentsVC else {
            return nil
        }
        cvc.titleText = self.contentTitles[idx]
        cvc.imageFile = self.contentImages[idx]
        cvc.pageIndex = idx
        return cvc
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard var index = (viewController as! TutorialContentsVC).pageIndex else {
            return nil
        }
        
        guard index > 0 else {
            return nil
        }
        
        index -= 1
        return self.getContentVC(atIndex: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard var index = (viewController as! TutorialContentsVC).pageIndex else {
            return nil
        }
        
        guard index > 0 else {
            return nil
        }
        
        index += 1
        return self.getContentVC(atIndex: index)
    }
    
    override func viewDidLoad() {
        //페이지 뷰컨트롤러 객체 생성
        self.pageVC = self.instanceTutorialVC(name: "PageVC") as? UIPageViewController
        self.pageVC.dataSource = self
        
        //기본 페이지 지정
        let startContentVC = self.getContentVC(atIndex: 0)!
        self.pageVC.setViewControllers([startContentVC], direction: .forward, animated: true, completion: nil)
        
        //출력 영역 지정
        self.pageVC.view.frame.origin = CGPoint(x: 0, y: 0)
        self.pageVC.view.frame.size.width = self.view.frame.width
        self.pageVC.view.frame.size.height = self.view.frame.height - 50
        
        //마스터 뷰컨트롤러의 자식 뷰컨트롤러로
        self.addChild(self.pageVC)
        self.view.addSubview(self.pageVC.view)
        self.pageVC.didMove(toParent: self)
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return self.contentTitles.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
}

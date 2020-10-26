//
//  DepartPickerVC.swift
//  Chapter06-HR
//
//  Created by Choi SeungHyuk on 2020/10/27.
//  Copyright © 2020 test. All rights reserved.
//

import UIKit

class DepartPickerVC: UIViewController {
  let departDAO = DepartmentDAO() // DAO 객체
  var departList: [(departCd: Int, departTitle: String, departAddr: String)]! // 피커 뷰의 데이터 소스
  var pickerView: UIPickerView! // 피커 뷰 객체
  
  // 현재 피커 뷰에 선택되어 있는 부서의 코드를 가져온다.
  var selectedDepartCd: Int {
    let row = self.pickerView.selectedRow(inComponent: 0)
    return self.departList[row].departCd
  }
  
  override func viewDidLoad() {
    // 1. DB에서 부서 목록을 가져와 튜플 배열을 초기화한다.
    self.departList = self.departDAO.find()
    
    // 2. 피커 뷰 객체를 초기화하고, 최상위 뷰의 서브 뷰로 추가한다.
    self.pickerView = UIPickerView(frame: CGRect(x: 0, y:0, width: 200, height: 100))
    self.pickerView.dataSource = self
    self.pickerView.delegate = self
    self.view.addSubview(self.pickerView)
    
    // 3. 외부에서 뷰 컨트롤러를 참조할 때를 위한 사이즈를 지정한다.
    let pWidth = self.pickerView.frame.width
    let pHeight = self.pickerView.frame.height
    self.preferredContentSize = CGSize(width: pWidth, height: pHeight)
  }
}

// MARK: - 피커 뷰 델리게이트 메소드 구현
extension DepartPickerVC: UIPickerViewDataSource, UIPickerViewDelegate {
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return self.departList.count
  }
  
  func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
    var titleView = view as? UILabel
    if titleView == nil {
      titleView = UILabel()
      titleView?.font = UIFont.systemFont(ofSize: 14)
      titleView?.textAlignment = .center
    }
    titleView?.text = "\(self.departList[row].departTitle) (\(self.departList[row].departAddr))"
    return titleView!
  }
  
}

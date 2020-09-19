//
//  MemoFromVC.swift
//  MyMemory
//
//  Created by Choi SeungHyuk on 2020/09/17.
//  Copyright © 2020 test. All rights reserved.
//

import UIKit

class MemoFromVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {
    var subject: String!
    
    @IBOutlet weak var contents: UITextView!
    @IBOutlet weak var preview: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contents.delegate = self
    }
    
    @IBAction func save(_ sender: Any) {
        guard contents.text.isEmpty == false else {
            let alert = UIAlertController(title: nil, message: "내용을 입력해주세요", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true)
            return
        }
        let data = MemoData()
        
        data.title = subject
        data.contents = contents.text
        data.image = preview.image
        data.regdate = Date()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.memolist.append(data)
        
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func pick(_ sender: Any) {
        let select = UIAlertController(title: "이미지를 가져올 곳을 선택해주세요.", message: nil, preferredStyle: .actionSheet)
        select.addAction(UIAlertAction(title: "카메라", style: .default) { (_) in
          self.presentPicker(source: .camera)
        })
        select.addAction(UIAlertAction(title: "저장앨범", style: .default) { (_) in
            self.presentPicker(source: .savedPhotosAlbum)
        })
        select.addAction(UIAlertAction(title: "사진 라이브러리", style: .default) { (_) in
            self.presentPicker(source: .photoLibrary)
        })
        self.present(select, animated: false)
    }
    
    func presentPicker(source: UIImagePickerController.SourceType) {
      guard UIImagePickerController.isSourceTypeAvailable(source) == true else {
        let alert = UIAlertController(title: "사용할 수 없는 타입입니다", message: nil, preferredStyle: .alert)
        self.present(alert, animated: false)
        return
      }
      
      // 이미지 피커 인스턴스를 생성한다.
      let picker = UIImagePickerController()
      
      picker.delegate = self
      picker.allowsEditing = true
      picker.sourceType = source
      
      // 이미지 피커 화면을 표시한다.
      self.present(picker, animated: false)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        preview.image = info[.editedImage] as? UIImage
        picker.dismiss(animated: false)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let contents = textView.text as NSString
        let length = ((contents.length > 15) ? 15 : contents.length)
        subject = contents.substring(with: NSRange(location: 0, length: length))
        
        navigationItem.title = subject
    }
}

//
//  ViewController.swift
//  imagePickerWithCollectionView
//
//  Created by 이유리 on 2020/04/20.
//  Copyright © 2020 이유리. All rights reserved.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift
import Then
import Action

enum TabType {
    case imageView
    case deleteButton(index: Int)
}

class ViewController: UIViewController {
    /// 선택된 이미지를 담아줄 릴레이
    let imageRelay = BehaviorRelay<[UIImage]>(value: [#imageLiteral(resourceName: "basicPhoto")])
    let disposeBag = DisposeBag()
    
    /// 액션
    lazy var tabAction = Action<TabType, Void> { input in
        switch input {
        case .imageView:
            self.openActionsheet()
            return .empty()
        case .deleteButton(let index):
            self.deletePhoto(index: index)
            return .empty()
        }
    }
    
    /// 이미지 픽커
    lazy var imagePicker = UIImagePickerController().then {
        $0.delegate = self
    }
    
    /// 이미지 담아줄 콜렉션뷰
    lazy var photoCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout().then {
        $0.scrollDirection = .horizontal // 스크롤 방향
        $0.minimumLineSpacing = 0 // 최소 라인간격
        $0.minimumInteritemSpacing = 5 // 최소 내부여백
        $0.itemSize = CGSize(width: 100, height: 100) // 셀크기
    }).then {
        $0.backgroundColor = .gray
        $0.register(PhotoSelectCell.self, forCellWithReuseIdentifier: "PhotoSelectCell")
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.showsVerticalScrollIndicator = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindDate()
    }
    
    //MARK: - setupUI
    func setupUI() {
        self.view.addSubview(photoCollectionView)
        
        photoCollectionView.snp.makeConstraints {
            $0.height.equalTo(100)
            $0.leading.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
    }
    
    //MARK: - binding
    func bindDate() {
        imageRelay.bind(to: self.photoCollectionView.rx.items(cellIdentifier: "PhotoSelectCell", cellType: PhotoSelectCell.self)) { index, element, cell in
            cell.selectedPhoto.image = element
            cell.deletePhotoButton.isHidden = index == 0 ? true : false // 삭제버튼은 첫번째(사진선택)이면 히든처리
            
            // 삭제버튼 없으면 이미지에 액션주고, 있으면 버튼에 액션줌
            if cell.deletePhotoButton.isHidden {
//                cell.selectedPhoto.image?.rx.bind(to: self.tabAction, input: .deleteButton(index: index))
            } else {
                cell.deletePhotoButton.rx.bind(to: self.tabAction, input: .deleteButton(index: index))
            }
        }.disposed(by: disposeBag)
        
//        self.photoCollectionView.rx.itemSelected.subscribe(onNext: { [weak self] index in
//            guard let `self` = self else { return }
//            if index.item == 0 {
//                self.openActionsheet()
//            } else {
//                var value = self.imageRelay.value
//                value.remove(at: index.item)
//                self.imageRelay.accept(value)
//                print("index : \(index.item)")
//            }
//        }).disposed(by: disposeBag)
    }
    
    func deletePhoto(index: Int) {
        var value = self.imageRelay.value
        value.remove(at: index)
        self.imageRelay.accept(value)
        print("index : \(index)")
    }
    
    func openActionsheet() {
        let alert =  UIAlertController(title: "사진선택", message: "사진을 선택해주세요.", preferredStyle: .actionSheet)
        let gellery =  UIAlertAction(title: "앨범", style: .default) { [weak self] _ in
            guard let `self` = self else { return }
            self.openGellery()
        }
        let camera =  UIAlertAction(title: "카메라", style: .default) { [weak self] _ in
            guard let `self` = self else { return }
            self.openCamera()
        }
        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alert.addAction(gellery)
        alert.addAction(camera)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    func openGellery() {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: false, completion: nil)
    }
    
    func openCamera() {
        if(UIImagePickerController .isSourceTypeAvailable(.camera)){
            imagePicker.sourceType = .camera
            present(imagePicker, animated: false, completion: nil)
        }
        else{
            print("Camera not available")
        }
    }
}

//MARK: - Delegate
extension ViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    // 이미지가 선택되었을때 실행됨
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            print("info \(info)")
            print("image \(image)")
            // 선택한 이미지를 imageRelay에 추가하여 콜렉션뷰에 바인딩
            self.imageRelay.accept(imageRelay.value + [image])
        }
        dismiss(animated: true, completion: nil)
    }
}


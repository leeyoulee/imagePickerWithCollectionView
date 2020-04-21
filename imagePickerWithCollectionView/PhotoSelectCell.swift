//
//  PhotoSelectCell.swift
//  imagePickerWithCollectionView
//
//  Created by 이유리 on 2020/04/20.
//  Copyright © 2020 이유리. All rights reserved.
//

import UIKit
import SnapKit

class PhotoSelectCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCellUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupCellUI()
    }

    /// 선택된 사진
    lazy var selectedPhoto = UIImageView()

    /// 사진 삭제 버튼
    lazy var deletePhotoButton = UIButton().then {
        $0.setImage(#imageLiteral(resourceName: "closeImage"), for: .normal)
    }

    func setupCellUI() {
        selectedPhoto.addSubview(deletePhotoButton)
        addSubview(selectedPhoto)

        selectedPhoto.snp.makeConstraints {
            $0.width.height.equalTo(90)
            $0.center.equalToSuperview()
        }

        deletePhotoButton.snp.makeConstraints {
            $0.width.height.equalTo(20)
            $0.top.equalTo(self.selectedPhoto.snp.top)
            $0.trailing.equalTo(self.selectedPhoto.snp.trailing)
        }
        
        _ = deletePhotoButton.rx.tap.map{ !self.isSelected }
    }
}

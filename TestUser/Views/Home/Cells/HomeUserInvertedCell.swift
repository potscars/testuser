//
//  HomeUserInvertedCell.swift
//  TestUser
//
//  Created by owner on 02/07/2023.
//

import Foundation
import UIKit
import Combine

class HomeUserInvertedCell: UITableViewCell {
    
    private var containerView: ShadowedView = {
        let view = ShadowedView()
        view.backgroundColor = UIColor(named: "basicViewColor")
        return view
    }()
    
    private var userImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .brown
        return iv
    }()
    
    private var labelStackView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .vertical
        sv.distribution = .fill
        return sv
    }()
    
    private var usernameLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        lbl.textColor = UIColor(named: "textColor")
        return lbl
    }()
    
    private var detailLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        lbl.numberOfLines = 2
        lbl.textColor = UIColor(named: "textColor")
        return lbl
    }()
    
    private var vm: HomeUserCellViewModel?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.initialConfigure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        vm?.disposeBag()
        userImageView.image = nil
        usernameLabel.text = nil
        detailLabel.text = nil
    }
}

extension HomeUserInvertedCell {
    
    private func initialConfigure() {
        selectionStyle = .none
        userImageView.layer.cornerRadius = 64 / 2
        userImageView.layer.masksToBounds = true
        
        self.setupConstraints()
    }
    
    private func setupConstraints() {
        
        labelStackView.addArrangedSubview(usernameLabel)
        labelStackView.addArrangedSubview(detailLabel)
        containerView.addSubview(userImageView)
        containerView.addSubview(labelStackView)
        contentView.addSubview(containerView)
        
        NSLayoutConstraint.activate([
            
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            
            userImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            userImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            userImageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10),
            
            userImageView.heightAnchor.constraint(equalToConstant: 64),
            userImageView.widthAnchor.constraint(equalTo: userImageView.heightAnchor),
            
            labelStackView.leadingAnchor.constraint(equalTo: userImageView.trailingAnchor, constant: 10),
            labelStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            labelStackView.centerYAnchor.constraint(equalTo: userImageView.centerYAnchor),
        ])
    }
}

extension HomeUserInvertedCell: ConfigurableCell {
    func configure(data user: User) {
        self.vm = HomeUserCellViewModel(user: user)
        usernameLabel.text = user.login
        detailLabel.text = user.avatarURL
        
        guard let vm = vm else { return }
        
        if let imageData = user.imageData {
            print("Core Data Image")
            self.userImageView.image = UIImage(data: imageData)?.negative
        } else {
            vm.cancellable = vm.loadImage().sink { [weak self] image in
                self?.userImageView.image = image?.negative
                vm.storeImageData(with: image)
            }
        }
    }
    
    public func getUser() -> User {
        vm?.getUser() ?? .empty
    }
}

//
//  FinishDialogViewController.swift
//  FaceScanner
//
//  Created by 江翰臻 on 2021/10/13.
//

import UIKit

protocol FinishDialogViewControllerDelegate: AnyObject {
    func finishDialogViewController(_ vc: FinishDialogViewController, didPressCloseButton: Void)
    func finishDialogViewController(_ vc: FinishDialogViewController, didPressAgainButton: Void)
}

// MARK: -
class FinishDialogViewController: UIViewController {

    weak var delegate: FinishDialogViewControllerDelegate?

    @IBOutlet weak var stackView: UIStackView! {
        didSet {
            stackView.backgroundColor = .clear
            stackView.spacing = UIScreen.main.bounds.width * (12.0 / 360.0)
        }
    }

    @IBOutlet weak var dialogView: UIView! {
        didSet {
            dialogView.layer.cornerRadius = 10
        }
    }

    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setTitle("关闭", for: .normal)
        button.setTitleColor(UIColor(named: "myPurple"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(named: "myPurple")?.cgColor
        button.addTarget(self, action: #selector(closeButtonDidPressed), for: .touchUpInside)
        return button
    }()

    private lazy var againButton: UIButton = {
        let button = UIButton()
        button.setTitle("再刷一次", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.layer.cornerRadius = 10
        button.backgroundColor = UIColor(named: "myPurple")
        button.addTarget(self, action: #selector(againButtonDidPressed), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        initConstraints()
    }
}

private extension FinishDialogViewController {

    func initConstraints() {
        stackView.addArrangedSubview(closeButton)
        stackView.addArrangedSubview(againButton)
        closeButton.snp.makeConstraints {
            $0.width.equalTo(againButton.snp.width).multipliedBy(98.0 / 150.0)
        }
    }

    @objc func closeButtonDidPressed() {
        dismiss(animated: false, completion: nil)
        delegate?.finishDialogViewController(self, didPressCloseButton: ())
    }

    @objc func againButtonDidPressed() {
        dismiss(animated: true, completion: nil)
        delegate?.finishDialogViewController(self, didPressAgainButton: ())
    }
}

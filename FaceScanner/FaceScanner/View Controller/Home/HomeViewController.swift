//
//  HomeViewController.swift
//  FaceScanner
//
//  Created by 江翰臻 on 2021/10/7.
//

import UIKit

class HomeViewController: UIViewController {

    // MARK: - View Components

    @IBOutlet weak var bottomView: UIView! {
        didSet {
            bottomView.layer.cornerRadius = 10
            bottomView.clipsToBounds = true
        }
    }

    @IBOutlet weak var bankSelectionView: UIView! {
        didSet {
            let tapGR = UITapGestureRecognizer(target: self, action: #selector(bankSelectionViewTapped))
            bankSelectionView.addGestureRecognizer(tapGR)
            bankSelectionView.isUserInteractionEnabled = true
        }
    }

    @IBOutlet weak var bankTextField: UITextField! {
        didSet {
            bankTextField.text = nil
            bankTextField.textColor = UIColor(named: "myPurple")
            bankTextField.font = UIFont.systemFont(ofSize: 18, weight: .semibold)

            bankTextField.delegate = self
            bankTextField.placeholder = "请选择银行"
        }
    }

    @IBOutlet weak var startButtonView: UIView! {
        didSet {
            let tapGR = UITapGestureRecognizer(target: self, action: #selector(startButtonViewTapped))
            startButtonView.addGestureRecognizer(tapGR)
            startButtonView.isUserInteractionEnabled = false
        }
    }

    @IBOutlet weak var startButton: UIButton! {
        didSet {
            startButton.isEnabled = false
            startButton.isUserInteractionEnabled = false
        }
    }
}

private extension HomeViewController {

    @objc func bankSelectionViewTapped() {
        bankTextField.becomeFirstResponder()
    }

    @objc func startButtonViewTapped() {
        let ratios: [ScannerViewController.PhotoRatio] = [.auto, .photo, .square]
        let scannerVC = ScannerViewController(photoRatio: ratios.randomElement()!)
        scannerVC.modalPresentationStyle = .fullScreen
        scannerVC.modalTransitionStyle = .crossDissolve
        self.present(scannerVC, animated: true, completion: nil)
    }

    func showBankSelectionSheet() {
        let alert = UIAlertController()
        for bank in Bank.allCases {
            let action = UIAlertAction(title: bank.localizedString, style: .default) { [weak self] _ in
                self?.didSelectedBank(bank: bank)
            }
            alert.addAction(action)
        }
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }

    func didSelectedBank(bank: Bank) {
        self.bankTextField.text = bank.localizedString
        self.startButton.isEnabled = true
        self.startButtonView.isUserInteractionEnabled = true
    }
}

extension HomeViewController: UITextFieldDelegate {
    // MARK: - UITextFieldDelegate

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        showBankSelectionSheet()
        return false
    }
}

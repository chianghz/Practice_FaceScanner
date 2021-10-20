//
//  HomeViewController.swift
//  FaceScanner
//
//  Created by 江翰臻 on 2021/10/7.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var startButtonView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        initLayout()
    }
}

private extension HomeViewController {

    func initLayout() {
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(startButtonViewTapped))
        startButtonView.addGestureRecognizer(tapGR)
        startButtonView.isUserInteractionEnabled = true
        startButtonView.layer.cornerRadius = 10
    }

    @objc func startButtonViewTapped() {
        let ratios: [ScannerViewModel.PhotoRatio] = [.auto, .photo, .square]
        let scannerVC = ScannerViewController(photoRatio: ratios.randomElement()!)
        scannerVC.modalPresentationStyle = .fullScreen
        scannerVC.modalTransitionStyle = .crossDissolve
        self.present(scannerVC, animated: true, completion: nil)
    }
}

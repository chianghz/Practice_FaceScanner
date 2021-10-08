//
//  ScannerViewController.swift
//  FaceScanner
//
//  Created by 江翰臻 on 2021/10/7.
//

import UIKit

class ScannerViewController: UIViewController {

    @IBOutlet weak var closeButton: UIButton!

    @IBOutlet weak var stackView: UIStackView!


    @IBOutlet weak var messageLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        initLayout()
    }

    @IBAction func closeButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}

private extension ScannerViewController {

    func initLayout() {

    }
}

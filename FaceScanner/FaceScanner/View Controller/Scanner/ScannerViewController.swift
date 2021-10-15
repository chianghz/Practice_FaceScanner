//
//  ScannerViewController.swift
//  FaceScanner
//
//  Created by 江翰臻 on 2021/10/7.
//

import UIKit
import Combine

class ScannerViewController: UIViewController {

    // MARK: - View Components

    @IBOutlet weak var closeButton: UIButton!

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var timerContainerView1: UIView!
    @IBOutlet weak var timerContainerView2: UIView!
    @IBOutlet weak var timerContainerView3: UIView!

    @IBOutlet weak var messageLabel: UILabel!

    private let timerView1 = ScannerTimerView(text: "1", duration: 1)
    private let timerView2 = ScannerTimerView(text: "2", duration: 1)
    private let timerView3 = ScannerTimerView(text: "3", duration: 1)

    private lazy var finishDialog: FinishDialogViewController = {
        let dialog = FinishDialogViewController()
        dialog.delegate = self
        return dialog
    }()

    private let previewContainer = UIView()

    // MARK: - Variables

    private var cancellables = Set<AnyCancellable>()

    private lazy var cameraController = CameraController(previewContainer: self.previewContainer)

    override func viewDidLoad() {
        super.viewDidLoad()

        initLayout()
        initConstraints()

        bindTimerViews()
        bindCameraController()

        cameraController.checkPermissions { [weak self] authorized in
            guard authorized else { return }
            self?.cameraController.setup()

            DispatchQueue.main.async {
                self?.timerView1.startAnimation()
            }
        }
    }

    @IBAction func closeButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

private extension ScannerViewController {

    func initLayout() {
        timerContainerView1.backgroundColor = .clear
        timerContainerView2.backgroundColor = .clear
        timerContainerView3.backgroundColor = .clear
        messageLabel.text = nil
    }

    func initConstraints() {
        timerContainerView1.addSubview(timerView1)
        timerView1.snp.makeConstraints { $0.edges.equalToSuperview() }
        timerContainerView2.addSubview(timerView2)
        timerView2.snp.makeConstraints { $0.edges.equalToSuperview() }
        timerContainerView3.addSubview(timerView3)
        timerView3.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    func bindTimerViews() {
        timerView1.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                switch state {
                case .ready: break
                case .animating: self?.messageLabel.text = "请眨眨眼"
                case .finished: self?.timerView2.startAnimation()
                }
            }
            .store(in: &cancellables)

        timerView2.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                switch state {
                case .ready: break
                case .animating: self?.messageLabel.text = "请点点头"
                case .finished: self?.timerView3.startAnimation()
                }
            }
            .store(in: &cancellables)

        timerView3.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                switch state {
                case .ready: break
                case .animating: self?.messageLabel.text = "请微微笑"
                case .finished: self?.showFinishDialog()
                }
            }
            .store(in: &cancellables)
    }

    func bindCameraController() {
        cameraController.errorCatched
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                let alert = UIAlertController(title: error.string, message: nil, preferredStyle: .alert)
                let closeAction = UIAlertAction(title: "ok", style: .cancel, handler: nil)
                alert.addAction(closeAction)
                self?.present(alert, animated: true, completion: nil)
            }
            .store(in: &cancellables)

//        cameraController.imageCaptured
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] image in
//                self?.capturedImageView.image = image
//            }
//            .store(in: &cancellables)
    }
}

extension ScannerViewController: FinishDialogViewControllerDelegate {
    // MARK: - FinishDialogViewControllerDelegate

    func showFinishDialog() {
        finishDialog.modalPresentationStyle = .overFullScreen
        finishDialog.modalTransitionStyle = .crossDissolve
        self.present(finishDialog, animated: true, completion: nil)
    }

    func finishDialogViewController(_ vc: FinishDialogViewController, didPressCloseButton: Void) {
        self.dismiss(animated: true, completion: nil)
    }

    func finishDialogViewController(_ vc: FinishDialogViewController, didPressAgainButton: Void) {
        [timerView1, timerView2, timerView3].forEach { $0.reset() }
        timerView1.startAnimation()
    }
}

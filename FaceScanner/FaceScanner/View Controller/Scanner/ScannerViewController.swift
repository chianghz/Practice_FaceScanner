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

    private let timerView1 = ScannerTimerView(text: "1", duration: 3)
    private let timerView2 = ScannerTimerView(text: "2", duration: 3)
    private let timerView3 = ScannerTimerView(text: "3", duration: 3)

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var imageViewFace: UIImageView!
    @IBOutlet weak var imageViewFocus: UIImageView!

    private lazy var finishDialog: FinishDialogViewController = {
        let dialog = FinishDialogViewController()
        dialog.delegate = self
        return dialog
    }()

    private let previewContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        return view
    }()

    private let blackMaskTop: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()

    private let blackMaskBottom: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()

    // MARK: -

    let photoRatio: ScannerViewModel.PhotoRatio
    let vm: ScannerViewModel

    private lazy var cameraController = CameraController(previewContainer: self.previewContainer)
    private var cancellables = Set<AnyCancellable>()

    init(photoRatio: ScannerViewModel.PhotoRatio) {
        self.photoRatio = photoRatio
        self.vm = ScannerViewModel(photoRatio: photoRatio)

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        initLayout()
        initConstraints()

        bindViewModel()
        bindTimerViews()
        bindCameraController()

        cameraController.checkPermissions { [weak self] authorized in
            guard authorized else { return }
//            self?.cameraController.setup()

            DispatchQueue.main.async {
                self?.timerView1.startAnimation()
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

//        self.cameraController.stop()
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

        imageViewFace.contentMode = photoRatio == .auto ? .scaleAspectFill : .scaleAspectFit
    }

    func initConstraints() {
        timerContainerView1.addSubview(timerView1)
        timerView1.snp.makeConstraints { $0.edges.equalToSuperview() }
        timerContainerView2.addSubview(timerView2)
        timerView2.snp.makeConstraints { $0.edges.equalToSuperview() }
        timerContainerView3.addSubview(timerView3)
        timerView3.snp.makeConstraints { $0.edges.equalToSuperview() }

        view.insertSubview(previewContainer, at: 0)
        previewContainer.snp.makeConstraints {
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide)

            switch photoRatio {
            case .auto:
                $0.top.bottom.equalTo(view.safeAreaLayoutGuide)

            case .photo:
                $0.top.equalTo(imageViewFocus.snp.top).offset(-60)
                $0.height.equalTo(previewContainer.snp.width).multipliedBy(4.0/3.0)

            case .square:
                $0.top.equalTo(imageViewFocus.snp.top).offset(-30)
                $0.height.equalTo(previewContainer.snp.width)
            }
        }

        view.insertSubview(blackMaskTop, aboveSubview: imageViewFace)
        blackMaskTop.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(previewContainer.snp.top)
        }
        view.insertSubview(blackMaskBottom, aboveSubview: imageViewFace)
        blackMaskBottom.snp.makeConstraints {
            $0.bottom.leading.trailing.equalToSuperview()
            $0.top.equalTo(previewContainer.snp.bottom)
        }
    }

    func bindViewModel() {
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

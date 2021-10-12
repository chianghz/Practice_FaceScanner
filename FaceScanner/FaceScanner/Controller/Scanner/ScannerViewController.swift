//
//  ScannerViewController.swift
//  FaceScanner
//
//  Created by 江翰臻 on 2021/10/7.
//

import UIKit
import Combine

class ScannerViewController: UIViewController {

    @IBOutlet weak var closeButton: UIButton!

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var timerContainerView1: UIView!
    @IBOutlet weak var timerContainerView2: UIView!
    @IBOutlet weak var timerContainerView3: UIView!

    @IBOutlet weak var messageLabel: UILabel!

    private let timerView1 = ScannerTimerView(text: "1", duration: 3)
    private let timerView2 = ScannerTimerView(text: "2", duration: 3)
    private let timerView3 = ScannerTimerView(text: "3", duration: 3)

    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        initLayout()
        initConstraints()

        bindTimerViews()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        timerView1.startAnimation()
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
                case .finished: print("THE END")
                }
            }
            .store(in: &cancellables)
    }

}

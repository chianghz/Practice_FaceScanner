//
//  ScannerTimerView.swift
//  FaceScanner
//
//  Created by 江翰臻 on 2021/10/8.
//

import UIKit

class ScannerTimerView: UIView {

    enum State {
        case ready
        case animating
        case finished
    }

    @Published private(set) var state: State = .ready

    private let duration: TimeInterval

    private lazy var circleProgressView: CircleProgressBarView = {
        let view = CircleProgressBarView()
        view.delegate = self
        return view
    }()

    private let label: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white.withAlphaComponent(0.3)
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        return label
    }()

    private let finishView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "myYellow")
        view.isHidden = true
        let checkIcon = UIImageView(image: UIImage(named: "ico_check"))
        view.addSubview(checkIcon)
        checkIcon.snp.makeConstraints { $0.center.equalToSuperview() }
        return view
    }()

    init(text: String, duration: TimeInterval) {
        self.duration = duration
        super.init(frame: .zero)

        self.initConstraints()
        self.label.text = text
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.finishView.layer.cornerRadius = self.finishView.frame.height / 2
        self.finishView.clipsToBounds = true
    }

    func startAnimation() {
        setState(.animating)
    }
}

private extension ScannerTimerView {

    func initConstraints() {
        self.addSubview(label)
        label.snp.makeConstraints { $0.center.equalToSuperview() }
        self.addSubview(circleProgressView)
        circleProgressView.snp.makeConstraints { $0.edges.equalToSuperview() }
        self.addSubview(finishView)
        finishView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    func setState(_ state: State) {
        switch state {
        case .ready:
            label.textColor = UIColor.white.withAlphaComponent(0.3)

        case .animating:
            label.textColor = .white
            circleProgressView.progressAnimation(duration: self.duration)

        case .finished:
            label.textColor = .clear
            finishView.isHidden = false
            circleProgressView.isHidden = true
        }
        self.state = state
    }
}

// MARK: -
extension ScannerTimerView: CircleProgressBarViewDelegate {
    func circleProgressBarView(_ view: CircleProgressBarView, animationFinished: Void) {
        self.setState(.finished)
    }
}

//
//  CameraController.swift
//  CameraController
//
//  Created by 江翰臻 on 2021/10/14.
//

import AVFoundation
import UIKit
import Combine

class CameraController: NSObject {

    // MARK: - Publishers

    @Published private(set) var currentCameraPosition: CameraPosition = .front
    @Published private(set) var isCameraSwitching: Bool = false
    private(set) var imageCaptured = PassthroughSubject<UIImage, Never>()
    private(set) var errorCatched = PassthroughSubject<CameraControllerError, Never>()

    // MARK: - Variables

    private var captureSession: AVCaptureSession!

    private var backCamera: AVCaptureDevice!
    private var backInput: AVCaptureInput!
    private var frontCamera: AVCaptureDevice!
    private var frontInput: AVCaptureInput!

    private var previewLayer: AVCaptureVideoPreviewLayer!

    private var videoOutput: AVCaptureVideoDataOutput!
    private var photoOutput: AVCapturePhotoOutput!

    private unowned var previewContainer: UIView

    private var cancellable: AnyCancellable?

    // MARK: -

    init(previewContainer view: UIView) {
        self.previewContainer = view

        self.cancellable = self.errorCatched
            .receive(on: DispatchQueue.main)
            .sink { error in
                print("[CameraController] error captured: \(error.string)")
            }
    }

    func setup() {
        self.setupAndStartCaptureSession()
    }

    func switchCamera() {
        self.switchCameraInput()
    }

    func captureImage() {
        guard captureSession.isRunning else {
            errorCatched.send(.unknown)
            return
        }
        let settings = AVCapturePhotoSettings()
        self.photoOutput.capturePhoto(with: settings, delegate: self)
    }
}

private extension CameraController {
    // MARK: - Camera Setup

    func setupAndStartCaptureSession() {
        if captureSession != nil, captureSession.isRunning {
            errorCatched.send(.captureSessionAlreadyRunning)
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession = AVCaptureSession()

            // start configuration
            self.captureSession.beginConfiguration()

            // session specific configuration
            if self.captureSession.canSetSessionPreset(.photo) {
                self.captureSession.sessionPreset = .photo
            }

            // setup inputs
            self.setupInputs()

            // setup preview layer
            DispatchQueue.main.async {
                self.setupPreviewLayer(on: self.previewContainer)
            }

            // setup outputs
            self.setupPhotoOutput()
//            self.setupVideoOutput()

            // commit configuration
            self.captureSession.commitConfiguration()

            self.captureSession.startRunning()
        }
    }

    func setupInputs() {
        // setup back camera input
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            backCamera = device
        } else {
            errorCatched.send(.noBackCamera)
        }

        do {
            let backInput = try AVCaptureDeviceInput(device: self.backCamera)
            self.backInput = backInput
        } catch {
            errorCatched.send(.noBackCameraInput)
        }

        if !captureSession.canAddInput(self.backInput) {
            errorCatched.send(.invalidBackCameraInput)
        }

        // setup front camera input
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
            frontCamera = device
        } else {
            errorCatched.send(.noFrontCamera)
        }

        do {
            let frontInput = try AVCaptureDeviceInput(device: self.frontCamera)
            self.frontInput = frontInput
        } catch {
            errorCatched.send(.noFrontCameraInput)
        }

        if !captureSession.canAddInput(self.frontInput) {
            errorCatched.send(.invalidFrontCameraInput)
        }

        // connect camera input to session
        (self.currentCameraPosition == .back)
        ? captureSession.addInput(backInput)
        : captureSession.addInput(frontInput)
    }

    func setupVideoOutput() {
        videoOutput = AVCaptureVideoDataOutput()
        let videoQueue = DispatchQueue(label: "videoQueue", qos: .userInteractive)
        videoOutput.setSampleBufferDelegate(self, queue: videoQueue)

        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        } else {
            errorCatched.send(.invalidVideoOutput)
        }

        videoOutput.connections.first?.videoOrientation = .portrait
        videoOutput.connections.first?.isVideoMirrored = (self.currentCameraPosition == .front)
    }

    func setupPhotoOutput() {
        self.photoOutput = AVCapturePhotoOutput()
        self.photoOutput.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])], completionHandler: nil)

        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        } else {
            errorCatched.send(.invalidPhotoOutput)
        }
    }

    func setupPreviewLayer(on view: UIView) {
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.layer.frame
    }

    func switchCameraInput() {
        defer { self.isCameraSwitching = false }
        self.isCameraSwitching = true

        // start configuration
        captureSession.beginConfiguration()

        switch self.currentCameraPosition {
        case .back:
            captureSession.removeInput(backInput)
            captureSession.addInput(frontInput)
            self.currentCameraPosition = .front

        case .front:
            captureSession.removeInput(frontInput)
            captureSession.addInput(backInput)
            self.currentCameraPosition = .back
        }

//        videoOutput.connections.first?.videoOrientation = .portrait
//        videoOutput.connections.first?.isVideoMirrored = (self.currentCameraPosition == .front)

        // commit configuration
        captureSession.commitConfiguration()
    }
}

extension CameraController: AVCaptureVideoDataOutputSampleBufferDelegate, AVCapturePhotoCaptureDelegate {
    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // 如有需要，可透過 VideoOutput 擷取照片
//        if !takePicture {
//            return //we have nothing to do with the image buffer
//        }
//
//        //try and get a CVImageBuffer out of the sample buffer
//        guard let cvBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
//            return
//        }
//
//        //get a CIImage out of the CVImageBuffer
//        let ciImage = CIImage(cvImageBuffer: cvBuffer)
//
//        //get UIImage out of CIImage
//        let uiImage = UIImage(ciImage: ciImage)
//
//        DispatchQueue.main.async {
//            self.photoCaptured.send(uiImage)
//            self.takePicture = false
//        }
    }

    // MARK: - AVCapturePhotoCaptureDelegate

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            self.errorCatched.send(.photoOutputError(error))
        }

        // See: https://stackoverflow.com/a/50528296/14631157
        guard let cgImage = photo.cgImageRepresentation() else { return }
        let orientation = photo.metadata[kCGImagePropertyOrientation as String] as! NSNumber
        let uiOrientation = UIImage.Orientation(rawValue: orientation.intValue)!
        let image = UIImage(cgImage: cgImage, scale: 1, orientation: uiOrientation)

        self.imageCaptured.send(image)
    }
}

//
//  CameraController+Extension.swift
//  CameraController
//
//  Created by 江翰臻 on 2021/10/14.
//

import AVFoundation

extension CameraController {

    enum CameraPosition {
        case front
        case back
    }

    enum CameraControllerError: Error {
        case invalidCameraPermission
        case captureSessionAlreadyRunning

        case noBackCamera
        case noBackCameraInput
        case invalidBackCameraInput

        case noFrontCamera
        case noFrontCameraInput
        case invalidFrontCameraInput

        case invalidVideoOutput
        case invalidPhotoOutput

        case photoOutputError(Error)
        case unknown

        var string: String {
            switch self {
            case .invalidCameraPermission:
                return "invalid camera permission"

            case .captureSessionAlreadyRunning:
                return "captureSession is already running"

            case .noBackCamera:
                return "no back camera"
            case .noBackCameraInput:
                return "could not create input device from back camera"
            case .invalidBackCameraInput:
                return "could not add back camera input to capture session"

            case .noFrontCamera:
                return "no front camera"
            case .noFrontCameraInput:
                return "could not create input device from front camera"
            case .invalidFrontCameraInput:
                return "could not add front camera input to capture session"

            case .invalidVideoOutput:
                return "could not add video output"
            case .invalidPhotoOutput:
                return "could not add photo output"

            case .photoOutputError(let error):
                return error.localizedDescription
            case .unknown:
                return "unknown"
            }
        }
    }

    func checkPermissions(completion: ((Bool)->Void)?) {
        switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video) {
        case .authorized:
            completion?(true)

        case .notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { [weak self] authorized in
                completion?(authorized)
                if !authorized {
                    self?.errorCatched.send(.invalidCameraPermission)
                }
            }
        default:
            completion?(false)
            self.errorCatched.send(.invalidCameraPermission)
        }
    }
}

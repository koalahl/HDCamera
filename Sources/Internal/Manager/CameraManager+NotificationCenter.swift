//
//  CameraManager+NotificationCenter.swift of MijickCamera
//
//  Created by Tomasz Kurylik. Sending ❤️ from Kraków!
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//    - Medium: https://medium.com/@mijick
//
//  Copyright ©2024 Mijick. All rights reserved.


import Foundation
import UIKit

@MainActor class CameraManagerNotificationCenter {
    private(set) var parent: CameraManager!
}

// MARK: Setup
extension CameraManagerNotificationCenter {
    func setup(parent: CameraManager) {
        self.parent = parent
        NotificationCenter.default.addObserver(self, selector: #selector(handleSessionWasInterrupted), name: .AVCaptureSessionWasInterrupted, object: parent.captureSession)
        NotificationCenter.default.addObserver(self, selector: #selector(handleAppDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleAppWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
    }
}
private extension CameraManagerNotificationCenter {
    @objc func handleSessionWasInterrupted() {
        parent.attributes.lightMode = .off
        parent.videoOutput.reset()
    }
    @objc func handleAppDidBecomeActive() {
        // 通知 SwiftUI 刷新视图（关键！）
        // 因为 captureSession.isRunning 不是 @Published 属性，
        // SwiftUI 不知道需要重新渲染依赖它的视图
        parent.objectWillChange.send()
    }
    @objc func handleAppWillResignActive() {
        // App 进入后台时，可以在这里做清理工作（可选）
    }
}

// MARK: Reset
extension CameraManagerNotificationCenter {
    func reset() {
        NotificationCenter.default.removeObserver(self, name: .AVCaptureSessionWasInterrupted, object: parent?.captureSession)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
    }
}

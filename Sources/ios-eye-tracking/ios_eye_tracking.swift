import ARKit
import UIKit

public class EyeTracking: NSObject {
    let arSession = ARSession()

    public var sessions = [Session]()
    public var currentSession: Session?

    public func startSession() {
        guard ARFaceTrackingConfiguration.isSupported else {
            assertionFailure("Face tracking not supported on this device.")
            return
        }
        guard currentSession == nil else {
            print("⛔️ Eye Tracking already in progress. Call endSession() ⛔️")
            return
        }

        currentSession = Session()

        arSession.delegate = self
        let configuration = ARFaceTrackingConfiguration()
        configuration.worldAlignment = .gravity
        arSession.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }

    public func endSession() {
        arSession.pause()
        currentSession?.endTime = Date().timeIntervalSince1970

        guard let currentSession = currentSession else { return }
        sessions.append(currentSession)
        self.currentSession = nil
    }
}

extension EyeTracking: ARSessionDelegate {
    public func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        guard let anchor = anchors.first as? ARFaceAnchor else { return }
        print("⛔️ \(anchor.lookAtPoint)")
        // Convert to screen coordinates.

        print("⛔️ \(String(describing: anchor.blendShapes[.eyeBlinkLeft]))")
        print("⛔️ \(String(describing: anchor.blendShapes[.eyeBlinkRight]))")
        // Determine whether the user has blinked.
    }
}

public struct Session: Codable {
    public var beginTime = Date().timeIntervalSince1970
    public var endTime: TimeInterval?
    public var scanPath = [Gaze]()
}

public struct Gaze: Codable {
    public var timestamp = Date().timeIntervalSince1970
    public let x: Double
    public let y: Double
}
////
////  ARViewContainer.swift
////  tt
////
////  Created by 川原龍成 on 2025/01/14.
////
//
//import ARKit
//import SceneKit
//import SwiftUI
//
//struct ARViewContainer: UIViewRepresentable {
//    @Binding var selectedImage: UIImage?
//    @Binding var statusMessage: String
//
//    static let worldMapKey = "SavedWorldMapData"
//    static var saveWorldMapAction: (() -> Void)?
//    static var loadWorldMapAction: (() -> Void)?
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(parent: self)
//    }
//
//    func makeUIView(context: Context) -> ARSCNView {
//        let arView = ARSCNView()
//        let configuration = ARWorldTrackingConfiguration()
//        configuration.planeDetection = [.horizontal, .vertical]
//        arView.session.run(configuration)
//        arView.scene = SCNScene()
//        arView.delegate = context.coordinator
//        arView.session.delegate = context.coordinator
//
//        let coachingOverlay = ARCoachingOverlayView()
//        coachingOverlay.session = arView.session
//        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        coachingOverlay.delegate = context.coordinator
//        arView.addSubview(coachingOverlay)
//        
//        coachingOverlay.goal = .horizontalPlane
//        coachingOverlay.activatesAutomatically = true
//        coachingOverlay.setActive(true, animated: true)
//
//        let tapGesture = UITapGestureRecognizer(
//            target: context.coordinator,
//            action: #selector(Coordinator.handleTap(_:))
//        )
//        arView.addGestureRecognizer(tapGesture)
//        context.coordinator.sceneView = arView
//
//        Self.saveWorldMapAction = { context.coordinator.saveCurrentWorldMap() }
//        Self.loadWorldMapAction = { context.coordinator.loadWorldMap() }
//
//        return arView
//    }
//
//    func updateUIView(_ uiView: ARSCNView, context: Context) {}
//
//    class Coordinator: NSObject, ARSCNViewDelegate, ARSessionDelegate, ARCoachingOverlayViewDelegate {
//        var parent: ARViewContainer
//        var sceneView: ARSCNView?
//
//        init(parent: ARViewContainer) {
//            self.parent = parent
//        }
//
//        private func createPlaneNode(_ anchor: ARPlaneAnchor) -> SCNNode {
//            let planeGeometry = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
//            planeGeometry.firstMaterial?.diffuse.contents = UIColor.green.withAlphaComponent(0.5)
//            let planeNode = SCNNode(geometry: planeGeometry)
//            planeNode.position = SCNVector3(anchor.center.x, 0, anchor.center.z)
//            planeNode.eulerAngles.x = -.pi / 2
//            return planeNode
//        }
//
//        @objc func handleTap(_ sender: UITapGestureRecognizer) {
//            guard let sceneView = sceneView else { return }
//            let location = sender.location(in: sceneView)
//            let hitTestResults = sceneView.hitTest(location, types: [.existingPlaneUsingExtent, .estimatedVerticalPlane])
//            guard let result = hitTestResults.first else { return }
//
//            if let image = parent.selectedImage {
//                if let filename = ImageFileManager.saveImageToDocuments(image) {
//                    let anchor = ARAnchor(name: filename, transform: result.worldTransform)
//                    sceneView.session.add(anchor: anchor)
//                } else {
//                    parent.statusMessage = "Failed to save image."
//                }
//            }
//        }
//
//        func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
//            if let planeAnchor = anchor as? ARPlaneAnchor {
//                let planeNode = createPlaneNode(planeAnchor)
//                node.addChildNode(planeNode)
//            }
//            
//            guard let filename = anchor.name else { return }
//            if let image = ImageFileManager.loadImageFromDocuments(filename: filename) {
//                let photoNode = createPhotoNode(image)
//                node.addChildNode(photoNode)
//            }
//        }
//        
//        private func createPhotoNode(_ image: UIImage, useCropping: Bool = true) -> SCNNode {
//            let node = SCNNode()
//
//            if #available(iOS 18.0, *), useCropping {
//                // iOS 18以上で切り抜きを有効にする場合
//                Task {
//                    if let croppedImage = await ImageProcessing.cropImage(image: image) {
//                        // 画像のアスペクト比を取得
//                        let imageAspect = croppedImage.size.width / croppedImage.size.height
//
//                        // 平面の幅と高さをアスペクト比に基づいて調整
//                        let planeHeight: CGFloat = 0.4 // 高さを固定（例: 30cm）
//                        let planeWidth = planeHeight * imageAspect
//
//                        let geometry = SCNPlane(width: planeWidth, height: planeHeight)
//                        geometry.firstMaterial?.diffuse.contents = croppedImage
//                        geometry.firstMaterial?.isDoubleSided = true
//                        node.geometry = geometry
//
//                        // カメラに正面が向くようにする制約を追加
//                        let billboardConstraint = SCNBillboardConstraint()
//                        billboardConstraint.freeAxes = .Y // Y軸の回転を許可
//                        node.constraints = [billboardConstraint]
//                    }
//                }
//            } else {
//                // iOS 18未満、または切り抜きを無効にする場合
//                let geometry = SCNPlane(width: 0.3, height: 0.3)
//                geometry.firstMaterial?.diffuse.contents = image
//                geometry.firstMaterial?.isDoubleSided = true
//                node.geometry = geometry
//
//                let billboardConstraint = SCNBillboardConstraint()
//                node.constraints = [billboardConstraint]
//            }
//
//            return node
//        }
//
//
//        func saveCurrentWorldMap() {
//            parent.statusMessage = "Saving world map..."
//            sceneView?.session.getCurrentWorldMap { worldMap, error in
//                guard let map = worldMap else {
//                    self.parent.statusMessage = "Save Error: \(error?.localizedDescription ?? "Unknown Error")"
//                    return
//                }
//                do {
//                    let data = try NSKeyedArchiver.archivedData(withRootObject: map, requiringSecureCoding: true)
//                    UserDefaults.standard.set(data, forKey: ARViewContainer.worldMapKey)
//                    self.parent.statusMessage = "World map saved successfully!"
//                } catch {
//                    self.parent.statusMessage = "Save Error: \(error.localizedDescription)"
//                }
//            }
//        }
//
//        func loadWorldMap() {
//            parent.statusMessage = "Restoring world map..."
//            guard let data = UserDefaults.standard.data(forKey: ARViewContainer.worldMapKey) else {
//                parent.statusMessage = "Restore Error: No saved data"
//                return
//            }
//            do {
//                let worldMap = try NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: data)
//                guard let validWorldMap = worldMap else {
//                    parent.statusMessage = "Restore Error: Failed to decode ARWorldMap"
//                    return
//                }
//                let configuration = ARWorldTrackingConfiguration()
//                configuration.initialWorldMap = validWorldMap
//                configuration.planeDetection = [.horizontal, .vertical]
//                sceneView?.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
//                parent.statusMessage = "World map restored successfully!"
//            } catch {
//                parent.statusMessage = "Restore Error: \(error.localizedDescription)"
//            }
//        }
//    }
//}


import SwiftUI
import ARKit
import SceneKit

/// ARView (SwiftUI View)
struct ARView: View {
    let restoreWorldMap: ARWorldMap? // Optional: restore a previous AR world map

    @State private var selectedImage: UIImage? = nil
    @State private var isImagePickerPresented = false
    @State private var sliderValue: Double = 8.0
    @State private var statusMessage: String = "準備完了"
    @State private var worldName: String = ""
    @State private var isNameAlertPresented = false

    @EnvironmentObject var store: WorldMapStore

    var body: some View {
        ZStack {
            ARViewContainer(selectedImage: $selectedImage,
                            statusMessage: $statusMessage,
                            store: store,
                            restoreMap: restoreWorldMap)
                .edgesIgnoringSafeArea(.all)

            VStack {
                // Top bar with navigation buttons
                HStack {
                    Button(action: { /* Back navigation action */ }) {
                        Image(systemName: "arrow.left")  // 戻る矢印
                            .font(.title2)
                            .padding()
                            .background(Color.white.opacity(0.8))
                            .clipShape(Circle())
                    }

                    Button(action: { /* Forward navigation action */ }) {
                        Image(systemName: "arrow.right")  // 進む矢印
                            .font(.title2)
                            .padding()
                            .background(Color.white.opacity(0.8))
                            .clipShape(Circle())
                    }

                    Spacer()

                    Button(action: { /* Close action */ }) {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .padding()
                            .background(Color.white.opacity(0.8))
                            .clipShape(Circle())
                    }
                }
                .padding([.top, .horizontal], 20)  // トップの余白調整

                Spacer()

                // Slider at the bottom
                VStack {
                    HStack {
                        Button(action: { sliderValue = max(sliderValue - 1, 1) }) {
                            Image(systemName: "minus.circle")
                                .font(.title2)  // 小さく調整
                        }

                        Slider(value: $sliderValue, in: 1...16, step: 1)
                            .frame(width: 200)
                            .padding(.horizontal, 10)

                        Button(action: { sliderValue = min(sliderValue + 1, 16) }) {
                            Image(systemName: "plus.circle")
                                .font(.title2)
                        }
                    }
                    .padding(8)
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(12)

                    Text("\(sliderValue, specifier: "%.1f")")
                        .font(.caption)
                }
                .padding()

                // Toolbar with buttons
                HStack(spacing: 40) {
                    Button(action: {
                        isImagePickerPresented = true
                    }) {
                        Image(systemName: "photo.fill")
                            .font(.title2)
                            .frame(width: 50, height: 50)
                    }

                    Button(action: { /* Add drawing action */ }) {
                        Image(systemName: "pencil")
                            .font(.title2)
                            .frame(width: 50, height: 50)
                    }

                    Button(action: { /* Add color picker action */ }) {
                        Circle()
                            .fill(Color.purple)
                            .frame(width: 40, height: 40)
                    }

                    Button(action: {
                        isNameAlertPresented = true // Save world map button action
                    }) {
                        Image(systemName: "square.and.arrow.down")
                            .font(.title2)
                            .frame(width: 50, height: 50)
                    }
                }
                .padding()
                .background(Color.white.opacity(0.8))
                .cornerRadius(12)
            }
            .padding()
        }
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(selectedImage: $selectedImage)
        }
        .alert("ワールドを保存", isPresented: $isNameAlertPresented) {
            TextField("ワールド名", text: $worldName)
            Button("保存") {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy年MM月dd日"
                let dateStr = formatter.string(from: Date())

                ARViewContainer.saveWorldMapAction?(worldName, dateStr)

                worldName = ""
            }
            Button("キャンセル", role: .cancel) {}
        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    @Binding var selectedImage: UIImage?
    @Binding var statusMessage: String

    @ObservedObject var store: WorldMapStore

    let restoreMap: ARWorldMap?

    static let worldMapKey = "SavedWorldMapData"

    static var saveWorldMapAction: ((String, String) -> Void)?
    static var loadWorldMapAction: (() -> Void)?

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self, store: store, restoreMap: restoreMap)
    }

    func makeUIView(context: Context) -> ARSCNView {
        let arView = ARSCNView()
        arView.session.delegate = context.coordinator
        arView.delegate = context.coordinator

        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]

        if let map = restoreMap {
            configuration.initialWorldMap = map
            arView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        } else {
            arView.session.run(configuration)
        }

        arView.scene = SCNScene()

        // Add ARCoachingOverlayView
        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.session = arView.session
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        coachingOverlay.goal = .horizontalPlane
        arView.addSubview(coachingOverlay)

        // Tap gesture for placing images
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        arView.addGestureRecognizer(tapGesture)

        // Long press gesture for deleting objects
        let longPressGesture = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleLongPress(_:)))
        arView.addGestureRecognizer(longPressGesture)

        context.coordinator.sceneView = arView

        Self.saveWorldMapAction = { name, dateString in
            context.coordinator.saveCurrentWorldMap(worldName: name, dateString: dateString)
        }
        Self.loadWorldMapAction = {
            // context.coordinator.loadWorldMapSingle() (implement as needed)
        }

        return arView
    }

    func updateUIView(_ uiView: ARSCNView, context: Context) {}

    class Coordinator: NSObject, ARSCNViewDelegate, ARSessionDelegate {
        var parent: ARViewContainer
        var sceneView: ARSCNView?

        @ObservedObject var store: WorldMapStore
        let restoreMap: ARWorldMap?

        // Store node-anchor mapping
        var nodeAnchorMap: [SCNNode: ARAnchor] = [:]
        
        // Store the node to be deleted
        var nodeToDelete: SCNNode?

        init(parent: ARViewContainer, store: WorldMapStore, restoreMap: ARWorldMap?) {
            self.parent = parent
            self.store = store
            self.restoreMap = restoreMap
        }

        @objc func handleLongPress(_ sender: UILongPressGestureRecognizer) {
            guard let sceneView = sceneView else { return }
            let location = sender.location(in: sceneView)

            // Long press started
            if sender.state == .began {
                let hitTestResults = sceneView.hitTest(location, options: nil)
                if let tappedNode = hitTestResults.first?.node {
                    // Store the node that was long-pressed
                    nodeToDelete = tappedNode

                    // Show the deletion confirmation alert
                    showDeletionAlert(for: tappedNode)
                }
            }
        }

        func showDeletionAlert(for node: SCNNode) {
            guard let sceneView = sceneView else { return }

            // Create an alert to confirm deletion
            let alert = UIAlertController(title: "削除確認", message: "選択した写真を削除しますか？", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "削除", style: .destructive, handler: { [weak self] _ in
                self?.deleteNode(node)
            }))

            // Present the alert on the current view controller
            if let viewController = sceneView.window?.rootViewController {
                viewController.present(alert, animated: true, completion: nil)
            }
        }

        func deleteNode(_ node: SCNNode) {
            guard let sceneView = sceneView else { return }

            // Remove the node from the scene
            node.removeFromParentNode()

            // If the node has an associated anchor, remove it from the AR session
            if let anchor = nodeAnchorMap[node] {
                sceneView.session.remove(anchor: anchor)
            }

            // Optionally, remove the anchor-node mapping from the dictionary
            nodeAnchorMap.removeValue(forKey: node)

            // Optional: Perform any additional actions (e.g., update UI state, etc.)
            parent.statusMessage = "写真が削除されました"
        }

        func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
            guard let filename = anchor.name else { return }
            if let image = ImageFileManager.loadImageFromDocuments(filename: filename) {
                let photoNode = createPhotoNode(image)
                node.addChildNode(photoNode)

                // Store the node-anchor mapping
                nodeAnchorMap[photoNode] = anchor
            }
        }
    
        
        @objc func handleTap(_ sender: UITapGestureRecognizer) {
                    guard let sceneView = sceneView else { return }
                    let location = sender.location(in: sceneView)

                    let hits = sceneView.hitTest(location, types: [.existingPlaneUsingExtent, .estimatedVerticalPlane])
                    guard let result = hits.first else { return }

                    if let image = parent.selectedImage {
                        if let filename = ImageFileManager.saveImageToDocuments(image) {
                            let anchor = ARAnchor(name: filename, transform: result.worldTransform)
                            sceneView.session.add(anchor: anchor)
                        } else {
                            parent.statusMessage = "画像の保存に失敗しました"
                        }
                    }
                }
        private func createPhotoNode(_ image: UIImage, useCropping: Bool = true) -> SCNNode {
            let node = SCNNode()

            if #available(iOS 18.0, *), useCropping {
                // iOS 18以上で切り抜きを有効にする場合
                Task {
                    if let croppedImage = await ImageProcessing.cropImage(image: image) {
                        // 画像のアスペクト比を取得
                        let imageAspect = croppedImage.size.width / croppedImage.size.height

                        // 平面の幅と高さをアスペクト比に基づいて調整
                        let planeHeight: CGFloat = 0.4 // 高さを固定（例: 30cm）
                        let planeWidth = planeHeight * imageAspect

                        let geometry = SCNPlane(width: planeWidth, height: planeHeight)
                        geometry.firstMaterial?.diffuse.contents = croppedImage
                        geometry.firstMaterial?.isDoubleSided = true
                        node.geometry = geometry

                        // カメラに正面が向くようにする制約を追加
                        let billboardConstraint = SCNBillboardConstraint()
                        billboardConstraint.freeAxes = .Y // Y軸の回転を許可
                        node.constraints = [billboardConstraint]
                    }
                }
            } else {
                // iOS 18未満、または切り抜きを無効にする場合
                let geometry = SCNPlane(width: 0.3, height: 0.3)
                geometry.firstMaterial?.diffuse.contents = image
                geometry.firstMaterial?.isDoubleSided = true
                node.geometry = geometry

                let billboardConstraint = SCNBillboardConstraint()
                node.constraints = [billboardConstraint]
            }

            return node
        }
        
        
        func saveCurrentWorldMap(worldName: String, dateString: String) {
            guard let sceneView = sceneView else { return }
            parent.statusMessage = "ワールドマップ保存中..."
            
            // 1) スクショ
            let screenshot = sceneView.snapshot()
            
            // 2) 切り抜き＆リサイズ (例: 351×200)
            let cropRect = CGRect(x: 0, y: 900, width: screenshot.size.width, height: screenshot.size.width * (200/351))
            var finalThumb: UIImage? = nil
            if let cropped = screenshot.cropped(to: cropRect) {
                finalThumb = cropped.resized(to: CGSize(width: 351, height: 200))
            }
            
            // 3) サムネ保存
            let thumbFilename = finalThumb != nil ? ImageFileManager.saveImageToDocuments(finalThumb!) : nil
            
            // 4) getCurrentWorldMap
            sceneView.session.getCurrentWorldMap { worldMap, error in
                guard let map = worldMap else {
                    self.parent.statusMessage = "保存エラー: \(error?.localizedDescription ?? "不明")"
                    return
                }

                // 5) store へ追加
                self.store.addWorldMapRecord(map, title: worldName, dateString: dateString, thumbnailFilename: thumbFilename)
                self.parent.statusMessage = "保存完了！（\(worldName), \(dateString)）"
            }
        }

    }
}


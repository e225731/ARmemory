import SwiftUI
import ARKit
import SceneKit



struct ARView: View {
    @State private var selectedImage: UIImage? = nil
    @State private var isImagePickerPresented = false
    @State private var statusMessage: String = "準備完了"
    @State private var isDetectingPlane = true
    @State private var detectionCompleteMessage = false

    var body: some View {
        
        ZStack {
            
            ARViewContainer(selectedImage: $selectedImage, statusMessage: $statusMessage, isDetectingPlane: $isDetectingPlane, detectionCompleteMessage: $detectionCompleteMessage).edgesIgnoringSafeArea(.all)

            VStack {
                
                
                if isDetectingPlane {
                    VStack {
                        ProgressView("Searching for planes...")
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .padding()
                            .background(Color.black.opacity(0.5))
                            .cornerRadius(8)
                            .foregroundColor(.white)
                        Spacer()
                    }
                } else if detectionCompleteMessage {
                    VStack {
                        Text("Planes detected!")
                            .font(.headline)
                            .padding()
                            .background(Color.green.opacity(0.7))
                            .cornerRadius(8)
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            detectionCompleteMessage = false
                        }
                    }
                }
                // ステータスメッセージ表示
                Text(statusMessage)
                    .padding()
                    .background(Color.black.opacity(0.6))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(.top, 40)
                
                Spacer()
                
                // ワールドマップ保存・復元ボタン
                HStack {
                    Button(action: {
                        ARViewContainer.saveWorldMapAction?()
                    }) {
                        Text("ワールドマップ保存")
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding()
                    
                    Button(action: {
                        ARViewContainer.loadWorldMapAction?()
                    }) {
                        Text("ワールドマップ復元")
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding()
                }

                // 画像選択ボタン
                Button(action: {
                    isImagePickerPresented = true
                }) {
                    Text("Select Image")
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.bottom, 20)
            }
        }
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(selectedImage: $selectedImage)
        }
    }
}


struct ARViewContainer: UIViewRepresentable {
    @Binding var selectedImage: UIImage?
    @Binding var statusMessage: String
    
    @Binding var isDetectingPlane: Bool
    @Binding var detectionCompleteMessage: Bool // Add this binding
    

    static let worldMapKey = "SavedWorldMapData"
    static var saveWorldMapAction: (() -> Void)?
    static var loadWorldMapAction: (() -> Void)?

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> ARSCNView {
        let arView = ARSCNView()
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        arView.session.run(configuration)
        arView.scene = SCNScene()
        arView.delegate = context.coordinator
        arView.session.delegate = context.coordinator

        let tapGesture = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleTap(_:))
        )
        arView.addGestureRecognizer(tapGesture)
        context.coordinator.sceneView = arView

        Self.saveWorldMapAction = { context.coordinator.saveCurrentWorldMap() }
        Self.loadWorldMapAction = { context.coordinator.loadWorldMap() }

        return arView
    }

    func updateUIView(_ uiView: ARSCNView, context: Context) {}

    class Coordinator: NSObject, ARSCNViewDelegate, ARSessionDelegate {
        var parent: ARViewContainer
        var sceneView: ARSCNView?

        init(parent: ARViewContainer) {
            self.parent = parent
        }
        
                // 緑色の半透明平面を作成
                private func createPlaneNode(_ anchor: ARPlaneAnchor) -> SCNNode {
                    let planeGeometry = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
                    planeGeometry.firstMaterial?.diffuse.contents = UIColor.green.withAlphaComponent(0.5) // 半透明の緑
        
                    let planeNode = SCNNode(geometry: planeGeometry)
                    planeNode.position = SCNVector3(anchor.center.x, 0, anchor.center.z)
                    planeNode.eulerAngles.x = -.pi / 2 // 平面を水平方向に調整
        
                    return planeNode
                }
        
        

        // タップ処理: 平面に画像を追加
        @objc func handleTap(_ sender: UITapGestureRecognizer) {
            guard let sceneView = sceneView else { return }
            let location = sender.location(in: sceneView)
            let hitTestResults = sceneView.hitTest(location, types: [.existingPlaneUsingExtent, .estimatedVerticalPlane])
            guard let result = hitTestResults.first else { return }

            if let image = parent.selectedImage {
                if let filename = ImageFileManager.saveImageToDocuments(image) {
                    let anchor = ARAnchor(name: filename, transform: result.worldTransform)
                    sceneView.session.add(anchor: anchor)
                } else {
                    parent.statusMessage = "画像の保存に失敗しました"
                }
            }
        }

        // 平面アンカーに画像を追加
        func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
            
            if let planeAnchor = anchor as? ARPlaneAnchor {
                    let planeNode = createPlaneNode(planeAnchor)
                    node.addChildNode(planeNode)

                    DispatchQueue.main.async {
                        self.parent.isDetectingPlane = false
                        self.parent.detectionCompleteMessage = true
                    }
                }
            
            guard let filename = anchor.name else { return }
                        if let image = ImageFileManager.loadImageFromDocuments(filename: filename) {
                            let photoNode = createPhotoNode(image)
                            node.addChildNode(photoNode)
                        }
            
            func updateUIView(_ uiView: ARSCNView, context: Context) {}
        }

        private func createPhotoNode(_ image: UIImage) -> SCNNode {
            let node = SCNNode()
            
            if #available(iOS 18.0, *) {
                // iOS 18以上の場合
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
                // iOS 18未満の場合
                let geometry = SCNPlane(width: 0.3, height: 0.3)
                geometry.firstMaterial?.diffuse.contents = image
                geometry.firstMaterial?.isDoubleSided = true
                node.geometry = geometry

                let billboardConstraint = SCNBillboardConstraint()
                node.constraints = [billboardConstraint]
            }
            
            return node
        }


        // ワールドマップ保存
        func saveCurrentWorldMap() {
            parent.statusMessage = "ワールドマップ保存中..."
            sceneView?.session.getCurrentWorldMap { worldMap, error in
                guard let map = worldMap else {
                    self.parent.statusMessage = "保存エラー: \(error?.localizedDescription ?? "不明なエラー")"
                    return
                }
                do {
                    let data = try NSKeyedArchiver.archivedData(withRootObject: map, requiringSecureCoding: true)
                    UserDefaults.standard.set(data, forKey: ARViewContainer.worldMapKey)
                    self.parent.statusMessage = "ワールドマップ保存完了！"
                } catch {
                    self.parent.statusMessage = "保存エラー: \(error.localizedDescription)"
                }
            }
        }

        // ワールドマップ復元
        func loadWorldMap() {
            parent.statusMessage = "ワールドマップ復元中..."
            guard let data = UserDefaults.standard.data(forKey: ARViewContainer.worldMapKey) else {
                parent.statusMessage = "復元エラー: 保存データがありません"
                return
            }
            do {
                let worldMap = try NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: data)
                guard let validWorldMap = worldMap else {
                    parent.statusMessage = "復元エラー: ARWorldMapのデコード失敗"
                    return
                }
                let configuration = ARWorldTrackingConfiguration()
                configuration.initialWorldMap = validWorldMap
                configuration.planeDetection = [.horizontal, .vertical]
                sceneView?.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
                parent.statusMessage = "ワールドマップ復元完了！"
            } catch {
                parent.statusMessage = "復元エラー: \(error.localizedDescription)"
            }
        }
    }
}


struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}

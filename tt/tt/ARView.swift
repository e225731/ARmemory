import SwiftUI
import ARKit
import SceneKit

struct ARView: View {
    @State private var selectedImage: UIImage? = nil
    @State private var isImagePickerPresented = false
    
    var body: some View {
        ZStack {
            ARViewContainer(selectedImage: $selectedImage)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                Button(action: {
                    isImagePickerPresented = true
                }) {
                    Text("Select Image")
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
            }
        }
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(selectedImage: $selectedImage)
        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    @Binding var selectedImage: UIImage?
    
    class Coordinator: NSObject, ARSCNViewDelegate {
        var parent: ARViewContainer
        var sceneView: ARSCNView?
        
        init(parent: ARViewContainer) {
            self.parent = parent
        }
        
        @objc func handleTap(_ sender: UITapGestureRecognizer) {
            guard let sceneView = sceneView else { return }
            let location = sender.location(in: sceneView)
            let hitTestResults = sceneView.hitTest(location, types: [.existingPlaneUsingExtent, .estimatedVerticalPlane])
            
            if let result = hitTestResults.first, let selectedImage = parent.selectedImage {
                let position = SCNVector3(result.worldTransform.columns.3.x,
                                          result.worldTransform.columns.3.y,
                                          result.worldTransform.columns.3.z)
                let node = createPhotoNode(selectedImage, position: position)
                sceneView.scene.rootNode.addChildNode(node)
            }
        }
        
        private func createPhotoNode(_ image: UIImage, position: SCNVector3) -> SCNNode {
            let node = SCNNode()
            let geometry = SCNPlane(width: 0.3, height: 0.3) // No resizing here, just a fixed size
            geometry.firstMaterial?.diffuse.contents = image
            geometry.firstMaterial?.isDoubleSided = true
            node.geometry = geometry
            node.position = position
            
            // Add this to always face the user
            let billboardConstraint = SCNBillboardConstraint()
            node.constraints = [billboardConstraint]
            
            return node
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIView(context: Context) -> ARSCNView {
        let arView = ARSCNView()
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical] // Enable plane detection
        arView.session.run(configuration)
        arView.scene = SCNScene()
        
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        arView.addGestureRecognizer(tapGesture)
        context.coordinator.sceneView = arView
        
        return arView
    }
    
    func updateUIView(_ uiView: ARSCNView, context: Context) {}
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

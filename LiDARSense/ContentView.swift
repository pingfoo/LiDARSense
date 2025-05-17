//
//  ContentView.swift
//  LiDARSense
//
//  Created by T Mori on 5/4/2023.
//

import ARKit
import SwiftUI
import SceneKit
import AVFoundation
import UIKit
import ZIPFoundation
import Combine
import AudioToolbox

class ContentViewModel: ObservableObject {
    @Published var capturedPlyFileURLs: [URL] = []
    @Published var capturedImageURLs: [URL] = []
}


struct ContentView {
    @State var session: ARSession
    @State var scene: SCNScene
    @State var pointColor = Color.white

    @State private var showPointCloud = true
    @State private var showMesh = false
    @State private var player: AVAudioPlayer?
    @State private var pointCloudData: [(position: SIMD3<Float>, color: UIColor)] = []
    @State private var isTakingPointCloud = false
    @State private var isScreenBlack = false
    @State private var currentTimestamp: String?
    
    @ObservedObject var viewModel = ContentViewModel()
    
    init() {
        let session = ARSession()
        let configuration = ARWorldTrackingConfiguration()
        configuration.sceneReconstruction = .mesh
        session.run(configuration)
        self.session = session
        self.scene = SCNScene()
    }
}

extension ContentView: View {
    func exitApp() {
        UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
    }

    func createPlyString(from points: [(position: SIMD3<Float>, color: UIColor)]) -> String {
        let header = "ply\n" +
            "format ascii 1.0\n" +
            "element vertex \(points.count)\n" +
            "property float x\n" +
            "property float y\n" +
            "property float z\n" +
            "property uchar red\n" +
            "property uchar green\n" +
            "property uchar blue\n" +
            "end_header\n"

        var body = ""

        for point in points {
            let red = UInt8((point.color.cgColor.components?[0] ?? 0.0) * 255)
            let green = UInt8((point.color.cgColor.components?[1] ?? 0.0) * 255)
            let blue = UInt8((point.color.cgColor.components?[2] ?? 0.0) * 255)

            body += "\(point.position.x) \(point.position.y) \(point.position.z) \(red) \(green) \(blue)\n"
        }

        return header + body
    }

    func savePlyFile() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        


        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if !self.isTakingPointCloud {
                timer.invalidate()
                guard !self.pointCloudData.isEmpty else { return }
                let plyString = self.createPlyString(from: self.pointCloudData)
                let dateString = currentTimestamp ?? dateFormatter.string(from: Date())
                let fileName = "PointCloud_\(dateString).ply"
                let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(fileName)
                
                do {
                      try plyString.write(to: fileURL, atomically: true, encoding: .utf8)
                      print("PLY file saved at: \(fileURL.path)")
                      self.viewModel.capturedPlyFileURLs.append(fileURL)
                  } catch {
                      print("Error saving PLY file: \(error)")
                  }
                  self.pointCloudData.removeAll()
            } else {
                guard let pointCloud = self.session.currentFrame?.rawFeaturePoints else { return }
                let pointsWithColor = pointCloud.points.map { (position: $0, color: UIColor(self.pointColor)) }
                self.pointCloudData.append(contentsOf: pointsWithColor)
            }
        }
    }
    
    func saveImage(_ image: UIImage) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        let dateString = currentTimestamp ?? dateFormatter.string(from: Date())
        let fileName = "Image_\(dateString).jpg"
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(fileName)
        
        if let data = image.jpegData(compressionQuality: 0.9) {
            do {
                try data.write(to: fileURL)
                print("Image saved at: \(fileURL.path)")
                self.viewModel.capturedImageURLs.append(fileURL)
            } catch {
                print("Error saving image: \(error)")
            }
        }
        
    }

    func captureImage() {
        if let currentFrame = self.session.currentFrame {
            let image = CIImage(cvPixelBuffer: currentFrame.capturedImage)
            let context = CIContext()
            if let cgImage = context.createCGImage(image, from: image.extent) {
                let uiImage = UIImage(cgImage: cgImage)
                saveImage(uiImage)
            }
        }
    }

    func shareFiles() {
        guard !viewModel.capturedPlyFileURLs.isEmpty, !viewModel.capturedImageURLs.isEmpty else {
            print("No PLY or JPG files found")
            return
        }

        let fileManager = FileManager.default
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        let dateString = dateFormatter.string(from: Date())
        let zipFileName = "PointCloud_\(dateString).zip"
        let documentsDirectoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let zipFileURL = documentsDirectoryURL.appendingPathComponent(zipFileName)

        do {
            let archive = Archive(url: zipFileURL, accessMode: .create)
            for plyFileURL in viewModel.capturedPlyFileURLs {
                try archive?.addEntry(with: plyFileURL.lastPathComponent, relativeTo: documentsDirectoryURL)
            }
            for imageFileURL in viewModel.capturedImageURLs {
                try archive?.addEntry(with: imageFileURL.lastPathComponent, relativeTo: documentsDirectoryURL)
            }

            DispatchQueue.main.async {
                let activityViewController = UIActivityViewController(activityItems: [zipFileURL], applicationActivities: nil)
                if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                    scene.windows.first?.rootViewController?.present(activityViewController, animated: true, completion: nil)
                }
            }

        } catch {
            print("Error sharing files: \(error)")
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ARSceneView(
                session: self.$session,
                scene: self.$scene,
                pointColor: self.$pointColor,
                showPointCloud: self.$showPointCloud,
                showMesh: self.$showMesh
            )
            .ignoresSafeArea()

            Color.black
                .opacity(isScreenBlack ? 1 : 0)
                .animation(.easeInOut(duration: 0.1))
            
            VStack {
                HStack {
                    Button(action: {
                        self.showPointCloud.toggle()
                        let recordStartSoundID: SystemSoundID = 1103
                        AudioServicesPlaySystemSound(recordStartSoundID)
                    }, label: {
                        Text("Point")
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                    })
                    .padding()
                    .background(Color.green.opacity(0.7))
                    .cornerRadius(10)
                    
                    Button(action: {
                        self.showMesh.toggle()
                        let recordStartSoundID: SystemSoundID = 1103
                        AudioServicesPlaySystemSound(recordStartSoundID)
                    }, label: {
                        Text("Mesh")
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                    })
                    .padding()
                    .background(Color.yellow.opacity(0.7))
                    .cornerRadius(10)
                }
                
                
                HStack {
                    Button(action: {
                        self.isTakingPointCloud = true
                        savePlyFile()
                        let recordStartSoundID: SystemSoundID = 1117
                        AudioServicesPlaySystemSound(recordStartSoundID)
                    }, label: {
                        Text("Take")
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                    })
                    .padding()
                    .background(Color.blue.opacity(0.7))
                    .cornerRadius(10)
                    .disabled(isTakingPointCloud)

                    Button(action: {
                        self.isTakingPointCloud = false
                        self.isScreenBlack = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            self.isScreenBlack = false
                        }
                        let recordStartSoundID: SystemSoundID = 1118
                        AudioServicesPlaySystemSound(recordStartSoundID)
                        captureImage()
                    }, label: {
                        Text("Stop")
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                    })
                    .padding()
                    .background(Color.red.opacity(0.7))
                    .cornerRadius(10)
                    .disabled(!isTakingPointCloud)
                }

                HStack {
                    Button(action: {
                        shareFiles()
                        let recordStartSoundID: SystemSoundID = 1103
                        AudioServicesPlaySystemSound(recordStartSoundID)
                    }, label: {
                        Text("Share")
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                    })
                    .padding()
                    .background(Color.orange.opacity(0.7))
                    .cornerRadius(10)

                    Button(action: {
                        exitApp()
                        let recordStartSoundID: SystemSoundID = 1103
                        AudioServicesPlaySystemSound(recordStartSoundID)
                    }, label: {
                        Text("Exit")
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                    })
                    .padding()
                    .background(Color.red.opacity(0.7))
                    .cornerRadius(10)
                }
            }
            .padding(.bottom, 20)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
        

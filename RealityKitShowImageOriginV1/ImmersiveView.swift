//
//  ImmersiveView.swift
//  RealityKitShowImageOriginV1
//
//

import SwiftUI
import RealityKit
import RealityKitContent
@MainActor
@Observable
class ModelUpdater {
    var pointXPosition:Float = 0
}

struct ImmersiveView: View {
    @Environment(ModelUpdater.self)
    private var updater:ModelUpdater
    @State
    private var triangleModel:CreateDynamicTriangle = .init()
    var body: some View {
        RealityView { content in
            // Add the initial RealityKit content
            if let immersiveContentEntity = try? await Entity(named: "Immersive", in: realityKitContentBundle) {
                let triangle = try! triangleModel.triangleEntity()
                content.add(triangle)
                triangle.position = .init(x: 0, y: 0, z: -1)
                // Put skybox here.  See example in World project available at
                // https://developer.apple.com/
            }
        }
       
        .onChange(of: updater.pointXPosition, initial: true, { oldValue, newValue in
            // 在这里更新顶点位置
            triangleModel.updateVertexPosition(index:2, newPosition: [Float(newValue),1, 0])
        })
    }
}


struct MyVertex {
    var position: SIMD3<Float> = .zero
    var color: UInt32 = .zero
    var texCoord: SIMD2<Float> = .zero  // 添加纹理坐标
}

extension MyVertex {
    static var vertexAttributes: [LowLevelMesh.Attribute] = [
        .init(semantic: .position, format: .float3, offset: MemoryLayout<Self>.offset(of: \.position)!),
        .init(semantic: .color, format: .uchar4Normalized_bgra, offset: MemoryLayout<Self>.offset(of: \.color)!) ,
        .init(semantic: .uv0, format: .float2, offset: MemoryLayout<Self>.offset(of: \.texCoord)!)  // 添加纹理坐标属性
    ]


    static var vertexLayouts: [LowLevelMesh.Layout] = [
        .init(bufferIndex: 0, bufferStride: MemoryLayout<Self>.stride)
    ]


    static var descriptor: LowLevelMesh.Descriptor {
        var desc = LowLevelMesh.Descriptor()
        desc.vertexAttributes = MyVertex.vertexAttributes
        desc.vertexLayouts = MyVertex.vertexLayouts
        desc.indexType = .uint32
        return desc
    }
}
@MainActor
@Observable
class CreateDynamicTriangle {

    private var lowLevelMesh: LowLevelMesh?
    
    func triangleMesh() throws -> LowLevelMesh {
        var desc = MyVertex.descriptor
        desc.vertexCapacity = 3  // 改为3个顶点
        desc.indexCapacity = 3   // 改为3个索引

        let mesh = try LowLevelMesh(descriptor: desc)

    
        mesh.withUnsafeMutableBytes(bufferIndex: 0) { rawBytes in
            let vertices = rawBytes.bindMemory(to: MyVertex.self)
            vertices[0] = MyVertex(position: [-1, -1, 0], color: 0xFF00FF00, texCoord: [0, 1])
            vertices[1] = MyVertex(position: [ 1, -1, 0], color: 0xFFFF0000, texCoord: [1, 1])
            vertices[2] = MyVertex(position: [ 0,  1, 0], color: 0xFF0000FF, texCoord: [0.5, 0])
        }

        mesh.withUnsafeMutableIndices { rawIndices in
            let indices = rawIndices.bindMemory(to: UInt32.self)
            indices[0] = 0
            indices[1] = 1
            indices[2] = 2
        }

        let meshBounds = BoundingBox(min: [-1, -1, 0], max: [1, 1, 0])
        mesh.parts.replaceAll([
            LowLevelMesh.Part(
                indexCount: 3,  // 更新为3个索引
                topology: .triangle,
                bounds: meshBounds
            )
        ])

        self.lowLevelMesh = mesh
        return mesh
    }

    func triangleEntity() throws -> Entity {
        let lowLevelMesh = try triangleMesh()  // 调用新的triangleMesh()方法
        let resource = try MeshResource(from: lowLevelMesh)

        // 创建纹理材质
        let uiImage:UIImage = .init(data: try! Data(contentsOf: Bundle.main.url(forResource: "amsler-grid-image.jpg", withExtension: "")!))!
            let cgImage:CGImage = uiImage.cgImage!
            
        let material = UnlitMaterial(texture: try .init(image: cgImage, options: .init(semantic: nil)))

        let modelComponent = ModelComponent(mesh: resource, materials: [material])

        let entity = Entity()
        entity.name = "Triangle"  // 更新名称
        entity.components.set(modelComponent)
        entity.scale *= 0.1
        return entity
    }

    func updateVertexPosition(index: Int, newPosition: SIMD3<Float>) {
        guard let mesh = lowLevelMesh else { return }
        
        mesh.withUnsafeMutableBytes(bufferIndex: 0) { rawBytes in
            let vertices = rawBytes.bindMemory(to: MyVertex.self)
            vertices[index].position = newPosition
        }
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
        .environment(AppModel())
}

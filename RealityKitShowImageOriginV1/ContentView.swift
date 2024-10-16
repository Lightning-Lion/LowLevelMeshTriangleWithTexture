//
//  ContentView.swift
//  RealityKitShowImageOriginV1
//
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {
    @Environment(ModelUpdater.self)
    private var updater:ModelUpdater
    @Environment(AppModel.self) private var appModel
    var body: some View {
        @Bindable
        var updaterB = updater
        VStack {
            if appModel.immersiveSpaceState == .open {
                Slider(value: $updaterB.pointXPosition, in: -1...1, step: 0.01) { _ in }
                    .frame(width: 300)
            }
            Text("LowLevelMesh Triangle with Texture")

            ToggleImmersiveSpaceButton()
        }
        .padding()
        .animation(.smooth, value: appModel.immersiveSpaceState)
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
        .environment(AppModel())
}

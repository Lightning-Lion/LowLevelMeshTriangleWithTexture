//
//  RealityKitShowImageOriginV1App.swift
//  RealityKitShowImageOriginV1
//
//

import SwiftUI

@main
struct RealityKitShowImageOriginV1App: App {

    @State private var appModel = AppModel()
    
    @State
    private var updater = ModelUpdater()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appModel)
        }
        .environment(updater)

        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            ImmersiveView()
                .environment(appModel)
                .onAppear {
                    appModel.immersiveSpaceState = .open
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                }
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
        .environment(updater)
     }
}

//
//  AudiR8.swift
//  TestObjectOnTheReality
//
//  Created by Vitalii Obertynskyi on 9/5/17.
//  Copyright © 2017 Vitalii Obertynskyi. All rights reserved.
//

import Foundation
import SceneKit
import ARKit

class AudiR8: SCNScene {

    let contentRootNode = SCNNode()
    private(set) var shell: SCNNode!
    private var leftWheel: SCNNode!
    private var rightWeel: SCNNode!
    
    private var shellColor: SCNMaterial!
    
    override init() {
        super.init()
        self.lightingEnvironment.contents = UIImage(named: "art.scnassets/environment_blur.exr")!
        loadModel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func loadModel() {
        guard let virtualObjectScene = SCNScene(named: "R8_14blend.scn", inDirectory: "art.scnassets") else {
            return
        }
        let wrapperNode = SCNNode()
        for child in virtualObjectScene.rootNode.childNodes {
            wrapperNode.addChildNode(child)
        }
        self.rootNode.addChildNode(contentRootNode)
        contentRootNode.addChildNode(wrapperNode)
    
        self.shell = contentRootNode.childNode(withName: "CAR", recursively: true)
        self.leftWheel = contentRootNode.childNode(withName: "Circle_002", recursively: true)
        self.rightWeel = contentRootNode.childNode(withName: "Circle_005", recursively: true)
    }
    
    func isVisible() -> Bool {
        return !contentRootNode.isHidden
    }
    
    func show() {
        contentRootNode.isHidden = false
    }
    
    func hide() {
        contentRootNode.isHidden = true
    }
    
    func setTransform(_ transform: simd_float4x4) {
        contentRootNode.simdTransform = transform
    }
    
    // action
    func rotateWeel(angle value: Float) {
        self.leftWheel.eulerAngles.z = value
        self.rightWeel.eulerAngles.z = value
    }
}

extension ViewController {
    @IBAction func rotateWeel(_ sender: UISlider) {
//        self.car?.rotateWeel(angle: sender.value)
    }
}

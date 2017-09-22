//
//  ViewController.swift
//  TmpAR
//
//  Created by Vitalii Obertynskyi on 9/13/17.
//  Copyright © 2017 Vitalii Obertynskyi. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController {

    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var carButton: UIButton!
    @IBOutlet weak var yLabel: UILabel!
    
    private var carModel: AudiR8?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSceneView()
        setupFocusSquare()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration, options: [.resetTracking])
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        sceneView.session.pause()
    }
    
    private func setupSceneView() {
        sceneView.delegate = self
        sceneView.automaticallyUpdatesLighting = false
//        sceneView.debugOptions = [.showLightExtents, .showLightInfluences]
    }
    
    //MARK: - Focus Square
    
    var focusSquare = FocusSquare()
    
    func setupFocusSquare() {
        focusSquare.unhide()
        focusSquare.removeFromParentNode()
        sceneView.scene.rootNode.addChildNode(focusSquare)
    }
    
    func updateFocusSquare() {
        let worldPosition = calculateWorldPositionFromScreen(view.center, objectPosition: focusSquare.position)
        if let pos = worldPosition.position {
            self.focusSquare.update(for: pos,
                                    planeAnchor: worldPosition.planeAnchor,
                                    camera: sceneView.session.currentFrame?.camera)
        }
    }
    
    //Action - add car
    @IBAction private func addCarAction(_ sender: UIButton) {
        if carModel != nil {
            carModel?.shell.removeFromParentNode()
            carModel = nil
            carButton.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            setupFocusSquare()
        } else {

            let hitTest = sceneView.hitTest(sceneView.center, types: .existingPlane)
            if let value = hitTest.first {
                carModel = AudiR8()
                carButton.tintColor = #colorLiteral(red: 0.6669999957, green: 0.6669999957, blue: 0.6669999957, alpha: 1)
                carModel?.setTransform(value.worldTransform)
//                carModel?.contentRootNode.position = focusSquare.lastPositionOnPlane!
                sceneView.scene = carModel!
            }
        }
    }
    
    @IBAction private func corectY(_ sender: UIButton) {
        if carModel == nil { return }
        if sender.tag == 1 { //+
            carModel?.contentRootNode.position.y += 0.1
        } else { //-
            carModel?.contentRootNode.position.y -= 0.1
        }
        
        if let y = carModel?.contentRootNode.position.y {
            yLabel.text = String(y)
        } else {
            yLabel.text = "-"
        }
    }
}

extension ViewController {
    
    func calculateWorldPositionFromScreen(_ position: CGPoint, objectPosition: SCNVector3?, infinitePlane: Bool = false) -> WorldPosition {
        
        // 1. Always do a hit test against exisiting plane anchors first.
        //    (If any such anchors exist & only within their extents.)
        let planeHitResults = sceneView.hitTest(position, types: .existingPlaneUsingExtent)
        if let value = planeHitResults.first {
            var result = WorldPosition()
            let WTValue = value.worldTransform
            result.position = SCNVector3Make(WTValue.columns.3.x,
                                             WTValue.columns.3.y,
                                             WTValue.columns.3.z)
            result.planeAnchor = value.anchor as? ARPlaneAnchor
            result.hitAPlane = true
            // Return immediately - this is the best possible outcome.
            return result
        }
        
        // 2. Collect more information about the environment by hit testing against
        //    the feature point cloud, but do not return the result yet.
        var featureHitTestPosition: SCNVector3?
        var highQualityFeatureHitTestResult = false
        
        let highQualityfeatureHitTestResults = sceneView.hitTestWithFeatures(position, coneOpeningAngleInDegrees: 18, minDistance: 0.2, maxDistance: 2.0)
        
        if !highQualityfeatureHitTestResults.isEmpty {
            let result = highQualityfeatureHitTestResults[0]
            featureHitTestPosition = result.position
            highQualityFeatureHitTestResult = true
        }
        
        // 3. If desired or necessary (no good feature hit test result): Hit test
        //    against an infinite, horizontal plane (ignoring the real world).
        let dragOnInfinitePlanesEnabled = true
        if (infinitePlane && dragOnInfinitePlanesEnabled) || !highQualityFeatureHitTestResult {
            
            let pointOnPlane = objectPosition ?? SCNVector3Zero
            
            let pointOnInfinitePlane = sceneView.hitTestWithInfiniteHorizontalPlane(position, pointOnPlane)
            if pointOnInfinitePlane != nil {
                var result = WorldPosition()
                result.position = pointOnInfinitePlane
                result.hitAPlane = true
                return result
            }
        }
        
        // 4. If available, return the result of the hit test against high quality
        //    features if the hit tests against infinite planes were skipped or no infinite plane was hit.
        if highQualityFeatureHitTestResult {
            var result = WorldPosition()
            result.position = featureHitTestPosition
            return result
        }
        
        // 5. As a last resort, perform a second, unfiltered hit test against features.
        //    If there are no features in the scene, the result returned here will be nil.
        let unfilteredFeatureHitTestResults = sceneView.hitTestWithFeatures(position)
        if !unfilteredFeatureHitTestResults.isEmpty {
            var result = WorldPosition()
            result.position = unfilteredFeatureHitTestResults[0].position
            return result
        }
        
        return WorldPosition()
    }
}

extension ViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            self.updateFocusSquare()
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        print("didAdd node")
        if anchor is ARPlaneAnchor {
            carModel?.setTransform(anchor.transform)
            carModel?.show()
        }
    }
}

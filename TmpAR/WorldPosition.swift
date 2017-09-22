//
//  WorldPosition.swift
//  TmpAR
//
//  Created by Vitalii Obertynskyi on 9/13/17.
//  Copyright © 2017 Vitalii Obertynskyi. All rights reserved.
//

import Foundation
import ARKit

struct WorldPosition {
    var position: SCNVector3?
    var planeAnchor: ARPlaneAnchor?
    var hitAPlane: Bool = false // tmp value
}

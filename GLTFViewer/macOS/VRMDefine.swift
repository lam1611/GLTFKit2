//
//  VRMDefine.swift
//  GLTFViewer-macOS
//
//  Created by Hung Nguyen Thanh on 06/03/2023.
//

import Foundation

class Humanoid {
    enum Bones: String {
        // GLB
        case leftArm        // Shoulder
        case rightArm
        case leftForeArm    // Elbow
        case rightForeArm
        case leftThig       // Hip - need check
        case rightThig
        case spine
        case spine1
        case spine2
        
        case leftHandThumb1
        case leftHandThumb2
        case leftHandThumb3
        case leftHandIndex1
        case leftHandIndex2
        case leftHandIndex3
        case leftHandMiddle1
        case leftHandMiddle2
        case leftHandMiddle3
        case leftHandRing1
        case leftHandRing2
        case leftHandRing3
        case leftHandPinky1
        case leftHandPinky2
        case leftHandPinky3
        
        case rightHandThumb1
        case rightHandThumb2
        case rightHandThumb3
        case rightHandIndex1
        case rightHandIndex2
        case rightHandIndex3
        case rightHandMiddle1
        case rightHandMiddle2
        case rightHandMiddle3
        case rightHandRing1
        case rightHandRing2
        case rightHandRing3
        case rightHandPinky1
        case rightHandPinky2
        case rightHandPinky3
        
        // VRM
        case hips
        case leftUpperLeg
        case rightUpperLeg
        case leftLowerLeg
        case rightLowerLeg
        case leftFoot
        case rightFoot
        case neck
        case head
        case leftShoulder
        case rightShoulder
        case leftUpperArm
        case rightUpperArm
        case leftLowerArm
        case rightLowerArm
        case leftHand
        case rightHand
        case leftToes
        case rightToes
        case leftEye
        case rightEye
        case jaw
        case leftThumbProximal
        case leftThumbIntermediate
        case leftThumbDistal
        case leftIndexProximal
        case leftIndexIntermediate
        case leftIndexDistal
        case leftMiddleProximal
        case leftMiddleIntermediate
        case leftMiddleDistal
        case leftRingProximal
        case leftRingIntermediate
        case leftRingDistal
        case leftLittleProximal
        case leftLittleIntermediate
        case leftLittleDistal
        case rightThumbProximal
        case rightThumbIntermediate
        case rightThumbDistal
        case rightIndexProximal
        case rightIndexIntermediate
        case rightIndexDistal
        case rightMiddleProximal
        case rightMiddleIntermediate
        case rightMiddleDistal
        case rightRingProximal
        case rightRingIntermediate
        case rightRingDistal
        case rightLittleProximal
        case rightLittleIntermediate
        case rightLittleDistal
        case upperChest
    }
}

import Foundation
import UIKit
import ImageIO
import MobileCoreServices

private let kErrorDomain = "com.GIFPlayground.error"
private let kGIFPropertiesKey = kCGImagePropertyGIFDictionary as String
private let kGIFPropertiesDelayKey = kCGImagePropertyGIFDelayTime as String
private let kGIFPropertiesLoopCountKey = kCGImagePropertyGIFLoopCount as String

public struct Animation {
    let frames: [UIImage]
    let frameDelay: NSTimeInterval
    private(set) public lazy var animatedImage: UIImage? = {
        return UIImage.animatedImageWithImages(self.frames, duration: (self.frameDelay * NSTimeInterval(self.frames.count)))
    }()
    private(set) public lazy var animatedGIFRepresentation: NSData = {
        let data = NSMutableData()
        let targetProperties: CFDictionaryRef = [kGIFPropertiesKey: [kGIFPropertiesLoopCountKey: 0]]
        let target = CGImageDestinationCreateWithData(data, kUTTypeGIF, self.frames.count, targetProperties)!
        CGImageDestinationSetProperties(target, targetProperties)
        return data
    }()
    
    init(frames: [UIImage], frameDelay: NSTimeInterval) {
        self.frames = frames
        self.frameDelay = frameDelay
    }
}

extension Animation {
    public typealias FrameRenderer = (Int, CGContext) -> Void
    public static func create(frameCount: Int, width: Int, height: Int, frameDelay: NSTimeInterval, renderer: FrameRenderer) throws -> Animation {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.PremultipliedLast.rawValue
        guard let context = CGBitmapContextCreate(nil, width, height, 8, 0, colorSpace, bitmapInfo) else {
            throw CreateError("Unable to create CGContext")
        }
        var rawFrames = [CGImageRef]()
        for frameIndex in 0..<frameCount {
            CGContextSaveGState(context)
            renderer(frameIndex, context)
            CGContextRestoreGState(context)
            guard let frameImage = CGBitmapContextCreateImage(context) else {
                throw CreateError("Coultn't create image for frame \(frameIndex)")
            }
            rawFrames.append(frameImage)
        }
        let frames = rawFrames.map { UIImage(CGImage: $0) }
        return Animation(frames: frames, frameDelay: frameDelay)
    }
}

private func CreateError(description: String, code: Int = -1) -> NSError {
    return NSError(domain: kErrorDomain, code: code, userInfo: [NSLocalizedDescriptionKey: description])
}

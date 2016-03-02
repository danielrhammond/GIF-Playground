import Foundation
import UIKit
import ImageIO
import MobileCoreServices

private let kErrorDomain = "com.GIFPlayground.error"
private let kGIFPropertiesKey = kCGImagePropertyGIFDictionary as String
private let kGIFPropertiesDelayKey = kCGImagePropertyGIFDelayTime as String
private let kGIFPropertiesLoopCountKey = kCGImagePropertyGIFLoopCount as String

public struct Animation {
    let frames: [CGImageRef]
    let frameDelay: NSTimeInterval

    public func animatedImage() -> UIImage? {
        let images = frames.map { UIImage(CGImage: $0) }
        return UIImage.animatedImageWithImages(images, duration: (self.frameDelay * NSTimeInterval(self.frames.count)))
    }
    
    public func animatedGIFRepresentation() -> NSData {
        let data = NSMutableData()
        let targetProperties: CFDictionaryRef = [kGIFPropertiesKey: [kGIFPropertiesLoopCountKey: 0]]
        let target = CGImageDestinationCreateWithData(data, kUTTypeGIF, self.frames.count, targetProperties)!
        CGImageDestinationSetProperties(target, targetProperties)
        let frameProperties: CFDictionaryRef = [kGIFPropertiesKey: [kGIFPropertiesDelayKey: 0.1]]
        for frame in frames {
            CGImageDestinationAddImage(target, frame, frameProperties)
        }
        CGImageDestinationFinalize(target)
        return data
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
        var frames = [CGImageRef]()
        for frameIndex in 0..<frameCount {
            CGContextSaveGState(context)
            renderer(frameIndex, context)
            CGContextRestoreGState(context)
            guard let frameImage = CGBitmapContextCreateImage(context) else {
                throw CreateError("Coultn't create image for frame \(frameIndex)")
            }
            frames.append(frameImage)
        }
        return Animation(frames: frames, frameDelay: frameDelay)
    }
}

private func CreateError(description: String, code: Int = -1) -> NSError {
    return NSError(domain: kErrorDomain, code: code, userInfo: [NSLocalizedDescriptionKey: description])
}

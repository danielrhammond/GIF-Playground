import Foundation
import UIKit
import ImageIO
import MobileCoreServices

private let kErrorDomain = "com.GIFPlayground.error"
private let kGIFPropertiesKey = kCGImagePropertyGIFDictionary as String
private let kGIFPropertiesDelayKey = kCGImagePropertyGIFDelayTime as String
private let kGIFPropertiesLoopCountKey = kCGImagePropertyGIFLoopCount as String

public struct Animation {
    let frames: [CGImage]
    let frameDelay: TimeInterval

    public func animatedImage() -> UIImage? {
        let images = frames.map { UIImage(cgImage: $0) }
        return UIImage.animatedImage(with: images, duration: (self.frameDelay * TimeInterval(self.frames.count)))
    }
    
    public func animatedGIFRepresentation() -> Data {
        let data = NSMutableData()
        let targetProperties = [kGIFPropertiesKey: [kGIFPropertiesLoopCountKey: 0]] as CFDictionary
        let target = CGImageDestinationCreateWithData(data, kUTTypeGIF, self.frames.count, targetProperties)!
        CGImageDestinationSetProperties(target, targetProperties)
        let frameProperties = [kGIFPropertiesKey: [kGIFPropertiesDelayKey: 0.1]] as CFDictionary
        for frame in frames {
            CGImageDestinationAddImage(target, frame, frameProperties)
        }
        CGImageDestinationFinalize(target)
        return data as Data
    }
}

extension Animation {
    public typealias FrameRenderer = (Int, CGContext) -> Void
    /// Creates an animated GIF with the specified frame count, duration, size and a function to draw a frame given an index and a CGContext
    public static func create(_ frameCount: Int, width: Int, height: Int, frameDelay: TimeInterval, renderer: FrameRenderer) throws -> Animation {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo) else {
            throw CreateError("Unable to create CGContext")
        }
        var frames = [CGImage]()
        for frameIndex in 0..<frameCount {
            context.saveGState()
            renderer(frameIndex, context)
            context.restoreGState()
            guard let frameImage = context.makeImage() else {
                throw CreateError("Coultn't create image for frame \(frameIndex)")
            }
            frames.append(frameImage)
        }
        return Animation(frames: frames, frameDelay: frameDelay)
    }
    
    /// Shortcut for creating a looping GIF where the second half reverses the frames of the first half so it ends where it begins
    public static func createAutoReversedLoop(_ halfFrameCount: Int, width: Int, height: Int, frameDelay: TimeInterval, renderer: FrameRenderer) throws -> Animation {
        let firstHalf = try create(halfFrameCount, width: width, height: height, frameDelay: frameDelay, renderer: renderer)
        let secondHalf = firstHalf.frames.reversed().dropFirst().dropLast()
        return Animation(frames: firstHalf.frames + secondHalf, frameDelay: frameDelay)
    }
}

private func CreateError(_ description: String, code: Int = -1) -> NSError {
    return NSError(domain: kErrorDomain, code: code, userInfo: [NSLocalizedDescriptionKey: description])
}

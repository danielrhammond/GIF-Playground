//: Playground - noun: a place where people can play

import UIKit
import ImageIO
import MobileCoreServices
import XCPlayground

var str = "Hello, playground"

func draw(frame: Int) -> CGImageRef? {
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let context = CGBitmapContextCreate(nil, 100, 100, 8, 0, colorSpace, CGImageAlphaInfo.PremultipliedLast.rawValue)
    CGContextSetFillColorWithColor(context, UIColor.whiteColor().CGColor)
    CGContextFillRect(context, CGRect(x: 0, y: 0, width: 100, height: 100))
    CGContextSetFillColorWithColor(context, UIColor.blueColor().colorWithAlphaComponent(CGFloat(frame)/10.0).CGColor)
    CGContextFillRect(context, CGRect(x: 0, y: 0, width: 100, height: 100))
    return CGBitmapContextCreateImage(context)
}

func createGIF(frameCount: Int = 10) -> NSData {
    let frameCount = 10
    let data = NSMutableData()
    let targetProperties: CFDictionaryRef = [(kCGImagePropertyGIFDictionary as String): [ (kCGImagePropertyGIFLoopCount as String): 0 ]]
    let target = CGImageDestinationCreateWithData(data, kUTTypeGIF, frameCount, targetProperties)!
    CGImageDestinationSetProperties(target, targetProperties)
    for i in 0..<frameCount {
        let frame = draw(i)!
        let properties: CFDictionaryRef = [(kCGImagePropertyGIFDictionary as String): [(kCGImagePropertyGIFDelayTime as String): 0.1]]
        CGImageDestinationAddImage(target, frame, properties)
    }
    guard CGImageDestinationFinalize(target) else { fatalError("couldn't finalize GIF") }
    return data
}

func animatedImageFromGIFData(data: NSData) -> UIImage? {
    guard let source = CGImageSourceCreateWithData(data, nil) else { return nil }
    var duration: NSTimeInterval = 0
    var frames = [UIImage]()
    for i in 0..<CGImageSourceGetCount(source) {
        duration += 0.1 // FIXME
        frames.append(UIImage(CGImage: CGImageSourceCreateImageAtIndex(source, i, nil)!))
    }
    return UIImage.animatedImageWithImages(frames, duration: duration)
}

animatedImageFromGIFData(createGIF())
let imageView = UIImageView(image: animatedImageFromGIFData(createGIF()))
imageView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
XCPlaygroundPage.currentPage.liveView = imageView

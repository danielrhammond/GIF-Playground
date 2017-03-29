import UIKit
import PlaygroundSupport

let frameCount = 25
let width = 800
let height = 800

// if you don't want your animation to automatically reverse, use create() instead

let animation = try! Animation.createAutoReversedLoop(frameCount, width: width, height: height, frameDelay: 0.1) { idx, context in
    // Here's an example block that just interpolater between two colors using HSV (via http://stackoverflow.com/a/24687720)
    let progress: CGFloat = CGFloat(idx) / CGFloat(frameCount)
    let from = UIColor(red: 207/255.0, green: 240/255.0, blue: 158/255.0, alpha: 1.0)
    let to = UIColor(red: 11/255.0, green: 72/255.0, blue: 107/255.0, alpha: 1.0)
    var h1: CGFloat = 0
    var s1: CGFloat = 0
    var b1: CGFloat = 0
    var a1: CGFloat = 0
    from.getHue(&h1, saturation: &s1, brightness: &b1, alpha: &a1)
    var h2: CGFloat = 0
    var s2: CGFloat = 0
    var b2: CGFloat = 0
    var a2: CGFloat = 0
    to.getHue(&h2, saturation: &s2, brightness: &b2, alpha: &a2)
    
    let fill = UIColor(
        hue: (h1 + (h2 - h1) * progress),
        saturation: (s1 + (s2 - s1) * progress),
        brightness: (b1 + (b2 - b1) * progress),
        alpha: (a1 + (a2 - a1) * progress))
    
    context.setFillColor(fill.cgColor)
    context.fill(CGRect(x: 0, y: 0, width: width, height: height))
}

let imageView = UIImageView(image: animation.animatedImage())
imageView.frame = CGRect(x: 0, y: 0, width: width, height: height)
PlaygroundPage.current.liveView = imageView

// Once you get something you like you can write result out as an animated GIF
//
// let resultURL = playgroundSharedDataDirectory.appendingPathComponent("result.gif")
// let GIFData = animation.animatedGIFRepresentation()
// do {
//     try GIFData.write(to: resultURL)
// } catch {
//     print("Error Writing File: \(error.localizedDescription)")
// }

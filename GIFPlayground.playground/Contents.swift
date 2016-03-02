//: Playground - noun: a place where people can play

import UIKit
import XCPlayground

let frameCount = 50
let width = 100
let height = 100
var animation = try! Animation.create(frameCount, width: width, height: height, frameDelay: 0.1) { idx, context in
    let progress: CGFloat = CGFloat(idx) / CGFloat(frameCount)
    let alpha = 1.0 - abs((progress - 0.5) * 2.0)
    CGContextSetFillColorWithColor(context, UIColor.whiteColor().CGColor)
    CGContextFillRect(context, CGRect(x: 0, y: 0, width: width, height: height))
    CGContextSetFillColorWithColor(context, UIColor.redColor().colorWithAlphaComponent(alpha).CGColor)
    CGContextFillRect(context, CGRect(x: 0, y: 0, width: width, height: height))
}

let imageView = UIImageView(image: animation.animatedImage)
imageView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
XCPlaygroundPage.currentPage.liveView = imageView

//
//  HelloTriangleViewController.swift
//  metal-programming-guide
//
//  Created by Christophe Bugnon on 5/8/20.
//  Copyright © 2020 Christophe Bugnon. All rights reserved.
//

import UIKit
import QuartzCore

class HelloTriangleViewController: UIViewController {
    private let vertexData: [Float] = [
        0.0, 0.5, 0.0,
        -0.5, -0.5, 0.0,
        0.5, -0.5, 0.0
    ]
    
    private var device: MTLDevice!
    private var metalLayer: CAMetalLayer!
    private var vertexBuffer: MTLBuffer!
    private var pipelineState: MTLRenderPipelineState!
    private var commandQueue: MTLCommandQueue!
    private var displayLink: CADisplayLink!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        
        self.device = MTLCreateSystemDefaultDevice()
        self.commandQueue = self.device.makeCommandQueue()!
        
        self.metalLayer = CAMetalLayer()
        self.metalLayer.device = device
        self.metalLayer.pixelFormat = .bgra8Unorm
        self.metalLayer.framebufferOnly = true
        self.metalLayer.frame = view.layer.frame
        self.view.layer.addSublayer(metalLayer)
        
        let dataSize = vertexData.count * MemoryLayout.size(ofValue: vertexData[0])
        self.vertexBuffer = self.device.makeBuffer(bytes: self.vertexData,
                                                   length: dataSize,
                                                   options: [])
        
        let library = self.device.makeDefaultLibrary()!
        let vertexFunction = library.makeFunction(name: "basic_vertex")
        let fragmentFunction = library.makeFunction(name: "basic_fragment")
        
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexFunction
        pipelineStateDescriptor.fragmentFunction = fragmentFunction
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        self.pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        
        self.displayLink = CADisplayLink(target: self, selector: #selector(gameLoop))
        self.displayLink.add(to: .main, forMode: .default)
    }
    
    func render() {
        guard let drawable = self.metalLayer.nextDrawable() else { return }
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 221/255, green: 160/255, blue: 221/255, alpha: 1)
        
        let commandBuffer = commandQueue.makeCommandBuffer()!
        
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        renderEncoder?.setRenderPipelineState(pipelineState)
        renderEncoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: self.vertexData.count)
        renderEncoder?.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    @objc func gameLoop() {
        autoreleasepool {
            self.render()
        }
    }
}


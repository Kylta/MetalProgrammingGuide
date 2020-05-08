//
//  TwoDimDrawingViewController.swift
//  metal-programming-guide
//
//  Created by Christophe Bugnon on 5/8/20.
//  Copyright © 2020 Christophe Bugnon. All rights reserved.
//

import MetalKit

class TwoDimDrawingViewController: UIViewController, MTKViewDelegate {
    var metalView: MTKView {
        let view = self.view as! MTKView
        view.delegate = self
        view.device = self.device
        view.preferredFramesPerSecond = 60
        view.isPaused = false
        view.enableSetNeedsDisplay = false
        view.colorPixelFormat = .bgra8Unorm
        return view
    }
    
    var device: MTLDevice!
    var commandQueue: MTLCommandQueue!
    var pipelineState: MTLRenderPipelineState!
    var vertexBuffer: MTLBuffer!
    var vertexColorBuffer: MTLBuffer!
    var bufferIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.device = MTLCreateSystemDefaultDevice()
        self.commandQueue = self.device.makeCommandQueue()
        
        let library = self.device.makeDefaultLibrary()
        let vertexFunction = library?.makeFunction(name: "passThroughVertex")
        let fragmentFunction = library?.makeFunction(name: "passThroughFragment")
        
        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineDescriptor.vertexFunction = vertexFunction
        renderPipelineDescriptor.fragmentFunction = fragmentFunction
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = self.metalView.colorPixelFormat
        renderPipelineDescriptor.sampleCount = metalView.sampleCount
        
        self.pipelineState = try! self.device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
        
        let dataSize = starVertexData.count * MemoryLayout<Float>.size
        self.vertexBuffer = self.device.makeBuffer(bytes: starVertexData, length: dataSize, options: [])
        self.vertexBuffer.label = "vertices"
        
        self.vertexColorBuffer = self.device.makeBuffer(bytes: starVertexColorData, length: dataSize, options: [])
        self.vertexColorBuffer.label = "colors"
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable, let rpd = view.currentRenderPassDescriptor else { return }
        
        let commandBuffer = self.commandQueue.makeCommandBuffer()
        
        let renderEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: rpd)
        renderEncoder?.label = "render encoder"
        
        renderEncoder?.pushDebugGroup("draw morphing star")
        renderEncoder?.setRenderPipelineState(self.pipelineState)
        renderEncoder?.setVertexBuffer(self.vertexBuffer, offset: 0, index: 0)
        renderEncoder?.setVertexBuffer(self.vertexColorBuffer, offset: 0, index: 1)
        renderEncoder?.drawPrimitives(type: .triangle,
                                     vertexStart: 0,
                                     vertexCount: starVertexData.count)

        renderEncoder?.popDebugGroup()
        renderEncoder?.endEncoding()
        
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
}

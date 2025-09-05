//
//  Untitled.swift
//  LangwithFootball
//
//  Created by Andrew Yuzgin on 26/05/2025.
//

import SwiftUI

struct ResizableHeaderScrollView<Header: View, StickyHeader: View, Background: View, Content: View>: View
{
    var spacing: CGFloat = 10
    @ViewBuilder var header: Header
    @ViewBuilder var stickyHeader: StickyHeader
    @ViewBuilder var background: Background
    @ViewBuilder var content: Content
    /// VIew Properties
    @State private var currentDragOffset: CGFloat = 0
    @State private var previousDragOffset: CGFloat = 0
    @State private var headerOffset: CGFloat = 0
    @State private var headerSize: CGFloat = 0
    @State private var scrollOffset: CGFloat = 0
    
    var body: some View {
        ScrollView(.vertical) {
            content
        }
        .frame(maxWidth: .infinity)
        .onScrollGeometryChange(for: CGFloat.self, of: {
            $0.contentOffset.y + $0.contentInsets.top
        }, action: {oldValue, newValue in
            scrollOffset = newValue
        })
        
        // ❌ Commented out to stop header dragging
        /*
        .simultaneousGesture(
            DragGesture(minimumDistance: 10)
                .onChanged({ value in
                    let dragOffset = -max(0, abs(value.translation.height) - 50) *
                        (value.translation.height < 0 ? -1 : 1)
                    
                    previousDragOffset = currentDragOffset
                    currentDragOffset = dragOffset
                    
                    let deltaOffset = (currentDragOffset - previousDragOffset).rounded()
                    
                    headerOffset = max(min(headerOffset + deltaOffset, headerSize), 0)
                    
                }).onEnded({ _ in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        if headerOffset > (headerSize * 0.5) && scrollOffset > headerSize {
                            headerOffset = headerSize
                        } else {
                            headerOffset = 0
                        }
                    }
                    
                    currentDragOffset = 0
                    previousDragOffset = 0
                })
        )
        */
        
        .safeAreaInset(edge: .top, spacing: spacing) {
            CombinedHeaderView()
        }
    }
    
    @ViewBuilder
    private func CombinedHeaderView() -> some View {
        VStack(spacing: spacing) {
            header
                .onGeometryChange(for: CGFloat.self) {
                    $0.size.height
                } action: { newValue in
                    headerSize = newValue + spacing
                }
            stickyHeader
        }
        // ❌ Commented out so header doesn’t move up/down
        //.offset(y: -headerOffset)
        .clipped()
        .background {
            background
                .ignoresSafeArea()
                // ❌ Commented out same offset for background
                //.offset(y: -headerOffset)
        }
    }
}


#Preview {
    ContentView()
        .environmentObject(AppState())
}


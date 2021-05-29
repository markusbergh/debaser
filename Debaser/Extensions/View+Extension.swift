//
//  View+Extension.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-04-09.
//

import SwiftUI

extension View {
    
    ///
    /// Sets a corner radius in the passed list of corners
    ///
    /// - Parameters:
    ///     - radius: The radius of roundness.
    ///     - corners: A list of corners to apply roundness to.
    /// - Returns: A  clipped `View` instance.
    ///
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(
            RoundedCorner(radius: radius, corners: corners)
        )
    }

    ///
    /// Calls the completion handler whenever an animation on the given value completes.
    ///
    /// - Parameters:
    ///   - value: The value to observe for animations.
    ///   - completion: The completion callback to call once the animation completes.
    /// - Returns: A modified `View` instance with the observer attached.
    ///
    func onAnimationCompleted<Value: VectorArithmetic>(for value: Value, completion: @escaping () -> Void) -> ModifiedContent<Self, AnimationCompletionObserverModifier<Value>> {
        return modifier(AnimationCompletionObserverModifier(observedValue: value, completion: completion))
    }
    
}

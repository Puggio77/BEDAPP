//
//  InterventionFlowEnvironment.swift
//  BEDAPP
//
//  Permite cerrar todo el flujo de intervención y volver a la pantalla principal.
//

import SwiftUI

struct DismissInterventionFlowKey: EnvironmentKey {
    static let defaultValue: (() -> Void)? = nil
}

extension EnvironmentValues {
    var dismissInterventionFlow: (() -> Void)? {
        get { self[DismissInterventionFlowKey.self] }
        set { self[DismissInterventionFlowKey.self] = newValue }
    }
}

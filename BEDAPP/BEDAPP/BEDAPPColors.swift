//
//  BEDAPPColors.swift
//  BEDAPP
//
//  Paleta de la app: color principal y secundario.
//

import SwiftUI

extension Color {
    /// Color principal: #A2CAE4 (azul claro, calmado).
    static let bedPrimary = Color(red: 162/255, green: 202/255, blue: 228/255)

    /// Color secundario: #4C667D (azul grisáceo, más sobrio).
    static let bedSecondary = Color(red: 76/255, green: 102/255, blue: 125/255)

    /// Variante más viva para botones e iconos (más saturada).
    static let bedPrimaryVivid = Color(red: 140/255, green: 190/255, blue: 230/255)
}

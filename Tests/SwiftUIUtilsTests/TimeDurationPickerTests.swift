import Testing
@testable import SwiftUIUtils

@Test func ensureCanCreate() async throws {
    await #expect(TimeDurationPicker(duration: .constant(1)) != nil)
    await #expect(TimeDurationPicker(duration: .constant(1), showHours: false) != nil)
}

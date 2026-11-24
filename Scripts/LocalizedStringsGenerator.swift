import Foundation

@main
public struct LocalizedStringsGenerator {
    static func main() throws {
        try createLocalizedStringsFile(filePath: CommandLine.arguments[1], stringsFile: URL(fileURLWithPath: CommandLine.arguments[2]))
    }

    private static func createLocalizedStringsFile(filePath: String, stringsFile: URL) throws {
        let stringsFileName = stringsFile.deletingPathExtension().lastPathComponent
        let fileContentString =
        """
        //
        // Auto-generated code. Do not modify this file manually.
        //

        \(imports)

        \(localizableProtocol(stringsFileName))

        \(stringExtension)

        \(try localizedStringsEnum(stringsFile))
        
        """

        try fileContentString.write(toFile: filePath, atomically: true, encoding: .utf8)
    }

    private static func localizedStringsEnum(_ stringsFile: URL) throws -> String {
        let data = try String(contentsOf: stringsFile, encoding: .utf8)
        let stringsLine = data.components(separatedBy: .newlines).filter { $0.contains(";") && $0.contains("=") }
        let stringsKeys = stringsLine
            .compactMap { $0.split(separator: "=").first }
            .map { $0?.replacingOccurrences(of: " ", with: "") }
            .map { $0?.replacingOccurrences(of: "\"", with: "") }
        let enumCases = stringsKeys.compactMap { $0 }.map { "case \($0)" }
        return """
            enum LocalizedStrings: String, Localizable {
                \(enumCases.joined(separator: "\n\t"))
            }
            """
    }

    // MARK: - Utils

    static let imports =
    """
    import Foundation
    """

    static func localizableProtocol(_ stringsFileName: String) -> String {
        """
        protocol Localizable {
            var tableName: String { get }
        }

        extension Localizable where Self: RawRepresentable, Self.RawValue == String {
            var tableName: String {
                "\(stringsFileName)"
            }

            func callAsFunction() -> String {
                rawValue.localized(tableName: tableName)
            }
        }
        """
    }

    static let stringExtension: String =
        """
        private extension String {
            func localized(bundle: Bundle = .main,
                           tableName: String,
                           comment: String = "") -> String {
                NSLocalizedString(self, tableName: tableName, value: self, comment: comment)
            }
        }
        """
}

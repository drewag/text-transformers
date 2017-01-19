//
//  Markdown.swift
//  drewag.me
//
//  Created by Andrew J Wagner on 1/14/17.
//
//

fileprivate protocol Styler {
    var output: String {get}
    mutating func append(character: Markdown.StructuredCharacter)
}

public class Markdown: StreamMapper {
    // TOOD: Add support for
    // • Nesting other structures (including blockquotes) inside blockquotes
    // • Ordered Lists

    public init() {}

    enum ParsedCharacter {
        case firstCharacter
        case lastCharacter

        case whitespace(count: Int)
        case newLine(count: Int, indented: Int)
        case hashes(count: Int)
        case equals(count: Int)
        case dashes(count: Int)
        case stars(count: Int)
        case forwardSlashes(count: Int)
        case codeCommentStart(spaceCount: Int)
        case listElementStart(spaceCount: Int)
        case quoteStart(spaceCount: Int)

        case other(Character)
    }

    enum StructuredCharacter {
        case firstCharacter
        case lastCharacter

        case whitespace(count: Int)
        case stars(count: Int)

        case other(Character)
    }

    fileprivate enum Structure {
        case none
        case paragraph(RichStyler)
        case list
        case listElement(RichStyler)
        case quote(PlainStyler)
        case code(lastCharacter: StructuredCharacter, collectingLanguage: Bool, language: String, PlainStyler)
        case header(level: Int, underlineCount: Int, RichStyler)
    }

    fileprivate struct PlainStyler: Styler {
        var output = ""
    }

    fileprivate struct RichStyler: Styler {
        enum Mode {
            case none
            case linkTitle(String)
            case linkFinishedTitle(String)
            case linkAddress(title: String, address: String)
        }

        enum ElementCharacter {
            case start
            case other(Character)
            case end
        }

        enum PossibleStyle {
            case none
            case strong([ElementCharacter])
            case emphasis([ElementCharacter])
            case code([ElementCharacter])
        }

        var output = ""
        var pendingStyled = ""
        var mode = Mode.none
        var possibleStyle = PossibleStyle.none
    }

    fileprivate var structure = Structure.none

    public func map(_ input: CharacterInputStream, to output: CharacterOutputStream) throws {
        var previousCharacter = ParsedCharacter.firstCharacter

        while let character = input.read() {
            // 1. If this character transforms the previous character update previous character
            // 2. If this character repeats previous character, just continue
            // 3. Otherwise, map the previous character and update to the new previous character
            switch character {
            case " ":
                switch previousCharacter {
                case .dashes(1): // 1
                    previousCharacter = .listElementStart(spaceCount: 1)
                case .forwardSlashes(2): // 1
                    previousCharacter = .codeCommentStart(spaceCount: 1)
                case .codeCommentStart(let spaceCount): // 2
                    previousCharacter = .codeCommentStart(spaceCount: spaceCount + 1)
                case .listElementStart(let spaceCount): // 2
                    previousCharacter = .listElementStart(spaceCount: spaceCount + 1)
                case .quoteStart(let spaceCount): // 2
                    previousCharacter = .quoteStart(spaceCount: spaceCount + 1)
                case .whitespace(let count): // 2
                    previousCharacter = .whitespace(count: count + 1)
                case .firstCharacter:
                    self.structure(parsed: .firstCharacter, to: output)
                    previousCharacter = .newLine(count: 1, indented: 1)
                case let .newLine(count: count, indented): // 2
                    previousCharacter = .newLine(count: count, indented: indented + 1)
                default: // 3
                    self.structure(parsed: previousCharacter, to: output)
                    previousCharacter = .whitespace(count: 1)
                }
            case "\n":
                switch previousCharacter {
                case .newLine(let count, 0): // 1
                    previousCharacter = .newLine(count: count + 1, indented: 0)
                default: // 3
                    self.structure(parsed: previousCharacter, to: output)
                    previousCharacter = .newLine(count: 1, indented: 0)
                }
            case "#":
                switch previousCharacter {
                case .hashes(let count): // 1
                    previousCharacter = .hashes(count: count + 1)
                default: // 3
                    self.structure(parsed: previousCharacter, to: output)
                    previousCharacter = .hashes(count: 1)
                }
            case "=":
                switch previousCharacter {
                case .equals(let count): // 1
                    previousCharacter = .equals(count: count + 1)
                default: // 3
                    self.structure(parsed: previousCharacter, to: output)
                    previousCharacter = .equals(count: 1)
                }
            case "/":
                switch previousCharacter {
                case .forwardSlashes(let count): // 1
                    previousCharacter = .forwardSlashes(count: count + 1)
                default: // 3
                    self.structure(parsed: previousCharacter, to: output)
                    previousCharacter = .forwardSlashes(count: 1)
                }
            case "-":
                switch previousCharacter {
                case .dashes(let count): // 1
                    previousCharacter = .dashes(count: count + 1)
                default: // 3
                    self.structure(parsed: previousCharacter, to: output)
                    previousCharacter = .dashes(count: 1)
                }
            case "*":
                switch previousCharacter {
                case .stars(let count): // 1
                    previousCharacter = .stars(count: count + 1)
                default: // 3
                    self.structure(parsed: previousCharacter, to: output)
                    previousCharacter = .stars(count: 1)
                }
            case ">":
                switch previousCharacter {
                case .newLine:
                    self.structure(parsed: previousCharacter, to: output)
                    previousCharacter = .quoteStart(spaceCount: 0)
                default:
                    self.structure(parsed: previousCharacter, to: output)
                    previousCharacter = .other(">")
                }
            default:
                self.structure(parsed: previousCharacter, to: output)
                previousCharacter = .other(character)
            }
        }

        self.structure(parsed: previousCharacter, to: output)
        self.structure(parsed: .lastCharacter, to: output)
    }
}

private extension Markdown {
    func structure(parsed character: ParsedCharacter, to output: CharacterOutputStream) {
        //print("parsed: \(character)")
        func endStructure(tags: [String], innerClass: String?, styler: Styler) {
            var styler = styler
            styler.append(character: .lastCharacter)
            for (i, tag) in tags.enumerated() {
                if i == tags.count - 1, let innerClass = innerClass {
                    output.write("<\(tag) class=\"\(innerClass)\">")
                }
                else {
                    output.write("<\(tag)>")
                }
            }
            output.write(styler.output)
            for tag in tags.reversed() {
                output.write("</\(tag)>")
            }
        }

        func endStructure(tag: String, innerClass: String? = nil, styler: Styler) {
            endStructure(tags: [tag], innerClass: innerClass, styler: styler)
        }

        func endStructure() {
            switch self.structure {
            case let .header(level, _, styler):
                endStructure(tag: "h\(level)", styler: styler)
                self.structure = .none
            case .listElement(let styler):
                endStructure(tag: "li", styler: styler)
                self.structure = .list
            case .list:
                output.write("</ul>")
                self.structure = .none
            case .paragraph(let styler):
                endStructure(tag: "p", styler: styler)
                self.structure = .none
            case .quote(let styler):
                endStructure(tag: "blockquote", styler: styler)
                self.structure = .none
            case let .code(_, _, language, styler):
                endStructure(tags: ["pre", "code"], innerClass: language.isEmpty ? nil : "language-\(language)", styler: styler)
                self.structure = .none
            case .none:
                break
            }
        }

        func appendToCurrentStructure(character: StructuredCharacter) {
            var character = character

            switch self.structure {
            case .header(let level, let underlineCount, var styler):
                styler.append(character: character)
                self.structure = .header(level: level, underlineCount: underlineCount, styler)
            case .none:
                var styler = RichStyler()
                styler.append(character: character)
                self.structure = .paragraph(styler)
            case .list:
                break
            case .listElement(var styler):
                styler.append(character: character)
                self.structure = .listElement(styler)
            case .paragraph(var styler):
                styler.append(character: character)
                self.structure = .paragraph(styler)
            case .quote(var styler):
                styler.append(character: character)
                self.structure = .quote(styler)
            case .code(let lastCharacter, let collectingLanguage, var language, var styler):
                switch lastCharacter {
                case .other("\n"):
                    var shouldFallthrough = false
                    switch character {
                    case .whitespace(4):
                        break
                    case .whitespace(let count) where count > 4:
                        character = .whitespace(count: count - 4)
                        shouldFallthrough = true
                    default:
                        shouldFallthrough = true
                    }
                    if shouldFallthrough {
                        fallthrough
                    }
                case .firstCharacter, .lastCharacter, .stars, .other, .whitespace:
                    switch character {
                    case .firstCharacter, .lastCharacter:
                        break
                    case .whitespace(let count):
                        if collectingLanguage {
                            for _ in 0 ..< count {
                                language += " "
                            }
                            self.structure = .code(lastCharacter: lastCharacter, collectingLanguage: true, language: language, styler)
                        }
                        else {
                            styler.append(character: character)
                            self.structure = .code(lastCharacter: character, collectingLanguage: false, language: language, styler)
                        }
                    case .stars(let count):
                        if collectingLanguage {
                            for _ in 0 ..< count {
                                language += "*"
                            }
                            self.structure = .code(lastCharacter: lastCharacter, collectingLanguage: true, language: language, styler)
                        }
                        else {
                            styler.append(character: character)
                            self.structure = .code(lastCharacter: character, collectingLanguage: false, language: language, styler)
                        }
                    case .other("\n"):
                        if !collectingLanguage {
                            styler.append(character: character)
                        }
                        self.structure = .code(lastCharacter: character, collectingLanguage: false, language: language, styler)
                    case .other(let rawCharacter):
                        if collectingLanguage {
                            language.append(rawCharacter)
                            self.structure = .code(lastCharacter: character, collectingLanguage: true, language: language, styler)
                        }
                        else {
                            styler.append(character: character)
                            self.structure = .code(lastCharacter: character, collectingLanguage: false, language: language, styler)
                        }
                    }
                }
            }
        }

        switch character {
        case .firstCharacter, .lastCharacter:
            endStructure()
        case .whitespace(let count):
            appendToCurrentStructure(character: .whitespace(count: count))
        case .newLine(1, let indented) where indented < 4:
            switch self.structure {
            case .header, .listElement:
                endStructure()
            //case .quote(var styler):
            //    styler.append(character: .other("\n"))
            case .paragraph:
                appendToCurrentStructure(character: .whitespace(count: 1))
            case .list, .none, .quote:
                break
            case .code:
                if indented < 4 {
                    endStructure()
                    if indented > 0 {
                        self.structure(parsed: .whitespace(count: indented), to: output)
                        return
                    }
                }
                else {
                    appendToCurrentStructure(character: .other("\n"))
                    for _ in 0 ..< indented - 4 {
                        appendToCurrentStructure(character: .other(" "))
                    }
                }
            }
        case let .newLine(count, indented):
            switch self.structure {
            case .listElement:
                endStructure()
                fallthrough
            case .header, .list, .paragraph, .quote:
                endStructure()
                fallthrough
            case .none:
                guard indented >= 4 else {
                    fallthrough
                }
                self.structure = .code(lastCharacter: .firstCharacter, collectingLanguage: false, language: "", PlainStyler())
                if indented > 4 {
                    appendToCurrentStructure(character: .whitespace(count: indented - 4))
                }
            case .code:
                if indented < 4 {
                    endStructure()
                    if indented > 0 {
                        self.structure(parsed: .whitespace(count: indented), to: output)
                        return
                    }
                }
                else {
                    for _ in 0 ..< count {
                        appendToCurrentStructure(character: .other("\n"))
                    }
                    for _ in 0 ..< indented - 4 {
                        appendToCurrentStructure(character: .other(" "))
                    }
                }
            }
        case .hashes(let count):
            switch self.structure {
            case .none:
                self.structure = .header(level: count, underlineCount: 0, RichStyler())
            default:
                for _ in 0 ..< count {
                    appendToCurrentStructure(character: .other("#"))
                }
            }
        case .equals(let count) where count < 3:
            for _ in 0 ..< count {
                appendToCurrentStructure(character: .other("="))
            }
        case .equals(let count):
            switch self.structure {
            case .paragraph(let styler):
                self.structure = .header(level: 1, underlineCount: count, styler)
            default:
                for _ in 0 ..< count {
                    appendToCurrentStructure(character: .other("="))
                }
            }
        case .dashes(let count) where count < 3:
            for _ in 0 ..< count {
                appendToCurrentStructure(character: .other("-"))
            }
        case .dashes(let count):
            switch self.structure {
            case .paragraph(let styler):
                self.structure = .header(level: 2, underlineCount: count, styler)
            default:
                for _ in 0 ..< count {
                    appendToCurrentStructure(character: .other("-"))
                }
            }
        case .stars(let count):
            appendToCurrentStructure(character: .stars(count: count))
        case .listElementStart(let spaceCount):
            switch self.structure {
            case .none:
                output.write("<ul>")
                fallthrough
            case .list:
                self.structure = .listElement(RichStyler())
            default:
                appendToCurrentStructure(character: .other("-"))
                appendToCurrentStructure(character: .whitespace(count: spaceCount))
            }
        case .forwardSlashes(let count):
            for _ in 0 ..< count {
                appendToCurrentStructure(character: .other("/"))
            }
        case .codeCommentStart(spaceCount: 1):
            switch self.structure {
            case .code(.firstCharacter, _, _, let styler):
                self.structure = .code(lastCharacter: .firstCharacter, collectingLanguage: true, language: "", styler)
            default:
                appendToCurrentStructure(character: .other("/"))
                appendToCurrentStructure(character: .other("/"))
                appendToCurrentStructure(character: .whitespace(count: 1))
            }
        case .codeCommentStart(let spaceCount):
            appendToCurrentStructure(character: .other("/"))
            appendToCurrentStructure(character: .other("/"))
            appendToCurrentStructure(character: .whitespace(count: spaceCount))
        case .quoteStart(let spaceCount):
            switch self.structure {
            case .none:
                self.structure = .quote(PlainStyler())
            case .quote(var styler):
                styler.append(character: .other("<"))
                styler.append(character: .other("b"))
                styler.append(character: .other("r"))
                styler.append(character: .other(" "))
                styler.append(character: .other("/"))
                styler.append(character: .other(">"))
                if spaceCount > 1 {
                    styler.append(character: .whitespace(count: spaceCount - 1))
                }
                self.structure = .quote(styler)
            default:
                appendToCurrentStructure(character: .other(">"))
                appendToCurrentStructure(character: .whitespace(count: spaceCount))
            }
        case .other(let rawCharacter):
            switch self.structure {
            case .header(2, let underlineCount, var styler) where underlineCount > 0:
                for _ in 0 ..< underlineCount {
                    styler.append(character: .other("-"))
                }
                self.structure = .paragraph(styler)
            case .header(1, let underlineCount, var styler) where underlineCount > 0:
                for _ in 0 ..< underlineCount {
                    styler.append(character: .other("="))
                }
                self.structure = .paragraph(styler)
            case .list, .listElement, .paragraph, .header, .none, .quote, .code:
                appendToCurrentStructure(character: .other(rawCharacter))
            }
        }
    }
}

private extension Markdown.PlainStyler {
    mutating func append(character: Markdown.StructuredCharacter) {
        switch character {
        case .firstCharacter, .lastCharacter:
            return
        case .whitespace(let count):
            for _ in 0 ..< count {
                self.output.append(" ")
            }
        case .stars(let count):
            for _ in 0 ..< count {
                self.output.append("*")
            }
        case .other(let rawCharacter):
            self.output.append(rawCharacter)
        }
    }
}

private extension Markdown.RichStyler {
    mutating func append(character: Markdown.StructuredCharacter) {
        if self.output.isEmpty && character != .firstCharacter, case .none = self.mode {
            self.append(character: .firstCharacter)
        }

        //print("structured: \(character)")
        func commit(_ characters: [ElementCharacter]) {
            for character in characters {
                self.append(styled: character)
            }
        }

        func commitStyle(tag: String, characters: [ElementCharacter]) {
            self.append(styled: .end)
            self.output += "<\(tag)>"
            self.append(styled: .start)
            commit(characters)
            self.append(styled: .end)
            self.output += "</\(tag)>"
        }

        func commitStyle() {
            switch self.possibleStyle {
            case .code(let characters):
                commitStyle(tag: "code", characters: characters)
            case .emphasis(let characters):
                commitStyle(tag: "em", characters: characters)
            case .strong(let characters):
                commitStyle(tag: "strong", characters: characters)
            case .none:
                return
            }
            self.possibleStyle = .none
        }

        func cancelStyle() {
            switch self.possibleStyle {
            case .code(let characters):
                self.append(styled: .other("`"))
                commit(characters)
            case .emphasis(let characters):
                self.append(styled: .other("*"))
                commit(characters)
            case .strong(let characters):
                self.append(styled: .other("*"))
                self.append(styled: .other("*"))
                commit(characters)
            case .none:
                break
            }
            self.append(styled: .end)
        }

        func appendToCurentStyle(character: ElementCharacter) {
            switch self.possibleStyle {
            case .code(let characters):
                self.possibleStyle = .code(characters + [character])
            case .emphasis(let characters):
                self.possibleStyle = .emphasis(characters + [character])
            case .strong(let characters):
                self.possibleStyle = .strong(characters + [character])
            case .none:
                self.append(styled: character)
            }
        }

        switch character {
        case .firstCharacter:
            self.append(styled: .start)
        case .lastCharacter:
            cancelStyle()
        case .whitespace:
            appendToCurentStyle(character: .other(" "))
        case .stars(1):
            switch self.possibleStyle {
            case .none:
                self.possibleStyle = .emphasis([])
            case .code, .strong:
                appendToCurentStyle(character: .other("*"))
            case .emphasis:
                commitStyle()
            }
        case .stars(2):
            switch self.possibleStyle {
            case .none:
                self.possibleStyle = .strong([])
            case .code:
                appendToCurentStyle(character: .other("*"))
                appendToCurentStyle(character: .other("*"))
            case .emphasis:
                appendToCurentStyle(character: .other("*"))
                fallthrough
            case .strong:
                commitStyle()
            }
        case .stars(let count):
            switch self.possibleStyle {
            case .none:
                self.possibleStyle = .strong([])
                for _ in 0 ..< count - 2 {
                    appendToCurentStyle(character: .other("*"))
                    appendToCurentStyle(character: .other("*"))
                }
            case .code:
                for _ in 0 ..< count {
                    appendToCurentStyle(character: .other("*"))
                    appendToCurentStyle(character: .other("*"))
                }
            case .emphasis:
                appendToCurentStyle(character: .other("*"))
                fallthrough
            case .strong:
                for _ in 0 ..< count - 2 {
                    appendToCurentStyle(character: .other("*"))
                    appendToCurentStyle(character: .other("*"))
                }
                commitStyle()
            }
        case .other("`"):
            switch self.possibleStyle {
            case .emphasis, .strong:
                cancelStyle()
                fallthrough
            case .none:
                self.possibleStyle = .code([])
            case .code:
                commitStyle()
            }
        case .lastCharacter:
            cancelStyle()
        case .other(let other):
            appendToCurentStyle(character: .other(other))
        }
    }

    mutating func append(styled character: ElementCharacter) {
        //print("styled: \(character)")
        switch self.mode {
        case .none:
            switch character {
            case .start, .end:
                break
            case .other("["):
                self.mode = .linkTitle("")
            case .other(let rawCharacter):
                self.output.append(rawCharacter)
            }
        case .linkTitle(let title):
            switch character {
            case .start, .end:
                self.output += "[\(title)"
                self.mode = .none
            case .other("]"):
                self.mode = .linkFinishedTitle(title)
            case .other(let rawCharacter):
                self.mode = .linkTitle(title + "\(rawCharacter)")
            }
        case .linkFinishedTitle(let title):
            switch character {
            case .start, .end:
                self.output += "[\(title)]"
                self.mode = .none
            case .other("("):
                self.mode = .linkAddress(title: title, address: "")
            case .other(let rawCharacter):
                self.output += "[\(title)]\(rawCharacter)"
                self.mode = .none
            }
        case let .linkAddress(title, address):
            switch character {
            case .start, .end:
                self.output += "[\(title)](\(address)"
                self.mode = .none
            case .other(")"):
                self.output += "<a href=\"\(address)\">\(title)</a>"
                self.mode = .none
            case .other(let rawCharacter):
                self.mode = .linkAddress(title: title, address: address + "\(rawCharacter)")
            }
        }
    }
}

extension Markdown.StructuredCharacter: Equatable {
    static func ==(lhs: Markdown.StructuredCharacter, rhs: Markdown.StructuredCharacter) -> Bool {
        switch lhs {
        case .firstCharacter:
            switch rhs {
            case .firstCharacter:
                return true
            default:
                return false
            }
        case .lastCharacter:
            switch rhs {
            case .lastCharacter:
                return true
            default:
                return false
            }
        case .whitespace(let lCount):
            switch rhs {
            case .whitespace(let rCount):
                return lCount == rCount
            default:
                return false
            }
        case .other(let lCharacter):
            switch rhs {
            case .other(let rCharacter):
                return lCharacter == rCharacter
            default:
                return false
            }
        case .stars(let lCount):
            switch rhs {
            case .stars(let rCount):
                return lCount == rCount
            default:
                return false
            }
        }
    }
}

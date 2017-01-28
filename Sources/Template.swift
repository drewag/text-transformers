//
//  Template.swift
//  TextTransformers
//
//  Created by Andrew J Wagner on 4/26/16.
//  Copyright © 2016 Drewag. All rights reserved.
//
// The MIT License (MIT)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

protocol TemplateCommand: AnyObject {
    func append(_ character: Character)
    func append(_ string: String)
    func end() -> (output: String, newIndex: String.CharacterView.Index?)
    func extraValue(forKey key: String) -> String?
    func extraValues(forKey key: String) -> [TemplateValues]?
}

public struct Template: Mapper {

    // Templates look like this: "Fixed text with variables {{ v1 }} {{ if v2 }} and {{v2}} {{ end }}"
    // - Variable replacements start with "{{" and end with "}}". The variable name will be replaced by
    //   the value provided in the values dictionary
    // - "{{ if <variable_name> }}" starts a conditional to only include the following text if variable_name
    //   exists. "{{ end }}" is used to return to including text regardless
    private var values: TemplateValues

    public init(build: (TemplateBuilder) throws -> ()) throws {
        let builder = TemplateBuilder()
        try build(builder)
        self.values = builder.values
    }

    public func map(_ input: String) -> String {
        enum Status {
            case PossibleOpen
            case Opened
            case PossibleClose
            case Closed
        }

        enum ActiveCommand {
            case If(passed: Bool)
            case Loop(startIndex: String.CharacterView.Index, placeholderName: String, inValues: [String], index: Int)
        }

        var status = Status.Closed
        var commandText = ""

        let defaultCommand = TemplateCommandDefault()
        var activeCommands: [TemplateCommand] = [defaultCommand]

        let characters = input.characters
        var index = characters.startIndex
        while index != characters.endIndex {
            let character = characters[index]
            let topCommand = activeCommands.last!

            switch status {
            case .Closed:
                switch character {
                case "{":
                    status = .PossibleOpen
                default:
                    topCommand.append(character)
                }
            case .PossibleOpen:
                switch character {
                case "{":
                    status = .Opened
                default:
                    status = .Closed
                    topCommand.append("{")
                    topCommand.append(character)
                }
            case .Opened:
                switch character {
                case "}":
                    status = .PossibleClose
                default:
                    commandText.append(character)
                }
            case .PossibleClose:
                switch character {
                case "}":
                    status = .Closed

                    // Completed command definition
                    switch self.parseCommand(fromText: commandText) {
                    case .PrintVariable(variableName: let variableName):
                        if let value = activeCommands.last!.extraValue(forKey: variableName) {
                            topCommand.append(value)
                        }
                        else if let value = self.values.string(forKey: variableName) {
                            topCommand.append(value)
                        }
                    case .IfExists(variableName: let variableName):
                        activeCommands.append(TemplateCommandIf(
                            passed: self.values.string(forKey: variableName) != nil
                                || self.values.values(forKey: variableName) != nil
                        ))
                    case .End:
                        let (output, overrideIndex) = topCommand.end()
                        activeCommands[activeCommands.count - 2].append(output)

                        if let overrideIndex = overrideIndex {
                            index = overrideIndex
                        }
                        else {
                            if activeCommands.count > 1 {
                                activeCommands.removeLast()
                            }
                        }
                    case .Unknown:
                        break
                    case let .ForIn(arrayName):
                        activeCommands.append(TemplateCommandLoop(
                            startIndex: index,
                            values: activeCommands.last!.extraValues(forKey: arrayName)
                                ?? self.values.values(forKey: arrayName)
                                ?? [TemplateValues]()
                        ))
                    }
                    commandText = ""
                default:
                    commandText.append("}")
                    commandText.append(character)
                }
            }

            index = characters.index(after: index)
        }

        let (output, _) = defaultCommand.end()
        return output
    }
}

private extension Template {
    enum Command {
        case PrintVariable(variableName: String)
        case IfExists(variableName: String)
        case End
        case Unknown
        case ForIn(arrayName: String)
    }

    func parseCommand(fromText: String) -> Command {
        let components = fromText.components(separatedBy: " ").filter { !$0.isEmpty }

        switch components.count {
        case 1:
            if components[0].lowercased() == "end" {
                return .End
            }
            return .PrintVariable(variableName: components[0])
        case 2:
            if components[0].lowercased() == "if" {
                return .IfExists(variableName: components[1])
            }
            if components[0].lowercased() == "repeat" {
                return .ForIn(arrayName: components[1])
            }
        default:
            break
        }
        return .Unknown
    }
}

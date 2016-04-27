//
//  TemplateMapper.swift
//  TextTransformers
//
//  Created by Andrew J Wagner on 4/26/16.
//  Copyright © 2016 Drewag. All rights reserved.
//

public struct TemplateMapper: Mapper {
    // Templates look like this: "Fixed text with variables {{ v1 }} {{ if v2 }} and {{v2}} {{ end }}"
    // - Variable replacements start with "{{" and end with "}}". The variable name will be replaced by
    //   the value provided in the values dictionary
    // - "{{ if <variable_name> }}" starts a conditional to only include the following text if variable_name
    //   exists. "{{ end }}" is used to return to including text regardless
    let values: [String:String]

    public init(values: [String:String]) {
        self.values = values
    }

    public func map(_ input: String) -> String {
        enum Status {
            case PossibleOpen
            case Opened
            case PossibleClose
            case Closed
        }

        var skip = false
        var output = ""
        var status = Status.Closed
        var commandText = ""

        for character in input.characters {
            switch status {
            case .Closed:
                switch character {
                case "{":
                    status = .PossibleOpen
                default:
                    if !skip {
                        output.append(character)
                    }
                }
            case .PossibleOpen:
                switch character {
                case "{":
                    status = .Opened
                default:
                    status = .Closed
                    if !skip {
                        output.append("{")
                        output.append(character)
                    }
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

                    // Completed command
                    switch self.parseCommand(fromText: commandText) {
                    case .PrintVariable(variableName: let variableName):
                        if let value = self.values[variableName] {
                            if !skip {
                                output.append(value)
                            }
                        }
                    case .IfExists(variableName: let variableName):
                        if self.values[variableName] == nil {
                            skip = true
                        }
                        else {
                            skip = false
                        }
                        break
                    case .End:
                        skip = false
                        break
                    case .Unknown:
                        break
                    }
                    commandText = ""
                default:
                    commandText.append("}")
                    commandText.append(character)
                }
            }
        }

        return output
    }
}

private extension TemplateMapper {
    enum Command {
        case PrintVariable(variableName: String)
        case IfExists(variableName: String)
        case End
        case Unknown
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
        default:
            break
        }
        return .Unknown
    }
}
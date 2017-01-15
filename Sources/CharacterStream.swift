//
//  CharacterStream.swift
//  drewag.me
//
//  Created by Andrew J Wagner on 12/24/16.
//
//

public class CharacterInputStream {
    let source: String
    var index: String.CharacterView.Index

    init(string: String) {
        self.source = string
        self.index = self.source.characters.startIndex
    }

    public func read() -> Character? {
        guard self.index != self.source.characters.endIndex else {
            return nil
        }

        let character = self.source.characters[self.index]
        self.index = self.source.characters.index(after: self.index)
        return character
    }
}

public class CharacterOutputStream {
    var output: String = ""

    public func write(_ character: Character) {
        self.output.append(character)
    }

    public func write(_ string: String) {
        self.output += string
    }
}

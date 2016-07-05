extension String {
    #if os(Linux)
    func components(separatedBy separator: String) -> [String] {
        guard !separator.isEmpty else {
            return [self]
        }

        var components = [String]()
        var nextComponent = ""
        var possibleSeparatorIndex: String.CharacterView.Index? = nil
        var testingSeparatorIndex = separator.startIndex
        var index = self.characters.startIndex
        while index != self.characters.endIndex {
            if testingSeparatorIndex == separator.endIndex {
                // Found complete separator
                testingSeparatorIndex = separator.startIndex
                possibleSeparatorIndex = nil
                components.append(nextComponent)
                nextComponent = ""
            }

            if let startIndex = possibleSeparatorIndex {
                // Currently testing for a separator
                if self.characters[index] == separator.characters[testingSeparatorIndex] {
                    // Found next character in separator
                    testingSeparatorIndex = testingSeparatorIndex.successor()
                }
                else {
                    // Not actually a separator
                    index = startIndex
                    nextComponent.append(self.characters[index])
                    testingSeparatorIndex = separator.startIndex
                    possibleSeparatorIndex = nil
                }
            }
            else {
                // Have not found beginning of separator
                if self.characters[index] == separator.characters[testingSeparatorIndex] {
                    // Found first character
                    possibleSeparatorIndex = index
                    testingSeparatorIndex = testingSeparatorIndex.successor()
                }
                else {
                    nextComponent.append(self.characters[index])
                }
            }

            index = index.successor()
        }
        components.append(nextComponent)
        return components
    }
    #endif
}


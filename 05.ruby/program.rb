#!/usr/bin/env ruby

def indexToReplace (instructions, cursor)
    return instructions[cursor + 3]
end

def getElementRec (instructions, index)
    return instructions[instructions[index]]
end

def getNewSummedValue (instructions, cursor)
    return (getElementRec(instructions, (cursor+1))) + (getElementRec(instructions, (cursor + 2)))
end

def getNewMultipliedValue (instructions, cursor)
    return (getElementRec instructions, (cursor+1)) * (getElementRec instructions, (cursor + 2))
end

def execute (instructions)
    cursor = 0
    continue = true
    while continue do
        case instructions[cursor]
        when 1
            instructions[indexToReplace(instructions, cursor)] = getNewSummedValue(instructions, cursor)
            cursor = cursor+4
        when 2
            instructions[indexToReplace(instructions, cursor)] = getNewMultipliedValue(instructions, cursor)
            cursor = cursor+4
        when 3
        when 4
        when 99
            continue = false
            return instructions
        end
    end
end

print execute([1,0,0,0,99])
print execute([2,3,0,3,99])
print execute([2,4,4,5,99,0])
print execute([1,1,1,4,99,5,6,0,99])


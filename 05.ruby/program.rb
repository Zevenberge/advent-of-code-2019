#!/usr/bin/env ruby

def indexToReplace (instructions, cursor)
    return instructions[cursor + 3]
end

def getElementRec (instructions, index)
    return instructions[instructions[index]]
end

def getElement (instructions, index, mode)
    # Position mode
    if(mode == 0) then return getElementRec(instructions, index)
    # Immediate mode
    else return instructions[index]
    end
end

def getElements(instructions, cursor, modes)
    return [
        getElement(instructions, cursor+1, modes[0]),
        getElement(instructions, cursor+2, modes[1])
    ]
end

def getNewSummedValue (instructions, cursor, modes)
    elements = getElements(instructions, cursor, modes)
    return elements[0] + elements[1]
    
end

def getNewMultipliedValue (instructions, cursor, modes)
    elements = getElements(instructions, cursor, modes)
    return elements[0] * elements[1]
end

def getInput
    return 1
end

def output (value)
    print "\n"
end

def getParameter (operation, n)
    case n
    when 1
        x = operation % 1000
        x = (x/100).floor()
        return x;
    when 2
        x = operation % 10000
        x = (x/1000).floor()
        return x;
    when 3
        return (operation/10000).floor()
    end
end

def execute (instructions)
    cursor = 0
    continue = true
    while continue do
        instruction = instructions[cursor]
        operation = instruction % 100
        modes = [
            getParameter(instruction, 1),
            getParameter(instruction, 2),
            getParameter(instruction, 3)
        ]
        case operation
        when 1
            instructions[indexToReplace(instructions, cursor)] = getNewSummedValue(instructions, cursor, modes)
            cursor = cursor+4
        when 2
            instructions[indexToReplace(instructions, cursor)] = getNewMultipliedValue(instructions, cursor, modes)
            cursor = cursor+4
        when 3
            instructions[instructions[cursor+1]] = getInput();
            cursor = cursor+2
        when 4
            output(getElementRec(instructions, cursor+1))
            cursor = cursor+2
        when 99
            continue = false
            return instructions
        end
    end
end

#print execute([1,0,0,0,99])
#print execute([2,3,0,3,99])
#print execute([2,4,4,5,99,0])
#print execute([1,1,1,4,99,5,6,0,99])
print execute([1002,4,3,4,33])

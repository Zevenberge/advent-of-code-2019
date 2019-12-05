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

def jumpIfTrue (instructions, cursor, modes)
    firstValue = getElement(instructions, cursor+1, modes[0])
    if(firstValue != 0) then
        return getElement(instructions, cursor+2, modes[1])
    else
        return cursor+3
    end
end

def jumpIfFalse (instructions, cursor, modes)
    firstValue = getElement(instructions, cursor+1, modes[0])
    if(firstValue == 0) then
        return getElement(instructions, cursor+2, modes[1])
    else
        return cursor+3
    end
end

def lessThan (instructions, cursor, modes)
    if(getElement(instructions, cursor+1, modes[0]) < getElement(instructions, cursor+2, modes[1])) then
        return 1
    else
        return 0
    end
end

def equals (instructions, cursor, modes)
    if(getElement(instructions, cursor+1, modes[0]) == getElement(instructions, cursor+2, modes[1])) then
        return 1
    else
        return 0
    end
end

def output (instructions, cursor, modes)
    print getElement(instructions, cursor+1, modes[0])
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
            output(instructions, cursor, modes)
            cursor = cursor+2
        when 5
            cursor = jumpIfTrue(instructions, cursor, modes)
        when 6
            cursor = jumpIfFalse(instructions, cursor, modes)
        when 7
            instructions[indexToReplace(instructions, cursor)] = lessThan(instructions, cursor, modes)
            cursor = cursor + 4
        when 8
            instructions[indexToReplace(instructions, cursor)] = equals(instructions, cursor, modes)
            cursor = cursor + 4
        when 99
            continue = false
            return instructions
        end
    end
end

def getInput
    return 5
end

#print execute([3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,
#1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,
#999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99])


execute([3,225,1,225,6,6,1100,1,238,225,104,0,1102,45,16,225,2,65,191,224,1001,224,-3172,224,4,224,102,8,223,223,1001,224,5,224,1,223,224,223,1102,90,55,225,101,77,143,224,101,-127,224,224,4,224,102,8,223,223,1001,224,7,224,1,223,224,223,1102,52,6,225,1101,65,90,225,1102,75,58,225,1102,53,17,224,1001,224,-901,224,4,224,1002,223,8,223,1001,224,3,224,1,224,223,223,1002,69,79,224,1001,224,-5135,224,4,224,1002,223,8,223,1001,224,5,224,1,224,223,223,102,48,40,224,1001,224,-2640,224,4,224,102,8,223,223,1001,224,1,224,1,224,223,223,1101,50,22,225,1001,218,29,224,101,-119,224,224,4,224,102,8,223,223,1001,224,2,224,1,223,224,223,1101,48,19,224,1001,224,-67,224,4,224,102,8,223,223,1001,224,6,224,1,223,224,223,1101,61,77,225,1,13,74,224,1001,224,-103,224,4,224,1002,223,8,223,101,3,224,224,1,224,223,223,1102,28,90,225,4,223,99,0,0,0,677,0,0,0,0,0,0,0,0,0,0,0,1105,0,99999,1105,227,247,1105,1,99999,1005,227,99999,1005,0,256,1105,1,99999,1106,227,99999,1106,0,265,1105,1,99999,1006,0,99999,1006,227,274,1105,1,99999,1105,1,280,1105,1,99999,1,225,225,225,1101,294,0,0,105,1,0,1105,1,99999,1106,0,300,1105,1,99999,1,225,225,225,1101,314,0,0,106,0,0,1105,1,99999,7,226,677,224,102,2,223,223,1005,224,329,1001,223,1,223,8,226,677,224,1002,223,2,223,1005,224,344,101,1,223,223,8,226,226,224,1002,223,2,223,1006,224,359,101,1,223,223,1008,677,226,224,1002,223,2,223,1005,224,374,1001,223,1,223,108,677,677,224,1002,223,2,223,1005,224,389,1001,223,1,223,1107,226,677,224,1002,223,2,223,1006,224,404,101,1,223,223,1008,226,226,224,102,2,223,223,1006,224,419,1001,223,1,223,7,677,226,224,1002,223,2,223,1005,224,434,101,1,223,223,1108,226,226,224,1002,223,2,223,1005,224,449,101,1,223,223,7,226,226,224,102,2,223,223,1005,224,464,101,1,223,223,108,677,226,224,102,2,223,223,1005,224,479,1001,223,1,223,1007,677,226,224,1002,223,2,223,1006,224,494,1001,223,1,223,1007,677,677,224,1002,223,2,223,1006,224,509,1001,223,1,223,107,677,677,224,1002,223,2,223,1005,224,524,101,1,223,223,1108,226,677,224,102,2,223,223,1006,224,539,1001,223,1,223,8,677,226,224,102,2,223,223,1005,224,554,101,1,223,223,1007,226,226,224,102,2,223,223,1006,224,569,1001,223,1,223,107,677,226,224,102,2,223,223,1005,224,584,1001,223,1,223,108,226,226,224,102,2,223,223,1006,224,599,1001,223,1,223,107,226,226,224,1002,223,2,223,1006,224,614,1001,223,1,223,1108,677,226,224,1002,223,2,223,1005,224,629,1001,223,1,223,1107,677,677,224,102,2,223,223,1005,224,644,1001,223,1,223,1008,677,677,224,102,2,223,223,1005,224,659,101,1,223,223,1107,677,226,224,1002,223,2,223,1006,224,674,101,1,223,223,4,223,99,226])

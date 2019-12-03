replace :: ([Int], Int, Int) -> [Int]
replace (array, 0, value) = value : tail array
replace (array, index, value) = (head array) : (replace ((tail array), (index-1), value))

elementToReplace :: ([Int], Int) -> Int
elementToReplace (array, cursor) = array !! (cursor + 3)

getElementRec :: ([Int], Int) -> Int
getElementRec (array, index) = array !! (array !! index)

getNewSummedValue :: ([Int], Int) -> Int
getNewSummedValue (array, cursor) = (getElementRec (array, (cursor + 1)))  + (getElementRec (array, (cursor + 2)))

getNewMultipliedValue :: ([Int], Int) -> Int
getNewMultipliedValue (array, cursor) = (getElementRec (array, (cursor + 1)))  * (getElementRec (array, (cursor + 2)))

executeImpl :: ([Int], Int) -> [Int]
executeImpl (array, cursor) = 
      case (array !! cursor) of
        1 -> executeImpl((replace (array, elementToReplace (array, cursor), getNewSummedValue (array, cursor))), (cursor+4))
        2 -> executeImpl((replace (array, elementToReplace (array, cursor), getNewMultipliedValue (array, cursor))), (cursor+4))
        99 -> array
        _ -> [42]

alert :: ([Int], Int, Int) -> [Int]
alert (array, noun, verb)  = replace ((replace (array, 1, noun)), 2, verb)

bruteForce :: ([Int], [Int], Int) -> [Int]
bruteForce (array, mutatedArray, counter) = 
        if (head mutatedArray) == 19690720
          then [counter-1]
          else bruteForce (array, executeImpl ((alert (array, counter `quot` 100, counter `mod` 100)), 0), counter+1)

execute :: [Int] -> [Int]
execute array = bruteForce (array, array, 0)

main = print (execute [1,0,0,3,1,1,2,3,1,3,4,3,1,5,0,3,2,1,6,19,1,9,19,23,1,6,23,27,1,10,27,31,1,5,31,35,2,6,35,39,1,5,39,43,1,5,43,47,2,47,6,51,1,51,5,55,1,13,55,59,2,9,59,63,1,5,63,67,2,67,9,71,1,5,71,75,2,10,75,79,1,6,79,83,1,13,83,87,1,10,87,91,1,91,5,95,2,95,10,99,2,9,99,103,1,103,6,107,1,107,10,111,2,111,10,115,1,115,6,119,2,119,9,123,1,123,6,127,2,127,10,131,1,131,6,135,2,6,135,139,1,139,5,143,1,9,143,147,1,13,147,151,1,2,151,155,1,10,155,0,99,2,14,0,0])


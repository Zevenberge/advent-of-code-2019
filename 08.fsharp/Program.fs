// Learn more about F# at http://fsharp.org

open System
open System.Linq

let rec tailsOf lists =
    match lists with
    | [] -> []
    | head :: tail -> match head with
                      | [] -> [] :: tailsOf tail
                      | h :: t -> t :: tailsOf tail

let rec countDigits digit layer =
    match layer with
    | [] -> 0
    | d :: tail when d <> digit -> countDigits digit tail
    | d :: tail -> 1 + countDigits digit tail

let rec peelLayer size input =
    if size = 0 then ([], input)
    else match input with
         | [] -> ([], [])
         | head :: tail -> let (layer, rest) = peelLayer (size-1) tail
                           (head :: layer, rest)

let rec splitIntoLayers size input =
    match input with
    | [] -> []
    | _ -> let (layer, rest) = peelLayer size input
           layer :: splitIntoLayers size rest

let rec findVisiblePixel layers =
    match layers with
    | [] -> 2
    | layer :: rest -> match layer with
                       | [] -> 2
                       | head :: tail when head = '0' -> 0
                       | head :: tail when head = '1' -> 1
                       | head :: tail -> findVisiblePixel rest

let rec findVisibleLayer layers =
    match layers with
    | [] -> []
    | head :: tail -> match head with
                      | [] -> []
                      | h :: t -> (findVisiblePixel layers) :: findVisibleLayer (tailsOf layers) 

let printColor digit =
    match digit with
    | 0 -> printf " "
    | 1 -> printf "X"
    | _ -> printf "#"

let rec printLine layer remainingWidth =
    if remainingWidth = 0 then printfn ""
                               layer
    else match layer with
         | [] -> []
         | head :: tail -> printColor head
                           printLine tail (remainingWidth-1)

let rec prettyPrint layer width =
    match layer with
    | [] -> []
    | head :: tail -> prettyPrint (printLine layer width) width

[<EntryPoint>]
let main argv =
    let size = 2*2
    let input = Seq.toList "1001"
    let layers = splitIntoLayers size input
    let visible = findVisibleLayer layers
    prettyPrint visible 2
    0 // return an integer exit code

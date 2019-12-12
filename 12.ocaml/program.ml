open Format;;
open List;;

type vector3 = { x : int; y: int; z : int };;

type moon = {position: vector3; velocity: vector3};;

let isSameStateAsBefore before now =
    before = now
  ;;

let createMoon x y z =
    { position = { x = x; y = y; z = z}; velocity = {x = 0; y = 0; z = 0}}
  ;;

let updateSpeed posMoon posOther speedMoon =
    if posOther > posMoon then speedMoon + 1
    else if posOther < posMoon then speedMoon -1
    else speedMoon
    ;;

let changeVelocity moon other =
    { position = moon.position;
      velocity = {
          x = (updateSpeed moon.position.x other.position.x moon.velocity.x);
          y = (updateSpeed moon.position.y other.position.y moon.velocity.y);
          z = (updateSpeed moon.position.z other.position.z moon.velocity.z)
      }}
    ;;

let rec determineVelocity others moon =
    match others with
    | [] -> moon
    | head :: tail -> determineVelocity tail (changeVelocity moon head)
  ;;

let energy vector =
    (abs vector.x) + (abs vector.y) + (abs vector.z)
    ;;

let kineticEnergy moon =
    energy moon.velocity
    ;;

let totalEnergy moon =
    (energy moon.position) * (energy moon.velocity)
    ;;

let sum = List.fold_left (+) 0;;

let printEnergy moons =
    moons |> List.map kineticEnergy |> sum |> Format.printf "Total energy %d\n"
  ;;


let move moon =
    {
        position = {
            x = moon.position.x + moon.velocity.x;
            y = moon.position.y + moon.velocity.y;
            z = moon.position.z + moon.velocity.z
        };
        velocity = moon.velocity
    }
    ;;

let simulateStep moons =
    moons |> List.map (determineVelocity moons) |> List.map move
    ;;

let rec simulateXSteps x moons =
    if x < 1 then moons
    else simulateXSteps (x - 1) (simulateStep moons)
    ;;

let rec simulateUntilPreviousState steps before moons =
  (* let () = printEnergy moons  in*)
   if before = moons then steps
   else if steps > 4686774924 then -1
   else simulateUntilPreviousState (steps+1) before (simulateStep moons)

let simulateUntilBefore moons =
   simulateUntilPreviousState 1 moons (simulateStep moons)
   ;;

let printMoon moon =
    Format.printf "(%d %d %d) with (%d %d %d)\n" moon.position.x moon.position.y moon.position.z moon.velocity.x moon.velocity.y moon.velocity.z
  ;;

let moon = createMoon 1 2 3;;
(*let moons = [
    (createMoon (-1) 0 2);
    (createMoon 2 (-10) (-7));
    (createMoon 4 (-8) 8);
    (createMoon 3 5 (-1))
];;*)

let moons = [
    (createMoon (-8) (-10) 0);
    (createMoon 5 5 10);
    (createMoon 2 (-7) 3);
    (createMoon 9 (-8) (-2))
];;

(*let moons = [
    (createMoon 16 (-8) 13);
    (createMoon 4 10 10);
    (createMoon 17 (-5) 6);
    (createMoon 13 (-3) 0)
];;*)

moons |> simulateUntilBefore |> Format.printf "%d"

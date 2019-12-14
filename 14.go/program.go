package main

import (
	"fmt"
	"bufio"
	"math"
	"os"
	"strings"
	"strconv"
)

type Item struct {
	Name string
	Reactions []Reaction
}

func NewItem(name string) *Item {
	return &Item {Name: name, Reactions: []Reaction{}}
}

type Material struct {
	Quantity int
	Thing *Item
}

func (m *Material) String() string {
	return "Name="+m.Thing.Name+"Quantity="+strconv.Itoa(m.Quantity)
  }

type Reaction struct {
	ProducedQuantity int
	Input []Material
}

func findOrCreateItem(name string, items [](*Item)) (*Item, [](*Item)) {
	for _, existing := range items {
		if existing.Name == name {
			return existing, items
		}
	}
	item := NewItem(name)
	items = append(items, item)
	return item, items
}

func stripTrailingComma(name string) string {
	return strings.Replace(name, ",", "", 1)
}

func processLine(line string, items []*Item) []*Item {
	words := strings.Split(line, " ")
	ingredients := []Material{}
	i := 0
	for ; words[i] != "=>" ; i +=2 {
		quantity, _ := strconv.Atoi(words[i])
		name := stripTrailingComma(words[i+1])
		var item *Item
		item, items = findOrCreateItem(name, items)
		material := Material{ Quantity: quantity, Thing: item}
		ingredients = append(ingredients, material)
	}
	i += 1 // Skip the arrow
	quantity, _ := strconv.Atoi(words[i])
	reaction := Reaction{ProducedQuantity: quantity, Input: ingredients}
	name := stripTrailingComma(words[i+1])
	item, items := findOrCreateItem(name, items)
	item.Reactions = append(item.Reactions, reaction)
	return items
}

func createItems(input []string) []*Item {
	items := []*Item{}
	for _, line := range input {
		items = processLine(line, items)
	}
	return items
}

func readFile() []string {
	file, _ := os.Open("input.txt")
	defer file.Close()
	lines := []string{}
	scanner := bufio.NewScanner(file)
    for scanner.Scan() {
        lines = append(lines, scanner.Text())
	}
	return lines
}

func consumeFromLeftovers(ingredient *Material, leftovers []*Material) {
	for _, rest := range leftovers {
		if ingredient.Thing.Name == rest.Thing.Name {
			amountRequired := ingredient.Quantity
			ingredient.Quantity = int(math.Max(0, float64(amountRequired - rest.Quantity)))
			rest.Quantity = int(math.Max(0, float64(rest.Quantity - amountRequired)))
		}
	}
}

func howOftenDoINeedToFuse(result Material, reaction Reaction) int {
	return int(math.Ceil(float64(result.Quantity)/float64(reaction.ProducedQuantity)))
}

func produceLeftovers(product Material, amountOfTimesReactionIsRequired int, 
	reaction Reaction, leftovers []*Material) []*Material {
	overproduce := reaction.ProducedQuantity * amountOfTimesReactionIsRequired - product.Quantity
	if overproduce > 0 {
		for _, rest := range leftovers {
			if rest.Thing.Name == product.Thing.Name {
				rest.Quantity += overproduce
				return leftovers
			}
		}
		leftovers = append(leftovers, &Material{Quantity: overproduce, Thing: product.Thing})
	}
	return leftovers
}

func findOreForItem(ingredient Material, leftovers []*Material) (int, []*Material) {
	if ingredient.Thing.Name == "ORE" {
		return ingredient.Quantity, leftovers
	}
	ores := 0
	reaction := ingredient.Thing.Reactions[0]
	consumeFromLeftovers(&ingredient, leftovers)
	amountOfTimesReactionIsRequired := howOftenDoINeedToFuse(ingredient, reaction)
	leftovers = produceLeftovers(ingredient, amountOfTimesReactionIsRequired, reaction, leftovers)
	for _, input := range reaction.Input {
		var usedOre int
		usedOre, leftovers = findOreForItem(Material{Thing: input.Thing, Quantity: input.Quantity * amountOfTimesReactionIsRequired}, leftovers)
		ores += usedOre
	}
	return ores, leftovers
}

func findOreForFuel(items []*Item) int {
	fuel, items := findOrCreateItem("FUEL", items)
	ores := 0
	leftovers := []*Material{}
	ores, leftovers = findOreForItem(Material{Thing: fuel, Quantity: 1}, leftovers)
	return ores
}

func main() {
	lines := readFile()
	items := createItems(lines)
	result := findOreForFuel(items)
	fmt.Printf("Total ores needed %d \n", result)
}
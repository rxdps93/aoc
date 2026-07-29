package day16.puzzle2;

import utils.InputParser;

import java.util.List;

public class d16p2 {

    private static int getByName(String name) {
        return switch (name) {
            case "children", "pomeranians", "trees" -> 3;
            case "cats" -> 7;
            case "samoyeds", "cars" -> 2;
            case "akitas", "vizslas" -> 0;
            case "goldfish" -> 5;
            case "perfumes" -> 1;
            default -> -1;
        };
    }

    private static boolean check(String name, int value) {
        if (name.equals("cats") || name.equals("trees")) {
            return value > getByName(name);
        } else if (name.equals("pomeranians") || name.equals("goldfish")) {
            return value < getByName(name);
        } else {
            return value == getByName(name);
        }
    }

    public static void main(String[] args) {

        int sue = -1;
        List<String> input = InputParser.parse("day16/input.txt").asList();
        for (String line : input) {
            String[] tokens = line.replace(":", ",").replace(" ", "").replace("Sue", "").split(",");
            if (check(tokens[1], Integer.parseInt(tokens[2])) &&
                    check(tokens[3], Integer.parseInt(tokens[4])) &&
                    check(tokens[5], Integer.parseInt(tokens[6]))) {
                sue = Integer.parseInt(tokens[0]);
                break;
            }
        }

        System.out.printf("You received the gift from Sue %d\n", sue);
    }
}

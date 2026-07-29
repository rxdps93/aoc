package day19.puzzle2;

import utils.InputParser;
import utils.Pair;

import java.util.HashSet;
import java.util.List;

public class d19p2 {

    private static int countElements(String molecule) {

        int elements = 0;
        for (int i = 0; i < molecule.length(); i++) {
            if (Character.isLowerCase(molecule.charAt(i))) {
                elements++;
            } else if (Character.isUpperCase(molecule.charAt(i)) &&
                    (i == molecule.length() - 1 ) || Character.isUpperCase(molecule.charAt(i + 1))) {
                elements++;
            }
        }
        return elements;
    }

    private static Pair<Integer, Integer> countTokens(String molecule) {
        int parenthesis = 0;
        int commas = 0;
        String temp = molecule.replace("Rn", "(").replace("Y", ",")
                .replace("Ar", ")");
        for (char c : temp.toCharArray()) {
            if (c == '(' || c == ')') {
                System.out.println(c + " -> " + parenthesis);
                parenthesis++;
            } else if (c == ',') {
                commas += 1;
            }
        }

        return Pair.of(parenthesis, commas);
    }

    public static void main(String[] args) {

        List<String> input = InputParser.parse("day19/input.txt").asList();

        String initialMolecule = input.remove(input.size() - 1);
        int elements = countElements(initialMolecule);
        Pair<Integer, Integer> count = countTokens(initialMolecule);
        System.out.println(elements - count.first() - (2 * count.second()) - 1);
    }
}

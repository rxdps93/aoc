package day19.puzzle1;

import utils.InputParser;

import java.util.HashSet;
import java.util.List;

public class d19p1 {

    public static void main(String[] args) {

        List<String> input = InputParser.parse("day19/input.txt").asList();

        final String initialMolecule = input.remove(input.size() - 1);
        input.remove(input.size() - 1); // clear blank line
        final HashSet<String> molecules = new HashSet<>();
        for (String instr : input) {
            String[] tokens = instr.split(" => ");

            StringBuilder sb = new StringBuilder(initialMolecule);
            for (int i = 0; i < initialMolecule.length(); i++) {
                if (sb.substring(i, Math.min(i + tokens[0].length(), initialMolecule.length())).equals(tokens[0])) {
                    sb.replace(i, i + tokens[0].length(), tokens[1]);
                    molecules.add(sb.toString());
                    sb = new StringBuilder(initialMolecule);
                }
            }
        }

        System.out.printf("There are %d distinct molecules that can be created after one replacement.", molecules.size());
    }
}

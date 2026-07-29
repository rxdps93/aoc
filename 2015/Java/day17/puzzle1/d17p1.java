package day17.puzzle1;

import utils.InputParser;

import java.util.ArrayList;
import java.util.List;

public class d17p1 {

    private static void combinations(final List<Integer> containers, List<Integer> combo,
                                     List<List<Integer>> combos, int index, int choose, int target) {
        if (choose == 0) {
            if (combo.stream().mapToInt(i -> i).sum() == target) {
                combos.add(new ArrayList<>(combo));
            }
            return;
        }

        for (int i = index; i <= containers.size() - choose; ++i) {
            combo.add(containers.get(i));
            combinations(containers, combo, combos, i + 1, choose - 1, target);
            combo.remove(combo.size() - 1);
        }
    }

    public static void main(String[] args) {
        List<Integer> containers = InputParser.parse("day17/input.txt").asList()
                .stream().map(Integer::parseInt).toList();

        List<List<Integer>> combos = new ArrayList<>();
        for (int k = 1; k <= containers.size(); k++) {
            combinations(new ArrayList<>(containers), new ArrayList<>(), combos, 0, k, 150);
        }

        System.out.printf("There are %d combinations that fit exactly 150 liters of eggnog.\n", combos.size());
    }
}

package day24.puzzle2;

import utils.InputParser;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;

public class d24p2 {

    private static void groupPackages(List<Integer> weights, List<List<Integer>> groups, List<Integer> group,
                                      int remainder, int index) {
        if (remainder < 0) {
            return;
        }

        if (remainder == 0) {
            groups.add(new ArrayList<>(group));
            return;
        }

        for (int i = index; i < weights.size(); i++) {
            if (i > index && weights.get(i).equals(weights.get(i - 1))) {
                continue;
            }

            group.add(weights.get(i));
            groupPackages(weights, groups, group, remainder - weights.get(i), i + 1);
            group.remove(group.size() - 1);
        }
    }

    public static void main(String[] args) {
        List<Integer> input = InputParser.parse("day24/input.txt").asList()
                .stream().map(Integer::parseInt).toList();

        final int totalWeight = input.stream().mapToInt(w -> w).sum();
        final int groupWeight = totalWeight / 4;



        List<List<Integer>> groups = new ArrayList<>();
        groupPackages(input, groups, new ArrayList<>(), groupWeight, 0);

        groups.sort(Comparator.comparing(List::size));
        groups.removeIf(list -> list.size() > groups.get(0).size());

        long bestQE = Long.MAX_VALUE;
        for (List<Integer> group : groups) {
            bestQE = Math.min(bestQE, group.stream().mapToLong(Integer::longValue).reduce(1, (a, b) -> a * b));
        }

        System.out.println("The quantium entanglement of the ideal first group is " + bestQE);
    }
}

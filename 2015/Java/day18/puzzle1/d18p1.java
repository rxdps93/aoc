package day18.puzzle1;

import utils.InputParser;
import utils.Pair;

import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;

public class d18p1 {

    private static List<Pair<Integer, Integer>> getAdjacent(Pair<Integer, Integer> light) {
        int r = light.first();
        int c = light.second();
        return List.of(
                Pair.of(r - 1, c - 1), Pair.of(r - 1, c), Pair.of(r - 1, c + 1),
                Pair.of(r, c - 1), Pair.of(r, c + 1),
                Pair.of(r + 1, c - 1), Pair.of(r + 1, c), Pair.of(r + 1, c + 1));
    }

    private static void print(int size, HashMap<Pair<Integer, Integer>, Boolean> lights) {
        char[][] show = new char[size][size];
        lights.forEach((k, v) -> {
            show[k.first()][k.second()] = switch (v.toString()) {
                case "true" -> '#';
                case "false" -> '.';
                default -> '?';
            };
        });

        for (int r = 0; r < size; r++) {
            for (int c = 0; c < size; c++) {
                System.out.print(show[r][c]);
            }
            System.out.println();
        }
    }

    public static void main(String[] args) {

        List<String> input = InputParser.parse("day18/input.txt").asList();

        HashMap<Pair<Integer, Integer>, Boolean> lights = new HashMap<>();
        final int size = input.size();
        final int steps = size == 6 ? 4 : 100;
        for (int row = 0; row < size; row++) {
            for (int col = 0; col < size; col++) {
                lights.put(Pair.of(row, col), input.get(row).charAt(col) == '#');
            }
        }

        HashSet<Pair<Integer, Integer>> toggle = new HashSet<>();
        for (int step = 0; step < steps; step++) {
            lights.forEach((light, isOn) -> {
                int adjOn = 0;
                for (Pair<Integer, Integer> adj : getAdjacent(light)) {
                    if (lights.containsKey(adj) && lights.get(adj)) {
                        adjOn++;
                    }
                }

                if (isOn && (adjOn != 2 && adjOn != 3)) {
                    toggle.add(light);
                } else if (!isOn && adjOn == 3) {
                    toggle.add(light);
                }
            });

            toggle.forEach(light -> lights.put(light, !lights.get(light)));
            toggle.clear();
        }

//        print(size, lights);

        System.out.printf("After %d steps there are %d lights on.\n",
                steps, lights.values().stream().mapToInt(v -> v ? 1 : 0).sum());
    }
}

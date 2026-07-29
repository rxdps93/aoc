package day03.puzzle2;

import utils.InputParser;
import utils.Pair;

import java.util.HashMap;

public class d3p2 {

    public static void main(String[] args) {
        String input = InputParser.parse("day03/input.txt").asArray()[0];
        HashMap<Pair<Integer, Integer>, Integer> grid = new HashMap<>();

        grid.put(Pair.of(0, 0), 1);

        int[] x = { 0, 0 };
        int[] y = { 0, 0 };
        int turn = 0;
        for (char c : input.toCharArray()) {
            switch (c) {
                case '<':
                    x[turn]--;
                    break;
                case '>':
                    x[turn]++;
                    break;
                case '^':
                    y[turn]++;
                    break;
                case 'v':
                    y[turn]--;
                    break;
            }

            Pair<Integer, Integer> pair = Pair.of(x[turn], y[turn]);
            if (grid.containsKey(pair)) {
                grid.replace(pair, grid.get(pair) + 1);
            } else {
                grid.put(pair, 1);
            }

            turn = 1 - turn;
        }

        System.out.println(grid.size());
    }
}

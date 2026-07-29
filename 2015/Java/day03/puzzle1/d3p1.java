package day03.puzzle1;

import utils.InputParser;
import utils.Pair;

import java.util.HashMap;

public class d3p1 {

    public static void main(String[] args) {
        String input = InputParser.parse("day03/input.txt").asArray()[0];
        HashMap<Pair<Integer, Integer>, Integer> grid = new HashMap<>();

        grid.put(Pair.of(0, 0), 1);

        int x = 0, y = 0;
        for (char c : input.toCharArray()) {
            switch (c) {
                case '<':
                    x--;
                    break;
                case '>':
                    x++;
                    break;
                case '^':
                    y++;
                    break;
                case 'v':
                    y--;
                    break;
            }

            Pair<Integer, Integer> pair = Pair.of(x, y);
            if (grid.containsKey(pair)) {
                grid.replace(pair, grid.get(pair) + 1);
            } else {
                grid.put(pair, 1);
            }
        }

        System.out.println(grid.size());
    }
}

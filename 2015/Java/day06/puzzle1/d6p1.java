package day06.puzzle1;

import utils.InputParser;
import utils.Pair;

import java.util.HashMap;
import java.util.List;

public class d6p1 {

    public static void main(String [] args) {
        List<String> instructions = InputParser.parse("day06/input.txt").asList();

        HashMap<Pair<Integer, Integer>, Integer> lights = new HashMap<>();
        for (String instr : instructions) {

            int action;
            if (instr.charAt(6) == 'f') {
                action = 0;
            } else if (instr.charAt(6) == 'n') {
                action = 1;
            } else {
                action = 2;
            }

            instr = instr.replace("through", ",");
            instr = instr.replaceAll("[^0-9,-]", "");
            String[] vals = instr.split(",");

            for (int x = Integer.parseInt(vals[0]); x <= Integer.parseInt(vals[2]); x++) {
                for (int y = Integer.parseInt(vals[1]); y <= Integer.parseInt(vals[3]); y++) {
                    if (action == 2) {
                        if (lights.containsKey(Pair.of(x, y))) {
                            lights.put(Pair.of(x, y), 1 - lights.get(Pair.of(x, y)));
                        } else {
                            lights.put(Pair.of(x, y), 1);
                        }
                    } else {
                        lights.put(Pair.of(x, y), action);
                    }
                }
            }
        }

        int on = 0;
        for (int v : lights.values()) {
            on += v;
        }

        System.out.format("There are %d lights on.", on);
    }
}

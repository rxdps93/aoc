package day06.puzzle2;

import utils.InputParser;
import utils.Pair;

import java.util.HashMap;
import java.util.List;

public class d6p2 {

    public static void main(String [] args) {
        List<String> instructions = InputParser.parse("day06/input.txt").asList();

        HashMap<Pair<Integer, Integer>, Integer> lights = new HashMap<>();
        for (String instr : instructions) {

            int action;
            if (instr.charAt(6) == 'f') {
                action = -1;
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
                    lights.compute(Pair.of(x, y),
                            (key, val) -> (val == null) ? Math.max(0, action) : Math.max(0, val + action));
                }
            }
        }

        int brightness = 0;
        for (int v : lights.values()) {
            brightness += v;
        }

        System.out.format("The total brightness is %d.", brightness);
    }
}

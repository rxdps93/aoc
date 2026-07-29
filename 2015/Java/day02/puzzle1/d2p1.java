package day02.puzzle1;

import utils.InputParser;

import java.util.Arrays;
import java.util.List;

public class d2p1 {
    public static void main(String[] args) {

        InputParser parser = InputParser.parse("day02/input.txt");
        List<String> input = parser.asList();

        int sum = 0;
        for (String box : input) {
            int[] dims = Arrays.stream(box.split("x")).mapToInt(Integer::parseInt).toArray();
            int[] sides = { dims[0] * dims[1], dims[1] * dims[2], dims[2] * dims[0] };
            Arrays.sort(sides);
            sum += (2 * (sides[0] + sides[1] + sides[2])) + sides[0];
        }

        System.out.println(sum + " sqft of wrapping paper");
    }
}

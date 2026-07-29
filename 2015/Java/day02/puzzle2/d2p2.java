package day02.puzzle2;

import utils.InputParser;

import java.util.Arrays;
import java.util.List;

public class d2p2 {
    public static void main(String[] args) {

        InputParser parser = InputParser.parse("day02/input.txt");
        List<String> input = parser.asList();

        int sum = 0;
        for (String box : input) {
            int[] dims = Arrays.stream(box.split("x")).mapToInt(Integer::parseInt).toArray();
            Arrays.sort(dims);

            sum += (2 * (dims[0] + dims[1])) + (dims[0] * dims[1] * dims[2]);
        }

        System.out.println(sum + " ft of ribbon");
    }
}

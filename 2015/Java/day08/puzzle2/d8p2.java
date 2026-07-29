package day08.puzzle2;

import utils.InputParser;

import java.util.List;

public class d8p2 {
    public static void main(String [] args) {
        List<String> lines = InputParser.parse("day08/input.txt").asList();

        int strSum = 0;
        int memSum = 0;

        for (String line : lines) {
            strSum += line.length();
            memSum += line.length() + 2;
            for (char c : line.toCharArray()) {
                if (c == '"') {
                    memSum++;
                } else if (c == '\\') {
                    memSum++;
                }
            }
        }

        System.out.println("The answer is " + (memSum - strSum));
    }
}

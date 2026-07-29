package day04.puzzle2;

import utils.InputParser;
import utils.MD5;

public class d4p2 {

    public static void main(String [] args) {
        String key = InputParser.parse("day04/input.txt").asArray()[0];

        int num = 1;
        String input = key + num;
        while (!MD5.of(input).substring(0, 6).equals("000000")) {
            num++;
            input = key + num;
        }

        System.out.println(num);
    }
}

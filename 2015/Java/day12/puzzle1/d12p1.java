package day12.puzzle1;

import utils.InputParser;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class d12p1 {

    public static void main(String[] args) {

        String input = InputParser.parse("day12/input.txt").asString();

        Matcher match = Pattern.compile("([-0-9]+)").matcher(input);
        int sum = 0;
        while (match.find()) {
            sum += Integer.parseInt(match.group());
        }

        System.out.println("The sum of all numbers is " + sum);
    }
}

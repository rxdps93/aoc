package day25.puzzle1;

import utils.InputParser;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class d25p1 {

    public static void main(String[] args) {
        String input = InputParser.parse("day25/input.txt").asString();
        Matcher regex = Pattern.compile("[0-9]+").matcher(input);

        regex.find();
        final int targetRow = Integer.parseInt(regex.group());
        regex.find();
        final int targetCol = Integer.parseInt(regex.group());

        final long codeNum = targetRow + targetCol - 1;
        final long triangle = ((codeNum * codeNum) + (targetRow + targetCol)) / 2;

        long code = 20151125;
        for (int i = 1; i < triangle - targetRow + 1; i++) {
            code = (code * 252533) % 33554393;
        }

        System.out.println("The weather machine code is " + code);
    }
}

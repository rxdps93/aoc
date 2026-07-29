package day10.puzzle1;

import utils.InputParser;

public class d10p1 {
    public static void main(String[] args) {
        char[] input = InputParser.parse("day10/input.txt").asArray()[0].toCharArray();

        for (int i = 0; i < 40; i++) {

            StringBuilder sb = new StringBuilder();

            for (int ci = 0; ci < input.length; ci++) {

                int scan = 0;
                char c = input[ci];
                int copies = 0;
                while (ci + scan < input.length && input[ci + scan] == c) {
                    scan++;
                    copies++;
                }

                ci += (scan - 1);

                sb.append(copies);
                sb.append(c);
            }

            input = sb.toString().toCharArray();
        }

        System.out.println(input.length);
    }
}

package day23.puzzle1;

import utils.InputParser;

import java.util.Arrays;
import java.util.List;

public class d23p1 {

    private static int a = 0;
    private static int b = 0;

    private static void hlf(String r) {
        if (r.equals("a")) {
            a /= 2;
        } else if (r.equals("b")) {
            b /= 2;
        }
    }

    private static void tpl(String r) {
        if (r.equals("a")) {
            a *= 3;
        } else if (r.equals("b")) {
            b *= 3;
        }
    }

    public static void inc(String r) {
        if (r.equals("a")) {
            a++;
        } else if (r.equals("b")) {
            b++;
        }
    }

    public static boolean jie(String r) {
        if (r.equals("a")) {
            return a % 2 == 0;
        } else {
            return b % 2 == 0;
        }
    }

    public static boolean jio(String r) {
        if (r.equals("a")) {
            return a == 1;
        } else {
            return b == 1;
        }
    }

    public static void main(String[] args) {
        List<String[]> programs = InputParser.parse("day23/input.txt").asList()
                .stream().map(str ->
                        str.replace(",", "").replace("+", "").split(" ")).toList();

        int i = 0;
        while (i < programs.size()) {
            String[] instr = programs.get(i);
            switch (instr[0]) {
                case "hlf" -> {
                    hlf(instr[1]);
                    i++;
                }
                case "tpl" -> {
                    tpl(instr[1]);
                    i++;
                }
                case "inc" -> {
                    inc(instr[1]);
                    i++;
                }
                case "jmp" -> i += Integer.parseInt(instr[1]);
                case "jie" -> i += jie(instr[1]) ? Integer.parseInt(instr[2]) : 1;

                case "jio" -> i += jio(instr[1]) ? Integer.parseInt(instr[2]) : 1;
            }
        }

        System.out.printf("Register values: [ a: %d, b: %d ]\n", a, b);
    }
}

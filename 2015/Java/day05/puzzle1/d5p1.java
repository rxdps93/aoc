package day05.puzzle1;

import utils.InputParser;

import java.util.List;
import java.util.regex.Pattern;

public class d5p1 {

    private static void parseVowels(List<String>lines) {

        final String regex = ".*[aeiou].*[aeiou].*[aeiou].*";

        for (int i = 0; i < lines.size(); i++) {
            if (!Pattern.matches(regex, lines.get(i))) {
                lines.set(i, "");
            }
        }
    }

    private static void parseDoubles(List<String> lines) {

        final String regex = ".*(([a-z])(\\2)).*";

        for (int i = 0; i < lines.size(); i++) {
            if (!Pattern.matches(regex, lines.get(i))) {
                lines.set(i, "");
            }
        }
    }

    private static void parseForbidden(List<String> lines) {

        final String regex = ".*(ab|cd|pq|xy).*";

        for (int i = 0; i < lines.size(); i++) {
            if (Pattern.matches(regex, lines.get(i))) {
                lines.set(i, "");
            }
        }
    }

    public static void main(String[] args) {
        List<String> lines = InputParser.parse("day05/input.txt").asList();

        parseVowels(lines);
        parseDoubles(lines);
        parseForbidden(lines);
        lines.removeIf(""::equals);

        System.out.println(lines.size());
    }
}

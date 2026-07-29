package day05.puzzle2;

import utils.InputParser;

import java.util.List;
import java.util.regex.Pattern;

public class d5p2 {

    private static void parse(List<String> lines) {

        final String regexPair = ".*(\\w{2}).*?(\\1).*";
        final String regexRepeat = ".*(\\w).(\\1).*";

        for (int i = 0; i < lines.size(); i++) {
            if (!Pattern.matches(regexPair, lines.get(i)) || !Pattern.matches(regexRepeat, lines.get(i))) {
                lines.set(i, "");
            }
        }

        lines.removeIf(""::equals);
    }

    public static void main(String[] args) {
        List<String> lines = InputParser.parse("day05/input.txt").asList();

        parse(lines);

        System.out.println(lines.size());
    }
}

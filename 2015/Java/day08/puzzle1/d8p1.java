package day08.puzzle1;

import utils.InputParser;

import java.util.List;
import java.util.regex.Pattern;
import java.util.regex.Matcher;

public class d8p1 {

    private static String convert(String old) {
        String str = old;

        Pattern hexPattern = Pattern.compile("\\\\x[0-9|A-F|a-f]{2}");

        Matcher hm = hexPattern.matcher(str);
        while (hm.find()) {
            String hex = hm.group().substring(2);
            str = str.replace(hm.group(0), Character.toString((char)Integer.parseInt(hex, 16)));
        }

        str = str.replace("\\\"", "\"").replace("\\\\", "\\");

        return str;
    }

    public static void main(String [] args) {
        List<String> lines = InputParser.parse("day08/input.txt").asList();

        int strSum = 0;
        int memSum = 0;

        for (String line : lines) {
            strSum += line.length();
            String str = convert(line.substring(1, line.lastIndexOf("\"")));
            memSum += str.length();
        }

        System.out.println("The answer is " + (strSum - memSum));
    }
}

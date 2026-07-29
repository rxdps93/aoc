package day07.puzzle1;

import utils.InputParser;

import java.util.*;

public class d7p1 {

    private static String and(String a, String b) {
        return Integer.toString(Integer.parseInt(a) & Integer.parseInt(b));
    }

    private static String or(String a, String b) {
        return Integer.toString(Integer.parseInt(a) | Integer.parseInt(b));
    }

    private static String not(String value) {
        return Integer.toString(~Integer.parseInt(value));
    }

    private static String lshift(String value, String amnt) {
        return Integer.toString(Integer.parseInt(value) << Integer.parseInt(amnt));
    }

    private static String rshift(String value, String amnt) {
        return Integer.toString(Integer.parseInt(value) >> Integer.parseInt(amnt));
    }

    public static void main(String[] args) {
        List<String> lines = InputParser.parse("day07/input.txt").asList();

        HashMap<String, String> withValues = new HashMap<>();
        HashMap<String, String> toProcess = new HashMap<>();

        lines.forEach(line -> {
            String[] tokens = Arrays.stream(line.split("->")).map(String::trim).toArray(String[]::new);
            String[] op = tokens[0].split(" ");
            if (op.length == 1) {
                if (op[0].matches("[0-9]*")) {
                    withValues.put(tokens[1], op[0]);
                } else if (withValues.containsKey(op[0])) {
                    withValues.put(tokens[1], withValues.get(op[0]));
                } else {
                    toProcess.put(tokens[1], op[0]);
                }
            } else {
                toProcess.put(tokens[1], tokens[0]);
            }
        });

        while (!toProcess.isEmpty()) {
            for (Iterator<Map.Entry<String, String>> iter = toProcess.entrySet().iterator(); iter.hasNext(); ) {
                Map.Entry<String, String> entry = iter.next();

                String[] op = entry.getValue().split(" ");
                switch (op.length) {
                    case 1 -> { // signal
                        if (withValues.containsKey(op[0])) {
                            withValues.put(entry.getKey(), withValues.get(op[0]));
                            iter.remove();
                        }
                    }
                    case 2 -> { // not
                        if (withValues.containsKey(op[1])) {
                            withValues.put(entry.getKey(), not(withValues.get(op[1])));
                            iter.remove();
                        }
                    }
                    case 3 -> { // and, or, lshift, rshift
                        switch (op[1]) {
                            case "AND" -> {
                                if ((withValues.containsKey(op[0]) || op[0].matches("[0-9]*")) && withValues.containsKey(op[2])) {
                                    String a = op[0].matches("[0-9]*") ? op[0] : withValues.get(op[0]);
                                    withValues.put(entry.getKey(), and(a, withValues.get(op[2])));
                                    iter.remove();
                                }
                            }
                            case "OR" -> {
                                if (withValues.containsKey(op[0]) && withValues.containsKey(op[2])) {
                                    withValues.put(entry.getKey(), or(withValues.get(op[0]), withValues.get(op[2])));
                                    iter.remove();
                                }
                            }
                            case "LSHIFT" -> {
                                if (withValues.containsKey(op[0])) {
                                    withValues.put(entry.getKey(), lshift(withValues.get(op[0]), op[2]));
                                    iter.remove();
                                }
                            }
                            case "RSHIFT" -> {
                                if (withValues.containsKey(op[0])) {
                                    withValues.put(entry.getKey(), rshift(withValues.get(op[0]), op[2]));
                                    iter.remove();
                                }
                            }
                        }
                    }
                }
            }
        }

        System.out.println("The value on wire a is " + withValues.get("a"));
    }
}

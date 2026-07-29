package day13.puzzle2;

import utils.InputParser;
import utils.Pair;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;

public class d13p2 {

    private static void swap(String[] arrangement, int a, int b) {
        String temp = arrangement[a];
        arrangement[a] = arrangement[b];
        arrangement[b] = temp;
    }

    private static void seatingArrangements(String[] arrangement, List<String[]> arrangements, int n) {

        if (n <= 0) {
            arrangements.add(arrangement);
            return;
        }

        String[] temp = Arrays.copyOf(arrangement, arrangement.length);
        for (int i = 0; i < n; i++) {
            swap(temp, i, n - 1);
            seatingArrangements(temp, arrangements, n - 1);
            swap(temp, i, n - 1);
        }
    }

    public static void main(String[] args) {

        List<String> input = InputParser.parse("day13/input.txt").asList();

        List<String> filterWords = List.of("would", "happiness", "units", "by", "sitting", "next", "to");
        HashMap<Pair<String, String>, Integer> connections = new HashMap<>();
        HashSet<String> people = new HashSet<>();
        input.forEach(line -> {
            String[] tokens = Arrays.stream(line.replace(".", "").split(" ")).filter(str -> !filterWords.contains(str)).toArray(String[]::new);
            people.add(tokens[0]);
            int units = tokens[1].equals("gain") ? Integer.parseInt(tokens[2]) : -Integer.parseInt(tokens[2]);
            connections.putIfAbsent(Pair.of(tokens[0], tokens[3]), units);
        });

        people.forEach(person -> {
            connections.putIfAbsent(Pair.of(person, "Me"), 0);
            connections.putIfAbsent(Pair.of("Me", person), 0);
        });
        people.add("Me");

        ArrayList<String[]> arrangements = new ArrayList<>();
        seatingArrangements(people.toArray(String[]::new), arrangements, people.size());

        int best = Integer.MIN_VALUE;
        for (String[] arrangement : arrangements) {
            int happiness = 0;
            for (int i = 0; i < arrangement.length - 1; i++) {
                happiness += connections.get(Pair.of(arrangement[i], arrangement[i + 1]));
                happiness += connections.get(Pair.of(arrangement[i + 1], arrangement[i]));
            }
            happiness += connections.get(Pair.of(arrangement[0], arrangement[arrangement.length - 1]));
            happiness += connections.get(Pair.of(arrangement[arrangement.length - 1], arrangement[0]));

            best = Math.max(happiness, best);
        }

        System.out.println("The optimal seating arrangement results in a total happiness gain of " + best);
    }
}

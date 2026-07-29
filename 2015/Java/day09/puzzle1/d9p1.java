package day09.puzzle1;

import utils.InputParser;
import utils.Pair;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;

public class d9p1 {

    private static void swap(String[] route, int a, int b) {
        String temp = route[a];
        route[a] = route[b];
        route[b] = temp;
    }

    private static void generateRoutes(String[] route, ArrayList<String[]> routes, int n) {

        if (n <= 0) {
            routes.add(route);
            return;
        }

        String[] temp = Arrays.copyOf(route, route.length);
        for (int i = 0; i < n; i++) {
            swap(temp, i, n - 1);
            generateRoutes(temp, routes, n - 1);
            swap(temp, i, n - 1);
        }
    }

    public static void main(String[] args) {
        List<String> lines = InputParser.parse("day09/input.txt").asList();

        HashMap<Pair<String, String>, Integer> connections = new HashMap<>();
        HashSet<String> locations = new HashSet<>();
        lines.forEach(line -> {
            String[] tokens = Arrays.stream(line.split("to|=")).map(String::trim).toArray(String[]::new);
            locations.add(tokens[0]);
            locations.add(tokens[1]);
            connections.putIfAbsent(Pair.of(tokens[0], tokens[1]), Integer.parseInt(tokens[2]));
            connections.putIfAbsent(Pair.of(tokens[1], tokens[0]), Integer.parseInt(tokens[2]));
        });

        ArrayList<String[]> allRoutes = new ArrayList<>();
        generateRoutes(locations.toArray(String[]::new), allRoutes, locations.size());

        int best = Integer.MAX_VALUE;
        for (String[] route : allRoutes) {
            int dist = 0;
            for (int i = 0; i < route.length - 1; i++) {
                dist += connections.get(Pair.of(route[i], route[i + 1]));
            }
            best = Math.min(dist, best);
        }

        System.out.println("The best route has a total distance of " + best);
    }
}

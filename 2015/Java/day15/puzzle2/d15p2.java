package day15.puzzle2;

import utils.InputParser;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.function.Predicate;
import java.util.stream.IntStream;

public class d15p2 {

    private static void generateRatios(int target, int index, List<List<Integer>> ratios, List<Integer> partial) {
        for (int i = 0; i <= target; i++) {
            List<Integer> ratio = new ArrayList<>(partial);
            ratio.set(index, i);

            if (index < partial.size() - 1 && ratio.subList(0, index).stream().mapToInt(v -> v).sum() <= target) {
                generateRatios(target, index + 1, ratios, ratio);
            }

            if (index == partial.size() - 1 && ratio.stream().mapToInt(v -> v).sum() == target) {
                ratios.add(ratio);
            }
        }
    }

    public static void main(String[] args) {

        List<Integer[]> ingredients = new ArrayList<>();
        List<Integer> partial = new ArrayList<>();
        InputParser.parse("day15/input.txt").asList().forEach(line -> {
            String[] tokens = Arrays.stream(line.split("[,: ]"))
                    .filter(Predicate.not(String::isBlank))
                    .filter(s -> !Character.isLowerCase(s.charAt(0)) ).toArray(String[]::new);

            ingredients.add(new Integer[]{
                    Integer.parseInt(tokens[1]),    // capacity
                    Integer.parseInt(tokens[2]),    // durability
                    Integer.parseInt(tokens[3]),    // flavor
                    Integer.parseInt(tokens[4]),    // texture
                    Integer.parseInt(tokens[5])});  // calories

            partial.add(0);
        });

        List<List<Integer>> ratios = new ArrayList<>();
        generateRatios(100, 0, ratios, partial);

        int bestRatio = -1;
        long bestScore = Long.MIN_VALUE;
        for (int r = 0; r < ratios.size(); r++) {

            int[] properties = new int[] { 0, 0, 0, 0, 0 };
            for (int i = 0; i < ingredients.size(); i++) {
                properties[0] += ingredients.get(i)[0] * ratios.get(r).get(i);  // capacity
                properties[1] += ingredients.get(i)[1] * ratios.get(r).get(i);  // durability
                properties[2] += ingredients.get(i)[2] * ratios.get(r).get(i);  // flavor
                properties[3] += ingredients.get(i)[3] * ratios.get(r).get(i);  // texture
                properties[4] += ingredients.get(i)[4] * ratios.get(r).get(i);  // calories
            }

            long score;
            if (Arrays.stream(properties).anyMatch(i -> i <= 0)) {
                score = 0L;
            } else {
                score = IntStream.of(Arrays.copyOfRange(properties, 0, 4)).reduce((i, j) -> i * j).orElse(0);
            }

            if (score > bestScore && properties[4] == 500) {
                bestScore = score;
                bestRatio = r;
            }
        }

        System.out.printf("The best score with 500 calories is %d from a ratio of %s\n", bestScore, ratios.get(bestRatio));
    }
}

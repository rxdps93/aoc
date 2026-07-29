package day14.puzzle1;

import utils.InputParser;

import java.util.List;

public class d14p1 {

    public static void main(String[] args) {

        List<String> input = InputParser.parse("day14/input.txt").asList();

        String bestName = "";
        int bestDistance = Integer.MIN_VALUE;
        final double seconds = 2503;
        for (String line : input) {
            String[] tokens = line.split(" ");
            int speed = Integer.parseInt(tokens[3]);
            double moveDuration = Double.parseDouble(tokens[6]);
            double restDuration = Double.parseDouble(tokens[tokens.length - 2]);

            double fullCycles = Math.floor(seconds / (moveDuration + restDuration));
            double remainder = seconds % (moveDuration + restDuration);

            int dist = 0;
            if (remainder >= moveDuration) {
                dist += speed * moveDuration;
            } else {
                dist += speed * remainder;
            }

            dist += fullCycles * (speed * moveDuration);

            if (dist > bestDistance) {
                bestName = tokens[0];
                bestDistance = dist;
            }
        }

        System.out.printf("The winning reindeer, %s, has travelled %d km after exactly %d seconds.", bestName, bestDistance, (int)seconds);
    }
}

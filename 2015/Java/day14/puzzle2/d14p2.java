package day14.puzzle2;

import utils.InputParser;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;

public class d14p2 {

    private static class Reindeer {

        public final String name;
        public final int speed;
        public final int moveDuration;
        public final int restDuration;
        private int points = 0;
        private int distanceTravelled = 0;
        private boolean resting = false;
        private int counter;

        public Reindeer(String name, int speed, int moveDuration, int restDuration) {
            this.name = name;
            this.speed = speed;
            this.moveDuration = moveDuration;
            this.restDuration = restDuration;
            this.counter = moveDuration;
        }

        public int getDistanceTravelled() {
            return this.distanceTravelled;
        }

        public int getPoints() {
            return this.points;
        }

        public void gainPoint() {
            this.points++;
        }

        public void update() {
            if (!resting) {
                distanceTravelled += speed;
            }
            counter--;

            if (counter == 0) {

                resting = !resting;
                if (resting) {
                    counter = restDuration;
                } else {
                    counter = moveDuration;
                }
            }
        }

        @Override
        public String toString() {
            return String.format("%s -> %d pts; %d km", this.name, this.points, this.distanceTravelled);
        }
    }

    public static void main(String[] args) {

        List<String> input = InputParser.parse("day14/input.txt").asList();

        List<Reindeer> reindeer = new ArrayList<>();
        for (String line : input) {
            String[] tokens = line.split(" ");
            reindeer.add(new Reindeer(tokens[0], Integer.parseInt(tokens[3]),
                    Integer.parseInt(tokens[6]), Integer.parseInt(tokens[tokens.length - 2])));
        }

        final int timeLimit = 2503;
        for (int s = 0; s < timeLimit; s++) {
            for (Reindeer rd : reindeer) {
                rd.update();
            }

            reindeer.sort(Comparator.comparing(Reindeer::getDistanceTravelled).reversed());

            int lead = reindeer.get(0).getDistanceTravelled();
            reindeer.forEach(r -> {
                if (r.getDistanceTravelled() == lead) {
                    r.gainPoint();
                }
            });
        }
        reindeer.sort(Comparator.comparing(Reindeer::getPoints).reversed());

        System.out.printf("The winning reindeer, %s, has gained %d points after exactly %d seconds.",
                reindeer.get(0).name, reindeer.get(0).getPoints(), timeLimit);
    }
}

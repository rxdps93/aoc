package day22.puzzle2;

import utils.InputParser;

import java.util.HashMap;
import java.util.PriorityQueue;

public class d22p2 {

    private enum Spell {
        MAGIC_MISSILE(53, null),
        DRAIN(73, null),
        SHIELD(113, Effect.SHIELD),
        POISON(173, Effect.POISON),
        RECHARGE(229, Effect.RECHARGE);

        private final int cost;
        private final Effect e;

        Spell(int cost, Effect e) {
            this.cost = cost;
            this.e = e;
        }

        public int getCost() {
            return this.cost;
        }

        public Effect getEffect() {
            return this.e;
        }
    }

    private enum Effect {
        SHIELD(6),
        POISON(6),
        RECHARGE(5);

        private final int timer;
        Effect(int timer) {
            this.timer = timer;
        }

        public int getTimer() {
            return this.timer;
        }
    }

    private static class GameState implements Cloneable {

        private int playerHP;
        private int playerMP;
        private int playerDEF;
        private int spentMP;

        private int bossHP;
        private final int bossATK;

        private HashMap<Effect, Integer> activeEffects = new HashMap<>();

        public GameState(int playerHP, int playerMP, int bossHP, int bossATK) {
            this.playerHP = playerHP;
            this.playerMP = playerMP;
            this.bossHP = bossHP;
            this.bossATK = bossATK;
        }

        public boolean isCastable(Spell s) {
            return (this.playerMP >= s.getCost()) &&
                    (!activeEffects.containsKey(s.getEffect()) || activeEffects.get(s.getEffect()) <= 1);
        }

        public void cast(Spell s) {
            this.playerMP -= s.getCost();
            this.spentMP += s.getCost();

            switch (s) {
                case MAGIC_MISSILE -> this.bossHP -= 4;
                case DRAIN -> {
                    this.bossHP -= 2;
                    this.playerHP += 2;
                }
                default -> {
                    this.activeEffects.put(s.getEffect(), s.getEffect().getTimer());
                }
            }
        }

        public void processEffects() {
            activeEffects.forEach((effect, timer) -> {
                if (timer > 0) {
                    activeEffects.put(effect, timer - 1);
                    switch (effect) {
                        case SHIELD -> this.playerDEF = 7;

                        case POISON -> this.bossHP -= 3;
                        case RECHARGE -> this.playerMP += 101;
                    }
                } else if (timer == 0 && effect == Effect.SHIELD) {
                    this.playerDEF = 0;
                }
            });
        }

        public GameState clone() {
            GameState clone = new GameState(this.playerHP, this.playerMP, this.bossHP, this.bossATK);
            clone.playerDEF = this.playerDEF;
            clone.spentMP = this.spentMP;
            clone.activeEffects.putAll(this.activeEffects);
            return clone;
        }
    }

    public static void main(String[] args) {

        String[] input = InputParser.parse("day22/input.txt").asArray();
        GameState initialState = new GameState(50, 500,
                Integer.parseInt(input[0].replace(" ", "").split(":")[1]),
                Integer.parseInt(input[1].replace(" ", "").split(":")[1]));

        PriorityQueue<GameState> queue = new PriorityQueue<>((a, b) -> Integer.compare(b.spentMP, a.spentMP));
        int bestManaSpent = Integer.MAX_VALUE;
        queue.add(initialState);
        while (!queue.isEmpty()) {
            GameState current = queue.poll();

            current.playerHP--;

            if (current.playerHP > 0) {
                current.processEffects();
                for (Spell s : Spell.values()) {
                    if (current.isCastable(s)) {
                        GameState next = current.clone();
                        next.cast(s);
                        next.processEffects();

                        if (next.bossHP <= 0) {
                            bestManaSpent = Math.min(bestManaSpent, next.spentMP);
                            queue.removeIf(gs -> gs.spentMP > next.spentMP);
                        } else {
                            next.playerHP -= Math.max(next.bossATK - next.playerDEF, 1);
                            if (next.playerHP > 0 && next.playerMP > 0 && next.spentMP < bestManaSpent) {
                                queue.add(next);
                            }
                        }
                    }
                }
            }
        }

        System.out.println("The least mana you can spend on hard mode is " + bestManaSpent);
    }
}

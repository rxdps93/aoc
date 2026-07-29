package day21.puzzle1;

import day21.utils.Armor;
import day21.utils.Entity;
import day21.utils.Inventory;
import day21.utils.Ring;
import day21.utils.Weapon;
import utils.InputParser;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;

public class d21p1 {

    private static boolean simulateBattle(Entity you, Entity boss) {
        final int playerWinsIn = (int)Math.ceil(boss.getBaseHP() / Math.max(you.getATK() - boss.getDEF(), 1.0));
        final int bossWinsIn = (int)Math.ceil(you.getBaseHP() / Math.max(boss.getATK() - you.getDEF(), 1.0));
        return playerWinsIn <= bossWinsIn;
    }

    private static List<Inventory> generateInventories() {

        List<Inventory> inventories = new ArrayList<>();
        for (Weapon weapon : Weapon.values()) {
            for (Armor armor: Armor.values()) {
                for (int left = 0; left < Ring.values().length; left++) {
                    for (int right = left + 1; right < Ring.values().length; right++) {
                        inventories.add(new Inventory(weapon, armor, Ring.values()[left], Ring.values()[right]));
                    }
                }
            }
        }
        return inventories;
    }

    public static void main(String[] args) {

        String[] input = InputParser.parse("day21/input.txt").asArray();
        Entity boss = new Entity(
                Integer.parseInt(input[0].replace(" ", "").split(":")[1]),
                Integer.parseInt(input[1].replace(" ", "").split(":")[1]),
                Integer.parseInt(input[2].replace(" ", "").split(":")[1]));
        Entity you = new Entity(100, 0, 0);

        List<Inventory> inventories = generateInventories();
        inventories.sort(Comparator.comparing(Inventory::getCost));
        for (Inventory inv : inventories) {

            you.equip(inv);
            if (simulateBattle(you, boss)) {
                System.out.println("You can win with the following inventory: " + inv);
                break;
            }
        }

    }
}

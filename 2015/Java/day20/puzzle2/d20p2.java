package day20.puzzle2;

public class d20p2 {

    public static void main(String[] args) {
        final int input = 29000000;

        int[] houses = new int[input];
        for (int elf = 1; elf < input; elf++) {
            int i = 0;
            for (int house = elf; house < input; house += elf) {
                houses[house] += elf * 11;
                i++;
                if (i >= 50) {
                    break;
                }
            }

            if (houses[elf - 1] >= input) {
                System.out.println(elf - 1);
                break;
            }
        }
    }
}

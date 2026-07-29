package day20.puzzle1;

public class d20p1 {

    public static void main(String[] args) {
        final int input = 29000000;

        int[] houses = new int[input / 10];
        for (int i = 1; i < (input / 10); i++) {
            for (int j = i; j < (input / 10); j += i) {
                houses[j] += i * 10;
            }
        }

        for (int i = 0; i < input / 10; i++) {
            if (houses[i] >= input) {
                System.out.println(i);
                break;
            }
        }
    }
}

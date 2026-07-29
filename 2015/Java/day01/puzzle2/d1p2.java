package day01.puzzle2;

import java.io.FileInputStream;
import java.io.IOException;

public class d1p2 {
    public static void main(String[] args) {

        try {
            FileInputStream input = new FileInputStream("day01/input.txt");

            int c;
            int floor = 0, pos = 0, bsmnt = 0;
            while ((c = input.read()) != -1) {
                if ((char)c == '(') {
                    floor++;
                    pos++;
                } else if ((char)c == ')') {
                    floor--;
                    pos++;
                }

                if (floor < 0 && bsmnt == 0) {
                    bsmnt = pos;
                }
            }

            System.out.println("Ends On Floor: " + floor);
            System.out.println("Entered Basement: " + bsmnt);
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }
}
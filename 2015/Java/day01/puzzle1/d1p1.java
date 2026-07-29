package day01.puzzle1;

import java.io.FileInputStream;
import java.io.IOException;

public class d1p1 {
    public static void main(String[] args) {

        try {
            FileInputStream input = new FileInputStream("day01/input.txt");

            int c;
            int floor = 0;
            while ((c = input.read()) != -1) {
                if ((char)c == '(') {
                    floor++;
                } else if ((char)c == ')') {
                    floor--;
                }
            }

            System.out.println("Floor: " + floor);
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }
}
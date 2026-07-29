package day11.puzzle1;

import java.util.regex.Pattern;
import java.util.regex.Matcher;

public class d11p1 {

    private static boolean containsStraight(char[] toCheck) {
        for (int i = 0; i < toCheck.length - 2; i++) {
            if ((toCheck[i] + 1 == toCheck[i + 1]) && (toCheck[i] + 2 == toCheck[i + 2])) {
                return true;
            }
        }

        return false;
    }

    private static boolean containsPairs(String toCheck) {
        Matcher match = Pattern.compile("([a-z])\\1").matcher(toCheck);
        int pairs = 0;
        while (match.find()) {
            pairs++;
        }

        return pairs >= 2;
    }

    private static boolean isValid(String toCheck) {
        if (!toCheck.contains("i") && !toCheck.contains("o") && !toCheck.contains("l")) {
            if (containsStraight(toCheck.toCharArray())) {
                return containsPairs(toCheck);
            }
        }

        return false;
    }

    public static void main(String[] args) {
        String password = "hxbxwxba";

        do {
            char[] pw = password.toCharArray();
            for (int i = password.length() - 1; i >= 0; i--) {
                pw[i]++;
                if (pw[i] > 'z') {
                    pw[i] = 'a';
                } else {
                    break;
                }
            }
            password = new String(pw);
        } while (!isValid(password));

        System.out.println(password);
    }
}

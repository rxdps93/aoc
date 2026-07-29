package day12.puzzle2;

import com.google.gson.Gson;
import utils.InputParser;

import java.util.List;
import java.util.Map;

public class d12p2 {

    private static int parseSum(Object json) {
        int sum = 0;

        if (json instanceof List) {
            for (Object obj : (List<Object>)json) {
                sum += parseSum(obj);
            }
            return sum;
        } else if (json instanceof Map) {
            for (Map.Entry<String, Object> entry : ((Map<String, Object>) json).entrySet()) {
                if (entry.getValue().equals("red")) {
                    return 0;
                }
                sum += parseSum(entry.getValue());
            }
            return sum;
        } else if (json instanceof Number) {
            return ((Number) json).intValue();
        }

        return 0;
    }
    public static void main(String[] args) {

        String input = InputParser.parse("day12/input.txt").asString();
        Gson gson = new Gson();
        Object json = gson.fromJson(input, Object.class);

        System.out.println("The sum of all numbers is " + parseSum(json));
    }
}

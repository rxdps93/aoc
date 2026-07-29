package day21.utils;

public enum Armor {
    NONE(0, 0, "None"),
    LEATHER(1, 13, "Leather"),
    CHAINMAIL(2, 31, "Chainmail"),
    SPLINTMAIL(3, 53, "Splintmail"),
    BANDEDMAIL(4, 75, "Bandedmail"),
    PLATEMAIL(5, 102, "Platemail");

    private final int value;
    private final int cost;
    private final String name;

    Armor(int value, int cost, String name) {
        this.value = value;
        this.cost = cost;
        this.name = name;
    }

    public int getValue() {
        return this.value;
    }

    public int getCost() {
        return this.cost;
    }

    public String getName() {
        return this.name;
    }

    @Override
    public String toString() {
        return String.format("%s [ %d def, %d gp ]", this.name, this.value, this.cost);
    }
}

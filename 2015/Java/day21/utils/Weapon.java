package day21.utils;

public enum Weapon {

    DAGGER(4, 8, "Dagger"),
    SHORTSWORD(5, 10, "Shortsword"),
    WARHAMMER(6, 25, "Warhammer"),
    LONGSWORD(7, 40, "Longsword"),
    GREATAXE(8, 74, "Greataxe");

    private final int value;
    private final int cost;
    private final String name;

    Weapon(int value, int cost, String name) {
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
        return String.format("%s [ %d atk, %d gp ]", this.name, this.value, this.cost);
    }
}

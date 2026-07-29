package day21.utils;

public enum Ring {
    NONE_ONE(0, 0, 0, "None"),
    NONE_TWO(0, 0, 0, "None"),
    DMG_ONE(1, 0, 25, "Damage +1"),
    DMG_TWO(2, 0, 50, "Damage +2"),
    DMG_THREE(3, 0, 100, "Damage +3"),
    DEF_ONE(0, 1, 20, "Defense +1"),
    DEF_TWO(0, 2, 40, "Defense +2"),
    DEF_THREE(0, 3, 80, "Defense +3");

    private final int atk;
    private final int def;
    private final int cost;
    private final String name;

    Ring(int atk, int def, int cost, String name) {
        this.atk = atk;
        this.def = def;
        this.cost = cost;
        this.name = name;
    }

    public int getAtk() {
        return this.atk;
    }

    public int getDef() {
        return this.def;
    }

    public int getCost() {
        return this.cost;
    }

    public String getName() {
        return this.name;
    }

    @Override
    public String toString() {
        return String.format("%s [ %d atk, %d def, %d gp ]", this.name, this.atk, this.def, this.cost);
    }
}
